//
//  ContentView.swift
//  FitnessTracker
//
//  Created by Kush Goswami on 2/1/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Fitness Tracker")
                    .font(.largeTitle)
                    .bold()
                
                Text("Ready to build your macro tracking app!")
                    .foregroundStyle(.secondary)
            }
            .navigationTitle("Dashboard")
        }
    }
}

#Preview {
    ContentView()
}
