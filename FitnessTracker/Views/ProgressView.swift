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
    var onBodyTap: (() -> Void)? = nil

    @Environment(UserGoals.self) private var userGoals
    @Query(sort: \WeightEntry.date) private var weightEntries: [WeightEntry]
    @Query(sort: \MealEntry.date) private var allMealEntries: [MealEntry]

    @State private var referenceDate = Date()
    @State private var showDatePicker = false

    // Week containing referenceDate, ordered Mon→Sun
    private var weekDates: [Date] {
        let cal = Calendar.current
        let ref = cal.startOfDay(for: referenceDate)
        let weekday = cal.component(.weekday, from: ref)
        let daysFromMonday = (weekday + 5) % 7
        let monday = cal.date(byAdding: .day, value: -daysFromMonday, to: ref)!
        return (0..<7).map { cal.date(byAdding: .day, value: $0, to: monday)! }
    }

    private var weekLabel: String {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let weekday = cal.component(.weekday, from: today)
        let daysFromMonday = (weekday + 5) % 7
        let thisMonday = cal.date(byAdding: .day, value: -daysFromMonday, to: today)!
        if cal.isDate(weekDates[0], inSameDayAs: thisMonday) { return "This Week" }
        let fmt = DateFormatter()
        fmt.dateFormat = "MMM d"
        return "\(fmt.string(from: weekDates[0])) – \(fmt.string(from: weekDates[6]))"
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
        let hits = daysWithData.filter { dailyProtein(for: $0) >= userGoals.proteinGoal }.count
        return Int((Double(hits) / Double(daysWithData.count)) * 100)
    }

    private var calorieConsistency: [Bool?] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        return weekDates.map { date in
            guard date <= today, !entries(for: date).isEmpty else { return nil }
            let cals = dailyCalories(for: date)
            // "Hit" = within ±200 of goal
            return abs(cals - userGoals.calorieGoal) <= 200
        }
    }

    private var proteinConsistency: [Bool?] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        return weekDates.map { date in
            guard date <= today, !entries(for: date).isEmpty else { return nil }
            return dailyProtein(for: date) >= userGoals.proteinGoal
        }
    }

    private func dailyCarbs(for date: Date) -> Int {
        Int(entries(for: date).reduce(0) { $0 + $1.carbs })
    }

    private func dailyFat(for date: Date) -> Int {
        Int(entries(for: date).reduce(0) { $0 + $1.fat })
    }

    private var carbsConsistency: [Bool?] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        return weekDates.map { date in
            guard date <= today, !entries(for: date).isEmpty else { return nil }
            let c = dailyCarbs(for: date)
            return abs(c - userGoals.carbsGoal) <= max(userGoals.carbsGoal / 5, 5)
        }
    }

    private var fatConsistency: [Bool?] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        return weekDates.map { date in
            guard date <= today, !entries(for: date).isEmpty else { return nil }
            let f = dailyFat(for: date)
            return abs(f - userGoals.fatGoal) <= max(userGoals.fatGoal / 5, 3)
        }
    }

    private func consistencyPercent(_ days: [Bool?]) -> Int {
        let logged = days.compactMap { $0 }
        guard !logged.isEmpty else { return 0 }
        return Int((Double(logged.filter { $0 }.count) / Double(logged.count)) * 100)
    }

    private var overallConsistencyScore: Int {
        let c  = Double(consistencyPercent(calorieConsistency))
        let p  = Double(consistencyPercent(proteinConsistency))
        let cb = Double(consistencyPercent(carbsConsistency))
        let f  = Double(consistencyPercent(fatConsistency))
        return Int((c * 0.75 + (p + cb + f) * (0.25 / 3)).rounded())
    }

    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Header(weekLabel: weekLabel, referenceDate: $referenceDate, showDatePicker: $showDatePicker)
                    .padding(.horizontal)

                ScrollView {
                    VStack(spacing: Spacing.xl) {
                        SummaryGrid(
                            avgCalories: avgCalories,
                            avgProtein: avgProtein,
                            proteinConsistencyPercent: proteinConsistencyPercent
                        )
                        WeightTrendCard(entries: weightEntries, onBodyTap: onBodyTap)
                        GoalConsistencySection(
                            calorieConsistency: calorieConsistency,
                            proteinConsistency: proteinConsistency,
                            carbsConsistency: carbsConsistency,
                            fatConsistency: fatConsistency,
                            calPercent: consistencyPercent(calorieConsistency),
                            proteinPercent: consistencyPercent(proteinConsistency),
                            carbsPercent: consistencyPercent(carbsConsistency),
                            fatPercent: consistencyPercent(fatConsistency),
                            overallScore: overallConsistencyScore
                        )
                    }
                    .padding(.horizontal)
                    .padding(.top, Spacing.lg)
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
        let weekLabel: String
        @Binding var referenceDate: Date
        @Binding var showDatePicker: Bool

        var body: some View {
            VStack(spacing: Spacing.md) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Progress")
                            .foregroundStyle(.white)
                            .font(.custom(Fonts.outfitSemiBold, size: 22))

                        Text(weekLabel)
                            .foregroundStyle(AppColors.lightMacroTextColor)
                            .font(.custom(Fonts.interRegular, size: FontSize.sm))
                    }

                    Spacer()

                    Button {
                        showDatePicker = true
                    } label: {
                        Image(systemName: "calendar")
                            .font(.system(size: IconSize.lg, weight: .medium))
                            .foregroundColor(AppColors.macroTextColor)
                    }
                }
                .sheet(isPresented: $showDatePicker) {
                    WeekPickerSheet(referenceDate: $referenceDate, isPresented: $showDatePicker)
                }

                Divider()
                    .overlay(AppColors.macroTextColor.opacity(Opacity.divider))
            }
        }
    }

    struct WeekPickerSheet: View {
        @Binding var referenceDate: Date
        @Binding var isPresented: Bool

        var body: some View {
            NavigationStack {
                DatePicker("Select Week", selection: $referenceDate, in: ...Date(), displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .tint(MacroColors.carbs)
                    .padding()
                    .navigationTitle("Select Week")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") { isPresented = false }
                        }
                    }
            }
            .presentationDetents([.medium])
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
        var onBodyTap: (() -> Void)? = nil

        private var weekChange: Double {
            let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
            let recent = entries.filter { $0.date >= sevenDaysAgo }
            guard let first = recent.first, let last = recent.last, first.id != last.id else { return 0 }
            return last.weight - first.weight
        }

        private var weekChangeLabel: String {
            let sign = weekChange >= 0 ? "+" : ""
            return "\(sign)\(String(format: "%.1f", weekChange))kg past 7 days"
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

                        Text(weekChangeLabel)
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
            .contentShape(Rectangle())
            .onTapGesture { onBodyTap?() }
        }
    }
}

