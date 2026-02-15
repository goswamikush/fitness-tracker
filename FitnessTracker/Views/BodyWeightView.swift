//
//  BodyWeightView.swift
//  FitnessTracker
//
//  Created by Kush Goswami on 2/14/26.
//

import SwiftUI
import Charts

struct WeightEntry: Identifiable {
    let id = UUID()
    let date: Date
    let weight: Double
    let change: Double
}

enum DateRange: String, CaseIterable {
    case oneWeek = "1W"
    case oneMonth = "1M"
    case threeMonths = "3M"
    case sixMonths = "6M"
    case oneYear = "1Y"
    case max = "MAX"
}

struct BodyWeightView: View {
    @State private var selectedRange: DateRange = .sixMonths

    private let entries: [WeightEntry] = {
        let calendar = Calendar.current
        let today = Date()
        return [
            // Week 1 (15 weeks ago)
            WeightEntry(date: calendar.date(byAdding: .day, value: -105, to: today)!, weight: 83.2, change: 0.0),
            WeightEntry(date: calendar.date(byAdding: .day, value: -104, to: today)!, weight: 83.5, change: 0.3),
            WeightEntry(date: calendar.date(byAdding: .day, value: -103, to: today)!, weight: 83.0, change: -0.5),
            WeightEntry(date: calendar.date(byAdding: .day, value: -101, to: today)!, weight: 83.4, change: 0.4),
            // Week 2
            WeightEntry(date: calendar.date(byAdding: .day, value: -98, to: today)!, weight: 82.8, change: -0.6),
            WeightEntry(date: calendar.date(byAdding: .day, value: -97, to: today)!, weight: 83.1, change: 0.3),
            WeightEntry(date: calendar.date(byAdding: .day, value: -95, to: today)!, weight: 82.6, change: -0.5),
            // Week 3
            WeightEntry(date: calendar.date(byAdding: .day, value: -91, to: today)!, weight: 83.0, change: 0.4),
            WeightEntry(date: calendar.date(byAdding: .day, value: -90, to: today)!, weight: 82.7, change: -0.3),
            WeightEntry(date: calendar.date(byAdding: .day, value: -88, to: today)!, weight: 83.2, change: 0.5),
            WeightEntry(date: calendar.date(byAdding: .day, value: -86, to: today)!, weight: 82.5, change: -0.7),
            // Week 4
            WeightEntry(date: calendar.date(byAdding: .day, value: -84, to: today)!, weight: 82.4, change: -0.1),
            WeightEntry(date: calendar.date(byAdding: .day, value: -83, to: today)!, weight: 82.8, change: 0.4),
            WeightEntry(date: calendar.date(byAdding: .day, value: -81, to: today)!, weight: 82.1, change: -0.7),
            // Week 5
            WeightEntry(date: calendar.date(byAdding: .day, value: -77, to: today)!, weight: 81.8, change: -0.3),
            WeightEntry(date: calendar.date(byAdding: .day, value: -76, to: today)!, weight: 82.2, change: 0.4),
            WeightEntry(date: calendar.date(byAdding: .day, value: -74, to: today)!, weight: 81.5, change: -0.7),
            // Week 6
            WeightEntry(date: calendar.date(byAdding: .day, value: -70, to: today)!, weight: 81.5, change: 0.0),
            WeightEntry(date: calendar.date(byAdding: .day, value: -69, to: today)!, weight: 81.9, change: 0.4),
            WeightEntry(date: calendar.date(byAdding: .day, value: -67, to: today)!, weight: 81.2, change: -0.7),
            // Week 7
            WeightEntry(date: calendar.date(byAdding: .day, value: -63, to: today)!, weight: 80.9, change: -0.3),
            WeightEntry(date: calendar.date(byAdding: .day, value: -62, to: today)!, weight: 81.3, change: 0.4),
            WeightEntry(date: calendar.date(byAdding: .day, value: -60, to: today)!, weight: 80.6, change: -0.7),
            // Week 8
            WeightEntry(date: calendar.date(byAdding: .day, value: -56, to: today)!, weight: 80.3, change: -0.3),
            WeightEntry(date: calendar.date(byAdding: .day, value: -55, to: today)!, weight: 80.7, change: 0.4),
            WeightEntry(date: calendar.date(byAdding: .day, value: -53, to: today)!, weight: 80.0, change: -0.7),
            // Week 9
            WeightEntry(date: calendar.date(byAdding: .day, value: -49, to: today)!, weight: 80.1, change: 0.1),
            WeightEntry(date: calendar.date(byAdding: .day, value: -48, to: today)!, weight: 80.5, change: 0.4),
            WeightEntry(date: calendar.date(byAdding: .day, value: -46, to: today)!, weight: 79.8, change: -0.7),
            // Week 10
            WeightEntry(date: calendar.date(byAdding: .day, value: -42, to: today)!, weight: 79.8, change: 0.0),
            WeightEntry(date: calendar.date(byAdding: .day, value: -41, to: today)!, weight: 80.2, change: 0.4),
            WeightEntry(date: calendar.date(byAdding: .day, value: -39, to: today)!, weight: 79.5, change: -0.7),
            // Week 11
            WeightEntry(date: calendar.date(byAdding: .day, value: -35, to: today)!, weight: 79.5, change: 0.0),
            WeightEntry(date: calendar.date(byAdding: .day, value: -34, to: today)!, weight: 79.9, change: 0.4),
            WeightEntry(date: calendar.date(byAdding: .day, value: -32, to: today)!, weight: 79.2, change: -0.7),
            // Week 12
            WeightEntry(date: calendar.date(byAdding: .day, value: -28, to: today)!, weight: 79.2, change: 0.0),
            WeightEntry(date: calendar.date(byAdding: .day, value: -27, to: today)!, weight: 79.6, change: 0.4),
            WeightEntry(date: calendar.date(byAdding: .day, value: -25, to: today)!, weight: 78.9, change: -0.7),
            // Week 13
            WeightEntry(date: calendar.date(byAdding: .day, value: -21, to: today)!, weight: 79.0, change: 0.1),
            WeightEntry(date: calendar.date(byAdding: .day, value: -20, to: today)!, weight: 79.4, change: 0.4),
            WeightEntry(date: calendar.date(byAdding: .day, value: -18, to: today)!, weight: 78.7, change: -0.7),
            // Week 14
            WeightEntry(date: calendar.date(byAdding: .day, value: -14, to: today)!, weight: 78.6, change: -0.1),
            WeightEntry(date: calendar.date(byAdding: .day, value: -13, to: today)!, weight: 79.1, change: 0.5),
            WeightEntry(date: calendar.date(byAdding: .day, value: -11, to: today)!, weight: 78.3, change: -0.8),
            // Week 15
            WeightEntry(date: calendar.date(byAdding: .day, value: -7, to: today)!, weight: 78.8, change: 0.5),
            WeightEntry(date: calendar.date(byAdding: .day, value: -5, to: today)!, weight: 78.2, change: -0.6),
            WeightEntry(date: calendar.date(byAdding: .day, value: -3, to: today)!, weight: 78.9, change: 0.7),
            WeightEntry(date: calendar.date(byAdding: .day, value: -1, to: today)!, weight: 78.1, change: -0.8),
            WeightEntry(date: calendar.date(byAdding: .day, value: 0, to: today)!, weight: 78.4, change: 0.3),
        ]
    }()

    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: Spacing.xl) {
                    Header()
                    WeightSummaryCards(entries: entries)
                    DateRangePicker(selectedRange: $selectedRange)
                    WeightChart(entries: entries)
                    HistorySection(entries: entries)
                }
                .padding(.horizontal)
            }
        }
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Subcomponents

