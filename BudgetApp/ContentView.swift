import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Int = 0
    @State private var showingAddExpense = false

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem { Label("Dashboard", systemImage: "house.fill") }
                .tag(0)
            ExpensesView()
                .tabItem { Label("Expenses", systemImage: "list.bullet") }
                .tag(1)
            InsightsView()
                .tabItem { Label("Insights", systemImage: "chart.bar.xaxis") }
                .tag(2)
            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
                .tag(3)
        }
        .overlay(alignment: .bottomTrailing) {
            if selectedTab == 0 || selectedTab == 1 {
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
