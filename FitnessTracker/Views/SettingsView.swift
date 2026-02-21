//
//  SettingsView.swift
//  FitnessTracker
//

import SwiftUI

private enum GoalField: Hashable {
    case calorie, protein, carbs, fat
}

struct SettingsView: View {
    @Environment(UserGoals.self) private var userGoals
    @Environment(\.dismiss) private var dismiss

    @State private var calorieText = ""
    @State private var proteinText = ""
    @State private var carbsText   = ""
    @State private var fatText     = ""
    @FocusState private var focusedField: GoalField?

    private var calorie:       Int { Int(calorieText) ?? 0 }
    private var protein:       Int { Int(proteinText) ?? 0 }
    private var carbs:         Int { Int(carbsText)   ?? 0 }
    private var fat:           Int { Int(fatText)      ?? 0 }
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: Spacing.xxl) {
                    calorieSection
                    macroSection
                }
                .padding()
                .padding(.bottom, 90)
            }

            saveButton
        }
        .background(AppColors.background)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppColors.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Goals")
                    .foregroundColor(.white)
                    .font(.custom(Fonts.outfitSemiBold, size: 18))
            }
        }
        .onAppear {
            calorieText = "\(userGoals.calorieGoal)"
            proteinText = "\(userGoals.proteinGoal)"
            carbsText   = "\(userGoals.carbsGoal)"
            fatText     = "\(userGoals.fatGoal)"
        }
        .onChange(of: calorieText) { _, _ in
            guard focusedField == .calorie else { return }
            adjustOthers(changed: .calorie)
        }
        .onChange(of: proteinText) { _, _ in
            guard focusedField == .protein else { return }
            adjustOthers(changed: .protein)
        }
        .onChange(of: carbsText) { _, _ in
            guard focusedField == .carbs else { return }
            adjustOthers(changed: .carbs)
        }
        .onChange(of: fatText) { _, _ in
            guard focusedField == .fat else { return }
            adjustOthers(changed: .fat)
        }
    }

    // MARK: - Sections

    private var calorieSection: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            SectionLabel("CALORIE GOAL")
            HStack(alignment: .firstTextBaseline, spacing: Spacing.sm) {
                TextField("2400", text: $calorieText)
                    .foregroundColor(.white)
                    .font(.custom(Fonts.outfitSemiBold, size: 36))
                    .keyboardType(.numberPad)
                    .focused($focusedField, equals: .calorie)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("kcal / day")
                    .foregroundColor(AppColors.lightMacroTextColor)
                    .font(.custom(Fonts.interRegular, size: FontSize.lg))
            }
            .padding(Spacing.lg)
            .background(cardBG)
        }
    }

    private var macroSection: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            SectionLabel("MACRO GOALS")
            VStack(spacing: 0) {
                MacroRow(color: MacroColors.protein, name: "Protein", calPerGram: 4,
                         text: $proteinText, focusedField: $focusedField, fieldValue: .protein)
                Divider().overlay(Color.white.opacity(0.08))
                MacroRow(color: MacroColors.carbs, name: "Carbs", calPerGram: 4,
                         text: $carbsText, focusedField: $focusedField, fieldValue: .carbs)
                Divider().overlay(Color.white.opacity(0.08))
                MacroRow(color: MacroColors.fats, name: "Fat", calPerGram: 9,
                         text: $fatText, focusedField: $focusedField, fieldValue: .fat)
            }
            .background(cardBG)
        }
    }

    private var saveButton: some View {
        Button { save() } label: {
            HStack {
                Text("Save Goals")
                    .foregroundColor(.black)
                    .font(.custom(Fonts.interSemiBold, size: FontSize.xl))
                Spacer()
                Text("\(calorie) kcal")
                    .foregroundColor(.black.opacity(0.7))
                    .font(.custom(Fonts.outfitSemiBold, size: FontSize.xl))
            }
            .padding()
            .background(MacroColors.carbs)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.sm))
            .padding()
        }
        .disabled(calorie == 0)
    }

    private var cardBG: some View {
        RoundedRectangle(cornerRadius: CornerRadius.sm)
            .fill(CardStyle.fillColor.opacity(CardStyle.fillOpacity))
            .overlay(
                RoundedRectangle(cornerRadius: CornerRadius.sm)
                    .stroke(Color.white.opacity(CardStyle.borderOpacity), lineWidth: CardStyle.borderWidth)
            )
    }

    // MARK: - Auto-adjustment logic

    /// When one macro (or the calorie goal) changes, redistribute the remaining
    /// calories across the other two macros, preserving their current calorie ratio.
    private func adjustOthers(changed: GoalField) {
        let cal = calorie
        guard cal > 0 else { return }

        switch changed {
        case .calorie:
            // Scale all macros proportionally to the new calorie goal.
            let oldTotal = Double(protein * 4 + carbs * 4 + fat * 9)
            if oldTotal > 0 {
                let scale = Double(cal) / oldTotal
                proteinText = "\(max(Int((Double(protein) * scale).rounded()), 0))"
                carbsText   = "\(max(Int((Double(carbs)   * scale).rounded()), 0))"
                fatText     = "\(max(Int((Double(fat)     * scale).rounded()), 0))"
            } else {
                // No existing macros — default 30 / 40 / 30 % calorie split.
                proteinText = "\(Int(Double(cal) * 0.30 / 4))"
                carbsText   = "\(Int(Double(cal) * 0.40 / 4))"
                fatText     = "\(Int(Double(cal) * 0.30 / 9))"
            }

        case .protein:
            let remaining = max(cal - protein * 4, 0)
            let (newCarbs, newFat) = splitRemaining(remaining,
                                                    aGrams: carbs, aPerGram: 4,
                                                    bGrams: fat,   bPerGram: 9)
            carbsText = "\(newCarbs)"
            fatText   = "\(newFat)"

        case .carbs:
            let remaining = max(cal - carbs * 4, 0)
            let (newProtein, newFat) = splitRemaining(remaining,
                                                      aGrams: protein, aPerGram: 4,
                                                      bGrams: fat,     bPerGram: 9)
            proteinText = "\(newProtein)"
            fatText     = "\(newFat)"

        case .fat:
            let remaining = max(cal - fat * 9, 0)
            let (newProtein, newCarbs) = splitRemaining(remaining,
                                                        aGrams: protein, aPerGram: 4,
                                                        bGrams: carbs,   bPerGram: 4)
            proteinText = "\(newProtein)"
            carbsText   = "\(newCarbs)"
        }
    }

    /// Splits `remainingKcal` between two macros (a and b) while preserving
    /// their current calorie ratio. Returns grams for each.
    private func splitRemaining(_ remainingKcal: Int,
                                aGrams: Int, aPerGram: Int,
                                bGrams: Int, bPerGram: Int) -> (Int, Int) {
        let aKcal = aGrams * aPerGram
        let bKcal = bGrams * bPerGram
        let total = aKcal + bKcal

        let newAKcal: Int
        if total == 0 {
            newAKcal = remainingKcal / 2       // equal split when both are zero
        } else {
            newAKcal = Int((Double(remainingKcal) * Double(aKcal) / Double(total)).rounded())
        }
        let newBKcal = remainingKcal - newAKcal
        return (newAKcal / aPerGram, newBKcal / bPerGram)
    }

    private func save() {
        guard calorie > 0 else { return }
        userGoals.calorieGoal = calorie
        userGoals.proteinGoal = protein
        userGoals.carbsGoal   = carbs
        userGoals.fatGoal     = fat
        userGoals.save()
        dismiss()
    }
}

