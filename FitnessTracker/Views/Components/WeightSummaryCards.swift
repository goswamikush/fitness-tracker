//
//  WeightSummaryCards.swift
//  FitnessTracker
//
//  Created by Kush Goswami on 2/14/26.
//

import SwiftUI

private enum SummaryCardLayout {
    static let valueFontSize: CGFloat = 32
    static let changeIconSize: CGFloat = 9
    static let baselineSpacing: CGFloat = 2
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

            HStack(alignment: .firstTextBaseline, spacing: SummaryCardLayout.baselineSpacing) {
                Text(value)
                    .foregroundStyle(.white)
                    .font(.custom(Fonts.outfitSemiBold, size: SummaryCardLayout.valueFontSize))
                Text(unit)
                    .foregroundStyle(AppColors.lightMacroTextColor)
                    .font(.custom(Fonts.interMedium, size: FontSize.md))
            }

            HStack(spacing: Spacing.xs) {
                Image(systemName: "arrow.down.right")
                    .font(.system(size: SummaryCardLayout.changeIconSize, weight: .bold))
                Text("\(change) \(changeLabel)")
                    .font(.custom(Fonts.interMedium, size: FontSize.xs))
            }
            .foregroundStyle(isNegative ? MacroColors.carbs : AppColors.negative)
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
