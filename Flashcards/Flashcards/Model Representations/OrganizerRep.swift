//
//  OrganizerRep.swift
//  Flashcards
//
//  Created by Samantha Gatt on 9/24/18.
//  Copyright © 2018 Samantha Gatt. All rights reserved.
//

import Foundation

enum OrganizerType: String {
    case group
    case set
}

// Structs can't have recursive attributes since the compiler needs to know how much space to reserve for a given instance
struct OrganizerRep: Codable, Equatable {
    
    // MARK: - Initializer
    
    init(type: OrganizerType, title: String, dateCreated: Date, identifier: String = UUID().uuidString, parentGroupID: String) {
        self.type = type.rawValue
        self.title = title
        self.dateCreated = dateCreated
        self.dateUpdated = dateCreated
        self.identifier = identifier
        self.parentGroupID = parentGroupID
    }
    
    
    // MARK: - Properties
    
    let type: String
    var title: String
    let dateCreated: Date
    var dateUpdated: Date
    var identifier: String
    var parentGroupID: String
}


// MARK: - GroupRep and Group equatability

func == (lhs: OrganizerRep, rhs: Organizer) -> Bool {
    return lhs.title == rhs.title &&
        lhs.dateCreated == rhs.dateCreated &&
        lhs.dateUpdated == rhs.dateUpdated &&
        lhs.identifier == rhs.identifier
}

func == (lhs: Organizer, rhs: OrganizerRep) -> Bool {
    return rhs == lhs
}

func != (lhs: OrganizerRep, rhs: Organizer) -> Bool {
    return !(rhs == lhs)
}

func != (lhs: Organizer, rhs: OrganizerRep) -> Bool {
    return rhs != lhs
}
