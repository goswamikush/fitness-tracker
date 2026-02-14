//
//  DashboardView.swift
//  FitnessTracker
//
//  Created by Kush Goswami on 2/2/26.
//

import SwiftUI

struct DashboardView: View {
    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()

            VStack(spacing: 24) {
                DashboardHeaderView()
                    .padding(.horizontal)

                ScrollView {
                    VStack(spacing: 24) {
                        MealsSectionHeader()

                        MealCard()
                        MealCard()
                    }
                    .padding(.horizontal)
                }
            }
        }
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Subcomponents

private extension DashboardView {

    struct MealsSectionHeader: View {
        var body: some View {
            HStack {
                Text("Meals")
                    .foregroundStyle(.white)
                    .font(.custom(Fonts.outfitSemiBold, size: 22))

                Spacer()

                Text("5 Items")
                    .foregroundStyle(AppColors.lightMacroTextColor)
                    .font(.custom(Fonts.interRegular, size: 12))
            }
        }
    }
}

#Preview {
    NavigationStack {
        DashboardView()
    }
}
