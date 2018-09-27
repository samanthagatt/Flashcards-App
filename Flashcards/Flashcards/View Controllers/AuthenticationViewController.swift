//
//  AuthenticationViewController.swift
//  Flashcards
//
//  Created by Samantha Gatt on 9/27/18.
//  Copyright © 2018 Samantha Gatt. All rights reserved.
//

import UIKit

class AuthenticationViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let greenColor = UIColor(red: 141.0/255.0, green: 204.0/255.0, blue: 149.0/255.0, alpha: 1.0)
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        gradientLayer.colors = [greenColor.cgColor, UIColor.white.cgColor]
        self.view.layer.insertSublayer(gradientLayer, at: 0)
        
        loginButton.layer.cornerRadius = loginButton.frame.height / 2
        loginButton.clipsToBounds = true
        
        signupButton.layer.borderColor = greenColor.cgColor
        signupButton.layer.borderWidth = 2.0
        signupButton.layer.cornerRadius = loginButton.frame.height / 2
        signupButton.clipsToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        animateView()
    }
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var flashcardsLabel: UILabel!
    
    
    func animateView() {
        
        flashcardsLabel.frame.origin.y = flashcardsLabel.frame.origin.y - flashcardsLabel.frame.height - 125
        
        UIView.animate(withDuration: 1.0, animations: { () -> Void in
            self.flashcardsLabel.frame.origin.y = self.flashcardsLabel.frame.origin.y + self.flashcardsLabel.frame.height + 125
        })
    }
}
