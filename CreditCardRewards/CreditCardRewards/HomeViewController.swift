//
//  HomeViewController.swift
//  CreditCardRewards
//
//  Created by Jeffrey Xiao on 4/12/20.
//  Copyright © 2020 Jeffrey Xiao. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    // Relevant user interation items
    @IBOutlet weak var noCardsAddedLabel: UILabel!
    @IBOutlet weak var pickerViewGroceries: UIPickerView!
    @IBOutlet weak var filterSegmentedControl: UISegmentedControl!
    @IBOutlet weak var pickerViewTravel: UIPickerView!
    @IBOutlet weak var filtersLabel: UILabel!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var homeCollectionView: UICollectionView!
    
    let transition = SlideTransition()
    var ref: DatabaseReference!
    var refHandle: DatabaseHandle!
    var allCards: [Card] = []
    var addedCards: [Card] = []
    var unaddedCards: [Card] = []
    var uid: String = ""
    var cards: [NSDictionary] = []
    var travelPickerOn: Bool = false
    var shoppingPickerOn: Bool = false
    var groceriesPickerOn: Bool = false
    var firstName: String = ""
    var dateJoined: String = ""
    
    // Arrays used for the three picker views
    static let shoppingSource = ["All", "Amazon", "Whole Foods", "Apple"]
    static let groceriesSource = ["All", "Amazon", "Whole Foods"]
    static let travelSource = ["All", "United", "Delta", "Southwest", "British Airways", "Uber"]

    override func viewDidLoad() {
        super.viewDidLoad()
        homeCollectionView.dataSource = self
        homeCollectionView.delegate = self
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerViewGroceries.delegate = self
        pickerViewGroceries.dataSource = self
        pickerViewTravel.delegate = self
        pickerViewTravel.dataSource = self
        

        ref = Database.database().reference()

        // Fetching most up-to-date information about cards
        refHandle = ref.child("users/\(uid)/cards").observe(DataEventType.value, with: { (snapshot) in
            if let myCards = snapshot.value as? [NSDictionary] {
                let cardArray = CardCollectionViewController.createCard(cardsTranscribed: self.cards, myCards: myCards)
                
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
                self.checkNoCardsLabel()
                
                DispatchQueue.main.async {
                    self.homeCollectionView.reloadData()
                }
            }
        })
        
        // Layout touches
        noCardsAddedLabel.isHidden = true
        filtersLabel.text = "Filter: None"
        adjustPickerBools(shopping: false, groceries: false, travel: false)
        let itemSize = UIScreen.main.bounds.width/2 - 3
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 5, left: 1, bottom: 20, right: 1)
        layout.itemSize = CGSize(width: itemSize, height: itemSize)
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 2
        
        homeCollectionView.collectionViewLayout = layout
    }
    
    // Helper function to adjust "No Cards" label
    private func checkNoCardsLabel() {
        noCardsAddedLabel.isHidden = (addedCards.count != 0)
    }
    
    // Helper function to automatically show/hide the relevant pickers
    private func adjustPickerBools(shopping: Bool, groceries: Bool, travel: Bool) {
        shoppingPickerOn = shopping
        travelPickerOn = travel
        groceriesPickerOn = groceries
        pickerView.isHidden = !shoppingPickerOn
        pickerViewGroceries.isHidden = !groceriesPickerOn
        pickerViewTravel.isHidden = !travelPickerOn
    }
    
    // Controls the filter segment and determines which picker (if any) to show
    @IBAction func filterSegmentedControlSwitch(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            filtersLabel.text = "Filter: None"
            adjustPickerBools(shopping: false, groceries: false, travel: false)
        case 1:
            filtersLabel.text = "Filter: Dining"
            sortToShowBest(tag: 1)
            adjustPickerBools(shopping: false, groceries: false, travel: false)
        case 2:
            filtersLabel.text = "Filter: Travel"
            sortToShowBest(tag: 2)
            pickerViewTravel.selectRow(0, inComponent: 0, animated: false)
            adjustPickerBools(shopping: false, groceries: false, travel: true)
        case 3:
            filtersLabel.text = "Filter: Gas"
            sortToShowBest(tag: 3)
            adjustPickerBools(shopping: false, groceries: false, travel: false)
        case 4:
            filtersLabel.text = "Filter: Shopping"
            sortToShowBest(tag: 4)
            pickerView.selectRow(0, inComponent: 0, animated: false)
            adjustPickerBools(shopping: true, groceries: false, travel: false)
        case 5:
            filtersLabel.text = "Filter: Entertainment"
            sortToShowBest(tag: 5)
            adjustPickerBools(shopping: false, groceries: false, travel: false)
        case 6:
            filtersLabel.text = "Filter: Groceries"
            sortToShowBest(tag: 6)
            pickerViewGroceries.selectRow(0, inComponent: 0, animated: false)
            adjustPickerBools(shopping: false, groceries: true, travel: false)
        default:
            filtersLabel.text = ""
        }
        self.homeCollectionView.reloadData()
    }
    
    // Helper function to sort the cards in order of most relevant/most useful
    private func sortToShowBest(tag: Int) {
        addedCards.sort { (cardA, cardB) -> Bool in
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
            } else if tag == 7 {    // Shopping, Amazon
                return max(cardA.amazonCBP, cardA.shoppingCBP) >= max(cardB.amazonCBP, cardB.shoppingCBP)
            } else if tag == 8 {    // Groceries, Amazon
                return max(cardA.amazonCBP, cardA.groceriesCBP) >= max(cardB.amazonCBP, cardB.groceriesCBP)
            } else if tag == 9 {    // Shopping, Whole Foods
                return max(cardA.wholeFoodsCBP, cardA.shoppingCBP) >= max(cardB.wholeFoodsCBP, cardB.shoppingCBP)
            } else if tag == 10 {   // Groceries, Whole Foods
                return max(cardA.wholeFoodsCBP, cardA.groceriesCBP) >= max(cardB.wholeFoodsCBP, cardB.groceriesCBP)
            } else if tag == 11 {   // Travel, United
                return max(cardA.unitedCBP, cardA.travelCBP) >= max(cardB.unitedCBP, cardB.travelCBP)
            } else if tag == 12 {   // Travel, Delta
                return max(cardA.deltaCBP, cardA.travelCBP) >= max(cardB.deltaCBP, cardB.travelCBP)
            } else if tag == 13 {   // Travel, Southwest
                return max(cardA.southwestCBP, cardA.travelCBP) >= max(cardB.southwestCBP, cardB.travelCBP)
            } else if tag == 14 {   // Travel, BritishAirways
                return max(cardA.britishAirwaysCBP, cardA.travelCBP) >= max(cardB.britishAirwaysCBP, cardB.travelCBP)
            } else if tag == 15 {   // Travel, Uber
                return max(cardA.uberCBP, cardA.travelCBP) >= max(cardB.uberCBP, cardB.travelCBP)
            } else {                // Shopping, Apple
                return max(cardA.appleCBP, cardA.shoppingCBP) >= max(cardB.appleCBP, cardB.shoppingCBP)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func didTapMenu(_ sender: UIBarButtonItem) {
        guard let menuViewController = storyboard?.instantiateViewController(identifier: "MenuViewController") as? MenuViewController else { return }
        
        menuViewController.didTapMenuType = { menuType in
            self.transitionToNew(menuType)
        }
        
        menuViewController.firstName = self.firstName
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
                ccVC.uid = self.uid
                ccVC.cards = self.cards
                ccVC.firstName = self.firstName
                ccVC.dateJoined = self.dateJoined
            }
        case .home:
            break
        case .analytics:
            guard let analyticsNavController = storyboard!.instantiateViewController(identifier: "AnalyticsNavController") as? UINavigationController else { return }
            analyticsNavController.modalPresentationStyle = .fullScreen
            self.present(analyticsNavController, animated: true, completion: nil)
            
            if let aVC = analyticsNavController.topViewController as? AnalyticsTableViewController {
                aVC.uid = self.uid
                aVC.cards = self.cards
                aVC.firstName = self.firstName
                aVC.dateJoined = self.dateJoined
            }
        case .profile:
            guard let profileNavController = storyboard!.instantiateViewController(identifier: "ProfileNavController") as? UINavigationController else { return }
            profileNavController.modalPresentationStyle = .fullScreen
            self.present(profileNavController, animated: true, completion: nil)
            
            if let pVC = profileNavController.topViewController as? ProfileViewController {
                pVC.allCards = self.allCards
                pVC.addedCards = self.addedCards
                pVC.uid = self.uid
                pVC.cards = self.cards
                pVC.firstName = self.firstName
                pVC.dateJoined = self.dateJoined
            }
        }
    }
    
    // MARK: - Collection View methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return addedCards.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CardCollectionViewCell
        
        cell.cardImageView.kf.setImage(with: addedCards[indexPath.item].imageUrl)
        cell.cardLabel.text = addedCards[indexPath.item].cardName
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "CardViewSegue", sender: allCards[addedCards[indexPath.item].id - 1])
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
}

