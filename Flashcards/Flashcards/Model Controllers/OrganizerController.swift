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
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", id)
        
        do {
            return try context.fetch(fetchRequest).first
        } catch {
            NSLog("Error fetching group: \(error)")
            return nil
        }
    }
    
    func update(_ organizer: Organizer, from organizerRep: OrganizerRep) {
        organizer.title = organizerRep.title
        organizer.parentGroupID = organizerRep.parentGroupID
    }
    
    func updateOrganizers(from organizerReps: [OrganizerRep], context: NSManagedObjectContext) throws {
        context.performAndWait {
            for organizerRep in organizerReps {
                let organizer = loadSingleOrganizer(id: organizerRep.identifier, context: context)
                if let organizer = organizer {
                    if organizer != organizerRep {
                        self.update(organizer, from: organizerRep)
                    }
                } else {
                    _ = Organizer(fromRep: organizerRep, context: context)
                }
            saveToPersistentStore(context: context)
        }
    }
    }
    
    
    // MARK: - Networking
    
    func createURL(for organizer: Organizer?, isParent: Bool = false) -> URL? {
        
        guard let userUID = Auth.auth().currentUser?.uid else { return nil }
        
        if isParent {
            let url = OrganizerController.baseURL
                .appendingPathComponent("users")
                .appendingPathComponent(userUID)
                .appendingPathComponent("organizers")
                .appendingPathComponent(organizer?.identifier ?? "noParentGroup")
                .appendingPathExtension("json")
            return url
            
        } else {
            guard let parentGroupID = organizer?.parentGroupID,
                let identifier = organizer?.identifier else { return nil }
            
            let url = OrganizerController.baseURL
                .appendingPathComponent("users")
                .appendingPathComponent(userUID)
                .appendingPathComponent("organizers")
                .appendingPathComponent(parentGroupID)
                .appendingPathComponent(identifier)
                .appendingPathExtension("json")
            return url
        }
    }
    
    func fetchOrganizers(in organizer: Organizer?, completion: @escaping (Error?) -> Void = { _ in }) {
        
        guard let url = createURL(for: organizer, isParent: true) else { completion(NSError()); return }
        
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
                let organizers = try JSONDecoder().decode([String: OrganizerRep].self, from: data).compactMap { $0.value }
                let backgroundContext = CoreDataStack.shared.container.newBackgroundContext()
                try self.updateOrganizers(from: organizers, context: backgroundContext)
                completion(nil)
            } catch {
                completion(error)
                return
            }
        }
    }
    
    func put(organizer: Organizer, completion: @escaping (Error?) -> Void = { _ in }) {
        
        guard let url = createURL(for: organizer) else { completion(NSError()); return }
        
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
        
        guard let url = createURL(for: organizer) else { completion(NSError()); return }
        
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
