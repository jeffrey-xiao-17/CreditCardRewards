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
    
    var addedCards: [Card] = []
    var ref: DatabaseReference!
    var refHandle: DatabaseHandle!
    let transition = SlideTransition()
    var uid: String = "invalid-override"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        var personal: [NSDictionary] = []
        ref.child("users/\(uid)/cards").observe(DataEventType.value) { (snapshot) in
            if let p = snapshot.value as? [NSDictionary] {
                personal = p
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        refHandle = ref.child("cards").observe(DataEventType.value, with: { (snapshot) in
            if let cards = snapshot.value as? [NSDictionary] {
                var cardArray = [Card]()
                for card in cards {
                    if let name = card["name"] as? String, let tags = card["tags"] as? [NSDictionary], let imageLink = card["imageUrl"] as? String, let id = card["id"] as? Int, let added = personal[id - 1]["added"] as? Bool, let cash = personal[id - 1]["cashSaved"] as? Double {
                        
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
            cell.cardCashBackLabel.text = "$\(addedCards[indexPath.row - 1].cashSaved)"
            showOrNoShowTableViewCell(b: false)
        } else {
            cell.selectionStyle = .none
            var sum: Double = 0.00
            
            for card in addedCards {
                sum += card.cashSaved
            }
            
            cell.totalMoneyEarned.text = "$\(Double(String(format: "%.2f", sum))!)"
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
            }
            self.present(collectionNavController, animated: true, completion: nil)
        case .home:
            guard let homeNavController = storyboard!.instantiateViewController(identifier: "HomeNavController") as? UINavigationController else { return }
            homeNavController.modalPresentationStyle = .fullScreen
            
            if let hVC = homeNavController.topViewController as? HomeViewController {
                hVC.uid = self.uid
            }
            
            self.present(homeNavController, animated: true, completion: nil)
        case .analytics:
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
