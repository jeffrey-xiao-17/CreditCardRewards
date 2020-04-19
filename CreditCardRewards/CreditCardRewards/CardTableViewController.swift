//
//  CardsTableViewController.swift
//  CreditCardRewards
//
//  Created by Jeffrey Xiao on 4/14/20.
//  Copyright © 2020 Jeffrey Xiao. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher
import Firebase

class CardTableViewController: UITableViewController {
    
    var ref: DatabaseReference!
    var refHandle: DatabaseHandle!
    var allCards: [Card] = []
    var addedCards: [Card] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        
    }
    
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return 4
//    }
//    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let row = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! UITableViewCell
//        if (indexPath.row == 1 || indexPath.row == 3) {
//            
//        }
//        if let addedCollection = row.viewWithTag(50) as? UICollectionView {
//            
//        } else if let unaddedCollection = row.viewWithTag(100) as? UICollectionView {
//            
//        }
////        row.cardImageView.kf.setImage(with: allCards[indexPath.item].imageUrl)
////        row.cardLabel.text = allCards[indexPath.item].cardName
//        
//        return row
//    }
//    
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        <#code#>
//    }
//    
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 1
//    }
//    
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 100.0
//    }
    
}
