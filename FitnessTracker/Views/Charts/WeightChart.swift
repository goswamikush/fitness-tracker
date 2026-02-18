//
//  WeightChart.swift
//  FitnessTracker
//
//  Created by Kush Goswami on 2/14/26.
//

import SwiftUI
import Charts

// MARK: - Constants

private enum ChartLayout {
    static let height: CGFloat = 200
    static let dailyLineWidth: CGFloat = 1
    static let weeklyLineWidth: CGFloat = 3
    static let weeklyDotSize: CGFloat = 20
    static let xAxisStrideDays: Int = 21
    static let yAxisLineCount: Int = 4
    static let gridLineWidth: CGFloat = 0.5
    static let gridDash: [CGFloat] = [4, 4]
    static let gridOpacity: Double = 0.08
    static let dailyLineOpacity: Double = 0.35
    static let areaGradientTop: Double = 0.1
    static let areaGradientBottom: Double = 0.01
    static let yPaddingBottom: Double = 1.0
    static let yPaddingTop: Double = 0.5
    static let defaultYMin: Double = 78
    static let defaultYMax: Double = 84
}

// MARK: - Models

struct WeeklyAverage: Identifiable {
    let id = UUID()
    let date: Date
    let average: Double
}

// MARK: - View

struct WeightChart: View {
    let entries: [WeightEntry]
    let selectedRange: DateRange

    private var showWeeklyAverages: Bool {
        selectedRange != .oneWeek
    }

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
        var allValues = entries.map(\.weight)
        if showWeeklyAverages { allValues += weeklyAverages.map(\.average) }
        return (allValues.min() ?? ChartLayout.defaultYMin) - ChartLayout.yPaddingBottom
    }
    private var yMax: Double {
        var allValues = entries.map(\.weight)
        if showWeeklyAverages { allValues += weeklyAverages.map(\.average) }
        return (allValues.max() ?? ChartLayout.defaultYMax) + ChartLayout.yPaddingTop
    }

    var body: some View {
        Chart {
            ForEach(entries) { entry in
                LineMark(
                    x: .value("Date", entry.date),
                    y: .value("Weight", entry.weight),
                    series: .value("Series", "Daily")
                )
                .foregroundStyle(MacroColors.carbs.opacity(ChartLayout.dailyLineOpacity))
                .interpolationMethod(.monotone)
                .lineStyle(StrokeStyle(lineWidth: ChartLayout.dailyLineWidth))

                AreaMark(
                    x: .value("Date", entry.date),
                    yStart: .value("Min", yMin),
                    yEnd: .value("Weight", entry.weight),
                    series: .value("Series", "Daily")
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            MacroColors.carbs.opacity(ChartLayout.areaGradientTop),
                            MacroColors.carbs.opacity(ChartLayout.areaGradientBottom),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .interpolationMethod(.monotone)
            }

            if showWeeklyAverages {
                ForEach(weeklyAverages) { avg in
                    LineMark(
                        x: .value("Date", avg.date),
                        y: .value("Weight", avg.average),
                        series: .value("Series", "Weekly Avg")
                    )
                    .foregroundStyle(MacroColors.carbs)
                    .interpolationMethod(.monotone)
                    .lineStyle(StrokeStyle(lineWidth: ChartLayout.weeklyLineWidth))

                    PointMark(
                        x: .value("Date", avg.date),
                        y: .value("Weight", avg.average)
                    )
                    .foregroundStyle(MacroColors.carbs)
                    .symbolSize(ChartLayout.weeklyDotSize)
                }
            }
        }
        .chartYScale(domain: yMin...yMax)
        .chartXAxis {
            AxisMarks(values: .stride(by: .day, count: ChartLayout.xAxisStrideDays)) { _ in
                AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                    .foregroundStyle(AppColors.lightMacroTextColor)
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading, values: .automatic(desiredCount: ChartLayout.yAxisLineCount)) { _ in
                AxisGridLine(stroke: StrokeStyle(lineWidth: ChartLayout.gridLineWidth, dash: ChartLayout.gridDash))
                    .foregroundStyle(Color.white.opacity(ChartLayout.gridOpacity))
                AxisValueLabel()
                    .foregroundStyle(AppColors.lightMacroTextColor)
            }
        }
        .chartPlotStyle { plotArea in
            plotArea.clipped()
        }
        .frame(height: ChartLayout.height)
        .padding(.vertical, Spacing.lg)
    }
}