private extension BodyWeightView {

    struct Header: View {
        var body: some View {
            VStack(spacing: Spacing.md) {
                HStack {
                    Text("Body Weight")
                        .foregroundStyle(.white)
                        .font(.custom(Fonts.outfitSemiBold, size: 22))

                    Spacer()

                    NavigationLink(destination: AddWeightView()) {
                        Image(systemName: "plus")
                            .font(.system(size: IconSize.lg, weight: .medium))
                            .foregroundColor(AppColors.macroTextColor)
                    }
                }

                Divider()
                    .overlay(AppColors.macroTextColor.opacity(Opacity.divider))
            }
        }
    }

    struct WeightSummaryCards: View {
        let entries: [WeightEntry]

        private var currentWeight: Double {
            entries.last?.weight ?? 0
        }

        private var weeklyAvg: Double {
            let calendar = Calendar.current
            let oneWeekAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
            let thisWeek = entries.filter { $0.date >= oneWeekAgo }
            guard !thisWeek.isEmpty else { return currentWeight }
            return thisWeek.map(\.weight).reduce(0, +) / Double(thisWeek.count)
        }

        private var lastWeekAvg: Double {
            let calendar = Calendar.current
            let oneWeekAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
            let twoWeeksAgo = calendar.date(byAdding: .day, value: -14, to: Date())!
            let lastWeek = entries.filter { $0.date >= twoWeeksAgo && $0.date < oneWeekAgo }
            guard !lastWeek.isEmpty else { return weeklyAvg }
            return lastWeek.map(\.weight).reduce(0, +) / Double(lastWeek.count)
        }

