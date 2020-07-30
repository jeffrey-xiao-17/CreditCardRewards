//
//  MenuViewController.swift
//  CreditCardRewards
//
//  Created by Jeffrey Xiao on 4/13/20.
//  Copyright © 2020 Jeffrey Xiao. All rights reserved.
//

import UIKit

enum MenuType: Int {
    case profile
    case home
    case cards
    case analytics
}

class MenuViewController: UITableViewController {
    
    @IBOutlet weak var profileNameLabel: UILabel!
    var didTapMenuType: ((MenuType) -> Void)?
    var firstName: String = "Profile"

    override func viewDidLoad() {
        super.viewDidLoad()
        profileNameLabel.text = firstName
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(_:)))
        swipeLeft.direction = UISwipeGestureRecognizer.Direction.left
        self.view.addGestureRecognizer(swipeLeft)
    }

    @objc func respondToSwipeGesture(_ gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizer.Direction.left:
                dismiss(animated: true, completion: nil)
            default:
                break
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let menuType = MenuType(rawValue: indexPath.row) else { return }
        dismiss(animated: true) { [weak self] in
            self?.didTapMenuType?(menuType)
        }
    }
}
