//
//  Group+Encodable.swift
//  Flashcards
//
//  Created by Samantha Gatt on 9/25/18.
//  Copyright © 2018 Samantha Gatt. All rights reserved.
//

import Foundation

extension Group: Encodable {
    
    enum CodingKeys: String, CodingKey {
        case title
        case dateCreated
        case dateUpdated
        case urlString
        case identifier
        case parentGroup
        case sets
        case groups
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(title, forKey: .title)
        try container.encode(dateCreated, forKey: .dateCreated)
        try container.encode(dateUpdated, forKey: .dateUpdated)
        try container.encode(urlString, forKey: .urlString)
        try container.encode(identifier, forKey: .identifier)
        try container.encodeIfPresent(parentGroup, forKey: .parentGroup)
        
        var arrayOfSets: [Set] = []
        if let sets = sets {
            for set in sets {
                guard let childSet = set as? Set else { continue }
                arrayOfSets.append(childSet)
            }
        }
        if arrayOfSets != [] {
            try container.encode(arrayOfSets, forKey: .sets)
        }
        
        var arrayOfGroups: [Group] = []
        if let groups = groups {
            for group in groups {
                guard let childGroup = group as? Group else { continue }
                arrayOfGroups.append(childGroup)
            }
        }
        if arrayOfGroups != [] {
            try container.encode(arrayOfGroups, forKey: .groups)
        }
    }
}
