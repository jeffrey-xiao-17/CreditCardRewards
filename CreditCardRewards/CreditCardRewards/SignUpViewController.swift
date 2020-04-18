//
//  SignUpViewController.swift
//  CreditCardRewards
//
//  Created by Jeffrey Xiao on 4/16/20.
//  Copyright © 2020 Jeffrey Xiao. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth


class SignUpViewController: UIViewController {

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorLabel.isHidden = true
    }

    @IBAction func signUpTapped(_ sender: Any) {
        
        let err = validateItems()
        
        if err != nil {
            errorLabel.text = err
            errorLabel.isHidden = false
        } else {
            Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { (result, error) in
                if error != nil {
                    self.errorLabel.text = "An error has ocurred in creating user"
                } else {
                    let ref = Database.database().reference()
                    
                    ref.child("users/\(result!.user.uid)").setValue(["first_name": self.firstNameTextField.text!, "last_name": self.lastNameTextField.text!, "email": self.emailTextField.text!, "password": self.passwordTextField.text!, "uid": result!.user.uid, "cards": []]) { (error, ref) in
                        if error != nil {
                            self.errorLabel.text = "Data couldn't be saved"
                        }
                    }
                    
                    // UPDATE THIS TO ACCOUNT FOR TOTAL NUMBER OF CARDS
                    for index in 0...5 {
                        ref.child("users/\(result!.user.uid)/cards/\(index)").setValue(["added": false, "cashSaved": 0.0, "id": index + 1]) { (error, ref) in
                            if error != nil {
                                self.errorLabel.text = "Data couldn't be saved"
                            }
                        }
                    }
                    
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
        
        if firstNameTextField.text!.isEmpty || lastNameTextField.text!.isEmpty || emailTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            return "Empty fields found."
        }
        
        return nil
    }
    
}
