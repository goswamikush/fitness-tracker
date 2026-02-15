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
            WeightEntry(date: calendar.date(byAdding: .day, value: -105, to: today)!, weight: 83.2, change: 0.0),
            WeightEntry(date: calendar.date(byAdding: .day, value: -98, to: today)!, weight: 82.8, change: -0.4),
            WeightEntry(date: calendar.date(byAdding: .day, value: -91, to: today)!, weight: 83.0, change: 0.2),
            WeightEntry(date: calendar.date(byAdding: .day, value: -84, to: today)!, weight: 82.4, change: -0.6),
            WeightEntry(date: calendar.date(byAdding: .day, value: -77, to: today)!, weight: 81.8, change: -0.6),
            WeightEntry(date: calendar.date(byAdding: .day, value: -70, to: today)!, weight: 81.5, change: -0.3),
            WeightEntry(date: calendar.date(byAdding: .day, value: -63, to: today)!, weight: 80.9, change: -0.6),
            WeightEntry(date: calendar.date(byAdding: .day, value: -56, to: today)!, weight: 80.3, change: -0.6),
            WeightEntry(date: calendar.date(byAdding: .day, value: -49, to: today)!, weight: 80.1, change: -0.2),
            WeightEntry(date: calendar.date(byAdding: .day, value: -42, to: today)!, weight: 79.8, change: -0.3),
            WeightEntry(date: calendar.date(byAdding: .day, value: -35, to: today)!, weight: 79.5, change: -0.3),
            WeightEntry(date: calendar.date(byAdding: .day, value: -28, to: today)!, weight: 79.2, change: -0.3),
            WeightEntry(date: calendar.date(byAdding: .day, value: -21, to: today)!, weight: 79.0, change: -0.2),
            WeightEntry(date: calendar.date(byAdding: .day, value: -14, to: today)!, weight: 78.6, change: -0.4),
            WeightEntry(date: calendar.date(byAdding: .day, value: -7, to: today)!, weight: 78.8, change: 0.2),
            WeightEntry(date: calendar.date(byAdding: .day, value: 0, to: today)!, weight: 78.4, change: -0.4),
        ]
    }()

    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: Spacing.xl) {
                    Header()
                    CurrentWeightSection()
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

    struct CurrentWeightSection: View {
        var body: some View {
            VStack(spacing: Spacing.sm) {
                Text("CURRENT WEIGHT")
                    .foregroundStyle(AppColors.lightMacroTextColor)
                    .font(.custom(Fonts.interMedium, size: FontSize.xs))
                    .tracking(1)

                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("78.4")
                        .foregroundStyle(.white)
                        .font(.custom(Fonts.outfitSemiBold, size: 48))

                    Text("kg")
                        .foregroundStyle(AppColors.lightMacroTextColor)
                        .font(.custom(Fonts.interMedium, size: 20))
                }

                Text("-0.2kg this week")
                    .foregroundStyle(MacroColors.carbs)
                    .font(.custom(Fonts.interMedium, size: FontSize.sm))
                    .padding(.top, Spacing.xs)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.lg)
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

    struct WeightChart: View {
        let entries: [WeightEntry]

        private var yMin: Double {
            (entries.map(\.weight).min() ?? 78) - 1.0
        }
        private var yMax: Double {
            (entries.map(\.weight).max() ?? 84) + 0.5
        }

        var body: some View {
            Chart(entries) { entry in
                LineMark(
                    x: .value("Date", entry.date),
                    y: .value("Weight", entry.weight)
                )
                .foregroundStyle(MacroColors.carbs)
                .interpolationMethod(.catmullRom)
                .lineStyle(StrokeStyle(lineWidth: 2))

                AreaMark(
                    x: .value("Date", entry.date),
                    y: .value("Weight", entry.weight)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [MacroColors.carbs.opacity(0.15), MacroColors.carbs.opacity(0.02)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .interpolationMethod(.catmullRom)
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
