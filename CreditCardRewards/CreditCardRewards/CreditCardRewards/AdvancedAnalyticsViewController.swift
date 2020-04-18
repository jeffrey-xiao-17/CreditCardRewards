//
//  AdvancedAnalyticsViewController.swift
//  CreditCardRewards
//
//  Created by Jeffrey Xiao on 4/18/20.
//  Copyright © 2020 Jeffrey Xiao. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher
import Charts

class AdvancedAnalyticsViewController: UIViewController {

    
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var pickerViewGroceries: UIPickerView!
    @IBOutlet weak var pickerViewTravel: UIPickerView!
    @IBOutlet weak var filtersLabel: UILabel!
    @IBOutlet weak var pieChartView: PieChartView!
    let currencyFormatter = NumberFormatter()
    var ref: DatabaseReference!
    var addedCards: [Card] = []
    var travelPickerOn: Bool = false
    var shoppingPickerOn: Bool = false
    var groceriesPickerOn: Bool = false
    var filter: Int = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerViewGroceries.delegate = self
        pickerViewGroceries.dataSource = self
        pickerViewTravel.delegate = self
        pickerViewTravel.dataSource = self
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.numberStyle = .currency
        currencyFormatter.locale = Locale.current
        adjustPickerBools(shopping: false, groceries: false, travel: false)
        pieChartUpdate()
    }
    
    func pieChartUpdate() {
        var entries: [PieChartDataEntry] = []
        var sum = 0.0
        
        if (filter == -1) {
            for card in addedCards {
                if card.cashSaved > 0.0 {
                    sum += card.cashSaved
                    entries.append(PieChartDataEntry(value: card.cashSaved, label: card.cardName))
                }
            }
        } else {
            for card in addedCards {
                if card.filterSaved[filter] > 0.0 {
                    sum += filterSaved[filter]
                    entries.append(PieChartDataEntry(value: card.filterSaved[filter], label: card.cardName))
                }
            }
        }
        
        let dataSet = PieChartDataSet(entries: entries)
        dataSet.colors = ChartColorTemplates.pastel()
        let data = PieChartData(dataSet: dataSet)
        pieChartView.data = data
        pieChartView.centerText = "Total: " + currencyFormatter.string(from: NSNumber(value: sum))!
        pieChartView.entryLabelColor = .darkText
        pieChartView.chartDescription?.text = "Share of cash saved by card"

        pieChartView.notifyDataSetChanged()
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
            filtersLabel.text = "Filter: None"
            filter = -1
            adjustPickerBools(shopping: false, groceries: false, travel: false)
        case 1:
            filtersLabel.text = "Filter: Dining"
            filter = 0
            adjustPickerBools(shopping: false, groceries: false, travel: false)
        case 2:
            filtersLabel.text = "Filter: Travel"
            filter = 1
            pickerViewTravel.selectRow(0, inComponent: 0, animated: false)
            adjustPickerBools(shopping: false, groceries: false, travel: true)
        case 3:
            filtersLabel.text = "Filter: Gas"
            filter = 2
            adjustPickerBools(shopping: false, groceries: false, travel: false)
        case 4:
            filtersLabel.text = "Filter: Shopping"
            filter = 3
            pickerView.selectRow(0, inComponent: 0, animated: false)
            adjustPickerBools(shopping: true, groceries: false, travel: false)
        case 5:
            filtersLabel.text = "Filter: Entertainment"
            filter = 4
            adjustPickerBools(shopping: false, groceries: false, travel: false)
        case 6:
            filtersLabel.text = "Filter: Groceries"
            filter = 5
            pickerViewGroceries.selectRow(0, inComponent: 0, animated: false)
            adjustPickerBools(shopping: false, groceries: true, travel: false)
        default:
            filtersLabel.text = ""
        }
        pieChartUpdate()
    }
}

extension AdvancedAnalyticsViewController:  UIPickerViewDelegate, UIPickerViewDataSource {
    
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
                filter = 3
            } else if row == 1 {    // target: amazon
                filtersLabel.text! = endOfBase == nil ? "\(filtersLabel.text!), Amazon" : "\(filtersLabel.text![..<endOfBase!]), Amazon"
                filter = 6
            } else if row == 2 {    // target: whole foods
                filtersLabel.text! = endOfBase == nil ? "\(filtersLabel.text!), Whole Foods" : "\(filtersLabel.text![..<endOfBase!]), Whole Foods"
                filter = 7
            } else if row == 3 {    // target: apple
                filtersLabel.text! = endOfBase == nil ? "\(filtersLabel.text!), Apple" : "\(filtersLabel.text![..<endOfBase!]), Apple"
                filter = 13
            }
        } else if (pickerView.tag == 20) {
            if row == 0 {
                filtersLabel.text = endOfBase == nil ? "\(filtersLabel.text!)" : "\(filtersLabel.text![..<endOfBase!])"
                filter = 5
            } else if row == 1 {    // target: amazon
                filtersLabel.text! = endOfBase == nil ? "\(filtersLabel.text!), Amazon" : "\(filtersLabel.text![..<endOfBase!]), Amazon"
                filter = 7
            } else if row == 2 {    // target: whole foods
                filtersLabel.text! = endOfBase == nil ? "\(filtersLabel.text!), Whole Foods" : "\(filtersLabel.text![..<endOfBase!]), Whole Foods"
                filter = 13
            }
        } else if (pickerView.tag == 30) {
            if row == 0 {
                filtersLabel.text = endOfBase == nil ? "\(filtersLabel.text!)" : "\(filtersLabel.text![..<endOfBase!])"
                filter = 1
            } else if row == 1 {    // target: united
                filtersLabel.text! = endOfBase == nil ? "\(filtersLabel.text!), United" : "\(filtersLabel.text![..<endOfBase!]), United"
                filter = 8
            } else if row == 2 {    // target: delta
                filtersLabel.text! = endOfBase == nil ? "\(filtersLabel.text!), Delta" : "\(filtersLabel.text![..<endOfBase!]), Delta"
                filter = 9
            } else if row == 3 {    // target: southwest
                filtersLabel.text! = endOfBase == nil ? "\(filtersLabel.text!), Southwest" : "\(filtersLabel.text![..<endOfBase!]), Southwest"
                filter = 10
            } else if row == 4 {    // target: british airways
                filtersLabel.text! = endOfBase == nil ? "\(filtersLabel.text!), British Airways" : "\(filtersLabel.text![..<endOfBase!]), British Airways"
                filter = 11
            } else if row == 5 {    // target: uber
                filtersLabel.text! = endOfBase == nil ? "\(filtersLabel.text!), Uber" : "\(filtersLabel.text![..<endOfBase!]), Uber"
                filter = 12
            }
        }
        pieChartUpdate()
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
