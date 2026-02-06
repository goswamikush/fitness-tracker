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
            HStack() {
                Text("BREAKFAST")
                    .foregroundColor(.gray)
                
                Spacer()
                
                Text("290 kcal")
                    .foregroundColor(.gray)
            }
        }
        .padding()
    }
}

#Preview {
    ZStack {
        AppColors.background
            .ignoresSafeArea()
        
        MealCard()
    }
}
