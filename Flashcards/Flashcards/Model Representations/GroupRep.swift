//
//  GroupRep.swift
//  Flashcards
//
//  Created by Samantha Gatt on 9/24/18.
//  Copyright © 2018 Samantha Gatt. All rights reserved.
//

import Foundation

class GroupRep: Codable {
    var title: String
    let dateCreated: Date
    var dateUpdated: Date?
    
    var sets: [SetRep]?
    var groups: [GroupRep]?
    var group: GroupRep?
    
    
}

extension GroupRep: Equatable {
    static func == (lhs: GroupRep, rhs: GroupRep) -> Bool {
        return
            lhs.sets == rhs.sets &&
                lhs.groups == rhs.groups &&
                lhs.group == rhs.group
    }
}
