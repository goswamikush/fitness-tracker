//
//  WaterEntry.swift
//  FitnessTracker
//

import Foundation
import SwiftData

@Model
final class WaterEntry {
    var date: Date
    var amountMl: Double

    init(date: Date, amountMl: Double) {
        self.date = date
        self.amountMl = amountMl
    }
}
