//
//  AnalyticsTableViewController.swift
//  CreditCardRewards
//
//  Created by Jeffrey Xiao on 4/15/20.
//  Copyright © 2020 Jeffrey Xiao. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher
import Firebase

class AnalyticsTableViewCell: UITableViewCell {
    @IBOutlet weak var cardCashBackLabel: UILabel!
    @IBOutlet weak var cardNameLabel: UILabel!
    @IBOutlet weak var cardImageView: UIImageView!
    @IBOutlet weak var totalMoneyEarned: UILabel!
    @IBOutlet weak var cashMadeBackStaticLabel: UILabel!
    
    override func layoutSubviews() {
        totalMoneyEarned.adjustsFontSizeToFitWidth = true
        totalMoneyEarned.minimumScaleFactor = 0.2
    }
}


class AnalyticsTableViewController: UITableViewController {
    
    var allCards: [Card] = []
    var addedCards: [Card] = []
    var ref: DatabaseReference!
    var refHandle: DatabaseHandle!
    var firstName: String = ""
    let transition = SlideTransition()
    var uid: String = "invalid-override"
    var cards: [NSDictionary] = []
    let currencyFormatter = NumberFormatter()
    var dateJoined: String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = Locale.current
        
        ref = Database.database().reference()

        refHandle = ref.child("users/\(uid)/cards").observe(DataEventType.value, with: { (snapshot) in
            if let myCards = snapshot.value as? [NSDictionary] {
                var cardArray = [Card]()
                for myCard in myCards {
                    if let added = myCard["added"] as? Bool, let cash = myCard["cashSaved"] as? Double, let id = myCard["id"] as? Int, let filters = myCard["filters"] as? [NSDictionary], let name = self.cards[id - 1]["name"] as? String, let tags = self.cards[id - 1]["tags"] as? [NSDictionary], let imageLink = self.cards[id - 1]["imageUrl"] as? String {
                    
                        let dining = tags[0]["cashBackPercent"] as! Double
                        let travel = tags[1]["cashBackPercent"] as! Double
                        let gas = tags[2]["cashBackPercent"] as! Double
                        let shopping = tags[3]["cashBackPercent"] as! Double
                        let entertainment = tags[4]["cashBackPercent"] as! Double
                        let groceries = tags[5]["cashBackPercent"] as! Double
                        let amazon = tags[6]["cashBackPercent"] as! Double
                        let wholeFoods = tags[7]["cashBackPercent"] as! Double
                        let united = tags[8]["cashBackPercent"] as! Double
                        let delta = tags[9]["cashBackPercent"] as! Double
                        let southwest = tags[10]["cashBackPercent"] as! Double
                        let britishAirways = tags[11]["cashBackPercent"] as! Double
                        let uber = tags[12]["cashBackPercent"] as! Double
                        let apple = tags[13]["cashBackPercent"] as! Double
                            
                        let diningSaved = filters[0]["cashSaved"] as! Double
                        let travelSaved = filters[1]["cashSaved"] as! Double
                        let gasSaved = filters[2]["cashSaved"] as! Double
                        let shoppingSaved = filters[3]["cashSaved"] as! Double
                        let entertainmentSaved = filters[4]["cashSaved"] as! Double
                        let groceriesSaved = filters[5]["cashSaved"] as! Double
                        let amazonSaved = filters[6]["cashSaved"] as! Double
                        let wholeFoodsSaved = filters[7]["cashSaved"] as! Double
                        let unitedSaved = filters[8]["cashSaved"] as! Double
                        let deltaSaved = filters[9]["cashSaved"] as! Double
                        let southwestSaved = filters[10]["cashSaved"] as! Double
                        let britishAirwaysSaved = filters[11]["cashSaved"] as! Double
                        let uberSaved = filters[12]["cashSaved"] as! Double
                        let appleSaved = filters[13]["cashSaved"] as! Double
                            
                        cardArray.append(Card(cardName: name, diningCBP: dining, travelCBP: travel, gasCBP: gas, shoppingCBP: shopping, entertainmentCBP: entertainment, groceriesCBP: groceries, amazonCBP: amazon, wholeFoodsCBP: wholeFoods, unitedCBP: united, deltaCBP: delta, southwestCBP: southwest, britishAirwaysCBP: britishAirways, uberCBP: uber, appleCBP: apple, imageUrl: imageLink, added: added, id: id, cash: cash, dining: diningSaved, travel: travelSaved, gas: gasSaved, shopping: shoppingSaved, entertainment: entertainmentSaved, groceries: groceriesSaved, amazon: amazonSaved, wholeFoods: wholeFoodsSaved, united: unitedSaved, delta: deltaSaved, southwest: southwestSaved, britishAirways: britishAirwaysSaved, uber: uberSaved, apple: appleSaved))
                    }
                }
                
                self.addedCards = []
                
                for card in cardArray {
                    if card.added {
                        self.addedCards.append(card)
                    }
                }
                
                self.addedCards.sort { (cardA, cardB) -> Bool in
                    return cardA.cashSaved >= cardB.cashSaved
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            self.tableView.reloadData()
        })
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addedCards.count + 1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row != 0 {
            performSegue(withIdentifier: "CardViewSegue", sender: addedCards[indexPath.row-1])
            tableView.deselectRow(at: indexPath, animated: true)
        } else if indexPath.row == 0 {
            performSegue(withIdentifier: "AdvancedAnalyticsSegue", sender: nil)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "prototypeTableCell", for: indexPath) as! AnalyticsTableViewCell
        
        func showOrNoShowTableViewCell(b: Bool) {
            cell.cardCashBackLabel.isHidden = b
            cell.cardNameLabel.isHidden = b
            cell.cardImageView.isHidden = b
            cell.cashMadeBackStaticLabel.isHidden = !b
            cell.totalMoneyEarned.isHidden = !b
        }
        
        if (indexPath.row != 0) {
            cell.cardImageView.kf.setImage(with: addedCards[indexPath.row - 1].imageUrl)
            cell.cardNameLabel.text = addedCards[indexPath.row - 1].cardName
            cell.cardCashBackLabel.text = currencyFormatter.string(from: NSNumber(value: addedCards[indexPath.row - 1].cashSaved))
            showOrNoShowTableViewCell(b: false)
        } else {
//            cell.selectionStyle = .none
            var sum: Double = 0.00
            
            for card in addedCards {
                sum += card.cashSaved
            }
        
            cell.totalMoneyEarned.text = currencyFormatter.string(from: NSNumber(value: sum))!
            showOrNoShowTableViewCell(b: true)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.row == 0) {
            return 175.0
        }
        return 145.0
    }


    @IBAction func didTapMenu(_ sender: UIBarButtonItem) {
        guard let menuViewController = storyboard?.instantiateViewController(identifier: "MenuViewController") as? MenuViewController else { return }

        menuViewController.didTapMenuType = { menuType in
            self.transitionToNew(menuType)
        }

        menuViewController.firstName = self.firstName
        menuViewController.modalPresentationStyle = .overCurrentContext
        menuViewController.transitioningDelegate = self
        present(menuViewController, animated: true)
    }

    func transitionToNew(_ menuType: MenuType) {
        switch menuType {
        case .cards:
            guard let collectionNavController = storyboard!.instantiateViewController(identifier: "CardsCollectionNavController") as? UINavigationController else { return }
            collectionNavController.modalPresentationStyle = .fullScreen
            
            if let ccVC = collectionNavController.topViewController as? CardCollectionViewController {
                ccVC.uid = self.uid
                ccVC.cards = self.cards
                ccVC.firstName = self.firstName
                ccVC.dateJoined = self.dateJoined
                ccVC.allCards = self.allCards
            }
            
            self.present(collectionNavController, animated: true, completion: nil)
        case .home:
            guard let homeNavController = storyboard!.instantiateViewController(identifier: "HomeNavController") as? UINavigationController else { return }
            homeNavController.modalPresentationStyle = .fullScreen
            
            if let hVC = homeNavController.topViewController as? HomeViewController {
                hVC.uid = self.uid
                hVC.cards = self.cards
                hVC.firstName = self.firstName
                hVC.dateJoined = self.dateJoined
                hVC.allCards = self.allCards
            }
            
            self.present(homeNavController, animated: true, completion: nil)
        case .analytics:
            break
        case .profile:
            guard let profileNavController = storyboard!.instantiateViewController(identifier: "ProfileNavController") as? UINavigationController else { return }
            profileNavController.modalPresentationStyle = .fullScreen
            self.present(profileNavController, animated: true, completion: nil)
            
            if let pVC = profileNavController.topViewController as? ProfileViewController {
                pVC.addedCards = self.addedCards
                pVC.uid = self.uid
                pVC.cards = self.cards
                pVC.firstName = self.firstName
                pVC.dateJoined = self.dateJoined
                pVC.allCards = self.allCards
            }
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
        } else if (segue.identifier == "AdvancedAnalyticsSegue") {
            if let aaVC = segue.destination as? AdvancedAnalyticsViewController {
                aaVC.addedCards = self.addedCards
            }
        }
    }
    
}

extension AnalyticsTableViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.isPresenting = true
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.isPresenting = false
        return transition
    }
}
