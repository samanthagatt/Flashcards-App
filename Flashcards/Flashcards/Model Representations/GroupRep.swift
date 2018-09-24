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
    var title: String
    let dateCreated: Date
    var dateUpdated: Date?
    
    var sets: [SetRep]?
    var groups: [GroupRep]?
    var parentGroup: GroupRep?
    
    
}

extension GroupRep: Equatable {
    static func == (lhs: GroupRep, rhs: GroupRep) -> Bool {
        return
            lhs.sets == rhs.sets &&
                lhs.groups == rhs.groups &&
                lhs.parentGroup == rhs.parentGroup
    }
}
