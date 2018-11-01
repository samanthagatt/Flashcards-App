//
//  CardDetailViewController.swift
//  Flashcards
//
//  Created by Samantha Gatt on 9/27/18.
//  Copyright © 2018 Samantha Gatt. All rights reserved.
//

import UIKit
import DrawingKit

class CardDetailViewController: UIViewController, UITextViewDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        saveButton.isEnabled = false
        
        let cornerRadius: CGFloat = 10.0
        canvasView.layer.cornerRadius = cornerRadius
        cardView.layer.cornerRadius = cornerRadius
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
        
        guard let card = card else { return }
        if card.isImageCard {
            textView.isHidden = true
            canvasView.isHidden = false
        } else {
            canvasView.isHidden = true
            textView.isHidden = false
        }
        
//        _ = canvasView.toggleEditIsEnabled()
        
        cardController.fetchCardImages(for: card) { (frontImage, backImage, error) in
            if let error = error {
                NSLog("Error fetching front and back images: \(error)")
                return
            }
            
            if let frontImage = frontImage {
                self.frontImage = frontImage
            }
            
            if let backImage = backImage {
                self.backImage = backImage
            }
        }
    }
    
    
    // MARK: - Properties
    
    public var card: Card?
    public let cardController = CardController()
    
    
    // MARK: - Private Properties
    
    private var isFront = true
    private var frontImage: UIImage? {
        didSet {
            DispatchQueue.main.async {
                self.canvasView.startingImage = self.frontImage
            }
        }
    }
    private var backImage: UIImage?
    
    
    // MARK: -  Outlets
    
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var flipButton: UIButton!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var canvasView: CanvasView!
    
    
    // MARK: - Actions
    
    @IBAction func save(_ sender: Any) {
        saveCard()
        textView.resignFirstResponder()
        saveButton.isEnabled = false
    }
    
    @IBAction func flip(_ sender: Any) {
        guard let card = card else { return }
        switch card.isImageCard {
        case false:
            if textView.text != card.front && textView.text != card.back {
                self.saveCard()
                saveButton.isEnabled = false
                self.flipCard(card)
            } else {
                self.flipCard(card)
            }
        case true:
            self.saveCard()
            self.flipCard(card)
        }
    }
    
    
    // MARK: - Functions
    
    func saveCard() {
        guard let card = card else { return }
        let text = textView.text ?? ""
        
        switch card.isImageCard {
        case false:
            if isFront {
                cardController.update(card: card, front: text, context: CoreDataStack.moc)
            } else if !isFront {
                cardController.update(card: card, back: text, context: CoreDataStack.moc)
            }
        case true:
            guard let image = canvasView.getCurrentImage() else { return }
            let imageData = image.pngData()
            if isFront {
                cardController.update(card: card, frontImageData: imageData, context: CoreDataStack.moc)
            } else if !isFront {
                cardController.update(card: card, backImageData: imageData, context: CoreDataStack.moc)
            }
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
