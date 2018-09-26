//
//  Organizer+Convenience.swift
//  Flashcards
//
//  Created by Samantha Gatt on 9/24/18.
//  Copyright © 2018 Samantha Gatt. All rights reserved.
//

import Foundation
import CoreData

extension Organizer {
    convenience init(type: OrganizerType, title: String, dateCreated: Date = Date(), identifier: String = UUID().uuidString, parentGroupID: String, context: NSManagedObjectContext = CoreDataStack.moc) {
        
        self.init(context: context)
        self.type = type.rawValue
        self.title = title
        self.dateCreated = dateCreated
        self.dateUpdated = dateCreated
        self.identifier = identifier
        self.parentGroupID = parentGroupID
    }
    
    convenience init?(fromRep organizerRep: OrganizerRep, context: NSManagedObjectContext = CoreDataStack.moc) {
        
        guard let type = OrganizerType(rawValue: organizerRep.type) else { return nil }
        
        self.init(type: type, title: organizerRep.title, dateCreated: organizerRep.dateCreated, identifier: organizerRep.identifier, parentGroupID: organizerRep.parentGroupID, context: context)
    }
}
