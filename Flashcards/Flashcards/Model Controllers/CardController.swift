//
//  CardController.swift
//  Flashcards
//
//  Created by Samantha Gatt on 9/24/18.
//  Copyright © 2018 Samantha Gatt. All rights reserved.
//

import Foundation
import CoreData
import FirebaseAuth

class CardController {
    
    // MARK: - Initializer
    
    init(dataLoader: NetworkDataLoader = URLSession.shared) {
        self.dataLoader = dataLoader
    }
    
    
    // MARK: - Properties
    
    let dataLoader: NetworkDataLoader
    
    
    // MARK: - CRUD
    
    func create(front: String = "", back: String = "", dateCreated: Date = Date(), parentSetID: String, context: NSManagedObjectContext) {
        
        let card = Card(front: front, back: back, parentSetID: parentSetID, context: context)
        put(card: card)
        saveToPersistentStore(context: context)
    }
    
    func update(card: Card, front: String? = nil, back: String? = nil, context: NSManagedObjectContext) {
        if let front = front {
            card.front = front
        }
        if let back = back {
            card.back = back
        }
        card.dateUpdated = Date()
        put(card: card)
        saveToPersistentStore(context: context)
    }
    
    func delete(card: Card, context: NSManagedObjectContext) {
        deleteFromServer(card: card)
        context.delete(card)
        saveToPersistentStore(context: context)
    }
    
    
    // MARK: - Core Data
    
    func saveToPersistentStore(context: NSManagedObjectContext) {
        context.performAndWait {
            do {
                try context.save()
            }
            catch {
                NSLog("Error saving entry: \(error)")
            }
        }
    }
    
    func loadSingleCard(id: String, context: NSManagedObjectContext) -> Card? {
        let fetchRequest: NSFetchRequest<Card> = Card.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", id)
        
        do {
            return try context.fetch(fetchRequest).first
        } catch {
            NSLog("Error fetching group: \(error)")
            return nil
        }
    }
    
    func update(_ card: Card, from cardRep: CardRep) {
        card.front = cardRep.front
        card.back = cardRep.back
        card.parentSetID = cardRep.parentSetID
    }
    
    func updateCards(from cardReps: [CardRep], context: NSManagedObjectContext) throws {
        context.performAndWait {
            for cardRep in cardReps {
                let card = loadSingleCard(id: cardRep.identifier, context: context)
                if let card = card {
                    if card != cardRep {
                        self.update(card, from: cardRep)
                    }
                } else {
                    _ = Card(fromRep: cardRep, context: context)
                }
                saveToPersistentStore(context: context)
            }
        }
    }
    
    
    // MARK: - Networking
    
    func createURL(for card: Card? = nil, from parentSet: Organizer? = nil) -> URL? {
        
        guard let userUID = Auth.auth().currentUser?.uid else { return nil }
        
        if parentSet == nil {
            guard let parentSetID = card?.parentSetID,
                let identifier = card?.identifier else { return nil }
            
            let url = OrganizerController.baseURL
                .appendingPathComponent("users")
                .appendingPathComponent(userUID)
                .appendingPathComponent("cards")
                .appendingPathComponent(parentSetID)
                .appendingPathComponent(identifier)
                .appendingPathExtension("json")
            
            return url
        } else {
            guard let setID = parentSet?.identifier else { return nil }
            let url = OrganizerController.baseURL
                .appendingPathComponent("users")
                .appendingPathComponent(userUID)
                .appendingPathComponent("cards")
                .appendingPathComponent(setID)
                .appendingPathExtension("json")
            return url
        }
    }
    
    func fetchCards(in set: Organizer?, completion: @escaping (Error?) -> Void = { _ in }) {
        
        guard let url = createURL(from: set) else { completion(NSError()); return }
        
        dataLoader.loadData(from: url) { (data, error) in
            
            if let error = error {
                NSLog("Error fetching entries: \(error)")
                completion(error)
                return
            }
            
            guard let data = data else {
                completion(error)
                return
            }
            
            do {
                let cardReps = try JSONDecoder().decode([String: CardRep].self, from: data).compactMap { $0.value }
                let backgroundContext = CoreDataStack.shared.container.newBackgroundContext()
                try self.updateCards(from: cardReps, context: backgroundContext)
                completion(nil)
            } catch {
                completion(error)
                return
            }
        }
    }
    
    func put(card: Card, completion: @escaping (Error?) -> Void = { _ in }) {
        
        guard let url = createURL(for: card) else { completion(NSError()); return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        
        do {
            request.httpBody = try JSONEncoder().encode(card)
        } catch {
            NSLog("Error encoding group: \(error)")
            completion(error)
        }
        
        dataLoader.uploadData(to: request) { (_, error) in
            if let error = error {
                NSLog("Error PUTting data: \(error)")
                completion(error)
                return
            }
            completion(nil)
        }
    }
    
    func deleteFromServer(card: Card, completion: @escaping (Error?) -> Void = { _ in }) {
        
        guard let url = createURL(for: card) else { completion(NSError()); return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        dataLoader.deleteData(with: request) { (_, error) in
            if let error = error {
                NSLog("Error deleting group: \(error)")
                completion(error)
                return
            }
            completion(nil)
        }
    }
}
