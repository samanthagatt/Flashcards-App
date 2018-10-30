//
//  LoginViewController.swift
//  Flashcards
//
//  Created by Samantha Gatt on 9/25/18.
//  Copyright © 2018 Samantha Gatt. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    // MARK: - ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let greenColor = UIColor(red: 141.0/255.0, green: 204.0/255.0, blue: 149.0/255.0, alpha: 1.0)
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        gradientLayer.colors = [greenColor.cgColor, UIColor.white.cgColor]
        self.view.layer.insertSublayer(gradientLayer, at: 0)
        
        loginButton.layer.borderColor = greenColor.cgColor
        loginButton.layer.borderWidth = 2.0
        loginButton.layer.cornerRadius = loginButton.frame.height / 2
        loginButton.clipsToBounds = true
        
        passwordTextField.isSecureTextEntry = true
    }
    
    
    // MARK: - Outlets
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    
    // MARK: - Actions
    
    @IBAction func login(_ sender: Any) {
        guard let email = emailTextField.text,
            let password = passwordTextField.text else { return }
        
        Auth.auth().signIn(withEmail: email, password: password) { user, error in
            if let error = error {
                print("Error logging in: \(error)")
            }
            
            if let _ = user {
                self.dismiss(animated: true, completion: nil)
            } else {
                print("Error logging in")
            }
        }
        
        passwordTextField.text = ""
    }
}
