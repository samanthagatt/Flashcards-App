//
//  Group+Convenience.swift
//  Flashcards
//
//  Created by Samantha Gatt on 9/24/18.
//  Copyright © 2018 Samantha Gatt. All rights reserved.
//

import Foundation
import CoreData

extension Group {
    convenience init(title: String, dateCreated: Date = Date(), identifier: String = UUID().uuidString, parentGroupID: String, context: NSManagedObjectContext = CoreDataStack.moc) {
        
        self.init(context: context)
        self.title = title
        self.dateCreated = dateCreated
        self.dateUpdated = dateCreated
        self.identifier = identifier
        self.parentGroupID = parentGroupID
    }
    
    convenience init(fromRep groupRep: GroupRep, context: NSManagedObjectContext = CoreDataStack.moc) {
        
        self.init(title: groupRep.title, dateCreated: groupRep.dateCreated, identifier: groupRep.identifier, parentGroupID: groupRep.parentGroupID, context: context)
    }
}
