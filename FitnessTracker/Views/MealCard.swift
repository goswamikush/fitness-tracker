//
//  MealCard.swift
//  FitnessTracker
//
//  Created by Kush Goswami on 2/2/26.
//

import SwiftUI

struct MealCard: View {
    var isEmpty: Bool = false
    @State private var isExpanded = true

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            if isEmpty {
                EmptyContent(isExpanded: $isExpanded)
            } else if isExpanded {
                ExpandedContent(isExpanded: $isExpanded)
            } else {
                CollapsedContent(isExpanded: $isExpanded)
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
        .shadow(color: .black.opacity(CardStyle.shadowOpacity), radius: CardStyle.shadowRadius, x: 0, y: CardStyle.shadowY)
        .mask(
            Rectangle()
                .padding(.bottom, CardStyle.maskPadding)
        )
        .animation(.easeInOut(duration: 0.25), value: isExpanded)
    }
}

// MARK: - Subcomponents

private extension MealCard {

    struct EmptyContent: View {
        @Binding var isExpanded: Bool

        var body: some View {
            VStack(spacing: Spacing.xl) {
                HStack {
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("Dinner")
                            .foregroundStyle(.white)
                            .font(.custom(Fonts.outfitSemiBold, size: FontSize.xl))
                        Text("No food logged")
                            .foregroundStyle(AppColors.lightMacroTextColor)
                            .font(.custom(Fonts.interRegular, size: FontSize.sm))
                    }

                    Spacer()

                    HStack(spacing: Spacing.xl) {
                        NavigationLink(destination: AddFoodView(mealName: "Dinner")) {
                            Image(systemName: "plus")
                                .font(.system(size: IconSize.lg, weight: .medium))
                                .foregroundColor(AppColors.macroTextColor)
                        }

                        Button {
                            isExpanded.toggle()
                        } label: {
                            Image(systemName: "chevron.up")
                                .font(.system(size: IconSize.lg, weight: .medium))
                                .foregroundColor(AppColors.macroTextColor)
                        }
                    }
                }

                NavigationLink(destination: AddFoodView(mealName: "Dinner")) {
                    Text("Tap + to add food")
                        .foregroundStyle(AppColors.lightMacroTextColor)
                        .font(.custom(Fonts.interRegular, size: FontSize.md))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Spacing.lg)
                        .background(
                            RoundedRectangle(cornerRadius: CornerRadius.sm)
                                .stroke(style: StrokeStyle(lineWidth: 1, dash: [6]))
                                .foregroundStyle(Color.white.opacity(0.15))
                        )
                }
            }
        }
    }

    struct ExpandedContent: View {
        @Binding var isExpanded: Bool

        var body: some View {
            VStack(spacing: Spacing.xxl) {
                ExpandedHeader(isExpanded: $isExpanded)
                FoodItem()
                FoodItem()
                Footer()
            }
        }
    }

    struct CollapsedContent: View {
        @Binding var isExpanded: Bool

        var body: some View {
            HStack {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Lunch")
                        .foregroundStyle(.white)
                        .font(.custom(Fonts.outfitSemiBold, size: FontSize.xl))
                    Text("2 items")
                        .foregroundStyle(AppColors.lightMacroTextColor)
                        .font(.custom(Fonts.interRegular, size: FontSize.sm))
                }

                Spacer()

                HStack(spacing: Spacing.lg) {
                    HStack(spacing: Spacing.xs) {
                        Circle()
                            .fill(MacroColors.protein)
                            .frame(width: IconSize.md, height: IconSize.md)
                        Text("36p")
                            .foregroundStyle(AppColors.lightMacroTextColor)
                            .font(.custom(Fonts.interRegular, size: FontSize.sm))
                    }

                    HStack(spacing: Spacing.xs) {
                        Circle()
                            .fill(MacroColors.carbs)
                            .frame(width: IconSize.md, height: IconSize.md)
                        Text("63c")
                            .foregroundStyle(AppColors.lightMacroTextColor)
                            .font(.custom(Fonts.interRegular, size: FontSize.sm))
                    }

                    HStack(spacing: Spacing.xs) {
                        Circle()
                            .fill(MacroColors.fats)
                            .frame(width: IconSize.md, height: IconSize.md)
                        Text("7f")
                            .foregroundStyle(AppColors.lightMacroTextColor)
                            .font(.custom(Fonts.interRegular, size: FontSize.sm))
                    }

                    Text("470 kcal")
                        .foregroundStyle(AppColors.lightMacroTextColor)
                        .font(.custom(Fonts.interRegular, size: FontSize.sm))

                    NavigationLink(destination: AddFoodView(mealName: "Lunch")) {
                        Image(systemName: "plus")
                            .font(.system(size: IconSize.lg, weight: .medium))
                            .foregroundColor(AppColors.macroTextColor)
                    }

                    Button {
                        isExpanded.toggle()
                    } label: {
                        Image(systemName: "chevron.down")
                            .font(.system(size: IconSize.lg, weight: .medium))
                            .foregroundColor(AppColors.macroTextColor)
                    }
                }
            }
        }
    }

    struct ExpandedHeader: View {
        @Binding var isExpanded: Bool

        var body: some View {
            HStack {
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("Lunch")
                        .foregroundStyle(.white)
                        .font(.custom(Fonts.outfitSemiBold, size: FontSize.xl))

                    Text("545 kcal")
                        .foregroundStyle(AppColors.macroTextColor)
                        .font(.custom(Fonts.interMedium, size: FontSize.sm))
                }

                Spacer()

                HStack(spacing: Spacing.xl) {
                    NavigationLink(destination: AddFoodView(mealName: "Lunch")) {
                        Image(systemName: "plus")
                            .font(.system(size: IconSize.lg, weight: .medium))
                            .foregroundColor(AppColors.macroTextColor)
                    }

                    Button {
                        isExpanded.toggle()
                    } label: {
                        Image(systemName: "chevron.up")
                            .font(.system(size: IconSize.lg, weight: .medium))
                            .foregroundColor(AppColors.macroTextColor)
                    }
                }
            }
        }
    }

    struct Footer: View {
        var body: some View {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                Divider()
                    .overlay(AppColors.macroTextColor.opacity(Opacity.divider))
                HStack {
                    HStack(spacing: Spacing.lg) {
                        HStack(spacing: Spacing.xs) {
                            Circle()
                                .fill(MacroColors.protein)
                                .frame(width: IconSize.md, height: IconSize.md)
                            Text("45p")
                                .foregroundStyle(AppColors.lightMacroTextColor)
                                .font(.custom(Fonts.interRegular, size: FontSize.sm))
                        }

                        HStack(spacing: Spacing.xs) {
                            Circle()
                                .fill(MacroColors.carbs)
                                .frame(width: IconSize.md, height: IconSize.md)
                            Text("12c")
                                .foregroundStyle(AppColors.lightMacroTextColor)
                                .font(.custom(Fonts.interRegular, size: FontSize.sm))
                        }

                        HStack(spacing: Spacing.xs) {
                            Circle()
                                .fill(MacroColors.fats)
                                .frame(width: IconSize.md, height: IconSize.md)
                            Text("20f")
                                .foregroundStyle(AppColors.lightMacroTextColor)
                                .font(.custom(Fonts.interRegular, size: FontSize.sm))
                        }
                    }

                    Spacer()

                    Text("900 cal")
                        .foregroundStyle(AppColors.lightMacroTextColor)
                        .font(.custom(Fonts.interRegular, size: FontSize.sm))
                }
            }
        }
    }
}

#Preview {
    ZStack {
        AppColors.background
            .ignoresSafeArea()

        NavigationStack {
            VStack(alignment: .leading, spacing: 8) {
                MealCard(isEmpty: true)
            }
            .padding()
        }
    }
}
