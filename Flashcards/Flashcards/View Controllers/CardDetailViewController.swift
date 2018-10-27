//
//  CardDetailViewController.swift
//  Flashcards
//
//  Created by Samantha Gatt on 9/27/18.
//  Copyright © 2018 Samantha Gatt. All rights reserved.
//

import UIKit

class CardDetailViewController: UIViewController, UITextViewDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        saveButton.isEnabled = false
        
        cardView.layer.cornerRadius = 10.0
        cardView.layer.shadowOffset = CGSize.zero
        cardView.layer.shadowOpacity = 0.5
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowRadius = 5.0
        
        textView.delegate = self
        textView.text = card?.front
        
        let greenColor = UIColor(red: 141.0/255.0, green: 204.0/255.0, blue: 149.0/255.0, alpha: 1.0)
        flipButton.layer.borderColor = greenColor.cgColor
        flipButton.layer.borderWidth = 3.0
        flipButton.layer.cornerRadius = flipButton.frame.height / 2
        flipButton.clipsToBounds = true
    }
    
    
    // MARK: - Properties
    
    var card: Card?
    let cardController = CardController()
    var isFront = true
    
    
    // MARK: -  Outlets
    
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var flipButton: UIButton!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    
    // MARK: - Actions
    
    @IBAction func save(_ sender: Any) {
        saveCard()
        textView.resignFirstResponder()
        saveButton.isEnabled = false
    }
    
    @IBAction func flip(_ sender: Any) {
        guard let card = card else { return }
        if textView.text != card.front && textView.text != card.back {
            self.saveCard()
            self.flipCard(card)
        } else {
            flipCard(card)
        }
    }
    
    
    // MARK: - Functions
    
    func saveCard() {
        guard let card = card else { return }
        let text = textView.text ?? ""
        
        if isFront {
            cardController.update(card: card, front: text, context: CoreDataStack.moc)
        } else if !isFront {
            cardController.update(card: card, back: text, context: CoreDataStack.moc)
        }
    }
    
    func flipCard(_ card: Card) {
        if isFront {
            UIView.transition(with: cardView, duration: 1.0, options: [.transitionFlipFromRight], animations: {
                self.textView.text = card.back
            })
            isFront = false
            flipButton.setTitle("Flip to front", for: .normal)
        } else if textView.text == card.back {
            UIView.transition(with: cardView, duration: 1.0, options: [.transitionFlipFromRight], animations: {
                self.textView.text = card.front
            })
            isFront = true
            flipButton.setTitle("Flip to back", for: .normal)
        }
        textView.resignFirstResponder()
    }
    
    
    // MARK: - UITextViewDelegate
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        saveButton.isEnabled = true
    }
}
