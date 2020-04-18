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
    
    @IBOutlet weak var pickerViewTravel: UIPickerView!
    @IBOutlet weak var pickerViewGroceries: UIPickerView!
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
    var travelPickerOn: Bool = false
    var shoppingPickerOn: Bool = false
    var groceriesPickerOn: Bool = false
    
    weak var delegate: AddCashDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cardView.kf.setImage(with: card!.imageUrl)
        cardName.text = "\(card!.cardName)"
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerViewGroceries.delegate = self
        pickerViewGroceries.dataSource = self
        pickerViewTravel.delegate = self
        pickerViewTravel.dataSource = self
        inputAmountTextField.delegate = self
        filtersLabel.text = "Filter: Dining"
        segmentMultiplier = card.diningCBP
        cashBackPercentageLabel.text = "Cash Back (%): \(max(segmentMultiplier, pickerMultiplier))"
        pickerView.isHidden = true
        ref = Database.database().reference()
    }
    
    private func adjustPickerBools(shopping: Bool, groceries: Bool, travel: Bool) {
        shoppingPickerOn = shopping
        travelPickerOn = travel
        groceriesPickerOn = groceries
        pickerView.isHidden = !shoppingPickerOn
        pickerViewGroceries.isHidden = !groceriesPickerOn
        pickerViewTravel.isHidden = !travelPickerOn
    }
    
    
    @IBAction func filterSegmentedControlSwitch(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            filtersLabel.text = "Filter: Dining"
            segmentMultiplier = card.diningCBP
            adjustPickerBools(shopping: false, groceries: false, travel: false)
        case 1:
            filtersLabel.text = "Filter: Travel"
            segmentMultiplier = card.travelCBP
            pickerViewTravel.selectRow(0, inComponent: 0, animated: false)
            adjustPickerBools(shopping: false, groceries: false, travel: true)
        case 2:
            filtersLabel.text = "Filter: Gas"
            segmentMultiplier = card.gasCBP
            adjustPickerBools(shopping: false, groceries: false, travel: false)
        case 3:
            filtersLabel.text = "Filter: Shopping"
            pickerView.selectRow(0, inComponent: 0, animated: false)
            segmentMultiplier = card.shoppingCBP
            adjustPickerBools(shopping: true, groceries: false, travel: false)
        case 4:
            filtersLabel.text = "Filter: Entertainment"
            segmentMultiplier = card.entertainmentCBP
            adjustPickerBools(shopping: false, groceries: false, travel: false)
        case 5:
            filtersLabel.text = "Filter: Groceries"
            segmentMultiplier = card.groceriesCBP
            pickerViewGroceries.selectRow(0, inComponent: 0, animated: false)
            adjustPickerBools(shopping: false, groceries: true, travel: false)
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
        if (pickerView.tag == 10) {
            return HomeViewController.shoppingSource.count
        } else if (pickerView.tag == 20) {
            return HomeViewController.groceriesSource.count
        }
        
        return HomeViewController.travelSource.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let endOfBase = filtersLabel.text!.firstIndex(of: ",")
        if (pickerView.tag == 10) {
            if row == 0 {
                filtersLabel.text = endOfBase == nil ? "\(filtersLabel.text!)" : "\(filtersLabel.text![..<endOfBase!])"
                pickerMultiplier = card.shoppingCBP
            } else if row == 1 {    // target: amazon
                filtersLabel.text! = endOfBase == nil ? "\(filtersLabel.text!), Amazon" : "\(filtersLabel.text![..<endOfBase!]), Amazon"
                pickerMultiplier = card.amazonCBP
            } else if row == 2 {    // target: whole foods
                filtersLabel.text! = endOfBase == nil ? "\(filtersLabel.text!), Whole Foods" : "\(filtersLabel.text![..<endOfBase!]), Whole Foods"
                pickerMultiplier = card.wholeFoodsCBP
            } else if row == 3 {    // target: apple
                filtersLabel.text! = endOfBase == nil ? "\(filtersLabel.text!), Apple" : "\(filtersLabel.text![..<endOfBase!]), Apple"
                pickerMultiplier = card.appleCBP
            }
        } else if (pickerView.tag == 20) {
            if row == 0 {
                filtersLabel.text = endOfBase == nil ? "\(filtersLabel.text!)" : "\(filtersLabel.text![..<endOfBase!])"
                pickerMultiplier = card.groceriesCBP
            } else if row == 1 {    // target: amazon
                filtersLabel.text! = endOfBase == nil ? "\(filtersLabel.text!), Amazon" : "\(filtersLabel.text![..<endOfBase!]), Amazon"
                pickerMultiplier = card.amazonCBP
            } else if row == 2 {    // target: whole foods
                filtersLabel.text! = endOfBase == nil ? "\(filtersLabel.text!), Whole Foods" : "\(filtersLabel.text![..<endOfBase!]), Whole Foods"
                pickerMultiplier = card.wholeFoodsCBP
            }
        } else if (pickerView.tag == 30) {
            if row == 0 {
                filtersLabel.text = endOfBase == nil ? "\(filtersLabel.text!)" : "\(filtersLabel.text![..<endOfBase!])"
                pickerMultiplier = card.travelCBP
            } else if row == 1 {    // target: united
                filtersLabel.text! = endOfBase == nil ? "\(filtersLabel.text!), United" : "\(filtersLabel.text![..<endOfBase!]), United"
                pickerMultiplier = card.unitedCBP
            } else if row == 2 {    // target: delta
                filtersLabel.text! = endOfBase == nil ? "\(filtersLabel.text!), Delta" : "\(filtersLabel.text![..<endOfBase!]), Delta"
                pickerMultiplier = card.deltaCBP
            } else if row == 1 {    // target: southwest
                filtersLabel.text! = endOfBase == nil ? "\(filtersLabel.text!), Southwest" : "\(filtersLabel.text![..<endOfBase!]), Southwest"
                pickerMultiplier = card.southwestCBP
            } else if row == 2 {    // target: british airways
                filtersLabel.text! = endOfBase == nil ? "\(filtersLabel.text!), British Airways" : "\(filtersLabel.text![..<endOfBase!]), British Airways"
                pickerMultiplier = card.britishAirwaysCBP
            } else if row == 1 {    // target: uber
                filtersLabel.text! = endOfBase == nil ? "\(filtersLabel.text!), Uber" : "\(filtersLabel.text![..<endOfBase!]), Uber"
                pickerMultiplier = card.uberCBP
            }
        }
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

extension AddCashViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let _ = string.rangeOfCharacter(from: NSCharacterSet.decimalDigits) {
            return true
        } else {
            return false
        }
    }
}
