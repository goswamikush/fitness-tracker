//
//  ProgressView.swift
//  FitnessTracker
//
//  Created by Kush Goswami on 2/15/26.
//

import SwiftUI
import SwiftData
import Charts

struct ProgressView: View {

    @Query(sort: \WeightEntry.date) private var weightEntries: [WeightEntry]
    @Query(sort: \MealEntry.date) private var allMealEntries: [MealEntry]

    private let calorieGoal = 2400
    private let proteinGoal = 180

    // Last 7 days (today + 6 prior), ordered Mon→Sun
    private var weekDates: [Date] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        // Find the Monday of the current week
        let weekday = cal.component(.weekday, from: today)
        // weekday: 1=Sun, 2=Mon, ...
        let daysFromMonday = (weekday + 5) % 7
        let monday = cal.date(byAdding: .day, value: -daysFromMonday, to: today)!
        return (0..<7).map { cal.date(byAdding: .day, value: $0, to: monday)! }
    }

    private func entries(for date: Date) -> [MealEntry] {
        let cal = Calendar.current
        return allMealEntries.filter { cal.isDate($0.date, inSameDayAs: date) }
    }

    private func dailyCalories(for date: Date) -> Int {
        Int(entries(for: date).reduce(0) { $0 + $1.calories })
    }

    private func dailyProtein(for date: Date) -> Int {
        Int(entries(for: date).reduce(0) { $0 + $1.protein })
    }

    // Only count days up to and including today that have at least some logged food
    private var daysWithData: [Date] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        return weekDates.filter { $0 <= today && !entries(for: $0).isEmpty }
    }

    private var avgCalories: Int {
        guard !daysWithData.isEmpty else { return 0 }
        let total = daysWithData.reduce(0) { $0 + dailyCalories(for: $1) }
        return total / daysWithData.count
    }

    private var avgProtein: Int {
        guard !daysWithData.isEmpty else { return 0 }
        let total = daysWithData.reduce(0) { $0 + dailyProtein(for: $1) }
        return total / daysWithData.count
    }

    private var proteinConsistencyPercent: Int {
        guard !daysWithData.isEmpty else { return 0 }
        let hits = daysWithData.filter { dailyProtein(for: $0) >= proteinGoal }.count
        return Int((Double(hits) / Double(daysWithData.count)) * 100)
    }

    private var calorieConsistency: [Bool?] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        return weekDates.map { date in
            guard date <= today, !entries(for: date).isEmpty else { return nil }
            let cals = dailyCalories(for: date)
            // "Hit" = within ±200 of goal
            return abs(cals - calorieGoal) <= 200
        }
    }

    private var proteinConsistency: [Bool?] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        return weekDates.map { date in
            guard date <= today, !entries(for: date).isEmpty else { return nil }
            return dailyProtein(for: date) >= proteinGoal
        }
    }

    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Header()
                    .padding(.horizontal)

                ScrollView {
                    VStack(spacing: Spacing.xl) {
                        SummaryGrid(
                            avgCalories: avgCalories,
                            avgProtein: avgProtein,
                            proteinConsistencyPercent: proteinConsistencyPercent
                        )
                        WeightTrendCard(entries: weightEntries)
                        GoalConsistencySection(
                            calorieConsistency: calorieConsistency,
                            proteinConsistency: proteinConsistency
                        )
                    }
                    .padding(.horizontal)
                    .padding(.bottom, Spacing.xxl)
                }
            }
        }
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Header

private extension ProgressView {

    struct Header: View {
        var body: some View {
            VStack(spacing: Spacing.md) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Progress")
                            .foregroundStyle(.white)
                            .font(.custom(Fonts.outfitSemiBold, size: 22))

                        Text("This Week")
                            .foregroundStyle(AppColors.lightMacroTextColor)
                            .font(.custom(Fonts.interRegular, size: FontSize.sm))
                    }

                    Spacer()

                    Image(systemName: "calendar")
                        .font(.system(size: IconSize.lg, weight: .medium))
                        .foregroundColor(AppColors.macroTextColor)
                }

                Divider()
                    .overlay(AppColors.macroTextColor.opacity(Opacity.divider))
            }
        }
    }
}

// MARK: - Summary Grid (2x2)

private extension ProgressView {

    struct SummaryGrid: View {
        let avgCalories: Int
        let avgProtein: Int
        let proteinConsistencyPercent: Int

        private let columns = [
            GridItem(.flexible(), spacing: Spacing.lg),
            GridItem(.flexible(), spacing: Spacing.lg),
        ]

