//
//  GroupRep.swift
//  Flashcards
//
//  Created by Samantha Gatt on 9/24/18.
//  Copyright © 2018 Samantha Gatt. All rights reserved.
//

import Foundation

// Structs can't have recursive attributes since the compiler needs to know how much space to reserve for a given instance
class GroupRep: Codable {
    
    // MARK: - Initializer
    
    init(title: String, dateCreated: Date, urlString: String, identifier: String = UUID().uuidString) {
        self.title = title
        self.dateCreated = dateCreated
        self.dateUpdated = dateCreated
        self.urlString = urlString
        self.identifier = identifier
    }
    
    
    // MARK: - Properties
    
    var title: String
    let dateCreated: Date
    var dateUpdated: Date
    var urlString: String
    var identifier: String
    
    var parentGroupRep: GroupRep?
    var setReps: [SetRep]?
    var groupReps: [GroupRep]?
}


// MARK: - GroupRep Equatable extension

extension GroupRep: Equatable {
    static func == (lhs: GroupRep, rhs: GroupRep) -> Bool {
        return
            lhs.setReps == rhs.setReps &&
                lhs.groupReps == rhs.groupReps &&
                lhs.parentGroupRep == rhs.parentGroupRep
    }
}


// MARK: - GroupRep and Group equatability

func == (lhs: GroupRep, rhs: Group) -> Bool {
    return
        lhs.title == rhs.title &&
        lhs.dateCreated == rhs.dateCreated &&
        lhs.dateUpdated == rhs.dateUpdated // &&
//        lhs.parentGroupRep == rhs.parentGroup &&
//        NSSet(array: lhs.setReps) == rhs.sets &&
//        NSSet(array: lhs.groupReps) == rhs.groups
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
