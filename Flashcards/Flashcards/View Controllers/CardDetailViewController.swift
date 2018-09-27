//
//  CardDetailViewController.swift
//  Flashcards
//
//  Created by Samantha Gatt on 9/27/18.
//  Copyright © 2018 Samantha Gatt. All rights reserved.
//

import UIKit

class CardDetailViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cardView.layer.cornerRadius = 10.0
        cardView.layer.shadowOffset = CGSize.zero
        cardView.layer.shadowOpacity = 0.5
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowRadius = 5.0
        
        textView.text = card?.front
    }
    
    
    // MARK: - Properties
    
    var card: Card?
    let cardController = CardController()
    var isFront = true
    
    
    // MARK: -  Outlets
    
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var textView: UITextView!
    
    
    // MARK: - Actions
    
    @IBAction func save(_ sender: Any) {
        saveCard()
    }
    
    @IBAction func flip(_ sender: Any) {
        guard let card = card else { return }
        if textView.text != card.front && textView.text != card.back {
            let alert = UIAlertController(title: "Uh Oh!", message: "Looks like you haven't saved your changes", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let saveAction = UIAlertAction(title: "Save", style: .default) { (_) in
                self.saveCard()
            }
            alert.addAction(cancelAction)
            alert.addAction(saveAction)
            self.present(alert, animated: true, completion: nil)
        } else if isFront {
            UIView.transition(with: cardView, duration: 1.0, options: [.transitionFlipFromRight], animations: {
                self.textView.text = card.back
            })
            isFront = false
        } else if textView.text == card.back {
            UIView.transition(with: cardView, duration: 1.0, options: [.transitionFlipFromRight], animations: {
                self.textView.text = card.front
            })
            isFront = true
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
}
