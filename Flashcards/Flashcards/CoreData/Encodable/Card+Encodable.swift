//
//  Card+Encodable.swift
//  Flashcards
//
//  Created by Samantha Gatt on 9/25/18.
//  Copyright © 2018 Samantha Gatt. All rights reserved.
//

import Foundation

extension Card: Encodable {
    
    enum CodingKeys: String, CodingKey {
        case front
        case back
        case dateCreated
        case dateUpdated
        case identifier
        case parentSetID
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(front, forKey: .front)
        try container.encodeIfPresent(back, forKey: .back)
        try container.encode(dateCreated, forKey: .dateCreated)
        try container.encode(dateUpdated, forKey: .dateUpdated)
        try container.encode(identifier, forKey: .identifier)
        try container.encode(parentSetID, forKey: .parentSetID)
    }
}
