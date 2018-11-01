//
//  CreateCardAlertController.swift
//  Flashcards
//
//  Created by Samantha Gatt on 11/1/18.
//  Copyright © 2018 Samantha Gatt. All rights reserved.
//

import UIKit

protocol CreateCardAlertControllerDelegate {
    func createCard(type: CardType)
}

class CreateCardAlertController: UIViewController {
    
    // MARK: - View controller override functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        alertView.layer.cornerRadius = 15
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        animateView()
    }
    
    
    // MARK: - Properties
    
    var delegate: CreateCardAlertControllerDelegate?
    var selectedType: CardType = .text
    
    
    // MARK: - Outlets
    
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var imageView: UIImageView!
    
    
    // MARK: - Private Functions
    
    private func animateView() {
        alertView.alpha = 0;
        self.alertView.frame.origin.y = self.alertView.frame.origin.y + 50
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.alertView.alpha = 1.0
            self.alertView.frame.origin.y = self.alertView.frame.origin.y - 50
        })
    }
    
    
    // MARK: - Actions
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func create(_ sender: Any) {
        delegate?.createCard(type: selectedType)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func toggleCardType(_ sender: Any) {
        switch segmentedControl.selectedSegmentIndex {
        case 1:
            imageView.image = UIImage(named: "imageCard")
            selectedType = .image
        default:
            imageView.image = UIImage(named: "textCard")
            selectedType = .text
        }
    }
}
