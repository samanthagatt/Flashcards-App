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
    convenience init(title: String, dateCreated: Date = Date(), parentGroup: Group?, context: NSManagedObjectContext = CoreDataStack.moc) {
        
        self.init(context: context)
        self.title = title
        self.dateCreated = dateCreated
        self.dateUpdated = dateCreated
        self.parentGroup = parentGroup
        self.sets = nil
        self.groups = nil
    }
}
