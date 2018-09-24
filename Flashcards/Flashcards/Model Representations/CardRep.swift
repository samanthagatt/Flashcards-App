//
//  CardRep.swift
//  Flashcards
//
//  Created by Samantha Gatt on 9/24/18.
//  Copyright © 2018 Samantha Gatt. All rights reserved.
//

import Foundation

struct CardRep: Codable, Equatable {
    var front: String
    var back: String?
    let dateCreated: Date
    var dateUpdated: Date?
    var identifier: String
    
    var setRep: SetRep
}

func == (lhs: CardRep, rhs: Card) -> Bool {
    return
        lhs.front == rhs.front &&
            lhs.back == rhs.back &&
            lhs.dateCreated == rhs.dateCreated &&
            lhs.dateUpdated == rhs.dateUpdated // &&
//            lhs.set == rhs.set
}

func == (lhs: Card, rhs: CardRep) -> Bool {
    return rhs == lhs
}

func != (lhs: CardRep, rhs: Card) -> Bool {
    return !(rhs == lhs)
}

func != (lhs: Card, rhs: CardRep) -> Bool {
    return rhs != lhs
}
