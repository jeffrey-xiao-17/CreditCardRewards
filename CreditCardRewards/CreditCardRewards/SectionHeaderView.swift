//
//  SectionHeaderView.swift
//  CreditCardRewards
//
//  Created by Jeffrey Xiao on 4/15/20.
//  Copyright © 2020 Jeffrey Xiao. All rights reserved.
//

import Foundation
import UIKit

class SectionHeaderView: UICollectionReusableView {
    
    @IBOutlet weak var sectionHeaderLabel: UILabel!
    
    
    var sectionTitle: String! {
        didSet {
            sectionHeaderLabel.text = sectionTitle
        }
    }
    
}