// MARK: - Goal Consistency Section

private extension ProgressView {

    struct GoalConsistencySection: View {
        let calorieConsistency: [Bool?]
        let proteinConsistency: [Bool?]
        let carbsConsistency: [Bool?]
        let fatConsistency: [Bool?]
        let calPercent: Int
        let proteinPercent: Int
        let carbsPercent: Int
        let fatPercent: Int
        let overallScore: Int

        @State private var showDetail = false

        private var scoreColor: Color {
            if overallScore >= 80 { return MacroColors.carbs }
            if overallScore >= 60 { return MacroColors.calories }
            if overallScore >= 40 { return MacroColors.fats }
            return AppColors.negative
        }

        var body: some View {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                Text("GOAL CONSISTENCY")
                    .foregroundStyle(AppColors.lightMacroTextColor)
                    .font(.custom(Fonts.outfitBold, size: FontSize.xs))
                    .tracking(1)

                VStack(spacing: 0) {
                    // Overall score row — tappable
                    Button { showDetail = true } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Overall Score")
                                    .foregroundStyle(AppColors.lightMacroTextColor)
                                    .font(.custom(Fonts.interMedium, size: FontSize.sm))
                                HStack(alignment: .firstTextBaseline, spacing: 2) {
                                    Text("\(overallScore)")
                                        .foregroundStyle(scoreColor)
                                        .font(.custom(Fonts.outfitSemiBold, size: 36))
                                    Text("%")
                                        .foregroundStyle(scoreColor)
                                        .font(.custom(Fonts.outfitSemiBold, size: 20))
                                }
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(AppColors.lightMacroTextColor)
                        }
                        .padding(Spacing.lg)
                    }
                    .buttonStyle(.plain)

                    Divider().overlay(Color.white.opacity(0.06))

                    ConsistencyRow(label: "Calories", days: calorieConsistency, hitColor: MacroColors.calories)
                        .padding(.horizontal, Spacing.lg)

                    Divider().overlay(Color.white.opacity(0.06))

                    ConsistencyRow(label: "Protein", days: proteinConsistency, hitColor: MacroColors.protein)
                        .padding(.horizontal, Spacing.lg)

