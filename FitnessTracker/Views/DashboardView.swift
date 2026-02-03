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
                Text("Dashboard")
                    .foregroundColor(.white)
            }
        }
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    NavigationStack {
        DashboardView()
    }
}
