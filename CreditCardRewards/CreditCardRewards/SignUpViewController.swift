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


class SignUpViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorLabel.isHidden = true
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
                    UserDefaults.standard.set(true, forKey: LoggedInSettings.UserIsLoggedIn.rawValue)
                    UserDefaults.standard.set("\(result!.user.uid)", forKey: LoggedInSettings.LoggedInUserUID.rawValue)
                    UserDefaults.standard.synchronize()
                    
                    let ref = Database.database().reference()
                    let date = Date()
                    let formatter = DateFormatter()
                    formatter.timeStyle = .none
                    formatter.dateStyle = .long
                    let dateJoined: String = formatter.string(from: date)
                    ref.child("users/\(result!.user.uid)").setValue(["first_name": self.firstNameTextField.text!, "last_name": self.lastNameTextField.text!, "email": self.emailTextField.text!, "password": self.passwordTextField.text!, "uid": result!.user.uid, "cards": [], "date_joined": dateJoined]) { (error, ref) in
                        if error != nil {
                            self.errorLabel.text = "Data couldn't be saved"
                        }
                    }
                    
                    // TODO: UPDATE THIS TO ACCOUNT FOR TOTAL NUMBER OF CARDS (0 to N-1)
                    for index in 0...16 {
                        ref.child("users/\(result!.user.uid)/cards/\(index)").setValue(["added": false, "cashSaved": 0.0, "id": index + 1]) { (error, ref) in
                            if error != nil {
                                self.errorLabel.text = "Data couldn't be saved"
                            }
                        }
                        // TODO: UPDATE THIS TO ACCOUNT FOR TOTAL NUMBER OF FILTERS (0 to N-1)
                        for filter in 0...13 {
                            ref.child("users/\(result!.user.uid)/cards/\(index)/filters/\(filter)").setValue(["cashSaved": 0.0]) { (error, ref) in
                                if error != nil {
                                    self.errorLabel.text = "Data couldn't be saved"
                                }
                            }
                        }
                    }
                    
                    let homeNav = self.storyboard?.instantiateViewController(identifier: "HomeNavController") as? UINavigationController
                    
                    if let hVC = homeNav?.topViewController as? HomeViewController {
                        hVC.uid = result!.user.uid
                        let ref = Database.database().reference()
                        
                        
                        
                        ref.child("users/\(result!.user.uid)").observe(DataEventType.value) { (snapshot) in
                            if let items = snapshot.value as? NSDictionary, let name = items["first_name"] as? String {
                                hVC.firstName = name
                                hVC.dateJoined = dateJoined
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
    
    @objc func keyboardWillChange(notification: Notification) {
        
        guard let keyboardDimension = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        if notification.name == UIResponder.keyboardWillShowNotification || notification.name == UIResponder.keyboardWillChangeFrameNotification {
            view.frame.origin.y = -keyboardDimension.height + 200
        } else {
            view.frame.origin.y = 0
        }
    }
    
    func validateItems() -> String? {
        if firstNameTextField.text!.isEmpty || lastNameTextField.text!.isEmpty || emailTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
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
