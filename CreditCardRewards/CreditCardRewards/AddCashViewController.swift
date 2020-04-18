//
//  AddCashViewController.swift
//  CreditCardRewards
//
//  Created by Jeffrey Xiao on 4/15/20.
//  Copyright © 2020 Jeffrey Xiao. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import Kingfisher

protocol AddCashDelegate: class {
    func didAdd(_ cash: Double)
}


class AddCashViewController: UIViewController {
    
    var card: Card!
    @IBOutlet var cardView: UIImageView!
    @IBOutlet var cardName: UILabel!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var filtersLabel: UILabel!
    @IBOutlet weak var inputAmountTextField: UITextField!
    @IBOutlet weak var filterSegmentedControl: UISegmentedControl!
    @IBOutlet weak var cashBackPercentageLabel: UILabel!
    var ref: DatabaseReference!
    var segmentMultiplier: Double = 1.0
    var pickerMultiplier: Double = 1.0
    
    weak var delegate: AddCashDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cardView.kf.setImage(with: card!.imageUrl)
        cardName.text = "\(card!.cardName)"
        pickerView.delegate = self
        pickerView.dataSource = self
        inputAmountTextField.delegate = self
        filtersLabel.text = "Filter: Dining"
        segmentMultiplier = card.diningCBP
        cashBackPercentageLabel.text = "Cash Back (%): \(max(segmentMultiplier, pickerMultiplier))"
        pickerView.isHidden = true
        ref = Database.database().reference()
    }
    
    @IBAction func filterSegmentedControlSwitch(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            filtersLabel.text = "Filter: Dining"
            pickerView.isHidden = true
            segmentMultiplier = card.diningCBP
        case 1:
            filtersLabel.text = "Filter: Travel"
            pickerView.isHidden = true
            segmentMultiplier = card.travelCBP
        case 2:
            filtersLabel.text = "Filter: Gas"
            pickerView.isHidden = true
            segmentMultiplier = card.gasCBP
        case 3:
            filtersLabel.text = "Filter: Shopping"
            pickerView.selectRow(0, inComponent: 0, animated: false)
            pickerView.isHidden = false
            segmentMultiplier = card.shoppingCBP
        case 4:
            filtersLabel.text = "Filter: Entertainment"
            pickerView.isHidden = true
            segmentMultiplier = card.entertainmentCBP
        case 5:
            filtersLabel.text = "Filter: Groceries"
            pickerView.isHidden = false
            segmentMultiplier = card.groceriesCBP
            pickerView.selectRow(0, inComponent: 0, animated: false)
        default:
            filtersLabel.text = ""
        }
        cashBackPercentageLabel.text = "Cash Back (%): \(max(segmentMultiplier, pickerMultiplier))"
    }
    
    @IBAction func cancelAddCash() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveAddCash() {
        let cash: Double = createCash()
        
        if cash >= 0 {
            self.delegate?.didAdd(cash)
        }
    }
    
    func createCash() -> Double {
        if inputAmountTextField.text!.isEmpty {
            return -1
        }
        
        return (inputAmountTextField.text! as NSString).doubleValue * max(segmentMultiplier, pickerMultiplier) / 100
    }
}

extension AddCashViewController:  UIPickerViewDelegate, UIPickerViewDataSource {
    
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
                pickerMultiplier = card.shoppingCBP
            } else {
                pickerMultiplier = card.groceriesCBP
            }
        } else if row == 1 {
            if (endOfBase != nil && filtersLabel.text!.count == 24) {
                pickerMultiplier = max(card.shoppingCBP, card.amazonCBP)
            } else {
                pickerMultiplier = max(card.groceriesCBP, card.amazonCBP)
            }
            filtersLabel.text! = endOfBase == nil ? "\(filtersLabel.text!), Amazon" : "\(filtersLabel.text![..<endOfBase!]), Amazon"
        } else if row == 2 {
            if (endOfBase != nil && filtersLabel.text!.count == 29) {
                pickerMultiplier = max(card.shoppingCBP, card.wholeFoodsCBP)
            } else {
                pickerMultiplier = max(card.groceriesCBP, card.wholeFoodsCBP)
            }
            filtersLabel.text! = endOfBase == nil ? "\(filtersLabel.text!), Whole Foods" : "\(filtersLabel.text![..<endOfBase!]), Whole Foods"
        }
    }
    
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return HomeViewController.shoppingAndGroceriesSource[row]
    }
}

extension AddCashViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let _ = string.rangeOfCharacter(from: NSCharacterSet.decimalDigits) {
            return true
        } else {
            return false
        }
    }
}
