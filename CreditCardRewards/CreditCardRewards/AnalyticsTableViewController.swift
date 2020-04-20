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
                let cardArray = CardCollectionViewController.createCard(cardsTranscribed: self.cards, myCards: myCards)
                
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
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(_:)))
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
        self.view.addGestureRecognizer(swipeRight)
    }

    @objc func respondToSwipeGesture(_ gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizer.Direction.right:
                didTapMenu(UIBarButtonItem())
            default:
                break
            }
        }
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
            }
            
            self.present(homeNavController, animated: true, completion: nil)
        case .analytics:
            break
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
