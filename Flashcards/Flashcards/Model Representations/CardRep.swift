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
    
    var set: SetRep
}
