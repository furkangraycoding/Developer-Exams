//
//  Item.swift
//  Developer Exams
//
//  Created by furkan gurcay on 12.01.2025.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
