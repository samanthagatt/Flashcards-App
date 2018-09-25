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
    
    init(parentGroup: Group? = nil, dataLoader: NetworkDataLoader = URLSession.shared) {
        self.parentGroup = parentGroup
        self.dataLoader = dataLoader
    }
    
    
    // MARK: - Properties
    
    let parentGroup: Group?
    let dataLoader: NetworkDataLoader
    var groups: [Group] {
        return loadGroupsFromPersistentStore(context: CoreDataStack.moc)
    }
    
    
    // MARK: - CRUD
    
    func create(title: String, dateCreated: Date = Date(), parentGroup: Group?, context: NSManagedObjectContext) {
        
        guard let userUID = Auth.auth().currentUser?.uid else { return }
        var url: URL
        
        if let parentGroup = parentGroup,
            let parentURLString = parentGroup.urlString,
            let parentURL = URL(string: parentURLString) {
           
            url = parentURL
                .appendingPathComponent(title)
                .appendingPathExtension("json")
        } else {
            url = GroupController.baseURL
                .appendingPathComponent(userUID)
                .appendingPathComponent(title)
                .appendingPathExtension("json")
        }
        
        let group = Group(title: title, dateCreated: dateCreated, urlString: url.absoluteString, context: context)
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
    
    // probably move this to view controllers as fetched results controller
    func loadGroupsFromPersistentStore(context: NSManagedObjectContext) -> [Group] {
        let fetchRequest: NSFetchRequest<Group> = Group.fetchRequest()
        if let parentGroup = self.parentGroup {
            fetchRequest.predicate = NSPredicate(format: "ANY parentGroup = %@", parentGroup)
        } else {
            fetchRequest.predicate = NSPredicate(format: "ANY parentGroup == nil")
        }
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            NSLog("Error fetching groups: \(error)")
            return []
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
        guard let url = group.urlString,
            let requestURL = URL(string: url) else { completion(NSError()); return }
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"
        
        do {
            request.httpBody = try JSONEncoder().encode(group)
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

    func deleteFromServer(group: Group, completion: @escaping (Error?) -> Void = { _ in }) {
        guard let url = group.urlString,
            let requestURL = URL(string: url) else { completion(NSError()); return }
        
        var request = URLRequest(url: requestURL)
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
