//
//  MealCard.swift
//  FitnessTracker
//
//  Created by Kush Goswami on 2/2/26.
//

import SwiftUI

struct MealSectionHeader: View {
    let title: String
    let calories: Int

    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.gray)

            Spacer()

            Text("\(calories) kcal")
                .foregroundColor(.gray)
        }
    }
}

struct MealCard: View {

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

        }
        .padding()
    }
}

#Preview {
    ZStack {
        AppColors.background
            .ignoresSafeArea()

        VStack(alignment: .leading, spacing: 8) {
            MealSectionHeader(title: "BREAKFAST", calories: 290)
            MealCard()
        }
        .padding()
    }
}
