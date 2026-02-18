//
//  AddWeightView.swift
//  FitnessTracker
//
//  Created by Kush Goswami on 2/15/26.
//

import SwiftUI
import SwiftData

enum WeightUnit: String, CaseIterable {
    case kg = "kg"
    case lbs = "lbs"
}

struct AddWeightView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \WeightEntry.date, order: .reverse) private var entries: [WeightEntry]

    @State private var weightText = ""
    @State private var selectedDate = Date()
    @State private var selectedUnit: WeightUnit = .kg

    private var lastWeight: Double? {
        entries.first?.weight
    }

    private var change: Double? {
        guard let current = Double(weightText), let last = lastWeight else { return nil }
        let currentKg = selectedUnit == .lbs ? current / 2.20462 : current
        return currentKg - last
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            AppColors.background
                .ignoresSafeArea()

            VStack(spacing: Spacing.xxl) {
                Spacer()

                WeightInput(weightText: $weightText)

                WeightLabel(selectedUnit: $selectedUnit)

                if let change {
                    ChangeFromLast(change: change, unit: selectedUnit)
                }

                DatePickerRow(selectedDate: $selectedDate)

                Spacer()
                Spacer()
            }

            SaveButton {
                    guard let value = Double(weightText) else { return }
                    let kg = selectedUnit == .lbs ? value / 2.20462 : value
                    let entry = WeightEntry(date: selectedDate, weight: kg, unit: selectedUnit.rawValue)
                    modelContext.insert(entry)
                    dismiss()
                }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear {
            if weightText.isEmpty, let last = lastWeight {
                weightText = String(format: "%.1f", last)
            }
        }
    }
}

// MARK: - Subcomponents

private extension AddWeightView {

    struct WeightInput: View {
        @Binding var weightText: String
        @FocusState private var isFocused: Bool

        var body: some View {
            TextField("", text: $weightText)
                .foregroundStyle(.white)
                .font(.custom(Fonts.outfitSemiBold, size: 48))
                .multilineTextAlignment(.center)
                .keyboardType(.decimalPad)
                .focused($isFocused)
                .onAppear { isFocused = true }
        }
    }

    struct WeightLabel: View {
        @Binding var selectedUnit: WeightUnit

        var body: some View {
            HStack(spacing: Spacing.md) {
                UnitToggle(selectedUnit: $selectedUnit)

                Circle()
                    .fill(AppColors.lightMacroTextColor)
                    .frame(width: IconSize.sm, height: IconSize.sm)

                Text("CURRENT WEIGHT")
                    .foregroundStyle(AppColors.lightMacroTextColor)
                    .font(.custom(Fonts.interMedium, size: FontSize.xs))
                    .tracking(1)
            }
        }
    }

    struct UnitToggle: View {
        @Binding var selectedUnit: WeightUnit

        var body: some View {
            HStack(spacing: 0) {
                ForEach(WeightUnit.allCases, id: \.self) { unit in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedUnit = unit
                        }
                    } label: {
                        Text(unit.rawValue)
                            .font(.custom(Fonts.interMedium, size: FontSize.md))
                            .foregroundStyle(selectedUnit == unit ? .black : AppColors.lightMacroTextColor)
                            .padding(.horizontal, Spacing.lg)
                            .padding(.vertical, Spacing.sm)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(selectedUnit == unit ? MacroColors.carbs : Color.clear)
                            )
                    }
                }
            }
            .padding(3)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(CardStyle.fillColor.opacity(CardStyle.fillOpacity))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.white.opacity(CardStyle.borderOpacity), lineWidth: CardStyle.borderWidth)
                    )
            )
        }
    }

    struct ChangeFromLast: View {
        let change: Double
        let unit: WeightUnit

        private var isLoss: Bool { change <= 0 }

        var body: some View {
            HStack(spacing: Spacing.sm) {
                Image(systemName: isLoss ? "arrow.down.right" : "arrow.up.right")
                    .font(.system(size: FontSize.sm, weight: .medium))

                Text("\(change >= 0 ? "+" : "")\(String(format: "%.1f", change)) \(unit.rawValue) since last weigh-in")
                    .font(.custom(Fonts.interMedium, size: FontSize.sm))
            }
            .foregroundStyle(isLoss ? MacroColors.carbs : Color(red: 250/255, green: 100/255, blue: 100/255))
        }
    }

    struct DatePickerRow: View {
        @Binding var selectedDate: Date

        var body: some View {
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
        }
    }

    struct SaveButton: View {
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                HStack(spacing: Spacing.md) {
                    Image(systemName: "checkmark")
                        .font(.system(size: FontSize.lg, weight: .semibold))
                        .foregroundColor(.black)
                    Text("Save Entry")
                        .foregroundColor(.black)
                        .font(.custom(Fonts.interSemiBold, size: FontSize.xl))
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(MacroColors.carbs)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.sm))
                .padding()
            }
        }
    }
}

#Preview {
    NavigationStack {
        AddWeightView()
    }
    .modelContainer(for: WeightEntry.self, inMemory: true)
}
