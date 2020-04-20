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

class LogInViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorLabel.isHidden = true
        emailTextField.delegate = self
        passwordTextField.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillChange(notification: Notification) {
        
        guard let keyboardDimension = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        if notification.name == UIResponder.keyboardWillShowNotification || notification.name == UIResponder.keyboardWillChangeFrameNotification {
            view.frame.origin.y = -keyboardDimension.height + 200
        } else {
            view.frame.origin.y = 0
        }
    }

    @IBAction func logInButtonTapped(_ sender: Any) {
        
        let err = validateItems()
        
        if err != nil {
            errorLabel.text = err
            errorLabel.isHidden = false
        } else {
            Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (result, error) in
                if error != nil {
                    self.errorLabel.text = "An error has occurred while logging in."
                    self.errorLabel.isHidden = false
                } else {
                    
                    UserDefaults.standard.set(true, forKey: LoggedInSettings.UserIsLoggedIn.rawValue)
                    UserDefaults.standard.set("\(result!.user.uid)", forKey: LoggedInSettings.LoggedInUserUID.rawValue)
                    UserDefaults.standard.synchronize()
                    
                    let homeNav = self.storyboard?.instantiateViewController(identifier: "HomeNavController") as? UINavigationController
                    
                    if let hVC = homeNav?.topViewController as? HomeViewController {
                        hVC.uid = result!.user.uid
                        
                        let ref = Database.database().reference()
                        
                        ref.child("users/\(result!.user.uid)").observe(DataEventType.value) { (snapshot) in
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
    }

    func validateItems() -> String? {
        if emailTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            return "Empty fields found."
        }
        return nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
