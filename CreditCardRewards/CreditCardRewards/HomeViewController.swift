//
//  ViewController.swift
//  CreditCardRewards
//
//  Created by Jeffrey Xiao on 4/12/20.
//  Copyright © 2020 Jeffrey Xiao. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var filterSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var filtersLabel: UILabel!
    @IBOutlet weak var pickerView: UIPickerView!
    let transition = SlideTransition()
    
    @IBOutlet weak var homeCollectionView: UICollectionView!
    var ref: DatabaseReference!
    var refHandle: DatabaseHandle!
    var allCards: [Card] = []
    var showCards: [Card] = []
    var addedCards: [Card] = []
    var unaddedCards: [Card] = []
    var uid: String = "invalid-override"
    
    static let shoppingAndGroceriesSource = ["All", "Amazon", "Whole Foods"]

    override func viewDidLoad() {
        super.viewDidLoad()
        homeCollectionView.dataSource = self
        homeCollectionView.delegate = self
        pickerView.delegate = self
        pickerView.dataSource = self
        print(uid)
        ref = Database.database().reference()
        
        var cards: [NSDictionary] = []
        ref.child("cards").observe(DataEventType.value) { (snapshot) in
            if let c = snapshot.value as? [NSDictionary] {
                cards = c
            }
            DispatchQueue.main.async {
                self.homeCollectionView.reloadData()
            }
        }
        print("before")
        refHandle = ref.child("users/\(uid)/cards").observe(DataEventType.value, with: { (snapshot) in
            if let myCards = snapshot.value as? [NSDictionary] {
                var cardArray = [Card]()
                for myCard in myCards {
                    if let added = myCard["added"] as? Bool, let cash = myCard["cashSaved"] as? Double, let id = myCard["id"] as? Int, let name = cards[id - 1]["name"] as? String, let tags = cards[id - 1]["tags"] as? [NSDictionary], let imageLink = cards[id - 1]["imageUrl"] as? String {
                        
                        let dining = tags[0]["cashBackPercent"] as! Double
                        let travel = tags[1]["cashBackPercent"] as! Double
                        let gas = tags[2]["cashBackPercent"] as! Double
                        let shopping = tags[3]["cashBackPercent"] as! Double
                        let entertainment = tags[4]["cashBackPercent"] as! Double
                        let groceries = tags[5]["cashBackPercent"] as! Double
                        let amazon = tags[6]["cashBackPercent"] as! Double
                        let wholeFoods = tags[7]["cashBackPercent"] as! Double
                        
                        cardArray.append(Card(cardName: name, diningCBP: dining, travelCBP: travel, gasCBP: gas, shoppingCBP: shopping, entertainmentCBP: entertainment, groceriesCBP: groceries, amazonCBP: amazon, wholeFoodsCBP: wholeFoods, imageUrl: imageLink, added: added, id: id, cash: cash))
                    }
                }
                
                self.allCards = cardArray
                self.addedCards = []
                self.unaddedCards = []
                
                for card in self.allCards {
                    if card.added {
                        self.addedCards.append(card)
                    } else {
                        self.unaddedCards.append(card)
                    }
                }
                
                DispatchQueue.main.async {
                    print("inside - viewDidLoad (CCC), second")
                    self.homeCollectionView.reloadData()
                }
                print("outside - viewDidLoad (CCC), second")
            }
            
            print("asdf")
            self.homeCollectionView.reloadData()
        })
        
        filtersLabel.text = "Filter: None"
        pickerView.isHidden = true
        let itemSize = UIScreen.main.bounds.width/2 - 2
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 5, left: 1, bottom: 20, right: 1)
        layout.itemSize = CGSize(width: itemSize, height: itemSize)
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 2
        
        homeCollectionView.collectionViewLayout = layout
        self.homeCollectionView.reloadData()

    }
    
    @IBAction func filterSegmentedControlSwitch(_ sender: UISegmentedControl) {
        showCards = addedCards
        switch sender.selectedSegmentIndex {
        case 0:
            filtersLabel.text = "Filter: None"
            pickerView.isHidden = true
        case 1:
            filtersLabel.text = "Filter: Dining"
            sortToShowBest(tag: 1)
            pickerView.isHidden = true
        case 2:
            filtersLabel.text = "Filter: Travel"
            sortToShowBest(tag: 2)
            pickerView.isHidden = true
        case 3:
            filtersLabel.text = "Filter: Gas"
            sortToShowBest(tag: 3)
            pickerView.isHidden = true
        case 4:
            filtersLabel.text = "Filter: Shopping"
            sortToShowBest(tag: 4)
            pickerView.selectRow(0, inComponent: 0, animated: false)
            pickerView.isHidden = false
        case 5:
            filtersLabel.text = "Filter: Entertainment"
            sortToShowBest(tag: 5)
            pickerView.isHidden = true
        case 6:
            filtersLabel.text = "Filter: Groceries"
            pickerView.isHidden = false
            sortToShowBest(tag: 6)
            pickerView.selectRow(0, inComponent: 0, animated: false)
        default:
            filtersLabel.text = ""
        }
        self.homeCollectionView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return showCards.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("adsfsa")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CardCollectionViewCell
        
        cell.cardImageView.kf.setImage(with: showCards[indexPath.item].imageUrl)
        cell.cardLabel.text = showCards[indexPath.item].cardName
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "CardViewSegue", sender: allCards[showCards[indexPath.item].id - 1])
    }
    
    
    @IBAction func didTapMenu(_ sender: UIBarButtonItem) {
        guard let menuViewController = storyboard?.instantiateViewController(identifier: "MenuViewController") as? MenuViewController else { return }
        
        menuViewController.didTapMenuType = { menuType in
            self.transitionToNew(menuType)
        }
        
        menuViewController.modalPresentationStyle = .overCurrentContext
        menuViewController.transitioningDelegate = self
        self.present(menuViewController, animated: true)
    }

    func transitionToNew(_ menuType: MenuType) {
        switch menuType {
        case .cards:
            guard let collectionNavController = storyboard!.instantiateViewController(identifier: "CardsCollectionNavController") as? UINavigationController else { return }
            collectionNavController.modalPresentationStyle = .fullScreen
            self.present(collectionNavController, animated: true, completion: nil)
            
            if let ccVC = collectionNavController.topViewController as? CardCollectionViewController {
                ccVC.allCards = self.allCards
                ccVC.addedCards = self.addedCards
                ccVC.unaddedCards = self.unaddedCards
                ccVC.uid = self.uid
            }
        case .home:
            break
        case .analytics:
            guard let analyticsNavController = storyboard!.instantiateViewController(identifier: "AnalyticsNavController") as? UINavigationController else { return }
            analyticsNavController.modalPresentationStyle = .fullScreen
            self.present(analyticsNavController, animated: true, completion: nil)
            
            if let aVC = analyticsNavController.topViewController as? AnalyticsTableViewController {
                aVC.addedCards = self.addedCards
                aVC.uid = self.uid
            }
            print("analytics")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "CardViewSegue") {
            if let currentCard = sender as? Card {
                if let cardVC = segue.destination as? DetailCardViewController {
                    cardVC.card = currentCard
                    cardVC.ref = self.ref
                    cardVC.uid = self.uid
                }
            }
        }
    }
    
    private func sortToShowBest(tag: Int) {
        showCards.sort { (cardA, cardB) -> Bool in
            if tag == 1 {
                return cardA.diningCBP >= cardB.diningCBP
            } else if tag == 2 {
                return cardA.travelCBP >= cardB.travelCBP
            } else if tag == 3 {
                return cardA.gasCBP >= cardB.gasCBP
            } else if tag == 4 {
                return cardA.shoppingCBP >= cardB.shoppingCBP
            } else if tag == 5 {
                return cardA.entertainmentCBP >= cardB.entertainmentCBP
            } else if tag == 6 {
                return cardA.groceriesCBP >= cardB.groceriesCBP
            } else if tag == 7 {
                if (cardA.amazonCBP != cardB.amazonCBP) {
                    return cardA.amazonCBP > cardB.amazonCBP
                } else {
                    return cardA.shoppingCBP >= cardB.shoppingCBP
                }
            } else if tag == 8 {
                if (cardA.amazonCBP != cardB.amazonCBP) {
                    return cardA.amazonCBP > cardB.amazonCBP
                } else {
                    return cardA.groceriesCBP >= cardB.groceriesCBP
                }
            } else if tag == 9 {
                if (cardA.wholeFoodsCBP != cardB.wholeFoodsCBP) {
                    return cardA.wholeFoodsCBP > cardB.wholeFoodsCBP
                } else {
                    return cardA.shoppingCBP >= cardB.shoppingCBP
                }
            } else /* if tag == 10 */ {
                if (cardA.wholeFoodsCBP != cardB.wholeFoodsCBP) {
                    return cardA.wholeFoodsCBP > cardB.wholeFoodsCBP
                } else {
                    return cardA.groceriesCBP >= cardB.groceriesCBP
                }
            }
        }
    }
}


