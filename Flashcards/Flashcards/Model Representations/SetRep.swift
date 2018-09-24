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
    
    var cardReps: [CardRep]?
    var group: GroupRep
}
