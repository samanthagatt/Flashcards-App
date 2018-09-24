//
//  SetRep.swift
//  Flashcards
//
//  Created by Samantha Gatt on 9/24/18.
//  Copyright © 2018 Samantha Gatt. All rights reserved.
//

import Foundation

struct SetRep: Codable, Equatable {
    
    var title: String
    let dateCreated: Date
    var dateUpdated: Date?
    var identifier: String
    
    var groupRep: GroupRep?
    var cardReps: [CardRep]?
}


// MARK: - SetRep and Set equatability

func == (lhs: SetRep, rhs: Set) -> Bool {
    return
        lhs.title == rhs.title &&
            lhs.dateCreated == rhs.dateCreated &&
            lhs.dateUpdated == rhs.dateUpdated // &&
//            lhs.groupRep == rhs.group &&
//            NSSet(array: lhs.cardReps) == rhs.cards
}

func == (lhs: Set, rhs: SetRep) -> Bool {
    return rhs == lhs
}

func != (lhs: SetRep, rhs: Set) -> Bool {
    return !(rhs == lhs)
}

func != (lhs: Set, rhs: SetRep) -> Bool {
    return rhs != lhs
}
