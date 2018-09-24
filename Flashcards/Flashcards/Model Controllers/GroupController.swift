//
//  GroupController.swift
//  Flashcards
//
//  Created by Samantha Gatt on 9/24/18.
//  Copyright © 2018 Samantha Gatt. All rights reserved.
//

import Foundation
import CoreData

let baseURL = URL(string: "https://samsflashcardsapp.firebaseio.com/")!

class GroupController {
    
    // MARK: - Initializer
    
    init(parentGroup: Group? = nil, dataLoader: NetworkDataLoader = URLSession.shared) {
        self.parentGroup = parentGroup
        self.dataLoader = dataLoader
    }
    
    
    // MARK: - Properties
    
    let parentGroup: Group?
    let dataLoader: NetworkDataLoader
    var groups: [Group] {
        return loadGroupsFromPersistentStore()
    }
    
    
    // MARK: - CRUD
    
    func create(title: String, dateCreated: Date = Date(), parentGroup: Group? = nil, context: NSManagedObjectContext) {
        _ = Group(title: title, dateCreated: dateCreated, parentGroup: parentGroup, context: context)
        
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