        private var formattedCalories: String {
            if avgCalories >= 1000 {
                let thousands = avgCalories / 1000
                let hundreds = (avgCalories % 1000) / 100
                // e.g. 1,850 → "1,850"
                return "\(thousands),\(String(format: "%03d", avgCalories % 1000))"
            }
            return "\(avgCalories)"
        }

        var body: some View {
            LazyVGrid(columns: columns, spacing: Spacing.lg) {
                SummaryCard(icon: "flame", iconColor: MacroColors.fats, value: formattedCalories, unit: nil, subtitle: "Daily Average", badge: "WEEK")
                SummaryCard(icon: "target", iconColor: MacroColors.protein, value: "\(avgProtein)", unit: "g", subtitle: "\(proteinConsistencyPercent)% consistency", badge: "WEEK")
                SummaryCard(icon: "drop", iconColor: MacroColors.protein, value: "n/a", unit: nil, subtitle: "Daily Average", badge: "WATER")
                SummaryCard(icon: "figure.walk", iconColor: MacroColors.carbs, value: "n/a", unit: nil, subtitle: "Daily Average", badge: "STEPS")
            }
        }
    }

    struct SummaryCard: View {
        let icon: String
        let iconColor: Color
        let value: String
        let unit: String?
        let subtitle: String
        let badge: String

        var body: some View {
            VStack(alignment: .leading, spacing: Spacing.md) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(iconColor.opacity(0.15))
                            .frame(width: 32, height: 32)

                        Image(systemName: icon)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(iconColor)
                    }

                    Spacer()

                    Text(badge)
                        .foregroundStyle(AppColors.lightMacroTextColor)
                        .font(.custom(Fonts.interMedium, size: 9))
                        .tracking(0.5)
                }

                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text(value)
                        .foregroundStyle(.white)
                        .font(.custom(Fonts.outfitSemiBold, size: 26))
                        .tracking(-0.5)

                    if let unit {
                        Text(unit)
                            .foregroundStyle(.white)
                            .font(.custom(Fonts.outfitSemiBold, size: 26))
                            .tracking(-0.5)
                    }
                }

                Text(subtitle)
                    .foregroundStyle(AppColors.lightMacroTextColor)
                    .font(.custom(Fonts.interRegular, size: FontSize.sm))
            }
            .padding(Spacing.lg)
            .background(
                ZStack(alignment: .topTrailing) {
                    RoundedRectangle(cornerRadius: CornerRadius.sm)
                        .fill(CardStyle.fillColor.opacity(CardStyle.fillOpacity))

                    Circle()
                        .fill(iconColor)
                        .frame(width: 80, height: 80)
                        .blur(radius: 24)
                        .opacity(0.1)
                        .offset(x: 4, y: -4)

                    RoundedRectangle(cornerRadius: CornerRadius.sm)
                        .stroke(Color.white.opacity(CardStyle.borderOpacity), lineWidth: CardStyle.borderWidth)
                }
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.sm))
            )
            .shadow(color: .black.opacity(CardStyle.shadowOpacity), radius: CardStyle.shadowRadius, y: CardStyle.shadowY)
        }
    }
}

// MARK: - Weight Trend Card

private extension ProgressView {

    struct WeightTrendCard: View {
        let entries: [WeightEntry]

        private var weekChange: Double {
            guard let last = entries.last, entries.count >= 2 else { return 0 }
            let prev = entries[entries.count - 2]
            return last.weight - prev.weight
        }

        private var yMin: Double {
            (entries.map(\.weight).min() ?? 77) - 0.2
        }
        private var yMax: Double {
            (entries.map(\.weight).max() ?? 80) + 0.5
        }

        var body: some View {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(MacroColors.carbs.opacity(0.15))
                            .frame(width: 32, height: 32)

                        Image(systemName: "scalemass")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(MacroColors.carbs)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Weight Trend")
                            .foregroundStyle(.white)
                            .font(.custom(Fonts.interSemiBold, size: FontSize.lg))

                        Text("\(String(format: "%.1f", weekChange))kg this week")
                            .foregroundStyle(AppColors.lightMacroTextColor)
                            .font(.custom(Fonts.interRegular, size: FontSize.sm))
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(AppColors.lightMacroTextColor)
                }

