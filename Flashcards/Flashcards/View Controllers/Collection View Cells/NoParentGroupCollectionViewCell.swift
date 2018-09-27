//
//  NoParentGroupCollectionViewCell.swift
//  Flashcards
//
//  Created by Samantha Gatt on 9/27/18.
//  Copyright © 2018 Samantha Gatt. All rights reserved.
//

import UIKit

// Wanted to use a protocol but couldn't figure out how to inherit from uicollectionviewcell
class OrganizerCell: UICollectionViewCell {
    var organizer: Organizer?
}

class NoParentGroupCollectionViewCell: OrganizerCell {
    
    // MARK: - Properties
    
    override var organizer: Organizer? {
        didSet {
            updateViews()
        }
    }
    
    
    // MARK: - Outlets
    
    @IBOutlet weak var titleLabel: UILabel!
    
    
    // MARK: - Functions
    
    func updateViews() {
        guard let title = organizer?.title else { return }
        titleLabel.text = title
    }
}
