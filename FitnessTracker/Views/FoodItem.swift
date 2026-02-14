//
//  FoodItem.swift
//  FitnessTracker
//
//  Created by Kush Goswami on 2/14/26.
//

import SwiftUI

struct FoodItem: View {

    var body: some View {
        
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    // Item
                    HStack() {
                        Text("Grilled Chicken Salad")
                            .foregroundStyle(.white)
                            .font(.custom(Fonts.interMedium, size: 15))
                    }
                    
                    // Macros
                    HStack() {
                        HStack(spacing: 3) {
                            Circle()
                                .fill(MacroColors.protein)
                                  .frame(width: 4, height: 4)
                            Text("45p")
                                .foregroundStyle(AppColors.macroTextColor)
                                .font(.custom(Fonts.interRegular, size: 11))
                        }
                        
                        HStack(spacing: 3) {
                            Circle()
                                .fill(MacroColors.carbs)
                                  .frame(width: 4, height: 4)
                            Text("12c")
                                .foregroundStyle(AppColors.macroTextColor)
                                .font(.custom(Fonts.interRegular, size: 11))
                        }
                        
                        HStack(spacing: 3) {
                            Circle()
                                .fill(MacroColors.fats)
                                  .frame(width: 4, height: 4)
                            Text("20f")
                                .foregroundStyle(AppColors.macroTextColor)
                                .font(.custom(Fonts.interRegular, size: 11))
                        }
                        
                        Divider()
                            .frame(height: 15)
                            .overlay(AppColors.macroTextColor)
                            .padding(.horizontal, 5)
                        
                        HStack(spacing: 7) {
                            Circle()
                                .fill(AppColors.macroTextColor)
                                  .frame(width: 3, height: 3)
                            Text("256g")
                                .foregroundStyle(AppColors.macroTextColor.opacity(0.6))
                                .font(.custom(Fonts.interRegular, size: 11))
                        }
                    }
                }
                
                Spacer()

                Text("450 cal")
                    .foregroundStyle(.white)
                    .font(.custom(Fonts.interRegular, size: 14))
            }
//            .border(.gray)
        }
        .padding()
    }
}

#Preview {
    ZStack {
        AppColors.background
            .ignoresSafeArea()

        VStack(alignment: .leading, spacing: 8) {
            FoodItem()
        }
        .padding()
    }
}