// MARK: - Subcomponents

private extension SettingsView {

    struct SectionLabel: View {
        let title: String
        init(_ title: String) { self.title = title }
        var body: some View {
            Text(title)
                .foregroundStyle(AppColors.lightMacroTextColor)
                .font(.custom(Fonts.interMedium, size: FontSize.xs))
                .tracking(1)
        }
    }

    struct MacroRow: View {
        let color: Color
        let name: String
        let calPerGram: Int
        @Binding var text: String
        var focusedField: FocusState<GoalField?>.Binding
        let fieldValue: GoalField

        private var grams: Int { Int(text) ?? 0 }
        private var kcal:  Int { grams * calPerGram }

        var body: some View {
            HStack(spacing: Spacing.lg) {
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)

                Text(name)
                    .foregroundColor(.white)
                    .font(.custom(Fonts.interMedium, size: FontSize.lg))
                    .frame(width: 70, alignment: .leading)

                Spacer()

                TextField("0", text: $text)
                    .foregroundColor(.white)
                    .font(.custom(Fonts.interSemiBold, size: FontSize.lg))
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .focused(focusedField, equals: fieldValue)
                    .frame(width: 55)

                Text("g")
                    .foregroundColor(AppColors.macroTextColor)
                    .font(.custom(Fonts.interRegular, size: FontSize.md))

                Text("\(kcal) kcal")
                    .foregroundColor(AppColors.lightMacroTextColor)
                    .font(.custom(Fonts.interRegular, size: FontSize.sm))
                    .frame(width: 70, alignment: .trailing)
            }
            .padding(Spacing.lg)
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
    .environment(UserGoals())
}
