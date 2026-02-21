//
//  WaterCard.swift
//  FitnessTracker
//

import SwiftUI
import SwiftData

// MARK: - Unit

enum WaterUnit: String, CaseIterable {
    case ml, oz

    static let mlPerOz: Double = 29.5735

    func fromMl(_ ml: Double) -> Double {
        self == .ml ? ml : ml / WaterUnit.mlPerOz
    }

    func toMl(_ value: Double) -> Double {
        self == .ml ? value : value * WaterUnit.mlPerOz
    }

    func format(_ ml: Double) -> String {
        let v = fromMl(ml)
        return self == .ml ? "\(Int(v))" : String(format: "%.1f", v)
    }

    func goalLabel(_ goalMl: Double) -> String {
        self == .ml
            ? "\(Int(goalMl)) ml"
            : String(format: "%.0f oz", fromMl(goalMl))
    }
}

// MARK: - WaterCard

struct WaterCard: View {
    @Environment(\.modelContext) private var modelContext

    let entries: [WaterEntry]
    let logDate: Date

    @State private var unit: WaterUnit = .ml
    @State private var showingInput = false

    private let goalMl: Double = 2500

    private var totalMl: Double { entries.reduce(0) { $0 + $1.amountMl } }
    private var progress: Double { min(totalMl / goalMl, 1.0) }
    private var progressPercent: Int { Int((totalMl / goalMl) * 100) }

    private var quickAmounts: [(label: String, ml: Double)] {
        unit == .ml
            ? [("250 ml", 250), ("500 ml", 500), ("750 ml", 750)]
            : [("8 oz", 8 * WaterUnit.mlPerOz), ("12 oz", 12 * WaterUnit.mlPerOz), ("16 oz", 16 * WaterUnit.mlPerOz)]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            headerRow
            amountRow
            progressBar
            quickAddRow
        }
        .padding(Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: CornerRadius.md)
                .fill(CardStyle.fillColor.opacity(CardStyle.fillOpacity))
                .overlay(
                    RoundedRectangle(cornerRadius: CornerRadius.sm)
                        .stroke(Color.white.opacity(CardStyle.borderOpacity), lineWidth: CardStyle.borderWidth)
                )
        )
        .sheet(isPresented: $showingInput) {
            WaterInputSheet(currentUnit: unit) { amountMl in
                addEntry(ml: amountMl)
            }
            .presentationDetents([.height(280)])
            .presentationBackground(AppColors.cardBackground)
            .presentationDragIndicator(.visible)
        }
    }

    // MARK: Sub-views

    private var headerRow: some View {
        HStack {
            HStack(spacing: Spacing.md) {
                Image(systemName: "drop.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(MacroColors.protein)
                Text("Water")
                    .foregroundStyle(.white)
                    .font(.custom(Fonts.outfitSemiBold, size: FontSize.xl))
            }
            Spacer()
            UnitToggle(selected: $unit)
        }
    }

    private var amountRow: some View {
        HStack(alignment: .firstTextBaseline, spacing: 5) {
            Text(unit.format(totalMl))
                .foregroundStyle(.white)
                .font(.custom(Fonts.outfitSemiBold, size: 20))
            Text(unit.rawValue)
                .foregroundStyle(AppColors.macroTextColor)
                .font(.custom(Fonts.interRegular, size: FontSize.lg))
            Text("/ \(unit.goalLabel(goalMl))")
                .foregroundStyle(AppColors.lightMacroTextColor)
                .font(.custom(Fonts.interRegular, size: FontSize.md))
            Spacer()
            Text("\(progressPercent)%")
                .foregroundStyle(MacroColors.protein)
                .font(.custom(Fonts.interSemiBold, size: FontSize.lg))
        }
    }

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(MacroColors.protein.opacity(0.15))
                RoundedRectangle(cornerRadius: 4)
                    .fill(MacroColors.protein)
                    .frame(width: geo.size.width * progress)
                    .animation(.easeOut(duration: 0.3), value: progress)
            }
        }
        .frame(height: 6)
    }

    private var quickAddRow: some View {
        HStack(spacing: Spacing.sm) {
            // Preset amounts
            ForEach(quickAmounts, id: \.label) { amount in
                Button {
                    addEntry(ml: amount.ml)
                } label: {
                    Text("+\(amount.label)")
                        .foregroundStyle(MacroColors.protein)
                        .font(.custom(Fonts.interMedium, size: FontSize.sm))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Spacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(MacroColors.protein.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(MacroColors.protein.opacity(0.25), lineWidth: 1)
                                )
                        )
                }
            }

            // Custom amount button — green accent to stand apart from presets
            Button { showingInput = true } label: {
                Image(systemName: "pencil")
                    .foregroundStyle(MacroColors.carbs)
                    .font(.system(size: 13, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Spacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(MacroColors.carbs.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(MacroColors.carbs.opacity(0.3), lineWidth: 1)
                            )
                    )
            }
        }
    }

    // MARK: Helpers

    private func addEntry(ml: Double) {
        let entry = WaterEntry(date: logDate, amountMl: ml)
        modelContext.insert(entry)
    }
}

