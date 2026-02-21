//
//  UserGoals.swift
//  FitnessTracker
//

import Foundation
import Observation

@Observable
final class UserGoals {
    var calorieGoal: Int
    var proteinGoal: Int
    var carbsGoal: Int
    var fatGoal: Int

    var macroCalories: Int { proteinGoal * 4 + carbsGoal * 4 + fatGoal * 9 }

    init() {
        let d = UserDefaults.standard
        calorieGoal = (d.object(forKey: "ug_calorieGoal") as? Int) ?? 2400
        proteinGoal = (d.object(forKey: "ug_proteinGoal") as? Int) ?? 180
        carbsGoal   = (d.object(forKey: "ug_carbsGoal")   as? Int) ?? 250
        fatGoal     = (d.object(forKey: "ug_fatGoal")     as? Int) ?? 70
    }

    func save() {
        let d = UserDefaults.standard
        d.set(calorieGoal, forKey: "ug_calorieGoal")
        d.set(proteinGoal, forKey: "ug_proteinGoal")
        d.set(carbsGoal,   forKey: "ug_carbsGoal")
        d.set(fatGoal,     forKey: "ug_fatGoal")
    }
}
