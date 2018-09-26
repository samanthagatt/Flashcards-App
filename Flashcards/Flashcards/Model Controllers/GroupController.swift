//
//  GroupController.swift
//  Flashcards
//
//  Created by Samantha Gatt on 9/24/18.
//  Copyright © 2018 Samantha Gatt. All rights reserved.
//

import Foundation
import CoreData
import FirebaseAuth

class GroupController {
    static let baseURL = URL(string: "https://samsflashcardsapp.firebaseio.com/")!
    
    // MARK: - Initializer
    
    init(dataLoader: NetworkDataLoader = URLSession.shared) {
        self.dataLoader = dataLoader
    }
    
    
    // MARK: - Properties
    
    let dataLoader: NetworkDataLoader
    
    
    // MARK: - CRUD
    
    func create(title: String, parentGroupID: String, context: NSManagedObjectContext) {
        
        let group = Group(title: title, parentGroupID: parentGroupID, context: context)
        put(group: group)
        saveToPersistentStore(context: context)
    }
    
    func updateTitle(group: Group, title: String, context: NSManagedObjectContext) {
        group.title = title
        group.dateUpdated = Date()
        put(group: group)
        saveToPersistentStore(context: context)
    }
    
    func delete(group: Group, context: NSManagedObjectContext) {
        deleteFromServer(group: group)
        context.delete(group)
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
    
    func loadSingleGroup(id: String, context: NSManagedObjectContext) -> Group? {
        let fetchRequest: NSFetchRequest<Group> = Group.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier %@", id)
        
        do {
            return try context.fetch(fetchRequest).first
        } catch {
            NSLog("Error fetching group: \(error)")
            return nil
        }
    }
    
    
    // MARK: - Networking
    
    func put(group: Group, completion: @escaping (Error?) -> Void = { _ in }) {
        
        guard let userUID = Auth.auth().currentUser?.uid,
            let parentGroupID = group.parentGroupID,
            let identifier = group.identifier else { completion(NSError()); return }
        
        let url = GroupController.baseURL
            .appendingPathComponent(userUID)
            .appendingPathComponent("groups")
            .appendingPathComponent(parentGroupID)
            .appendingPathComponent(identifier)
            .appendingPathExtension("json")
        
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        
        do {
            request.httpBody = try JSONEncoder().encode(group)
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

    func deleteFromServer(group: Group, completion: @escaping (Error?) -> Void = { _ in }) {
        
        guard let userUID = Auth.auth().currentUser?.uid,
            let parentGroupID = group.parentGroupID,
            let identifier = group.identifier else { completion(NSError()); return }
        
        let url = GroupController.baseURL
            .appendingPathComponent(userUID)
            .appendingPathComponent("groups")
            .appendingPathComponent(parentGroupID)
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
