//
//  WeightHistorySection.swift
//  FitnessTracker
//
//  Created by Kush Goswami on 2/14/26.
//

import SwiftUI

private enum HistoryLayout {
    static let changeColumnWidth: CGFloat = 50
    static let weightColumnWidth: CGFloat = 60
    static let rowVerticalPadding: CGFloat = 10
    static let dateSpacing: CGFloat = 2
    static let subtitleOpacity: Double = 0.6
}

struct WeightHistorySection: View {
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
            VStack(alignment: .leading, spacing: HistoryLayout.dateSpacing) {
                Text(Self.dateFormatter.string(from: entry.date))
                    .foregroundStyle(AppColors.lightMacroTextColor)
                    .font(.custom(Fonts.interRegular, size: FontSize.md))
                Text(Self.dayFormatter.string(from: entry.date))
                    .foregroundStyle(AppColors.lightMacroTextColor.opacity(HistoryLayout.subtitleOpacity))
                    .font(.custom(Fonts.interRegular, size: FontSize.sm))
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Text(change >= 0 ? "+\(String(format: "%.1f", change))" : "\(String(format: "%.1f", change))")
                .foregroundStyle(change <= 0 ? MacroColors.carbs : AppColors.negative)
                .font(.custom(Fonts.interMedium, size: FontSize.md))
                .frame(width: HistoryLayout.changeColumnWidth, alignment: .trailing)

            Text(String(format: "%.1f", entry.weight))
                .foregroundStyle(.white)
                .font(.custom(Fonts.interSemiBold, size: FontSize.lg))
                .frame(width: HistoryLayout.weightColumnWidth, alignment: .trailing)
        }
        .padding(.vertical, HistoryLayout.rowVerticalPadding)
    }
}
