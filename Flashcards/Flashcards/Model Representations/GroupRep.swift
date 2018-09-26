//
//  GroupRep.swift
//  Flashcards
//
//  Created by Samantha Gatt on 9/24/18.
//  Copyright © 2018 Samantha Gatt. All rights reserved.
//

import Foundation

// Structs can't have recursive attributes since the compiler needs to know how much space to reserve for a given instance
struct GroupRep: Codable, Equatable {
    
    // MARK: - Initializer
    
    init(title: String, dateCreated: Date, identifier: String = UUID().uuidString, parentGroupID: String) {
        self.title = title
        self.dateCreated = dateCreated
        self.dateUpdated = dateCreated
        self.identifier = identifier
        self.parentGroupID = parentGroupID
    }
    
    
    // MARK: - Properties
    
    var title: String
    let dateCreated: Date
    var dateUpdated: Date
    var identifier: String
    var parentGroupID: String
}


// MARK: - GroupRep and Group equatability

func == (lhs: GroupRep, rhs: Group) -> Bool {
    return lhs.title == rhs.title &&
        lhs.dateCreated == rhs.dateCreated &&
        lhs.dateUpdated == rhs.dateUpdated &&
        lhs.identifier == rhs.identifier
}

func == (lhs: Group, rhs: GroupRep) -> Bool {
    return rhs == lhs
}

func != (lhs: GroupRep, rhs: Group) -> Bool {
    return !(rhs == lhs)
}

func != (lhs: Group, rhs: GroupRep) -> Bool {
    return rhs != lhs
}
