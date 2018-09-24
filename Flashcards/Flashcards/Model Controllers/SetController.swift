//
//  SetController.swift
//  Flashcards
//
//  Created by Samantha Gatt on 9/24/18.
//  Copyright © 2018 Samantha Gatt. All rights reserved.
//

import Foundation
import CoreData

class SetController {
    
    // MARK: - Initializer
    
    init(group: Group? = nil, dataLoader: NetworkDataLoader = URLSession.shared) {
        self.group = group
    }
    
    
    // MARK: - Properties
    
    let group: Group?
    var sets: [Set] {
        return loadSetsFromPersistentStore()
    }
    
    
    // MARK: - CRUD
    
    func create() {
        
    }
    
    func update() {
        
    }
    
    func delete() {
        
    }
    
    
    // MARK: - Core Data
    
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
    func loadSetsFromPersistentStore(context: NSManagedObjectContext = CoreDataStack.moc) -> [Set] {
        let fetchRequest: NSFetchRequest<Set> = Set.fetchRequest()
        if let group = self.group {
            fetchRequest.predicate = NSPredicate(format: "ANY group = %@", group)
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
