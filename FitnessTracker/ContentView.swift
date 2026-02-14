//
//  ContentView.swift
//  FitnessTracker
//
//  Created by Kush Goswami on 2/1/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab(value: 0) {
                NavigationStack {
                    DashboardView()
                }
            } label: {
                Image(systemName: "house")
                Text("Log")
            }

            Tab(value: 1) {
                NavigationStack {
                    DashboardView() // Placeholder for Nutrients
                }
            } label: {
                Image(systemName: "chart.bar")
                Text("Nutrients")
            }

            Tab(value: 2) {
                NavigationStack {
                    BodyWeightView()
                }
            } label: {
                Image(systemName: "scale.3d")
                Text("Body")
            }
        }
        .tint(MacroColors.carbs)
        .onAppear {
            let appearance = UITabBarAppearance()
            appearance.configureWithTransparentBackground()
            appearance.backgroundColor = UIColor(red: 18/255, green: 18/255, blue: 18/255, alpha: 0.95)
            appearance.shadowColor = UIColor(white: 1.0, alpha: 0.05)
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

#Preview {
    ContentView()
}
