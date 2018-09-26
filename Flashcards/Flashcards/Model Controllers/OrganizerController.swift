//
//  OrganizerController.swift
//  Flashcards
//
//  Created by Samantha Gatt on 9/24/18.
//  Copyright © 2018 Samantha Gatt. All rights reserved.
//

import Foundation
import CoreData
import FirebaseAuth

class OrganizerController {
    static let baseURL = URL(string: "https://samsflashcardsapp.firebaseio.com/")!
    
    // MARK: - Initializer
    
    init(dataLoader: NetworkDataLoader = URLSession.shared) {
        self.dataLoader = dataLoader
    }
    
    
    // MARK: - Properties
    
    let dataLoader: NetworkDataLoader
    
    
    // MARK: - CRUD
    
    func create(type: OrganizerType, title: String, parentGroupID: String, context: NSManagedObjectContext) {
        
        let organizer = Organizer(type: type, title: title, parentGroupID: parentGroupID, context: context)
        put(organizer: organizer)
        saveToPersistentStore(context: context)
    }
    
    func updateTitle(organizer: Organizer, title: String, context: NSManagedObjectContext) {
        organizer.title = title
        organizer.dateUpdated = Date()
        put(organizer: organizer)
        saveToPersistentStore(context: context)
    }
    
    func delete(organizer: Organizer, context: NSManagedObjectContext) {
        deleteFromServer(organizer: organizer)
        context.delete(organizer)
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
    
    func loadSingleOrganizer(id: String, context: NSManagedObjectContext) -> Organizer? {
        let fetchRequest: NSFetchRequest<Organizer> = Organizer.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier %@", id)
        
        do {
            return try context.fetch(fetchRequest).first
        } catch {
            NSLog("Error fetching group: \(error)")
            return nil
        }
    }
    
    
    // MARK: - Networking
    
    func put(organizer: Organizer, completion: @escaping (Error?) -> Void = { _ in }) {
        
        var pathComponent: String?
        if organizer.type == OrganizerType.group.rawValue {
            pathComponent = "groups"
        } else if organizer.type == OrganizerType.set.rawValue {
            pathComponent = "sets"
        }
        
        guard let userUID = Auth.auth().currentUser?.uid,
            let parentGroupID = organizer.parentGroupID,
            let identifier = organizer.identifier,
            let path = pathComponent else { completion(NSError()); return }
        
        let url = OrganizerController.baseURL
            .appendingPathComponent(userUID)
            .appendingPathComponent(path)
            .appendingPathComponent(parentGroupID)
            .appendingPathComponent(identifier)
            .appendingPathExtension("json")
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        
        do {
            request.httpBody = try JSONEncoder().encode(organizer)
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

    func deleteFromServer(organizer: Organizer, completion: @escaping (Error?) -> Void = { _ in }) {
        
        var pathComponent: String?
        if organizer.type == OrganizerType.group.rawValue {
            pathComponent = "groups"
        } else if organizer.type == OrganizerType.set.rawValue {
            pathComponent = "sets"
        }
        
        guard let userUID = Auth.auth().currentUser?.uid,
            let parentGroupID = organizer.parentGroupID,
            let identifier = organizer.identifier,
            let path = pathComponent else { completion(NSError()); return }
        
        let url = OrganizerController.baseURL
            .appendingPathComponent(userUID)
            .appendingPathComponent(path)
            .appendingPathComponent(parentGroupID)
            .appendingPathComponent(identifier)
            .appendingPathExtension("json")
        
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
