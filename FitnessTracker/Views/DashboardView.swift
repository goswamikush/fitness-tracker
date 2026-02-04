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
            
            VStack {
                Text("Daily Log")
                    .foregroundColor(.white)
                    .font(.largeTitle.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    NavigationStack {
        DashboardView()
    }
}
