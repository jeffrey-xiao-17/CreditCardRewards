//
//  ProfileViewController.swift
//  CreditCardRewards
//
//  Created by Jeffrey Xiao on 4/17/20.
//  Copyright © 2020 Jeffrey Xiao. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var dateJoinedLabel: UILabel!
    @IBOutlet weak var cardsRegisteredLabel: UILabel!
    @IBOutlet weak var profilePictureView: UIImageView!
    @IBOutlet weak var profileNameLabel: UILabel!
    let transition = SlideTransition()
    var allCards: [Card] = []
    var addedCards: [Card] = []
    var uid: String = ""
    var cards: [NSDictionary] = []
    var ref: DatabaseReference!
    var firstName: String = ""
    var dateJoined: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profilePictureView.layer.cornerRadius = profilePictureView.frame.width / 2;
        profilePictureView.clipsToBounds = true
        
        ref = Database.database().reference()
        
        ref.child("users/\(uid)").observe(DataEventType.value, with: { (snapshot) in
            if let info = snapshot.value as? NSDictionary, let firstName = info["first_name"] as? String, let lastName = info["last_name"] as? String {
                self.profileNameLabel.text = "\(firstName) \(lastName)"
                self.cardsRegisteredLabel.text = "Total cards registered: \(self.addedCards.count)"
            }
        })
        dateJoinedLabel.text = "Date joined: \(dateJoined)"
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(_:)))
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
        self.view.addGestureRecognizer(swipeRight)
    }

    @objc func respondToSwipeGesture(_ gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizer.Direction.right:
                didTapMenu(UIBarButtonItem())
            default:
                break
            }
        }
    }
    
    @IBAction func clearDataButtonPressed(_ sender: Any) {
        for card in allCards {
            print(card)
            ref.updateChildValues(["users/\(self.uid)/cards/\(card.id - 1)/cashSaved" : 0.0])
            for int in 0 ... 13 {
                ref.updateChildValues(["users/\(self.uid)/cards/\(card.id - 1)/filters/\(int)/cashSaved" : 0.0])
            }
        }
    }
    
    @IBAction func signOutButtonPressed(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
            let firstNav = self.storyboard!.instantiateViewController(identifier: "FirstNavController") as? UINavigationController
            firstNav!.modalPresentationStyle = .fullScreen
            self.present(firstNav!, animated: true, completion: nil)
            UserDefaults.standard.set(false, forKey: LoggedInSettings.UserIsLoggedIn.rawValue)
            UserDefaults.standard.set("N/A", forKey: LoggedInSettings.LoggedInUserUID.rawValue)
            UserDefaults.standard.synchronize()
        } catch let error {
            print("\(error)")
        }
    }
    
    @IBAction func imagePressed(sender: UIGestureRecognizer) {
        presentImagePicker()
    }
    
    @IBAction func didTapMenu(_ sender: UIBarButtonItem) {
        guard let menuViewController = storyboard?.instantiateViewController(identifier: "MenuViewController") as? MenuViewController else { return }
        
        menuViewController.didTapMenuType = { menuType in
            self.transitionToNew(menuType)
        }
        
        menuViewController.firstName = self.firstName
        menuViewController.modalPresentationStyle = .overCurrentContext
        menuViewController.transitioningDelegate = self
        self.present(menuViewController, animated: true)
    }

    func transitionToNew(_ menuType: MenuType) {
        switch menuType {
        case .cards:
            guard let collectionNavController = storyboard!.instantiateViewController(identifier: "CardsCollectionNavController") as? UINavigationController else { return }
            collectionNavController.modalPresentationStyle = .fullScreen
            self.present(collectionNavController, animated: true, completion: nil)
            
            if let ccVC = collectionNavController.topViewController as? CardCollectionViewController {
                ccVC.uid = self.uid
                ccVC.cards = self.cards
                ccVC.firstName = self.firstName
                ccVC.dateJoined = self.dateJoined
            }
        case .home:
            guard let homeNavController = storyboard!.instantiateViewController(identifier: "HomeNavController") as? UINavigationController else { return }
            homeNavController.modalPresentationStyle = .fullScreen
            
            if let hVC = homeNavController.topViewController as? HomeViewController {
                hVC.uid = self.uid
                hVC.cards = self.cards
                hVC.firstName = self.firstName
                hVC.dateJoined = self.dateJoined
            }
            
            self.present(homeNavController, animated: true, completion: nil)
        case .analytics:
            guard let analyticsNavController = storyboard!.instantiateViewController(identifier: "AnalyticsNavController") as? UINavigationController else { return }
            analyticsNavController.modalPresentationStyle = .fullScreen
            self.present(analyticsNavController, animated: true, completion: nil)
            
            if let aVC = analyticsNavController.topViewController as? AnalyticsTableViewController {
                aVC.uid = self.uid
                aVC.cards = self.cards
                aVC.firstName = self.firstName
                aVC.dateJoined = self.dateJoined
            }
        case .profile:
            break
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            profilePictureView.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func presentImagePicker() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
}

extension ProfileViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.isPresenting = true
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.isPresenting = false
        return transition
    }
}
