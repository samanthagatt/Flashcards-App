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
    
    func create(title: String, dateCreated: Date = Date(), parentGroupID: String, context: NSManagedObjectContext) {
        
        let card = Card(parentSetID: parentGroupID, context: context)
        put(card: card)
        saveToPersistentStore(context: context)
    }
    
    func update(card: Card, front: String?, back: String?, context: NSManagedObjectContext) {
        card.front = front
        card.back = back
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
        fetchRequest.predicate = NSPredicate(format: "identifier %@", id)
        
        do {
            return try context.fetch(fetchRequest).first
        } catch {
            NSLog("Error fetching group: \(error)")
            return nil
        }
    }
    
    
    // MARK: - Networking
    
    func put(card: Card, completion: @escaping (Error?) -> Void = { _ in }) {
        
        guard let userUID = Auth.auth().currentUser?.uid,
            let parentSetID = card.parentSetID,
            let identifier = card.identifier else { completion(NSError()); return }
        
        let url = GroupController.baseURL
            .appendingPathComponent(userUID)
            .appendingPathComponent("groups")
            .appendingPathComponent(parentSetID)
            .appendingPathComponent(identifier)
            .appendingPathExtension("json")
        
        
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
        
        guard let userUID = Auth.auth().currentUser?.uid,
            let parentSetID = card.parentSetID,
            let identifier = card.identifier else { completion(NSError()); return }
        
        let url = GroupController.baseURL
            .appendingPathComponent(userUID)
            .appendingPathComponent("groups")
            .appendingPathComponent(parentSetID)
            .appendingPathComponent(identifier)
            .appendingPathExtension("json")
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        dataLoader.uploadData(to: request) { (_, error) in
            if let error = error {
                NSLog("Error deleting group: \(error)")
                completion(error)
                return
            }
            completion(nil)
        }
    }
}
