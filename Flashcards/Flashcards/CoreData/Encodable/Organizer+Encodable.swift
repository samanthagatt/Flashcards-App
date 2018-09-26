//
//  Organizer+Encodable.swift
//  Flashcards
//
//  Created by Samantha Gatt on 9/25/18.
//  Copyright © 2018 Samantha Gatt. All rights reserved.
//

import Foundation

extension Organizer: Encodable {
    
    enum CodingKeys: String, CodingKey {
        case type
        case title
        case dateCreated
        case dateUpdated
        case urlString
        case identifier
        case parentGroupID
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(type, forKey: .type)
        try container.encode(title, forKey: .title)
        try container.encode(dateCreated, forKey: .dateCreated)
        try container.encode(dateUpdated, forKey: .dateUpdated)
        try container.encode(identifier, forKey: .identifier)
        try container.encode(parentGroupID, forKey: .parentGroupID)
    }
}