// MARK: - Unit Toggle

private struct UnitToggle: View {
    @Binding var selected: WaterUnit

    var body: some View {
        HStack(spacing: 2) {
            ForEach(WaterUnit.allCases, id: \.self) { unit in
                Button {
                    withAnimation(.easeInOut(duration: 0.15)) { selected = unit }
                } label: {
                    Text(unit.rawValue)
                        .foregroundStyle(selected == unit ? .black : AppColors.macroTextColor)
                        .font(.custom(Fonts.interMedium, size: FontSize.sm))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(selected == unit ? MacroColors.protein : Color.clear)
                        )
                }
            }
        }
        .padding(3)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.07))
        )
    }
}

// MARK: - Custom Input Sheet

private struct WaterInputSheet: View {
    @Environment(\.dismiss) private var dismiss

    let currentUnit: WaterUnit
    let onAdd: (Double) -> Void

    @State private var amountText: String = ""
    @State private var unit: WaterUnit
    @FocusState private var focused: Bool

    init(currentUnit: WaterUnit, onAdd: @escaping (Double) -> Void) {
        self.currentUnit = currentUnit
        self.onAdd = onAdd
        self._unit = State(initialValue: currentUnit)
    }

    var body: some View {
        VStack(spacing: Spacing.xl) {
            // Title
            Text("Log Water")
                .foregroundStyle(.white)
                .font(.custom(Fonts.outfitSemiBold, size: FontSize.xl))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, Spacing.lg)

            // Input row
            HStack(spacing: Spacing.lg) {
                TextField("0", text: $amountText)
                    .foregroundColor(.white)
                    .font(.custom(Fonts.outfitSemiBold, size: 40))
                    .keyboardType(.decimalPad)
                    .focused($focused)
                    .frame(maxWidth: .infinity)

                // Unit selector
                VStack(spacing: Spacing.sm) {
                    ForEach(WaterUnit.allCases, id: \.self) { u in
                        Button {
                            // Convert existing text when switching units
                            if let v = Double(amountText), v > 0 {
                                let inMl = unit.toMl(v)
                                amountText = u.format(inMl)
                            }
                            unit = u
                        } label: {
                            Text(u.rawValue)
                                .foregroundStyle(unit == u ? .black : AppColors.macroTextColor)
                                .font(.custom(Fonts.interSemiBold, size: FontSize.md))
                                .padding(.horizontal, Spacing.lg)
                                .padding(.vertical, Spacing.sm)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(unit == u ? MacroColors.protein : Color.white.opacity(0.08))
                                )
                        }
                    }
                }
            }
            .padding(Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.sm)
                    .stroke(Color.white.opacity(CardStyle.borderOpacity), lineWidth: CardStyle.borderWidth)
            )

            // Add button
            Button {
                guard let value = Double(amountText), value > 0 else { return }
                onAdd(unit.toMl(value))
                dismiss()
            } label: {
                HStack {
                    Text("Add Water")
                        .foregroundColor(.black)
                        .font(.custom(Fonts.interSemiBold, size: FontSize.xl))
                    Spacer()
                    HStack(spacing: 4) {
                        Text(amountText.isEmpty ? "0" : amountText)
                            .foregroundColor(.black)
                            .font(.custom(Fonts.outfitSemiBold, size: FontSize.xl))
                        Text(unit.rawValue)
                            .foregroundColor(.black.opacity(0.7))
                            .font(.custom(Fonts.interRegular, size: FontSize.lg))
                    }
                }
                .padding()
                .background(MacroColors.protein)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.sm))
            }

            Spacer()
        }
        .padding(.horizontal, Spacing.lg)
        .background(AppColors.cardBackground)
        .onAppear { focused = true }
    }
}

#Preview {
    ZStack {
        AppColors.background.ignoresSafeArea()
        WaterCard(entries: [], logDate: Date())
            .padding()
    }
}
