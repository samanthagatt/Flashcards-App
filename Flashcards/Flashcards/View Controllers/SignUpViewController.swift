//
//  SignUpViewController.swift
//  Flashcards
//
//  Created by Samantha Gatt on 9/25/18.
//  Copyright © 2018 Samantha Gatt. All rights reserved.
//

import UIKit
import FirebaseAuth

class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let greenColor = UIColor(red: 141.0/255.0, green: 204.0/255.0, blue: 149.0/255.0, alpha: 1.0)
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        gradientLayer.colors = [greenColor.cgColor, UIColor.white.cgColor]
        self.view.layer.insertSublayer(gradientLayer, at: 0)
        
        signUpButton.layer.borderColor = greenColor.cgColor
        signUpButton.layer.borderWidth = 2.0
        signUpButton.layer.cornerRadius = signUpButton.frame.height / 2
        signUpButton.clipsToBounds = true
        
        passwordTextField.isSecureTextEntry = true
        
        usernameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    
    // MARK: - Outlets
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    
    
    // MARK: - Actions
    
    @IBAction func signUp(_ sender: Any) {
        guard let username = usernameTextField.text,
            let email = emailTextField.text,
            let password = passwordTextField.text else { return }
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if let error = error {
                NSLog("Error signing up: \(error)")
            }
            
            guard let _ = user else {
                NSLog("Error signing up")
                return
            }
            
            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
            changeRequest?.displayName = username
            changeRequest?.commitChanges() { (error) in
                if let error = error {
                    NSLog("Error setting username: \(error)")
                    return
                }
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
