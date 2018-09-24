//
//  GroupController.swift
//  Flashcards
//
//  Created by Samantha Gatt on 9/24/18.
//  Copyright © 2018 Samantha Gatt. All rights reserved.
//

import Foundation
import CoreData

class GroupController {
    
    // MARK: - Initializer
    
    init(parentGroup: Group? = nil) {
        self.parentGroup = parentGroup
    }
    
    
    // MARK: - Properties
    
    let parentGroup: Group?
    var groups: [Group] {
        return loadGroupsFromPersistentStore()
    }
    
    
    // MARK: - Functions
    
    func saveToPersistentStore(context: NSManagedObjectContext = CoreDataStack.moc) {
        context.performAndWait {
            do {
                try context.save()
            }
            catch {
                NSLog("Error saving entry: \(error)")
            }
        }
    }
    
    // probably move this to view controllers as fetched results controller
    func loadGroupsFromPersistentStore(context: NSManagedObjectContext = CoreDataStack.moc) -> [Group] {
        let fetchRequest: NSFetchRequest<Group> = Group.fetchRequest()
        if let parentGroup = self.parentGroup {
            fetchRequest.predicate = NSPredicate(format: "ANY parentGroup = %@", parentGroup)
        } else {
            fetchRequest.predicate = NSPredicate(format: "ANY parentGroup == nil")
        }
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            NSLog("Error fetching tasks: \(error)")
            return []
        }
    }
}
