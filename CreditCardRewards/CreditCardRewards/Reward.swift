//
//  Reward.swift
//  CreditCardRewards
//
//  Created by Jeffrey Xiao on 4/13/20.
//  Copyright © 2020 Jeffrey Xiao. All rights reserved.
//

import Foundation
import UIKit


struct Reward {
    
    let cashBackPercent: Double
    let pointsMultiplier: Double
    let restriction: String
    
    init(cashBackPercent: Double, pointsMultiplier: Double, restriction: String) {
        self.cashBackPercent = cashBackPercent
        self.pointsMultiplier = pointsMultiplier
        self.restriction = restriction
    }
}
