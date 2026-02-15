//
//  ProgressView.swift
//  FitnessTracker
//
//  Created by Kush Goswami on 2/15/26.
//

import SwiftUI
import Charts

struct ProgressView: View {

    // MARK: - Hardcoded Data

    private let weightEntries: [WeightEntry] = {
        let calendar = Calendar.current
        let today = Date()
        return [
            WeightEntry(date: calendar.date(byAdding: .day, value: -42, to: today)!, weight: 79.5, change: -0.3),
            WeightEntry(date: calendar.date(byAdding: .day, value: -35, to: today)!, weight: 79.2, change: -0.3),
            WeightEntry(date: calendar.date(byAdding: .day, value: -28, to: today)!, weight: 78.9, change: -0.3),
            WeightEntry(date: calendar.date(byAdding: .day, value: -21, to: today)!, weight: 78.7, change: -0.2),
            WeightEntry(date: calendar.date(byAdding: .day, value: -14, to: today)!, weight: 78.3, change: -0.4),
            WeightEntry(date: calendar.date(byAdding: .day, value: -7, to: today)!, weight: 78.4, change: 0.1),
            WeightEntry(date: calendar.date(byAdding: .day, value: 0, to: today)!, weight: 77.6, change: -0.8),
        ]
    }()

    // Goal consistency: true = hit goal, false = missed
    private let calorieConsistency: [Bool] = [true, true, false, true, true, true, true]
    private let proteinConsistency: [Bool] = [true, false, false, true, true, true, false]
    private let waterConsistency: [Bool] = [true, true, true, true, true, true, true]

    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: Spacing.xl) {
                    Header()
                    SummaryGrid()
                    WeightTrendCard(entries: weightEntries)
                    GoalConsistencySection(
                        calorieConsistency: calorieConsistency,
                        proteinConsistency: proteinConsistency,
                        waterConsistency: waterConsistency
                    )
                }
                .padding(.horizontal)
                .padding(.bottom, Spacing.xxl)
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
        private let columns = [
            GridItem(.flexible(), spacing: Spacing.lg),
            GridItem(.flexible(), spacing: Spacing.lg),
        ]

        var body: some View {
            LazyVGrid(columns: columns, spacing: Spacing.lg) {
                SummaryCard(icon: "flame", iconColor: MacroColors.fats, value: "1,850", unit: nil, subtitle: "avg. daily intake", badge: "TODAY")
                SummaryCard(icon: "target", iconColor: MacroColors.protein, value: "140", unit: "g", subtitle: "95% consistency", badge: "TODAY")
                SummaryCard(icon: "drop", iconColor: MacroColors.protein, value: "2.1", unit: "L", subtitle: "daily average", badge: "TODAY")
                SummaryCard(icon: "figure.walk", iconColor: MacroColors.carbs, value: "8,432", unit: nil, subtitle: "daily average", badge: "TODAY")
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
                        .font(.custom(Fonts.outfitBold, size: 26))

                    if let unit {
                        Text(unit)
                            .foregroundStyle(AppColors.lightMacroTextColor)
                            .font(.custom(Fonts.interMedium, size: FontSize.md))
                    }
                }

                Text(subtitle)
                    .foregroundStyle(AppColors.lightMacroTextColor)
                    .font(.custom(Fonts.interRegular, size: FontSize.sm))
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
        let calorieConsistency: [Bool]
        let proteinConsistency: [Bool]
        let waterConsistency: [Bool]

        var body: some View {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                Text("GOAL CONSISTENCY")
                    .foregroundStyle(AppColors.lightMacroTextColor)
                    .font(.custom(Fonts.outfitBold, size: FontSize.xs))
                    .tracking(1)

                VStack(spacing: 0) {
                    ConsistencyRow(label: "Calories", days: calorieConsistency, hitColor: MacroColors.calories)

                    Divider()
                        .overlay(Color.white.opacity(0.06))

                    ConsistencyRow(label: "Protein", days: proteinConsistency, hitColor: MacroColors.protein)

                    Divider()
                        .overlay(Color.white.opacity(0.06))

                    ConsistencyRow(label: "Water", days: waterConsistency, hitColor: Color(red: 80/255, green: 200/255, blue: 220/255))
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
        let days: [Bool]
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
                                if days[index] {
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

                                    Circle()
                                        .fill(Color.white.opacity(0.25))
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
}