        private var totalChange: Double {
            guard let first = entries.first else { return 0 }
            return currentWeight - first.weight
        }

        private var weekOverWeekChange: Double {
            weeklyAvg - lastWeekAvg
        }

        var body: some View {
            HStack(spacing: Spacing.lg) {
                SummaryCard(
                    label: "CURRENT",
                    value: String(format: "%.1f", currentWeight),
                    unit: "kg",
                    change: String(format: "%.1f", totalChange),
                    changeLabel: "kg",
                    isNegative: totalChange <= 0
                )

                SummaryCard(
                    label: "WEEKLY AVG",
                    value: String(format: "%.1f", weeklyAvg),
                    unit: "kg",
                    change: String(format: "%.1f", weekOverWeekChange),
                    changeLabel: "kg vs last wk",
                    isNegative: weekOverWeekChange <= 0
                )
            }
        }
    }

    struct SummaryCard: View {
        let label: String
        let value: String
        let unit: String
        let change: String
        let changeLabel: String
        let isNegative: Bool

        var body: some View {
            VStack(spacing: Spacing.md) {
                Text(label)
                    .foregroundStyle(AppColors.lightMacroTextColor)
                    .font(.custom(Fonts.interMedium, size: FontSize.xs))
                    .tracking(1)

                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text(value)
                        .foregroundStyle(.white)
                        .font(.custom(Fonts.outfitSemiBold, size: 32))
                    Text(unit)
                        .foregroundStyle(AppColors.lightMacroTextColor)
                        .font(.custom(Fonts.interMedium, size: FontSize.md))
                }

                HStack(spacing: Spacing.xs) {
                    Image(systemName: "arrow.down.right")
                        .font(.system(size: 9, weight: .bold))
                    Text("\(change) \(changeLabel)")
                        .font(.custom(Fonts.interMedium, size: FontSize.xs))
                }
                .foregroundStyle(isNegative ? MacroColors.carbs : Color(red: 250/255, green: 100/255, blue: 100/255))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.xl)
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

    struct DateRangePicker: View {
        @Binding var selectedRange: DateRange

