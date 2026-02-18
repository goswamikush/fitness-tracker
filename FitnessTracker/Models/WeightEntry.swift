//
//  WeightEntry.swift
//  FitnessTracker
//
//  Created by Kush Goswami on 2/17/26.
//

import Foundation
import SwiftData

@Model
final class WeightEntry {
    var date: Date
    var weight: Double
    var unit: String

    init(date: Date, weight: Double, unit: String = "kg") {
        self.date = date
        self.weight = weight
        self.unit = unit
    }
}
