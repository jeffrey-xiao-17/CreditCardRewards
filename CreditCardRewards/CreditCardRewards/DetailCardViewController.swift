//
//  CardViewController.swift
//  CreditCardRewards
//
//  Created by Jeffrey Xiao on 4/13/20.
//  Copyright © 2020 Jeffrey Xiao. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher
import Firebase

class DetailCardViewController: UIViewController, AddCashDelegate {
    func didAdd(_ cash: Double) {
        dismiss(animated: true, completion: nil)
        let newVal = card!.cashSaved + cash
        card!.cashSaved = newVal
        ref.updateChildValues(["users/\(uid)/cards/\(card!.id - 1)/cashSaved" : newVal])

        cardCashSaved.text = "Cash saved: " + currencyFormatter.string(from: NSNumber(value: newVal))!
    }
    
    var card: Card?
    @IBOutlet var addRemoveButton: UIButton!
    @IBOutlet var cardAddedLabel: UILabel!
    @IBOutlet var cardView: UIImageView!
    @IBOutlet var cardName: UILabel!
    @IBOutlet var cardRewards: UILabel!
    @IBOutlet var cardCashSaved: UILabel!
    @IBOutlet weak var addCashButton: UIBarButtonItem!
    var rewardsText: String = "None :("
    var ref: DatabaseReference!
    var uid: String = "invalid-override"
    let currencyFormatter = NumberFormatter()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = Locale.current
        formatRewardsText()
        changeAddVisibility()
    }
    
    @IBAction func addCash() {
        performSegue(withIdentifier: "addCashSegue", sender: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        cardView.kf.setImage(with: card!.imageUrl)
        cardName.text = "\(card!.cardName)"
        cardRewards.text = "\(rewardsText)"
        addRemoveButton.setTitle(card!.added ? "Remove Card" : "Add Card", for: .normal)
        cardAddedLabel.text = card!.added ? "Added" : "Not Added"
        cardCashSaved.text = "Cash saved: " + currencyFormatter.string(from: NSNumber(value: card!.cashSaved))!
        changeAddVisibility()
    }
    
    @IBAction func addRemoveButtonPressed(_ sender: Any) {
        card!.added.toggle()
        changeAddVisibility()
        addRemoveButton.setTitle(card!.added ? "Remove Card" : "Add Card", for: .normal)
        ref.updateChildValues(["users/\(uid)/cards/\(card!.id - 1)/added" : card!.added])
    }
    
    private func formatRewardsText() {
        rewardsText = ""
        
        rewardsText += "\u{2022} Dining: \(card!.diningCBP)\n"
        rewardsText += "\u{2022} Travel: \(card!.travelCBP)\n"
        rewardsText += "\u{2022} Gas: \(card!.gasCBP)\n"
        rewardsText += "\u{2022} Shopping: \(card!.shoppingCBP)\n"
        rewardsText += "\u{2022} Entertainment: \(card!.entertainmentCBP)\n"
        rewardsText += "\u{2022} Groceries: \(card!.groceriesCBP)\n"
        rewardsText += "\u{2022} Amazon: \(card!.amazonCBP)\n"
        rewardsText += "\u{2022} Whole Foods: \(card!.wholeFoodsCBP)\n"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addCashSegue" {
            if let navVC = segue.destination as? UINavigationController {
                if let addVC = navVC.topViewController as? AddCashViewController {
                    addVC.card = card!
                    addVC.delegate = self
                }
            }
        }
    }
    
    private func changeAddVisibility() {
        if !card!.added {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
            self.navigationItem.rightBarButtonItem?.tintColor = UIColor.clear
        } else {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            self.navigationItem.rightBarButtonItem?.tintColor = UIColor.systemBlue
        }
    }
}
