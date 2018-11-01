//
//  Card+Convenience.swift
//  Flashcards
//
//  Created by Samantha Gatt on 9/24/18.
//  Copyright © 2018 Samantha Gatt. All rights reserved.
//

import Foundation
import CoreData

extension Card {
    convenience init(front: String = "", back: String = "", dateCreated: Date = Date(), identifier: String = UUID().uuidString, parentSetID: String, isImageCard: Bool = false, frontURLString: String? = nil, backURLString: String? = nil, context: NSManagedObjectContext = CoreDataStack.moc) {
        
        self.init(context: context)
        self.front = front
        self.back = back
        self.dateCreated = dateCreated
        self.dateUpdated = dateCreated
        self.identifier = identifier
        self.parentSetID = parentSetID
        self.isImageCard = isImageCard
        self.frontURLString = frontURLString
        self.backURLString = backURLString
    }
    
    convenience init(fromRep cardRep: CardRep, context: NSManagedObjectContext = CoreDataStack.moc) {
        self.init(front: cardRep.front, back: cardRep.back, dateCreated: cardRep.dateCreated, identifier: cardRep.identifier, parentSetID: cardRep.parentSetID, isImageCard: cardRep.isImageCard, frontURLString: cardRep.frontImageURL?.absoluteString, backURLString: cardRep.backImageURL?.absoluteString, context: context)
    }
}
