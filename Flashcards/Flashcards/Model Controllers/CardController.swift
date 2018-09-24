//
//  CardController.swift
//  Flashcards
//
//  Created by Samantha Gatt on 9/24/18.
//  Copyright © 2018 Samantha Gatt. All rights reserved.
//

import Foundation
import CoreData

class CardController {
    
    // MARK: - Initializer
    
    init(set: Set) {
        self.set = set
    }
    
    
    // MARK: - Properties
    
    let set: Set
    var cards: [Card] {
        return loadCardsFromPersistentStore()
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
    func loadCardsFromPersistentStore(context: NSManagedObjectContext = CoreDataStack.moc) -> [Card] {
        let fetchRequest: NSFetchRequest<Card> = Card.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "ANY group = %@", set)
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            NSLog("Error fetching tasks: \(error)")
            return []
        }
    }
}
