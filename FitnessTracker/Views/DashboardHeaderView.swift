//
//  DashboardHeaderView.swift
//  FitnessTracker
//

import SwiftUI

struct DashboardHeaderView: View {
    @Environment(UserGoals.self) private var userGoals
    @Binding var selectedDate: Date
    var consumedCalories: Int = 0
    var consumedProtein: Int = 0
    var consumedCarbs: Int = 0
    var consumedFat: Int = 0

    private var remaining: Int {
        max(userGoals.calorieGoal - consumedCalories, 0)
    }

    var body: some View {
        VStack(spacing: 20) {
            DateBar(selectedDate: $selectedDate)
            CaloriesSection(consumed: consumedCalories, goal: userGoals.calorieGoal, remaining: remaining)
            NavigationLink(destination: NutritionAnalysisView(selectedDate: selectedDate)) {
                HStack(spacing: Spacing.md) {
                    Image(systemName: "chart.pie")
                        .font(.system(size: FontSize.sm))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [MacroColors.protein, MacroColors.carbs, MacroColors.fats],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    Text("View Nutrient Breakdown")
                        .font(.custom(Fonts.interMedium, size: FontSize.sm))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 10))
                }
                .foregroundStyle(AppColors.lightMacroTextColor)
                .padding(.horizontal, Spacing.xl)
                .padding(.vertical, Spacing.md)
                .background(
                    Capsule()
                        .fill(Color.white.opacity(0.08))
                )
            }
        }
    }
}

// MARK: - Subcomponents

private extension DashboardHeaderView {

    struct DateBar: View {
        @Binding var selectedDate: Date
        @State private var showDatePicker = false

        private var dateLabel: String {
            if Calendar.current.isDateInToday(selectedDate) {
                return "TODAY"
            } else if Calendar.current.isDateInYesterday(selectedDate) {
                return "YESTERDAY"
            } else if Calendar.current.isDateInTomorrow(selectedDate) {
                return "TOMORROW"
            } else {
                let formatter = DateFormatter()
                formatter.dateFormat = "MMM d, yyyy"
                return formatter.string(from: selectedDate).uppercased()
            }
        }

        var body: some View {
            HStack {
                Button {
                    showDatePicker = true
                } label: {
                    Image(systemName: "calendar")
                        .font(.system(size: 18))
                        .foregroundColor(AppColors.lightMacroTextColor)
                }

                Spacer()

                Button {
                    selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppColors.lightMacroTextColor)
                }

                Button {
                    showDatePicker = true
                } label: {
                    Text(dateLabel)
                        .foregroundStyle(.white)
                        .font(.custom(Fonts.interSemiBold, size: 18))
                        .padding(.horizontal, Spacing.lg)
                }

                Button {
                    selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppColors.lightMacroTextColor)
                }

                Spacer()

                NavigationLink(destination: SettingsView()) {
                    Image(systemName: "gearshape")
                        .font(.system(size: 18))
                        .foregroundColor(AppColors.lightMacroTextColor)
                }
            }
            .padding(.horizontal)
            .padding(.top, Spacing.lg)
            .sheet(isPresented: $showDatePicker) {
                DatePickerSheet(selectedDate: $selectedDate, isPresented: $showDatePicker)
            }
        }
    }

    struct DatePickerSheet: View {
        @Binding var selectedDate: Date
        @Binding var isPresented: Bool

        var body: some View {
            NavigationStack {
                DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .tint(MacroColors.carbs)
                    .padding()
                    .navigationTitle("Select Date")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") {
                                isPresented = false
                            }
                        }
                    }
            }
            .presentationDetents([.medium])
        }
    }

    struct CaloriesSection: View {
        let consumed: Int
        let goal: Int
        let remaining: Int

        var body: some View {
            VStack(spacing: 8) {
                Text("CALORIES REMAINING")
                    .foregroundStyle(AppColors.lightMacroTextColor)
                    .font(.custom(Fonts.interMedium, size: 11))

                Text("\(remaining)")
                    .foregroundStyle(.white)
                    .font(.custom(Fonts.outfitSemiBold, size: 30))
                    .padding(.bottom, 6)

                CalorieProgressBar(consumed: Double(consumed), goal: Double(goal))

                HStack {
                    Text("\(consumed)")
                        .foregroundStyle(AppColors.lightMacroTextColor)
                        .font(.custom(Fonts.interMedium, size: 11))

                    Spacer()

                    Text("\(goal) kcal goal")
                        .foregroundStyle(AppColors.lightMacroTextColor)
                        .font(.custom(Fonts.interMedium, size: 11))
                }
            }
            .padding(.horizontal, 55)
        }
    }

    struct CalorieProgressBar: View {
        let consumed: Double
        let goal: Double

        private var progress: Double {
            min(consumed / goal, 1.0)
        }

        var body: some View {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(AppColors.lightMacroTextColor.opacity(0.2))

                    RoundedRectangle(cornerRadius: 5)
                        .fill(
                            LinearGradient(
                                colors: [MacroColors.protein, MacroColors.carbs],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * progress)
                }
            }
            .frame(height: 6)
        }
    }

}

private struct PieSlice: Shape {
    let startAngle: Angle
    let endAngle: Angle

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        path.move(to: center)
        path.addArc(center: center, radius: radius, startAngle: startAngle - .degrees(90), endAngle: endAngle - .degrees(90), clockwise: false)
        path.closeSubpath()
        return path
    }
}

#Preview {
    ZStack {
        AppColors.background
            .ignoresSafeArea()

        DashboardHeaderView(selectedDate: .constant(Date()))
            .padding()
    }
}
