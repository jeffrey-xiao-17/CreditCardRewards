//
//  Card.swift
//  CreditCardRewards
//
//  Created by Jeffrey Xiao on 4/13/20.
//  Copyright © 2020 Jeffrey Xiao. All rights reserved.
//

import Foundation
import UIKit

struct Card {
    
    let cardName: String
    let diningCBP: Double
    let travelCBP: Double
    let gasCBP: Double
    let shoppingCBP: Double
    let entertainmentCBP: Double
    let groceriesCBP: Double
    let amazonCBP: Double
    let wholeFoodsCBP: Double
    let unitedCBP: Double
    let deltaCBP: Double
    let southwestCBP: Double
    let britishAirwaysCBP: Double
    let uberCBP: Double
    let appleCBP: Double
    
    var filterSaved: [Double]
//    var diningSaved: Double
//    var travelSaved: Double
//    var gasSaved: Double
//    var shoppingSaved: Double
//    var entertainmentSaved: Double
//    var groceriesSaved: Double
//    var amazonSaved: Double
//    var wholeFoodsSaved: Double
//    var unitedSaved: Double
//    var deltaSaved: Double
//    var southwestSaved: Double
//    var britishAirwaysSaved: Double
//    var uberSaved: Double
//    var appleSaved: Double
    
    let imageUrl: URL
    var added: Bool
    let id: Int
    var cashSaved: Double
    
    init(cardName: String, diningCBP: Double, travelCBP: Double, gasCBP: Double,
         shoppingCBP: Double, entertainmentCBP: Double, groceriesCBP: Double, amazonCBP: Double, wholeFoodsCBP: Double, unitedCBP: Double, deltaCBP: Double, southwestCBP: Double, britishAirwaysCBP: Double, uberCBP: Double, appleCBP: Double, imageUrl: String, added: Bool, id: Int, cash: Double, dining: Double, travel: Double, gas: Double, shopping: Double, entertainment: Double, groceries: Double, amazon: Double, wholeFoods: Double, united: Double, delta: Double, southwest: Double, britishAirways: Double, uber: Double, apple: Double) {
        self.cardName = cardName
        self.diningCBP = diningCBP
        self.travelCBP = travelCBP
        self.gasCBP = gasCBP
        self.shoppingCBP = shoppingCBP
        self.entertainmentCBP = entertainmentCBP
        self.groceriesCBP = groceriesCBP
        self.amazonCBP = amazonCBP
        self.wholeFoodsCBP = wholeFoodsCBP
        self.imageUrl = URL(string: imageUrl)!
        self.added = added
        self.id = id
        self.cashSaved = cash
        self.unitedCBP = unitedCBP
        self.deltaCBP = deltaCBP
        self.southwestCBP = southwestCBP
        self.britishAirwaysCBP = britishAirwaysCBP
        self.uberCBP = uberCBP
        self.appleCBP = appleCBP
        
        filterSaved = [dining, travel, gas, shopping, entertainment, groceries, amazon, wholeFoods, united, delta, southwest, britishAirways, uber, apple]
//        diningSaved = dining   0
//        travelSaved = travel  1
//        gasSaved = gas    2
//        shoppingSaved = shopping  3
//        entertainmentSaved = entertainment    4
//        groceriesSaved = groceries    5
//        amazonSaved = amazon  6
//        wholeFoodsSaved = wholeFoods  7
//        unitedSaved = united  8
//        deltaSaved = delta    9
//        southwestSaved = southwest    10
//        britishAirwaysSaved = britishAirways  11
//        uberSaved = uber  12
//        appleSaved = apple    13
    }
}