                    Divider().overlay(Color.white.opacity(0.06))

                    ConsistencyRow(label: "Carbs", days: carbsConsistency, hitColor: MacroColors.carbs)
                        .padding(.horizontal, Spacing.lg)

                    Divider().overlay(Color.white.opacity(0.06))

                    ConsistencyRow(label: "Fat", days: fatConsistency, hitColor: MacroColors.fats)
                        .padding(.horizontal, Spacing.lg)
                }
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
            .sheet(isPresented: $showDetail) {
                ConsistencyDetailSheet(
                    calorieConsistency: calorieConsistency,
                    proteinConsistency: proteinConsistency,
                    carbsConsistency: carbsConsistency,
                    fatConsistency: fatConsistency,
                    calPercent: calPercent,
                    proteinPercent: proteinPercent,
                    carbsPercent: carbsPercent,
                    fatPercent: fatPercent,
                    overallScore: overallScore
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
                    .font(.custom(Fonts.interSemiBold, size: FontSize.md))
                    .frame(width: 68, alignment: .leading)

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

    struct ConsistencyDetailSheet: View {
        let calorieConsistency: [Bool?]
        let proteinConsistency: [Bool?]
        let carbsConsistency: [Bool?]
        let fatConsistency: [Bool?]
        let calPercent: Int
        let proteinPercent: Int
        let carbsPercent: Int
        let fatPercent: Int
        let overallScore: Int

        @Environment(\.dismiss) private var dismiss

        private var scoreColor: Color {
            if overallScore >= 80 { return MacroColors.carbs }
            if overallScore >= 60 { return MacroColors.calories }
            if overallScore >= 40 { return MacroColors.fats }
            return AppColors.negative
        }

        var body: some View {
            NavigationStack {
                ZStack {
                    AppColors.background.ignoresSafeArea()

                    ScrollView {
                        VStack(alignment: .leading, spacing: Spacing.xxl) {

                            // Overall score hero
                            HStack {
                                Spacer()
                                VStack(spacing: Spacing.sm) {
                                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                                        Text("\(overallScore)")
                                            .foregroundStyle(scoreColor)
                                            .font(.custom(Fonts.outfitSemiBold, size: 64))
                                        Text("%")
                                            .foregroundStyle(scoreColor)
                                            .font(.custom(Fonts.outfitSemiBold, size: 32))
                                    }
                                    Text("Overall Consistency Score")
                                        .foregroundStyle(AppColors.lightMacroTextColor)
                                        .font(.custom(Fonts.interRegular, size: FontSize.sm))
                                }
                                Spacer()
                            }
                            .padding(.top, Spacing.lg)

                            // Individual breakdowns
                            VStack(alignment: .leading, spacing: Spacing.lg) {
                                Text("BREAKDOWN")
                                    .foregroundStyle(AppColors.lightMacroTextColor)
                                    .font(.custom(Fonts.interMedium, size: FontSize.xs))
                                    .tracking(1)

                                VStack(spacing: 0) {
                                    DetailRow(label: "Calories", percent: calPercent, weight: "75%",
                                              days: calorieConsistency, hitColor: MacroColors.calories,
                                              description: "Within ±200 kcal of goal")
                                    Divider().overlay(Color.white.opacity(0.06))
                                    DetailRow(label: "Protein", percent: proteinPercent, weight: "8.3%",
                                              days: proteinConsistency, hitColor: MacroColors.protein,
                                              description: "At or above goal")
                                    Divider().overlay(Color.white.opacity(0.06))
                                    DetailRow(label: "Carbs", percent: carbsPercent, weight: "8.3%",
                                              days: carbsConsistency, hitColor: MacroColors.carbs,
                                              description: "Within ±20% of goal")
                                    Divider().overlay(Color.white.opacity(0.06))
                                    DetailRow(label: "Fat", percent: fatPercent, weight: "8.3%",
                                              days: fatConsistency, hitColor: MacroColors.fats,
                                              description: "Within ±20% of goal")
                                }
                                .background(
                                    RoundedRectangle(cornerRadius: CornerRadius.sm)
                                        .fill(CardStyle.fillColor.opacity(CardStyle.fillOpacity))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: CornerRadius.sm)
                                                .stroke(Color.white.opacity(CardStyle.borderOpacity), lineWidth: CardStyle.borderWidth)
                                        )
                                )
                            }

                            // Formula
                            VStack(alignment: .leading, spacing: Spacing.lg) {
                                Text("HOW IT'S CALCULATED")
                                    .foregroundStyle(AppColors.lightMacroTextColor)
                                    .font(.custom(Fonts.interMedium, size: FontSize.xs))
                                    .tracking(1)

                                VStack(alignment: .leading, spacing: Spacing.md) {
                                    Text("Score = (Calories × 75%) + (Protein × 8.3%) + (Carbs × 8.3%) + (Fat × 8.3%)")
                                        .foregroundStyle(.white)
                                        .font(.custom(Fonts.interSemiBold, size: FontSize.sm))
                                        .fixedSize(horizontal: false, vertical: true)

                                    Divider().overlay(Color.white.opacity(0.08))

                                    Text("Each metric shows the % of logged days where you hit the target. Calories are weighted at 75% as the primary driver of body composition; protein, carbs, and fat each contribute an equal 8.3% of the remaining 25%.")
                                        .foregroundStyle(AppColors.lightMacroTextColor)
                                        .font(.custom(Fonts.interRegular, size: FontSize.sm))
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .padding(Spacing.lg)
                                .background(
                                    RoundedRectangle(cornerRadius: CornerRadius.sm)
                                        .fill(CardStyle.fillColor.opacity(CardStyle.fillOpacity))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: CornerRadius.sm)
                                                .stroke(Color.white.opacity(CardStyle.borderOpacity), lineWidth: CardStyle.borderWidth)
                                        )
                                )
                            }
                        }
                        .padding()
                        .padding(.bottom, Spacing.xxl)
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(AppColors.background, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Consistency Details")
                            .foregroundColor(.white)
                            .font(.custom(Fonts.outfitSemiBold, size: 18))
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") { dismiss() }
                            .foregroundColor(MacroColors.carbs)
                    }
                }
            }
            .presentationDragIndicator(.visible)
            .presentationDetents([.large])
        }
    }

    struct DetailRow: View {
        let label: String
        let percent: Int
        let weight: String
        let days: [Bool?]
        let hitColor: Color
        let description: String

        private let dayLabels = ["M", "T", "W", "T", "F", "S", "S"]

        var body: some View {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: Spacing.sm) {
                            Circle()
                                .fill(hitColor)
                                .frame(width: 8, height: 8)
                            Text(label)
                                .foregroundStyle(.white)
                                .font(.custom(Fonts.interSemiBold, size: FontSize.md))
                        }
                        Text(description)
                            .foregroundStyle(AppColors.lightMacroTextColor)
                            .font(.custom(Fonts.interRegular, size: FontSize.xs))
                            .padding(.leading, 16)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(percent)%")
                            .foregroundStyle(hitColor)
                            .font(.custom(Fonts.outfitSemiBold, size: FontSize.xl))
                        Text("weight: \(weight)")
                            .foregroundStyle(AppColors.lightMacroTextColor)
                            .font(.custom(Fonts.interRegular, size: FontSize.xs))
                    }
                }

                HStack(spacing: 0) {
                    ForEach(0..<7, id: \.self) { index in
                        VStack(spacing: 4) {
                            Text(dayLabels[index])
                                .foregroundStyle(AppColors.lightMacroTextColor)
                                .font(.custom(Fonts.interMedium, size: FontSize.xs))
                            ZStack {
                                if let hit = days[index] {
                                    if hit {
                                        Circle()
                                            .fill(hitColor.opacity(0.2))
                                            .stroke(hitColor.opacity(0.5), lineWidth: 1)
                                            .frame(width: 24, height: 24)
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 9, weight: .bold))
                                            .foregroundStyle(hitColor)
                                    } else {
                                        Circle()
                                            .fill(Color.white.opacity(0.08))
                                            .stroke(Color.white.opacity(0.05), lineWidth: 1)
                                            .frame(width: 24, height: 24)
                                        Image(systemName: "xmark")
                                            .font(.system(size: 8, weight: .bold))
                                            .foregroundStyle(AppColors.lightMacroTextColor)
                                    }
                                } else {
                                    Circle()
                                        .fill(Color.white.opacity(0.04))
                                        .stroke(Color.white.opacity(0.03), lineWidth: 1)
                                        .frame(width: 24, height: 24)
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
            .padding(Spacing.lg)
        }
    }
}

#Preview {
    NavigationStack {
        ProgressView()
    }
    .modelContainer(for: [WeightEntry.self, MealEntry.self, FoodItem.self], inMemory: true)
}
