//
//  CardCollectionViewCell.swift
//  Flashcards
//
//  Created by Samantha Gatt on 9/26/18.
//  Copyright © 2018 Samantha Gatt. All rights reserved.
//

import UIKit

class CardCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    var card: Card? {
        didSet {
            updateViews()
        }
    }
    // has to be made for each card cell (is there a better way or is it fine?)
    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter
    }()
    
    
    // MARK: - Outlets
    
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var frontTextLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    
    // MARK: - Functions
    
    func updateViews() {
        cardView.layer.cornerRadius = 10.0
        cardView.layer.shadowOffset = CGSize.zero
        cardView.layer.shadowOpacity = 0.5
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowRadius = 5.0
        
        guard let date = card?.dateUpdated else { return }
        frontTextLabel.text = card?.front
        dateLabel.text = dateFormatter.string(from: date)
    }
}
