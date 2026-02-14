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
            VStack(spacing: 30) {
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Lunch")
                            .foregroundStyle(.white)
                            .font(.custom(Fonts.outfitSemiBold, size: 18))
                        
                        Text("545 kcal")
                            .foregroundStyle(AppColors.macroTextColor)
                            .font(.custom(Fonts.interMedium, size: 12))
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 20) {
                        Image(systemName: "plus")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(AppColors.macroTextColor)
                        
                        Image(systemName: "chevron.up")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(AppColors.macroTextColor)
                    }
                }
                
//                FoodItem()
            }
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
