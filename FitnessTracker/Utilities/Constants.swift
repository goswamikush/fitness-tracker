//
//  Constants.swift
//  FitnessTracker
//
//  Created by Kush Goswami on 2/2/26.
//

import SwiftUI

struct AppColors {
    static let background = Color(red: 18/255, green: 18/255, blue: 18/255)
    static let cardBackground = Color(red: 26/255, green: 26/255, blue: 26/255)
    static let lightMacroTextColor = Color(red: 161/255, green:  161/255, blue: 170/255)
    static let macroTextColor = Color(red: 250/255, green:  250/255, blue: 250/255).opacity(0.8)
}

struct MacroColors {
    static let carbs = Color(red: 66/255, green: 240/255, blue: 153/255)
    static let protein = Color(red: 81/255, green: 166/255, blue: 251/255)
    static let fats = Color(red: 250/255, green: 185/255, blue: 56/255)
    static let calories = Color(red: 249/255, green: 115/255, blue: 22/255)
}

enum Fonts {
    static let interRegular = "Inter18pt-Regular"
    static let interMedium = "Inter18pt-Medium"
    static let interSemiBold = "Inter18pt-SemiBold"
    static let outfitSemiBold = "Outfit-SemiBold"
    static let outfitBold = "Outfit-Bold"
}

enum FontSize {
    static let xs: CGFloat = 11
    static let sm: CGFloat = 12
    static let md: CGFloat = 14
    static let lg: CGFloat = 15
    static let xl: CGFloat = 18
}

enum Spacing {
    static let xs: CGFloat = 3
    static let sm: CGFloat = 5
    static let md: CGFloat = 7
    static let lg: CGFloat = 16
    static let xl: CGFloat = 20
    static let xxl: CGFloat = 30
}

enum CornerRadius {
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
}

enum IconSize {
    static let xs: CGFloat = 3
    static let sm: CGFloat = 4
    static let md: CGFloat = 6
    static let lg: CGFloat = 12
}

enum Opacity {
    static let divider: Double = 0.2
}

enum CardStyle {
    static let fillColor = Color(red: 24/255, green: 24/255, blue: 27/255)
    static let fillOpacity: Double = 0.6
    static let borderOpacity: Double = 0.1
    static let borderWidth: CGFloat = 1
    static let shadowOpacity: Double = 0.3
    static let shadowRadius: CGFloat = 10
    static let shadowY: CGFloat = 3
    static let maskPadding: CGFloat = -10
}
