//
//  AppDelegate.swift
//  Flashcards
//
//  Created by Samantha Gatt on 9/22/18.
//  Copyright © 2018 Samantha Gatt. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let loginStoryboard = UIStoryboard(name: "LoginAndSignUp", bundle: nil)
            
            var controller: UIViewController?
            if let _ = user  {
                controller = mainStoryboard.instantiateInitialViewController()
            } else {
                controller = loginStoryboard.instantiateInitialViewController()
            }
            self.window?.rootViewController = controller
            self.window?.makeKeyAndVisible()
        }
        
        return true
    }
}

