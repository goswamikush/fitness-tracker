//
//  BodyWeightView.swift
//  FitnessTracker
//
//  Created by Kush Goswami on 2/14/26.
//

import SwiftUI
import SwiftData
import Charts

enum DateRange: String, CaseIterable {
    case oneWeek = "1W"
    case oneMonth = "1M"
    case threeMonths = "3M"
    case sixMonths = "6M"
    case oneYear = "1Y"
    case max = "MAX"
}

struct BodyWeightView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \WeightEntry.date) private var entries: [WeightEntry]
    @State private var selectedRange: DateRange = .sixMonths
    @State private var selectedEntry: WeightEntry?

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
                    HistorySection(entries: entries, onSelect: { selectedEntry = $0 })
                }
                .padding(.horizontal)
            }
        }
        .navigationBarTitleDisplayMode(.large)
        .sheet(item: $selectedEntry) { entry in
            EditWeightSheet(entry: entry) {
                modelContext.delete(entry)
                selectedEntry = nil
            }
        }
        .onAppear {
            if entries.isEmpty {
                seedSampleData()
            }
        }
    }

    private func seedSampleData() {
        let calendar = Calendar.current
        let today = Date()
        let sampleData: [(Int, Double)] = [
            (-105, 83.2), (-104, 83.5), (-103, 83.0), (-101, 83.4),
            (-98, 82.8), (-97, 83.1), (-95, 82.6),
            (-91, 83.0), (-90, 82.7), (-88, 83.2), (-86, 82.5),
            (-84, 82.4), (-83, 82.8), (-81, 82.1),
            (-77, 81.8), (-76, 82.2), (-74, 81.5),
            (-70, 81.5), (-69, 81.9), (-67, 81.2),
            (-63, 80.9), (-62, 81.3), (-60, 80.6),
            (-56, 80.3), (-55, 80.7), (-53, 80.0),
            (-49, 80.1), (-48, 80.5), (-46, 79.8),
            (-42, 79.8), (-41, 80.2), (-39, 79.5),
            (-35, 79.5), (-34, 79.9), (-32, 79.2),
            (-28, 79.2), (-27, 79.6), (-25, 78.9),
            (-21, 79.0), (-20, 79.4), (-18, 78.7),
            (-14, 78.6), (-13, 79.1), (-11, 78.3),
            (-7, 78.8), (-5, 78.2), (-3, 78.9),
            (-1, 78.1), (0, 78.4),
        ]
        for (dayOffset, weight) in sampleData {
            let entry = WeightEntry(
                date: calendar.date(byAdding: .day, value: dayOffset, to: today)!,
                weight: weight
            )
            modelContext.insert(entry)
        }
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
        var onSelect: (WeightEntry) -> Void

        private var entriesWithChange: [(entry: WeightEntry, change: Double)] {
            entries.enumerated().map { (index, entry) in
                let change = index > 0 ? entry.weight - entries[index - 1].weight : 0.0
                return (entry: entry, change: change)
            }
        }

        var body: some View {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                HStack {
                    Text("HISTORY")
                        .foregroundStyle(AppColors.lightMacroTextColor)
                        .font(.custom(Fonts.interMedium, size: FontSize.xs))
                        .tracking(1)

                    Spacer()

                    Text("\(entries.count) entries")
                        .foregroundStyle(AppColors.lightMacroTextColor)
                        .font(.custom(Fonts.interRegular, size: FontSize.sm))
                }

                VStack(spacing: 0) {
                    ForEach(entriesWithChange.reversed(), id: \.entry.id) { item in
                        WeightHistoryRow(entry: item.entry, change: item.change)
                            .contentShape(Rectangle())
                            .onTapGesture { onSelect(item.entry) }
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
        let change: Double

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

                Text(change >= 0 ? "+\(String(format: "%.1f", change))" : "\(String(format: "%.1f", change))")
                    .foregroundStyle(change <= 0 ? MacroColors.carbs : Color(red: 250/255, green: 100/255, blue: 100/255))
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

    struct EditWeightSheet: View {
        @Environment(\.dismiss) private var dismiss
        let entry: WeightEntry
        let onDelete: () -> Void

        @State private var weightText: String = ""
        @State private var selectedDate: Date = Date()
        @State private var showDeleteConfirmation = false

        var body: some View {
            NavigationStack {
                ZStack {
                    AppColors.background
                        .ignoresSafeArea()

                    VStack(spacing: Spacing.xxl) {
                        Spacer()

                        TextField("", text: $weightText)
                            .foregroundStyle(.white)
                            .font(.custom(Fonts.outfitSemiBold, size: 48))
                            .multilineTextAlignment(.center)
                            .keyboardType(.decimalPad)

                        HStack(spacing: Spacing.md) {
                            Text("kg")
                                .font(.custom(Fonts.interMedium, size: FontSize.lg))
                                .foregroundStyle(MacroColors.carbs)

                            Circle()
                                .fill(AppColors.lightMacroTextColor)
                                .frame(width: IconSize.sm, height: IconSize.sm)

                            Text("EDIT WEIGHT")
                                .foregroundStyle(AppColors.lightMacroTextColor)
                                .font(.custom(Fonts.interMedium, size: FontSize.xs))
                                .tracking(1)
                        }

                        DatePicker("", selection: $selectedDate, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .labelsHidden()
                            .colorScheme(.dark)
                            .tint(MacroColors.carbs)
                            .padding(.horizontal, Spacing.xl)
                            .padding(.vertical, Spacing.lg)
                            .background(
                                RoundedRectangle(cornerRadius: CornerRadius.sm)
                                    .stroke(Color.white.opacity(CardStyle.borderOpacity), lineWidth: CardStyle.borderWidth)
                            )
                            .fixedSize()

                        Spacer()
                        Spacer()
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                            .foregroundStyle(AppColors.lightMacroTextColor)
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            if let newWeight = Double(weightText) {
                                entry.weight = newWeight
                                entry.date = selectedDate
                            }
                            dismiss()
                        }
                        .foregroundStyle(MacroColors.carbs)
                        .font(.custom(Fonts.interSemiBold, size: FontSize.lg))
                    }
                }
                .toolbarColorScheme(.dark, for: .navigationBar)
                .safeAreaInset(edge: .bottom) {
                    Button {
                        showDeleteConfirmation = true
                    } label: {
                        HStack(spacing: Spacing.md) {
                            Image(systemName: "trash")
                                .font(.system(size: FontSize.md, weight: .semibold))
                            Text("Delete Entry")
                                .font(.custom(Fonts.interSemiBold, size: FontSize.lg))
                        }
                        .foregroundStyle(Color(red: 250/255, green: 100/255, blue: 100/255))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: CornerRadius.sm)
                                .fill(Color(red: 250/255, green: 100/255, blue: 100/255).opacity(0.12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: CornerRadius.sm)
                                        .stroke(Color(red: 250/255, green: 100/255, blue: 100/255).opacity(0.25), lineWidth: 1)
                                )
                        )
                        .padding()
                    }
                    .confirmationDialog("Delete this entry?", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
                        Button("Delete", role: .destructive) {
                            onDelete()
                            dismiss()
                        }
                    }
                }
            }
            .onAppear {
                weightText = String(format: "%.1f", entry.weight)
                selectedDate = entry.date
            }
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
    }
}

#Preview {
    NavigationStack {
        BodyWeightView()
    }
    .modelContainer(for: WeightEntry.self, inMemory: true)
}
