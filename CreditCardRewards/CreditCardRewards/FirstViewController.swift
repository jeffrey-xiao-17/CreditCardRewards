//
//  FirstViewController.swift
//  CreditCardRewards
//
//  Created by Jeffrey Xiao on 4/16/20.
//  Copyright © 2020 Jeffrey Xiao. All rights reserved.
//

import UIKit
import Firebase

enum LoggedInSettings: String {
    case UserIsLoggedIn
    case LoggedInUserUID
}


class FirstViewController: UIViewController {

    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UserDefaults.standard.bool(forKey: LoggedInSettings.UserIsLoggedIn.rawValue) {
            let homeNav = self.storyboard?.instantiateViewController(identifier: "HomeNavController") as? UINavigationController
            let uid = UserDefaults.standard.string(forKey: LoggedInSettings.LoggedInUserUID.rawValue)!
            if let hVC = homeNav?.topViewController as? HomeViewController {
                hVC.uid = uid
                
                let ref = Database.database().reference()
                
                ref.child("users/\(uid)").observe(DataEventType.value) { (snapshot) in
                    if let items = snapshot.value as? NSDictionary, let name = items["first_name"] as? String, let date = items["date_joined"] as? String {
                        hVC.firstName = name
                        hVC.dateJoined = date
                    }
                }

                ref.child("cards").observe(DataEventType.value) { (snapshot) in
                    if let c = snapshot.value as? [NSDictionary] {
                        hVC.cards = c
                        
                        
                        self.view.window?.rootViewController = homeNav
                        self.view.window?.makeKeyAndVisible()
                    }
                }
            }
        }
    }
}
