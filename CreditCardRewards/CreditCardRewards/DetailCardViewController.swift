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
    func didAdd(_ cash: Double, _ filter: Int) {
        dismiss(animated: true, completion: nil)
        let newVal = card!.cashSaved + cash
        card!.cashSaved = newVal
        
        switch filter {
        case 0:
            card!.filterSaved[0] += cash
            ref.updateChildValues(["users/\(uid)/cards/\(card!.id - 1)/filters/\(filter)/cashSaved" : card!.filterSaved[0]])
        case 1:
            card!.filterSaved[1] += cash
            ref.updateChildValues(["users/\(uid)/cards/\(card!.id - 1)/filters/\(filter)/cashSaved" : card!.filterSaved[1]])
        case 2:
            card!.filterSaved[2] += cash
            ref.updateChildValues(["users/\(uid)/cards/\(card!.id - 1)/filters/\(filter)/cashSaved" : card!.filterSaved[2]])
        case 3:
            card!.filterSaved[3] += cash
            ref.updateChildValues(["users/\(uid)/cards/\(card!.id - 1)/filters/\(filter)/cashSaved" : card!.filterSaved[3]])
        case 4:
            card!.filterSaved[4] += cash
            ref.updateChildValues(["users/\(uid)/cards/\(card!.id - 1)/filters/\(filter)/cashSaved" : card!.filterSaved[4]])
        case 5:
            card!.filterSaved[5] += cash
            ref.updateChildValues(["users/\(uid)/cards/\(card!.id - 1)/filters/\(filter)/cashSaved" : card!.filterSaved[5]])
        case 6:
            card!.filterSaved[6] += cash
            card!.filterSaved[3] += cash
            ref.updateChildValues(["users/\(uid)/cards/\(card!.id - 1)/filters/\(filter)/cashSaved" : card!.filterSaved[6]])
            ref.updateChildValues(["users/\(uid)/cards/\(card!.id - 1)/filters/3/cashSaved" : card!.filterSaved[3]])
        case 7:
            card!.filterSaved[7] += cash
            card!.filterSaved[3] += cash
            ref.updateChildValues(["users/\(uid)/cards/\(card!.id - 1)/filters/\(filter)/cashSaved" : card!.filterSaved[7]])
            ref.updateChildValues(["users/\(uid)/cards/\(card!.id - 1)/filters/3/cashSaved" : card!.filterSaved[3]])
        case 8:
            card!.filterSaved[8] += cash
            card!.filterSaved[1] += cash
            ref.updateChildValues(["users/\(uid)/cards/\(card!.id - 1)/filters/\(filter)/cashSaved" : card!.filterSaved[8]])
            ref.updateChildValues(["users/\(uid)/cards/\(card!.id - 1)/filters/1/cashSaved" : card!.filterSaved[1]])
        case 9:
            card!.filterSaved[9] += cash
            card!.filterSaved[1] += cash
            ref.updateChildValues(["users/\(uid)/cards/\(card!.id - 1)/filters/\(filter)/cashSaved" : card!.filterSaved[9]])
            ref.updateChildValues(["users/\(uid)/cards/\(card!.id - 1)/filters/1/cashSaved" : card!.filterSaved[1]])
        case 10:
            card!.filterSaved[10] += cash
            card!.filterSaved[1] += cash
            ref.updateChildValues(["users/\(uid)/cards/\(card!.id - 1)/filters/\(filter)/cashSaved" : card!.filterSaved[10]])
            ref.updateChildValues(["users/\(uid)/cards/\(card!.id - 1)/filters/1/cashSaved" : card!.filterSaved[1]])
        case 11:
            card!.filterSaved[11] += cash
            card!.filterSaved[1] += cash
            ref.updateChildValues(["users/\(uid)/cards/\(card!.id - 1)/filters/\(filter)/cashSaved" : card!.filterSaved[11]])
            ref.updateChildValues(["users/\(uid)/cards/\(card!.id - 1)/filters/1/cashSaved" : card!.filterSaved[1]])
        case 12:
            card!.filterSaved[12] += cash
            card!.filterSaved[1] += cash
            ref.updateChildValues(["users/\(uid)/cards/\(card!.id - 1)/filters/\(filter)/cashSaved" : card!.filterSaved[12]])
            ref.updateChildValues(["users/\(uid)/cards/\(card!.id - 1)/filters/1/cashSaved" : card!.filterSaved[1]])
        case 13:
            card!.filterSaved[13] += cash
            card!.filterSaved[3] += cash
            ref.updateChildValues(["users/\(uid)/cards/\(card!.id - 1)/filters/\(filter)/cashSaved" : card!.filterSaved[13]])
            ref.updateChildValues(["users/\(uid)/cards/\(card!.id - 1)/filters/3/cashSaved" : card!.filterSaved[3]])
        case 14:
            card!.filterSaved[6] += cash
            card!.filterSaved[5] += cash
            ref.updateChildValues(["users/\(uid)/cards/\(card!.id - 1)/filters/6/cashSaved" : card!.filterSaved[6]])
            ref.updateChildValues(["users/\(uid)/cards/\(card!.id - 1)/filters/5/cashSaved" : card!.filterSaved[5]])
        case 15:
            card!.filterSaved[7] += cash
            card!.filterSaved[5] += cash
            ref.updateChildValues(["users/\(uid)/cards/\(card!.id - 1)/filters/7/cashSaved" : card!.filterSaved[7]])
            ref.updateChildValues(["users/\(uid)/cards/\(card!.id - 1)/filters/5/cashSaved" : card!.filterSaved[5]])
        default:
            break
        }
        
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
        setChanges()
    }
    
    @IBAction func addCash() {
        performSegue(withIdentifier: "addCashSegue", sender: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        cardView.kf.setImage(with: card!.imageUrl)
        cardName.text = "\(card!.cardName)"
        cardRewards.text = "\(rewardsText)"
        cardRewards.adjustsFontSizeToFitWidth = true
        cardRewards.adjustsFontForContentSizeCategory = true
        addRemoveButton.setTitle(card!.added ? "Remove Card" : "Add Card", for: .normal)
        cardAddedLabel.text = card!.added ? "Added" : "Not Added"
        cardCashSaved.text = "Cash saved: " + currencyFormatter.string(from: NSNumber(value: card!.cashSaved))!
        changeAddVisibility()
    }
    
    @IBAction func addRemoveButtonPressed(_ sender: Any) {
        card!.added.toggle()
        changeAddVisibility()
        setChanges()
        ref.updateChildValues(["users/\(uid)/cards/\(card!.id - 1)/added" : card!.added])
    }
    
    private func setChanges() {
        addRemoveButton.setTitle(card!.added ? "Remove Card" : "Add Card", for: .normal)
        card!.added ? addRemoveButton.setTitleColor(UIColor.systemRed, for: .normal) : addRemoveButton.setTitleColor(UIColor.systemBlue, for: .normal)
        cardAddedLabel.text = card!.added ? "Added" : "Not Added"
    }
    
    private func formatRewardsText() {
        rewardsText = ""
        
        rewardsText += "\u{2022} Dining: \(card!.diningCBP)\n"
        rewardsText += "\u{2022} Travel: \(card!.travelCBP)\n"
        rewardsText += "\t\u{2022} United: \(card!.unitedCBP)\n"
        rewardsText += "\t\u{2022} Delta: \(card!.deltaCBP)\n"
        rewardsText += "\t\u{2022} Southwest: \(card!.southwestCBP)\n"
        rewardsText += "\t\u{2022} British Airways: \(card!.britishAirwaysCBP)\n"
        rewardsText += "\t\u{2022} Uber: \(card!.uberCBP)\n"
        rewardsText += "\u{2022} Gas: \(card!.gasCBP)\n"
        rewardsText += "\u{2022} Shopping: \(card!.shoppingCBP)\n"
        rewardsText += "\t\u{2022} Amazon: \(card!.amazonCBP)\n"
        rewardsText += "\t\u{2022} Whole Foods: \(card!.wholeFoodsCBP)\n"
        rewardsText += "\t\u{2022} Apple: \(card!.appleCBP)\n"
        rewardsText += "\u{2022} Entertainment: \(card!.entertainmentCBP)\n"
        rewardsText += "\u{2022} Groceries: \(card!.groceriesCBP)\n"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addCashSegue" {
            if let navVC = segue.destination as? UINavigationController {
                if let addVC = navVC.topViewController as? AddCashViewController {
                    addVC.card = card!
                    addVC.delegate = self
                    navVC.modalPresentationStyle = .fullScreen
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
