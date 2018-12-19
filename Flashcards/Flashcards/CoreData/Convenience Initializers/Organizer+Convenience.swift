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
    
    /**
     Creates an `Organizer` instance with all of its properties
          
     - Author: Samantha Gatt
     
     - Parameters:
         - type: The type of `Organizer` being initalized in the form of an `OrganizerType` (i.e. a `Group` or a `Set`)
         - title: The title of the organizer as a `String`
         - dateCreated: The date the organizer was created. By default the current date is used
         - identifier: A *unique* identifer. By default a new `UUID` string is created
         - parentGroupID: The identifier of the `Organizer`'s parent `Group`. If `Organizer` doesn't have a parent, the `String`, *"noParentGroup"*, should be used
         - context: The context on which this `Orgainizer` should be created
     
     */
    convenience init(type: OrganizerType, title: String, dateCreated: Date = Date(), identifier: String = UUID().uuidString, parentGroupID: String, context: NSManagedObjectContext = CoreDataStack.moc) {
        
        self.init(context: context)
        self.type = type.rawValue
        self.title = title
        self.dateCreated = dateCreated
        self.dateUpdated = dateCreated
        self.identifier = identifier
        self.parentGroupID = parentGroupID
    }
    
    /**
     Creates an `Organizer` instance based off of an `OrganizerRep`
     
     - Author: Samantha Gatt
     
     - Parameters:
         - organizerRep: The `OrganizerRep` containing all the properties that this instance of `Organizer` should be created with
         - context: The context on which this `Organizer` should be created
     */
    convenience init?(fromRep organizerRep: OrganizerRep, context: NSManagedObjectContext = CoreDataStack.moc) {
        
        guard let type = OrganizerType(rawValue: organizerRep.type) else { return nil }
        
        self.init(type: type, title: organizerRep.title, dateCreated: organizerRep.dateCreated, identifier: organizerRep.identifier, parentGroupID: organizerRep.parentGroupID, context: context)
    }
}
