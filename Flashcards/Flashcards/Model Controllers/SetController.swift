//
//  SetController.swift
//  Flashcards
//
//  Created by Samantha Gatt on 9/24/18.
//  Copyright © 2018 Samantha Gatt. All rights reserved.
//

import Foundation
import CoreData
import FirebaseAuth

class SetController {
    
    // MARK: - Initializer
    
    init(dataLoader: NetworkDataLoader = URLSession.shared) {
        self.dataLoader = dataLoader
    }
    
    
    // MARK: - Properties
    
    let dataLoader: NetworkDataLoader
    
    
    // MARK: - CRUD
    
    func create(title: String, dateCreated: Date = Date(), parentGroupID: String, context: NSManagedObjectContext) {
        
        let set = Set(title: title, dateCreated: dateCreated, parentGroupID: parentGroupID, context: context)
        put(set: set)
        saveToPersistentStore(context: context)
    }
    
    func updateTitle(set: Set, title: String, context: NSManagedObjectContext) {
        set.title = title
        set.dateUpdated = Date()
        put(set: set)
        saveToPersistentStore(context: context)
    }
    
    func delete(set: Set, context: NSManagedObjectContext) {
        deleteFromServer(set: set)
        context.delete(set)
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
    
    func loadSingleSet(id: String, context: NSManagedObjectContext) -> Set? {
        let fetchRequest: NSFetchRequest<Set> = Set.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier %@", id)
        
        do {
            return try context.fetch(fetchRequest).first
        } catch {
            NSLog("Error fetching group: \(error)")
            return nil
        }
    }
    
    
    // MARK: - Networking
    
    func put(set: Set, completion: @escaping (Error?) -> Void = { _ in }) {
        
        guard let userUID = Auth.auth().currentUser?.uid,
            let parentGroupID = set.parentGroupID,
            let identifier = set.identifier else { completion(NSError()); return }
        
        let url = GroupController.baseURL
            .appendingPathComponent(userUID)
            .appendingPathComponent("groups")
            .appendingPathComponent(parentGroupID)
            .appendingPathComponent(identifier)
            .appendingPathExtension("json")
        
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        
        do {
            request.httpBody = try JSONEncoder().encode(set)
        } catch {
            NSLog("Error encoding group: \(error)")
            completion(error)
        }
        
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            if let error = error {
                NSLog("Error PUTting data: \(error)")
                completion(error)
                return
            }
            completion(nil)
            }.resume()
    }
    
    func deleteFromServer(set: Set, completion: @escaping (Error?) -> Void = { _ in }) {
        
        guard let userUID = Auth.auth().currentUser?.uid,
            let parentGroupID = set.parentGroupID,
            let identifier = set.identifier else { completion(NSError()); return }
        
        let url = GroupController.baseURL
            .appendingPathComponent(userUID)
            .appendingPathComponent("groups")
            .appendingPathComponent(parentGroupID)
            .appendingPathComponent(identifier)
            .appendingPathExtension("json")
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { (_, _, error) in
            if let error = error {
                NSLog("Error deleting group: \(error)")
                completion(error)
                return
            }
            completion(nil)
        }.resume()
    }
}
