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
import FirebaseStorage

class CardController {
    
    // MARK: - Initializer
    
    init(dataLoader: NetworkDataLoader = URLSession.shared) {
        self.dataLoader = dataLoader
    }
    
    
    // MARK: - Properties
    
    let dataLoader: NetworkDataLoader
    
    
    // MARK: - CRUD
    
    func create(front: String = "", back: String = "", dateCreated: Date = Date(), parentSetID: String, isImageCard: Bool = false, context: NSManagedObjectContext) {
        
        let card = Card(front: front, back: back, parentSetID: parentSetID, isImageCard: isImageCard, context: context)
        put(card: card)
        saveToPersistentStore(context: context)
    }
    
    func update(card: Card, front: String? = nil, back: String? = nil, frontImageData: Data? = nil, backImageData: Data? = nil, context: NSManagedObjectContext) {
        if let front = front {
            card.front = front
        }
        if let back = back {
            card.back = back
        }
        card.dateUpdated = Date()
        
        // TODO: Come back and evaluate if I should make it a weak refrence to self to reduce risk of retain cycle
        // TODO: Clean up this code, very DRY
        // TODO: Error handling, if both image data's are not nil, card only gets put to data base if both storages succeed
        if let frontImageData = frontImageData {
            storeImage(data: frontImageData, for: card, isFront: true) { (url, error) in
                if let error = error {
                    NSLog("Error storing image: \(error)")
                    return
                }
                
                guard let urlString = url?.absoluteString else {
                    NSLog("No url was returned from storing image")
                    return
                }
                
                card.frontURLString = urlString
                
                if let backImageData = backImageData {
                    self.storeImage(data: backImageData, for: card, isFront: false) { (url, error) in
                        if let error = error {
                            NSLog("Error storing image: \(error)")
                            return
                        }
                        
                        guard let urlString = url?.absoluteString else {
                            NSLog("No url was returned from storing image")
                            return
                        }
                        
                        card.backURLString = urlString
                        
                        self.put(card: card)
                        self.saveToPersistentStore(context: context)
                    }
                }
            }
        } else if let backImageData = backImageData {
            storeImage(data: backImageData, for: card, isFront: false) { (url, error) in
                if let error = error {
                    NSLog("Error storing image: \(error)")
                    return
                }
                
                guard let urlString = url?.absoluteString else {
                    NSLog("No url was returned from storing image")
                    return
                }
                
                card.backURLString = urlString
                
                self.put(card: card)
                self.saveToPersistentStore(context: context)
            }
        } else {
            put(card: card)
            saveToPersistentStore(context: context)
        }
    }
    
    func delete(card: Card, context: NSManagedObjectContext) {
        deleteFromServer(card: card)
        context.delete(card)
        saveToPersistentStore(context: context)
    }
    
    
    // MARK: - Core Data
    
    private func saveToPersistentStore(context: NSManagedObjectContext) {
        context.performAndWait {
            do {
                try context.save()
            }
            catch {
                NSLog("Error saving entry: \(error)")
            }
        }
    }
    
    private func loadSingleCard(id: String, context: NSManagedObjectContext) -> Card? {
        let fetchRequest: NSFetchRequest<Card> = Card.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", id)
        
        do {
            return try context.fetch(fetchRequest).first
        } catch {
            NSLog("Error fetching group: \(error)")
            return nil
        }
    }
    
    private func update(_ card: Card, from cardRep: CardRep) {
        card.front = cardRep.front
        card.back = cardRep.back
        card.parentSetID = cardRep.parentSetID
    }
    
    private func updateCards(from cardReps: [CardRep], context: NSManagedObjectContext) throws {
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
    
    private func createURL(for card: Card? = nil, from parentSet: Organizer? = nil) -> URL? {
        
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
    
    private func createStorageRef(for card: Card, isFront: Bool) -> StorageReference? {
        
        guard let userUID = Auth.auth().currentUser?.uid else { return nil }
        
        return Storage.storage().reference().child("users").child(userUID).child("cards").child(card.identifier ?? "noIdentifier").child(isFront ? "front.png" : "back.png")
    }
    
    public func fetchCards(in set: Organizer?, completion: @escaping (Error?) -> Void = { _ in }) {
        
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
    
    /*
     po error
     ▿ DecodingError
     ▿ keyNotFound : 2 elements
     - .0 : CodingKeys(stringValue: "frontText", intValue: nil)
     ▿ .1 : Context
     ▿ codingPath : 1 element
     ▿ 0 : _DictionaryCodingKey(stringValue: "7580B62C-0CFD-4DE5-B09E-251BCD17A26E", intValue: nil)
     - stringValue : "7580B62C-0CFD-4DE5-B09E-251BCD17A26E"
     - intValue : nil
     - debugDescription : "No value associated with key CodingKeys(stringValue: \"frontText\", intValue: nil) (\"frontText\")."
     - underlyingError : nil
     */
    
    private func storeImage(data: Data, for card: Card, isFront: Bool, completion: @escaping (URL?, Error?) -> Void) {
        guard let storageRef = createStorageRef(for: card, isFront: isFront) else { return }
        
        storageRef.putData(data, metadata: nil) { (_, error) in
            if let error = error {
                NSLog("Error storing image: \(error)")
                completion(nil, error)
                return
            }
            
            storageRef.downloadURL() { url, error in
                if let error = error {
                    NSLog("Error getting url for stored image: \(error)")
                    completion(nil, error)
                    return
                }
                
                guard let url = url else {
                    NSLog("No url returned from storing image")
                    completion(nil, NSError())
                    return
                }
                
                completion(url, nil)
            }
        }
    }
    
    private func put(card: Card, completion: @escaping (Error?) -> Void = { _ in }) {
        
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
    
    private func deleteFromServer(card: Card, completion: @escaping (Error?) -> Void = { _ in }) {
        
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