        var body: some View {
            HStack(spacing: 0) {
                ForEach(DateRange.allCases, id: \.self) { range in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedRange = range
                        }
                    } label: {
                        Text(range.rawValue)
                            .font(.custom(Fonts.interMedium, size: FontSize.sm))
                            .foregroundStyle(selectedRange == range ? .black : AppColors.lightMacroTextColor)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(selectedRange == range ? MacroColors.carbs : Color.clear)
                            )
                    }
                }
            }
            .padding(4)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(CardStyle.fillColor.opacity(CardStyle.fillOpacity))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.white.opacity(CardStyle.borderOpacity), lineWidth: CardStyle.borderWidth)
                    )
            )
            .padding(.horizontal, Spacing.xl)
        }
    }

    struct WeeklyAverage: Identifiable {
        let id = UUID()
        let date: Date
        let average: Double
    }

    struct WeightChart: View {
        let entries: [WeightEntry]

        private var weeklyAverages: [WeeklyAverage] {
            let calendar = Calendar.current
            let grouped = Dictionary(grouping: entries) { entry in
                calendar.dateInterval(of: .weekOfYear, for: entry.date)?.start ?? entry.date
            }
            return grouped.map { (weekStart, weekEntries) in
                let avg = weekEntries.map(\.weight).reduce(0, +) / Double(weekEntries.count)
                return WeeklyAverage(date: weekStart, average: avg)
            }
            .sorted { $0.date < $1.date }
        }

        private var yMin: Double {
            let allValues = entries.map(\.weight) + weeklyAverages.map(\.average)
            return (allValues.min() ?? 78) - 1.0
        }
        private var yMax: Double {
            let allValues = entries.map(\.weight) + weeklyAverages.map(\.average)
            return (allValues.max() ?? 84) + 0.5
        }

        var body: some View {
            Chart {
                ForEach(entries) { entry in
                    LineMark(
                        x: .value("Date", entry.date),
                        y: .value("Weight", entry.weight),
                        series: .value("Series", "Daily")
                    )
                    .foregroundStyle(MacroColors.carbs.opacity(0.35))
                    .interpolationMethod(.catmullRom)
                    .lineStyle(StrokeStyle(lineWidth: 1))

                    AreaMark(
                        x: .value("Date", entry.date),
                        y: .value("Weight", entry.weight)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [MacroColors.carbs.opacity(0.1), MacroColors.carbs.opacity(0.01)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .interpolationMethod(.catmullRom)
                }

                ForEach(weeklyAverages) { avg in
                    LineMark(
                        x: .value("Date", avg.date),
                        y: .value("Weight", avg.average),
                        series: .value("Series", "Weekly Avg")
                    )
                    .foregroundStyle(MacroColors.carbs)
                    .interpolationMethod(.catmullRom)
                    .lineStyle(StrokeStyle(lineWidth: 3))

                    PointMark(
                        x: .value("Date", avg.date),
                        y: .value("Weight", avg.average)
                    )
                    .foregroundStyle(MacroColors.carbs)
                    .symbolSize(20)
                }
            }
            .chartYScale(domain: yMin...yMax)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: 21)) { _ in
                    AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                        .foregroundStyle(AppColors.lightMacroTextColor)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading, values: .automatic(desiredCount: 4)) { _ in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4, 4]))
                        .foregroundStyle(Color.white.opacity(0.08))
                    AxisValueLabel()
                        .foregroundStyle(AppColors.lightMacroTextColor)
                }
            }
            .chartPlotStyle { plotArea in
                plotArea.clipped()
            }
            .frame(height: 200)
            .padding(.vertical, Spacing.lg)
        }
    }

    struct HistorySection: View {
        let entries: [WeightEntry]

        var body: some View {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                HStack {
                    Text("HISTORY")
                        .foregroundStyle(AppColors.lightMacroTextColor)
                        .font(.custom(Fonts.interMedium, size: FontSize.xs))
                        .tracking(1)

                    Spacer()

                    Text("\(entries.filter { $0.change != 0.0 }.count) entries")
                        .foregroundStyle(AppColors.lightMacroTextColor)
                        .font(.custom(Fonts.interRegular, size: FontSize.sm))
                }

                VStack(spacing: 0) {
                    ForEach(entries.reversed()) { entry in
                        if entry.change != 0.0 {
                            WeightHistoryRow(entry: entry)
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: CornerRadius.md)
                        .fill(CardStyle.fillColor.opacity(CardStyle.fillOpacity))
                        .overlay(
                            RoundedRectangle(cornerRadius: CornerRadius.sm)
                                .stroke(Color.white.opacity(CardStyle.borderOpacity), lineWidth: CardStyle.borderWidth)
                        )
                )
            }
        }
    }

    struct WeightHistoryRow: View {
        let entry: WeightEntry

        private static let dateFormatter: DateFormatter = {
            let f = DateFormatter()
            f.dateFormat = "MMM d, yyyy"
            return f
        }()

        private static let dayFormatter: DateFormatter = {
            let f = DateFormatter()
            f.dateFormat = "EEEE"
            return f
        }()

        var body: some View {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(Self.dateFormatter.string(from: entry.date))
                        .foregroundStyle(AppColors.lightMacroTextColor)
                        .font(.custom(Fonts.interRegular, size: FontSize.md))
                    Text(Self.dayFormatter.string(from: entry.date))
                        .foregroundStyle(AppColors.lightMacroTextColor.opacity(0.6))
                        .font(.custom(Fonts.interRegular, size: FontSize.sm))
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Text(entry.change >= 0 ? "+\(String(format: "%.1f", entry.change))" : "\(String(format: "%.1f", entry.change))")
                    .foregroundStyle(entry.change <= 0 ? MacroColors.carbs : Color(red: 250/255, green: 100/255, blue: 100/255))
                    .font(.custom(Fonts.interMedium, size: FontSize.md))
                    .frame(width: 50, alignment: .trailing)

                Text(String(format: "%.1f", entry.weight))
                    .foregroundStyle(.white)
                    .font(.custom(Fonts.interSemiBold, size: FontSize.lg))
                    .frame(width: 60, alignment: .trailing)
            }
            .padding(.vertical, 10)
        }
    }
}

#Preview {
    NavigationStack {
        BodyWeightView()
    }
}
