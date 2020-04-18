//
//  LogInViewController.swift
//  CreditCardRewards
//
//  Created by Jeffrey Xiao on 4/16/20.
//  Copyright © 2020 Jeffrey Xiao. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher
import FirebaseAuth
import Firebase

class LogInViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorLabel.isHidden = true
    }

    @IBAction func logInButtonTapped(_ sender: Any) {
        
        let err = validateItems()
        
        if err != nil {
            errorLabel.text = err
            errorLabel.isHidden = false
        } else {
            Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (result, error) in
                if error != nil {
                    self.errorLabel.text = "An error has occurred while logging in"
                    self.errorLabel.isHidden = false
                } else {
                    let homeNav = self.storyboard?.instantiateViewController(identifier: "HomeNavController") as? UINavigationController
                    
                    if let hVC = homeNav?.topViewController as? HomeViewController {
                        hVC.uid = result!.user.uid
                    }
                    
                    self.view.window?.rootViewController = homeNav
                    self.view.window?.makeKeyAndVisible()
                }
            }
        }
        
    }

    func validateItems() -> String? {
        
        if emailTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            return "Empty fields found."
        }
        
        return nil
    }
}
