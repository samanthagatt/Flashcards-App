//
//  CreateOrganizerAlertController.swift
//  Flashcards
//
//  Created by Samantha Gatt on 9/26/18.
//  Copyright © 2018 Samantha Gatt. All rights reserved.
//

import UIKit

protocol CreateOrganizerAlertControllerDelegate: class {
    func createOrganizer(type: OrganizerType, title: String)
}

class CreateOrganizerAlertController: UIViewController {
    
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
    
    var delegate: CreateOrganizerAlertControllerDelegate?
    var selectedType: OrganizerType = .group
    
    
    // MARK: - Outlets
    
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
    
    // MARK: - Actions
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func create(_ sender: Any) {
        guard let title = titleTextField.text else { return }
        delegate?.createOrganizer(type: selectedType, title: title)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func switchImage(_ sender: Any) {
        switch segmentedControl.selectedSegmentIndex {
        case 1:
            imageView.image = UIImage(named: "set")
            selectedType = .set
        default:
            imageView.image = UIImage(named: "group")
            selectedType = .group
        }
    }
    
    
    // MARK: - Functions
    
    private func animateView() {
        alertView.alpha = 0;
        self.alertView.frame.origin.y = self.alertView.frame.origin.y + 50
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.alertView.alpha = 1.0
            self.alertView.frame.origin.y = self.alertView.frame.origin.y - 50
        })
    }
}
