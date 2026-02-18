//
//  DashboardView.swift
//  FitnessTracker
//
//  Created by Kush Goswami on 2/2/26.
//

import SwiftUI
import SwiftData

struct DashboardView: View {
    @Query(sort: \MealEntry.date) private var allEntries: [MealEntry]

    private let mealTypes = ["Breakfast", "Lunch", "Dinner", "Snack"]

    private var todayEntries: [MealEntry] {
        allEntries.filter { Calendar.current.isDateInToday($0.date) }
    }

    private func entries(for mealType: String) -> [MealEntry] {
        todayEntries.filter { $0.mealType == mealType }
    }

    private var totalCalories: Int {
        Int(todayEntries.reduce(0) { $0 + $1.calories })
    }

    private var totalProtein: Int {
        Int(todayEntries.reduce(0) { $0 + $1.protein })
    }

    private var totalCarbs: Int {
        Int(todayEntries.reduce(0) { $0 + $1.carbs })
    }

    private var totalFat: Int {
        Int(todayEntries.reduce(0) { $0 + $1.fat })
    }

    private var totalItems: Int {
        todayEntries.count
    }

    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()

            VStack(spacing: 24) {
                DashboardHeaderView(
                    consumedCalories: totalCalories,
                    consumedProtein: totalProtein,
                    consumedCarbs: totalCarbs,
                    consumedFat: totalFat
                )
                .padding(.horizontal)

                ScrollView {
                    VStack(spacing: 24) {
                        MealsSectionHeader(itemCount: totalItems)

                        ForEach(mealTypes, id: \.self) { mealType in
                            MealCard(mealName: mealType, entries: entries(for: mealType))
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Subcomponents

private extension DashboardView {

    struct MealsSectionHeader: View {
        let itemCount: Int

        var body: some View {
            HStack {
                Text("Meals")
                    .foregroundStyle(.white)
                    .font(.custom(Fonts.outfitSemiBold, size: 22))

                Spacer()

                Text("\(itemCount) Item\(itemCount == 1 ? "" : "s")")
                    .foregroundStyle(AppColors.lightMacroTextColor)
                    .font(.custom(Fonts.interRegular, size: 12))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.08))
                    )
            }
        }
    }
}

#Preview {
    NavigationStack {
        DashboardView()
    }
}
