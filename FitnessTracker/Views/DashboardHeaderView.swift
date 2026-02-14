//
//  DashboardHeaderView.swift
//  FitnessTracker
//

import SwiftUI

struct DashboardHeaderView: View {
    var body: some View {
        VStack(spacing: 20) {
            DateBar()
            CaloriesSection()
            MacroRingsSection()
        }
    }
}

// MARK: - Subcomponents

private extension DashboardHeaderView {

    struct DateBar: View {
        var body: some View {
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(AppColors.lightMacroTextColor)

                Spacer()

                Text("TODAY")
                    .foregroundStyle(.white)
                    .font(.custom(Fonts.interSemiBold, size: 14))

                Spacer()

                // Invisible icon to center "TODAY"
                Image(systemName: "calendar")
                    .foregroundColor(.clear)
            }
            .padding(.horizontal)
        }
    }

    struct CaloriesSection: View {
        var body: some View {
            VStack(spacing: 8) {
                Text("CALORIES REMAINING")
                    .foregroundStyle(AppColors.lightMacroTextColor)
                    .font(.custom(Fonts.interMedium, size: 11))

                Text("1285")
                    .foregroundStyle(.white)
                    .font(.custom(Fonts.outfitSemiBold, size: 30))
                    .padding(.bottom, 6)

                CalorieProgressBar(consumed: 1285, goal: 2400)

                HStack {
                    Text("0")
                        .foregroundStyle(AppColors.lightMacroTextColor)
                        .font(.custom(Fonts.interMedium, size: 11))

                    Spacer()

                    Text("2400 kcal goal")
                        .foregroundStyle(AppColors.lightMacroTextColor)
                        .font(.custom(Fonts.interMedium, size: 11))
                }
            }
            .padding(.horizontal, 55)
        }
    }

    struct CalorieProgressBar: View {
        let consumed: Double
        let goal: Double

        private var progress: Double {
            min(consumed / goal, 1.0)
        }

        var body: some View {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(AppColors.lightMacroTextColor.opacity(0.2))

                    RoundedRectangle(cornerRadius: 5)
                        .fill(
                            LinearGradient(
                                colors: [MacroColors.protein, MacroColors.carbs],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * progress)
                }
            }
            .frame(height: 6)
        }
    }

    struct MacroRingsSection: View {
        var body: some View {
            HStack(spacing: 50) {
                MacroRing(current: 97, goal: 180, color: MacroColors.protein, label: "Protein")
                MacroRing(current: 108, goal: 250, color: MacroColors.carbs, label: "Carbs")
                MacroRing(current: 27, goal: 70, color: MacroColors.fats, label: "Fat")
            }
        }
    }
}

#Preview {
    ZStack {
        AppColors.background
            .ignoresSafeArea()

        DashboardHeaderView()
            .padding()
    }
}
