//
//  SettingsTableViewController.swift
//  Flashcards
//
//  Created by Samantha Gatt on 9/25/18.
//  Copyright © 2018 Samantha Gatt. All rights reserved.
//

import UIKit
import FirebaseAuth

class SettingsAlertController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        alertView.layer.cornerRadius = 15
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        animateView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.layoutIfNeeded()
        
        let cancelButtonTopBorder = UIView(frame: CGRect(x: 0, y: 0, width: cancelButton.frame.size.width, height: 1))
        cancelButtonTopBorder.backgroundColor = UIColor.lightGray
        cancelButton.addSubview(cancelButtonTopBorder)
    }
    
    
    // MARK: - Properties
    
    var delegate: CreateOrganizerAlertControllerDelegate?
    var selectedType: OrganizerType = .group
    
    
    // MARK: - Outlets
    
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var themeButton: UIButton!
    @IBOutlet weak var prefrencesButton: UIButton!
    @IBOutlet weak var signOutButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    
    // MARK: - Actions
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func signOut(_ sender: Any) {
        presentSignOutAlert()
    }
    
    
    // MARK: - Functions
    
    func animateView() {
        alertView.alpha = 0;
        self.alertView.frame.origin.y = self.alertView.frame.origin.y + 50
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.alertView.alpha = 1.0;
            self.alertView.frame.origin.y = self.alertView.frame.origin.y - 50
        })
    }
    
    func presentSignOutAlert() {
        let alert = UIAlertController(title: "Are you sure you want to sign out?", message: nil, preferredStyle: .alert)
        let signOutAction = UIAlertAction(title: "Sign Out", style: .destructive) { (_) in
            do {
                try Auth.auth().signOut()
            } catch {
                self.presentUhOhAlert()
                return
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(signOutAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func presentUhOhAlert() {
        let alert = UIAlertController(title: "Uh Oh!", message: "It looks like something went wrong while trying to sign out", preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "Okay", style: .cancel, handler: nil)
        alert.addAction(okayAction)
        self.present(alert, animated: true, completion: nil)
    }
}
