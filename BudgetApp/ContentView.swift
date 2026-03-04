import SwiftUI

enum AppTab: Int, CaseIterable {
    case dashboard = 0
    case expenses = 1
    case insights = 2
    case settings = 3
}

struct ContentView: View {
    @State private var selectedTab: AppTab = .dashboard
    @State private var showingAddExpense = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            TabView(selection: $selectedTab) {
                Tab("Dashboard", systemImage: "house.fill", value: .dashboard) {
                    DashboardView()
                }
                Tab("Expenses", systemImage: "list.bullet", value: .expenses) {
                    ExpensesView()
                }
                Tab("Insights", systemImage: "chart.bar.xaxis", value: .insights) {
                    InsightsView()
                }
                Tab("Settings", systemImage: "gearshape.fill", value: .settings) {
                    SettingsView()
                }
            }

            if selectedTab == .dashboard || selectedTab == .expenses {
                Button {
                    HapticManager.impact()
                    showingAddExpense = true
                } label: {
                    Image(systemName: "plus")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(width: DesignTokens.FAB.size, height: DesignTokens.FAB.size)
                        .background(Color(red: 0, green: 0.259, blue: 0.145))
                        .clipShape(Circle())
                        .shadow(radius: 4, y: 2)
                }
                .padding(.trailing, 20)
                .padding(.bottom, 80)
            }
        }
        .sheet(isPresented: $showingAddExpense) {
            AddExpenseView()
        }
    }
}
