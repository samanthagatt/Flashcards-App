//
//  Set+Encodable.swift
//  Flashcards
//
//  Created by Samantha Gatt on 9/25/18.
//  Copyright © 2018 Samantha Gatt. All rights reserved.
//

import Foundation

extension Set: Encodable {
    
    enum CodingKeys: String, CodingKey {
        case title
        case dateCreated
        case dateUpdated
        case identifier
        case parentGroup
        case cards
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(title, forKey: .title)
        try container.encode(dateCreated, forKey: .dateCreated)
        try container.encode(dateUpdated, forKey: .dateUpdated)
        try container.encode(identifier, forKey: .identifier)
        try container.encodeIfPresent(parentGroup, forKey: .parentGroup)
        
        var arrayOfCards: [Card] = []
        if let cards = cards {
            for card in cards {
                guard let childCard = card as? Card else { continue }
                arrayOfCards.append(childCard)
            }
        }
        if arrayOfCards != [] {
            try container.encode(arrayOfCards, forKey: .cards)
        }
    }
}