// Menu Transition delegate
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

// Picker View Delegate
extension HomeViewController:  UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (pickerView.tag == 10) {
            return HomeViewController.shoppingSource.count
        } else if (pickerView.tag == 20) {
            return HomeViewController.groceriesSource.count
        }
        
        return HomeViewController.travelSource.count
    }
    
    // Determines which row is selected to determine optimal sort
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let endOfBase = filtersLabel.text!.firstIndex(of: ",")
        if (pickerView.tag == 10) {
            if row == 0 {
                filtersLabel.text = endOfBase == nil ? "\(filtersLabel.text!)" : "\(filtersLabel.text![..<endOfBase!])"
                sortToShowBest(tag: 4)
            } else if row == 1 {    // target: amazon
                filtersLabel.text! = endOfBase == nil ? "\(filtersLabel.text!), Amazon" : "\(filtersLabel.text![..<endOfBase!]), Amazon"
                sortToShowBest(tag: 7)
            } else if row == 2 {    // target: whole foods
                filtersLabel.text! = endOfBase == nil ? "\(filtersLabel.text!), Whole Foods" : "\(filtersLabel.text![..<endOfBase!]), Whole Foods"
                sortToShowBest(tag: 9)
            } else if row == 3 {    // target: apple
                filtersLabel.text! = endOfBase == nil ? "\(filtersLabel.text!), Apple" : "\(filtersLabel.text![..<endOfBase!]), Apple"
                sortToShowBest(tag: 16)
            }
        } else if (pickerView.tag == 20) {
            if row == 0 {
                filtersLabel.text = endOfBase == nil ? "\(filtersLabel.text!)" : "\(filtersLabel.text![..<endOfBase!])"
                sortToShowBest(tag: 6)
            } else if row == 1 {    // target: amazon
                filtersLabel.text! = endOfBase == nil ? "\(filtersLabel.text!), Amazon" : "\(filtersLabel.text![..<endOfBase!]), Amazon"
                sortToShowBest(tag: 8)
            } else if row == 2 {    // target: whole foods
                filtersLabel.text! = endOfBase == nil ? "\(filtersLabel.text!), Whole Foods" : "\(filtersLabel.text![..<endOfBase!]), Whole Foods"
                sortToShowBest(tag: 10)
            }
        } else if (pickerView.tag == 30) {
            if row == 0 {
                filtersLabel.text = endOfBase == nil ? "\(filtersLabel.text!)" : "\(filtersLabel.text![..<endOfBase!])"
                sortToShowBest(tag: 2)
            } else if row == 1 {    // target: united
                filtersLabel.text! = endOfBase == nil ? "\(filtersLabel.text!), United" : "\(filtersLabel.text![..<endOfBase!]), United"
                sortToShowBest(tag: 11)
            } else if row == 2 {    // target: delta
                filtersLabel.text! = endOfBase == nil ? "\(filtersLabel.text!), Delta" : "\(filtersLabel.text![..<endOfBase!]), Delta"
                sortToShowBest(tag: 12)
            } else if row == 3 {    // target: southwest
                filtersLabel.text! = endOfBase == nil ? "\(filtersLabel.text!), Southwest" : "\(filtersLabel.text![..<endOfBase!]), Southwest"
                sortToShowBest(tag: 13)
            } else if row == 4 {    // target: british airways
                filtersLabel.text! = endOfBase == nil ? "\(filtersLabel.text!), British Airways" : "\(filtersLabel.text![..<endOfBase!]), British Airways"
                sortToShowBest(tag: 14)
            } else if row == 5 {    // target: uber
                filtersLabel.text! = endOfBase == nil ? "\(filtersLabel.text!), Uber" : "\(filtersLabel.text![..<endOfBase!]), Uber"
                sortToShowBest(tag: 15)
            }
        }
        self.homeCollectionView.reloadData()
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (pickerView.tag == 10) {
            return HomeViewController.shoppingSource[row]
        } else if (pickerView.tag == 20) {
            return HomeViewController.groceriesSource[row]
        }
        return HomeViewController.travelSource[row]
    }
}
