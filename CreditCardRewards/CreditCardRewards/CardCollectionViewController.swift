//
//  CardViewController.swift
//  CreditCardRewards
//
//  Created by Jeffrey Xiao on 4/13/20.
//  Copyright © 2020 Jeffrey Xiao. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import Kingfisher

class CardCollectionViewController: UICollectionViewController {
    
    var allCards: [Card] = []
    var addedCards: [Card] = []
    var unaddedCards: [Card] = []
    var ref: DatabaseReference!
    var refHandle: DatabaseHandle!
    let sectionHeaderView = "SectionHeaderView"
    let transition = SlideTransition()
    var uid: String = "invalid-override"
    var cards: [NSDictionary] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
    
        refHandle = ref.child("users/\(uid)/cards").observe(DataEventType.value, with: { (snapshot) in
            if let myCards = snapshot.value as? [NSDictionary] {
                var cardArray = [Card]()
                for myCard in myCards {
                    if let added = myCard["added"] as? Bool, let cash = myCard["cashSaved"] as? Double, let id = myCard["id"] as? Int, let name = self.cards[id - 1]["name"] as? String, let tags = self.cards[id - 1]["tags"] as? [NSDictionary], let imageLink = self.cards[id - 1]["imageUrl"] as? String {
                        
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
                    self.collectionView.reloadData()
                }
            }
        })
        let itemSize = UIScreen.main.bounds.width/2 - 2
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 1, bottom: 20, right: 1)
        layout.itemSize = CGSize(width: itemSize, height: itemSize)
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 2
        
        layout.headerReferenceSize = CGSize(width: 0, height: 50)

        collectionView.collectionViewLayout = layout
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (section == 0) {
            return addedCards.count
        } else {
            return unaddedCards.count
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CardCollectionViewCell
        
        if (indexPath.section == 0) {
            cell.cardImageView.kf.setImage(with: addedCards[indexPath.item].imageUrl)
            cell.cardLabel.text = addedCards[indexPath.item].cardName
        } else {
            cell.cardImageView.kf.setImage(with: unaddedCards[indexPath.item].imageUrl)
            cell.cardLabel.text = unaddedCards[indexPath.item].cardName
        }
        
        cell.cardAddedCheck.isHidden = true
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            performSegue(withIdentifier: "CardViewSegue", sender: addedCards[indexPath.item])
        } else {
            performSegue(withIdentifier: "CardViewSegue", sender: unaddedCards[indexPath.item])
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
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: sectionHeaderView, for: indexPath) as! SectionHeaderView
        
        if (indexPath.section == 0) {
            sectionHeader.sectionTitle = "Added Cards"
        } else {
            sectionHeader.sectionTitle = "Unadded Cards"
        }
        
        return sectionHeader
        
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
            break
        case .home:
            guard let homeNavController = storyboard!.instantiateViewController(identifier: "HomeNavController") as? UINavigationController else { return }
            homeNavController.modalPresentationStyle = .fullScreen
            
            if let hVC = homeNavController.topViewController as? HomeViewController {
                hVC.uid = self.uid
                hVC.cards = self.cards
            }
            
            self.present(homeNavController, animated: true, completion: nil)
        case .analytics:
            guard let analyticsNavController = storyboard!.instantiateViewController(identifier: "AnalyticsNavController") as? UINavigationController else { return }
            analyticsNavController.modalPresentationStyle = .fullScreen
            self.present(analyticsNavController, animated: true, completion: nil)
            
            if let aVC = analyticsNavController.topViewController as? AnalyticsTableViewController {
                aVC.uid = self.uid
                aVC.cards = self.cards
            }
        case .profile:
            guard let profileNavController = storyboard!.instantiateViewController(identifier: "ProfileNavController") as? UINavigationController else { return }
            profileNavController.modalPresentationStyle = .fullScreen
            self.present(profileNavController, animated: true, completion: nil)
            
            if let pVC = profileNavController.topViewController as? ProfileViewController {
                pVC.allCards = self.allCards
                pVC.addedCards = self.addedCards
                pVC.unaddedCards = self.unaddedCards
                pVC.uid = self.uid
                pVC.cards = self.cards
            }
        }
    }
}

extension CardCollectionViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.isPresenting = true
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.isPresenting = false
        return transition
    }
}