extension HomeViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.isPresenting = true
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.isPresenting = false
        return transition
    }
}

extension HomeViewController:  UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return HomeViewController.shoppingAndGroceriesSource.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let endOfBase = filtersLabel.text!.firstIndex(of: ",")
        
        if row == 0 {
            filtersLabel.text = endOfBase == nil ? "\(filtersLabel.text!)" : "\(filtersLabel.text![..<endOfBase!])"
            
            if (filtersLabel.text!.count == 16) {
                sortToShowBest(tag: 4)
            } else {
                sortToShowBest(tag: 6)
            }
        } else if row == 1 {
            if (endOfBase != nil && filtersLabel.text!.count == 17) {
                sortToShowBest(tag: 7)
            } else {
                sortToShowBest(tag: 8)
            }
            filtersLabel.text! = endOfBase == nil ? "\(filtersLabel.text!), Amazon" : "\(filtersLabel.text![..<endOfBase!]), Amazon"
        } else if row == 2 {
            if (endOfBase != nil && filtersLabel.text!.count == 17) {
                sortToShowBest(tag: 9)
            } else {
                sortToShowBest(tag: 10)
            }
            filtersLabel.text! = endOfBase == nil ? "\(filtersLabel.text!), Whole Foods" : "\(filtersLabel.text![..<endOfBase!]), Whole Foods"
        }
        self.homeCollectionView.reloadData()
    }
    
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return HomeViewController.shoppingAndGroceriesSource[row]
    }
}
