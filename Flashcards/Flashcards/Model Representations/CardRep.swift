//
//  CardRep.swift
//  Flashcards
//
//  Created by Samantha Gatt on 9/24/18.
//  Copyright © 2018 Samantha Gatt. All rights reserved.
//

import Foundation

enum CardType: String {
    case text
    case image
}

struct CardRep: Codable, Equatable {
    
    var frontText: String
    var backText: String
    let dateCreated: Date
    var dateUpdated: Date
    var identifier: String
    var parentSetID: String
    var frontImageURL: URL?
    var backImageURL: URL?
    var isImageCard: Bool
}


// MARK: - CardRep and Card equatability

func == (lhs: CardRep, rhs: Card) -> Bool {
    return
        lhs.frontText == rhs.front &&
            lhs.backText == rhs.back &&
            lhs.dateCreated == rhs.dateCreated &&
            lhs.dateUpdated == rhs.dateUpdated &&
            lhs.parentSetID == rhs.parentSetID &&
            lhs.isImageCard == rhs.isImageCard &&
            lhs.frontImageURL?.absoluteString == rhs.frontURLString &&
            lhs.backImageURL?.absoluteString == rhs.backURLString
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
