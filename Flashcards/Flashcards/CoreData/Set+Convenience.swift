//
//  Set+Convenience.swift
//  Flashcards
//
//  Created by Samantha Gatt on 9/24/18.
//  Copyright © 2018 Samantha Gatt. All rights reserved.
//

import Foundation
import CoreData

extension Set {
    convenience init(title: String, dateCreated: Date = Date(), identifier: String = UUID().uuidString, context: NSManagedObjectContext = CoreDataStack.moc) {
        
        self.init(context: context)
        self.title = title
        self.dateCreated = dateCreated
        self.dateUpdated = dateCreated
        self.identifier = identifier
    }
    
    convenience init?(fromRep setRep: SetRep, context: NSManagedObjectContext = CoreDataStack.moc) {
        self.init(title: setRep.title, dateCreated: setRep.dateCreated, identifier: setRep.identifier, context: context)
    }
}
