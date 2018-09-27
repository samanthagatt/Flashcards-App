//
//  AppearanceHelper.swift
//  Flashcards
//
//  Created by Samantha Gatt on 9/27/18.
//  Copyright © 2018 Samantha Gatt. All rights reserved.
//

import UIKit

enum Appearance {
    
    static func setUpColoredTheme() {
        let greenColor = UIColor(red: 141.0/255.0, green: 204.0/255.0, blue: 149.0/255.0, alpha: 1.0)
        
        UINavigationBar.appearance().barTintColor = greenColor
        
        let navBarTitleFont = UIFont(name: "AvenirNext-Medium", size: 42.0)!
        let navBarTitleFontMetrics = UIFontMetrics(forTextStyle: .title1).scaledFont(for: navBarTitleFont)
        let navBarTitleText = [NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font : navBarTitleFontMetrics]
        UINavigationBar.appearance().titleTextAttributes = navBarTitleText
        UINavigationBar.appearance().largeTitleTextAttributes = navBarTitleText
        
        UIBarButtonItem.appearance().tintColor = UIColor.white
        let barButtonAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        UIBarButtonItem.appearance().setTitleTextAttributes(barButtonAttributes, for: .normal)
        
        UITextField.appearance().tintColor = greenColor
        UITextView.appearance().tintColor = greenColor
    }
}
