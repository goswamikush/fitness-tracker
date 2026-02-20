//
//  BodyWeightView.swift
//  FitnessTracker
//
//  Created by Kush Goswami on 2/14/26.
//

import SwiftUI
import SwiftData

// MARK: - Constants

private enum BodyWeightLayout {
    static let headerFontSize: CGFloat = 22
    static let animationDuration: Double = 0.2
    static let pickerItemPadding: CGFloat = 8
    static let pickerItemCornerRadius: CGFloat = 8
    static let pickerInnerPadding: CGFloat = 4
    static let pickerCornerRadius: CGFloat = 10
}

// MARK: - DateRange

enum DateRange: String, CaseIterable {
    case oneWeek = "1W"
    case oneMonth = "1M"
    case threeMonths = "3M"
    case sixMonths = "6M"
    case oneYear = "1Y"
    case max = "MAX"

    var cutoffDate: Date? {
        let calendar = Calendar.current
        let today = Date()
        switch self {
        case .oneWeek: return calendar.date(byAdding: .day, value: -7, to: today)
        case .oneMonth: return calendar.date(byAdding: .month, value: -1, to: today)
        case .threeMonths: return calendar.date(byAdding: .month, value: -3, to: today)
        case .sixMonths: return calendar.date(byAdding: .month, value: -6, to: today)
        case .oneYear: return calendar.date(byAdding: .year, value: -1, to: today)
        case .max: return nil
        }
    }
}

// MARK: - View

struct BodyWeightView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \WeightEntry.date) private var entries: [WeightEntry]
    @State private var selectedRange: DateRange = .sixMonths
    @State private var selectedEntry: WeightEntry?

    private var filteredEntries: [WeightEntry] {
        guard let cutoff = selectedRange.cutoffDate else { return entries }
        return entries.filter { $0.date >= cutoff }
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
                        WeightSummaryCards(entries: entries)
                        DateRangePicker(selectedRange: $selectedRange)
                        WeightChart(entries: filteredEntries, selectedRange: selectedRange)
                        WeightHistorySection(entries: filteredEntries, onSelect: { selectedEntry = $0 })
                    }
                    .padding(.horizontal)
                    .padding(.top, Spacing.lg)
                }
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
                        .font(.custom(Fonts.outfitSemiBold, size: BodyWeightLayout.headerFontSize))

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

    struct DateRangePicker: View {
        @Binding var selectedRange: DateRange

        var body: some View {
            HStack(spacing: 0) {
                ForEach(DateRange.allCases, id: \.self) { range in
                    Button {
                        withAnimation(.easeInOut(duration: BodyWeightLayout.animationDuration)) {
                            selectedRange = range
                        }
                    } label: {
                        Text(range.rawValue)
                            .font(.custom(Fonts.interMedium, size: FontSize.sm))
                            .foregroundStyle(selectedRange == range ? .black : AppColors.lightMacroTextColor)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, BodyWeightLayout.pickerItemPadding)
                            .background(
                                RoundedRectangle(cornerRadius: BodyWeightLayout.pickerItemCornerRadius)
                                    .fill(selectedRange == range ? MacroColors.carbs : Color.clear)
                            )
                    }
                }
            }
            .padding(BodyWeightLayout.pickerInnerPadding)
            .background(
                RoundedRectangle(cornerRadius: BodyWeightLayout.pickerCornerRadius)
                    .fill(CardStyle.fillColor.opacity(CardStyle.fillOpacity))
                    .overlay(
                        RoundedRectangle(cornerRadius: BodyWeightLayout.pickerCornerRadius)
                            .stroke(Color.white.opacity(CardStyle.borderOpacity), lineWidth: CardStyle.borderWidth)
                    )
            )
            .padding(.horizontal, Spacing.xl)
        }
    }
}

#Preview {
    NavigationStack {
        BodyWeightView()
    }
    .modelContainer(for: WeightEntry.self, inMemory: true)
}
