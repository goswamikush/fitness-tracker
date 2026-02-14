//
//  MacroRing.swift
//  FitnessTracker
//

import SwiftUI

struct MacroRing: View {
    let current: Double
    let goal: Double
    let color: Color
    let label: String

    private var progress: Double {
        min(current / goal, 1.0)
    }

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(
                        color.opacity(0.2),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        color,
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))

                Text("\(Int(current))")
                    .foregroundStyle(.white)
                    .font(.custom(Fonts.outfitSemiBold, size: 11))
            }
            .frame(width: 40, height: 40)
            
            VStack {
                Text(label.uppercased())
                    .foregroundStyle(AppColors.lightMacroTextColor)
                    .font(.custom(Fonts.interMedium, size: 10))
                
                Text("\(Int(goal))g")
                    .foregroundStyle(AppColors.lightMacroTextColor.opacity(0.6))
                    .font(.custom(Fonts.interRegular, size: 10))
            }
        }
    }
}

#Preview {
    ZStack {
        AppColors.background
            .ignoresSafeArea()

        HStack(spacing: 20) {
            MacroRing(current: 97, goal: 180, color: MacroColors.protein, label: "Protein")
            MacroRing(current: 108, goal: 250, color: MacroColors.carbs, label: "Carbs")
            MacroRing(current: 27, goal: 70, color: MacroColors.fats, label: "Fat")
        }
    }
}