                Chart {
                    ForEach(entries) { entry in
                        LineMark(
                            x: .value("Date", entry.date),
                            y: .value("Weight", entry.weight)
                        )
                        .foregroundStyle(MacroColors.carbs)
                        .interpolationMethod(.catmullRom)
                        .lineStyle(StrokeStyle(lineWidth: 2))

                        AreaMark(
                            x: .value("Date", entry.date),
                            yStart: .value("Min", yMin),
                            yEnd: .value("Weight", entry.weight)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [MacroColors.carbs.opacity(0.2), MacroColors.carbs.opacity(0.0)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .interpolationMethod(.catmullRom)
                    }
                }
                .chartYScale(domain: yMin...yMax)
                .chartXAxis(.hidden)
                .chartYAxis(.hidden)
                .frame(height: 80)
            }
            .padding(Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.sm)
                    .fill(CardStyle.fillColor.opacity(CardStyle.fillOpacity))
                    .overlay(
                        RoundedRectangle(cornerRadius: CornerRadius.sm)
                            .stroke(Color.white.opacity(CardStyle.borderOpacity), lineWidth: CardStyle.borderWidth)
                    )
                    .shadow(color: .black.opacity(CardStyle.shadowOpacity), radius: CardStyle.shadowRadius, y: CardStyle.shadowY)
            )
        }
    }
}

// MARK: - Goal Consistency Section

private extension ProgressView {

    struct GoalConsistencySection: View {
        let calorieConsistency: [Bool?]
        let proteinConsistency: [Bool?]

        var body: some View {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                Text("GOAL CONSISTENCY")
                    .foregroundStyle(Color(red: 161/255, green: 161/255, blue: 170/255))
                    .font(.custom(Fonts.outfitBold, size: FontSize.xs))
                    .tracking(1)

                VStack(spacing: 0) {
                    ConsistencyRow(label: "Calories", days: calorieConsistency, hitColor: MacroColors.calories)

                    Divider()
                        .overlay(Color.white.opacity(0.06))

                    ConsistencyRow(label: "Protein", days: proteinConsistency, hitColor: MacroColors.protein)
                }
                .padding(Spacing.lg)
                .background(
                    RoundedRectangle(cornerRadius: CornerRadius.sm)
                        .fill(CardStyle.fillColor.opacity(CardStyle.fillOpacity))
                        .overlay(
                            RoundedRectangle(cornerRadius: CornerRadius.sm)
                                .stroke(Color.white.opacity(CardStyle.borderOpacity), lineWidth: CardStyle.borderWidth)
                        )
                        .shadow(color: .black.opacity(CardStyle.shadowOpacity), radius: CardStyle.shadowRadius, y: CardStyle.shadowY)
                )
            }
        }
    }

    struct ConsistencyRow: View {
        let label: String
        let days: [Bool?]
        var hitColor: Color = MacroColors.carbs

        private let dayLabels = ["M", "T", "W", "T", "F", "S", "S"]

        var body: some View {
            HStack(spacing: 0) {
                Text(label)
                    .foregroundStyle(.white)
                    .font(.custom(Fonts.interSemiBold, size: FontSize.lg))
                    .frame(width: 80, alignment: .leading)

                Spacer()
                    .frame(width: 12)

                HStack(spacing: 0) {
                    ForEach(0..<7, id: \.self) { index in
                        VStack(spacing: 5) {
                            Text(dayLabels[index])
                                .foregroundStyle(AppColors.lightMacroTextColor)
                                .font(.custom(Fonts.interMedium, size: FontSize.xs))

                            ZStack {
                                if let hit = days[index] {
                                    if hit {
                                        Circle()
                                            .fill(hitColor.opacity(0.2))
                                            .stroke(hitColor.opacity(0.5), lineWidth: 1)
                                            .frame(width: 22, height: 22)

                                        Image(systemName: "checkmark")
                                            .font(.system(size: 9, weight: .bold))
                                            .foregroundStyle(hitColor)
                                    } else {
                                        Circle()
                                            .fill(Color.white.opacity(0.08))
                                            .stroke(Color.white.opacity(0.05), lineWidth: 1)
                                            .frame(width: 22, height: 22)

                                        Image(systemName: "xmark")
                                            .font(.system(size: 8, weight: .bold))
                                            .foregroundStyle(AppColors.lightMacroTextColor)
                                    }
                                } else {
                                    // No data / future day
                                    Circle()
                                        .fill(Color.white.opacity(0.04))
                                        .stroke(Color.white.opacity(0.03), lineWidth: 1)
                                        .frame(width: 22, height: 22)

                                    Circle()
                                        .fill(Color.white.opacity(0.15))
                                        .frame(width: 5, height: 5)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(.vertical, Spacing.lg)
        }
    }
}

#Preview {
    NavigationStack {
        ProgressView()
    }
    .modelContainer(for: [WeightEntry.self, MealEntry.self, FoodItem.self], inMemory: true)
}
