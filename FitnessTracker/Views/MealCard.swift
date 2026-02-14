//
//  MealCard.swift
//  FitnessTracker
//
//  Created by Kush Goswami on 2/2/26.
//

import SwiftUI

struct MealCard: View {

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Lunch")
                .foregroundStyle(.white)
            Text("545 kcal")
                .foregroundStyle(.white)
        }
        .padding()
    }
}

#Preview {
    ZStack {
        AppColors.background
            .ignoresSafeArea()

        VStack(alignment: .leading, spacing: 8) {
            MealCard()
        }
        .padding()
    }
}
