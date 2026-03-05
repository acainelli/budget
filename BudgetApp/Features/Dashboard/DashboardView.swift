import SwiftUI
import SwiftData

struct DashboardView: View {
    @Binding var showingAddExpense: Bool

    @Environment(\.modelContext) private var modelContext
    @Query private var allExpenses: [Expense]

    @State private var currentMonth: Date = {
        let cal = Calendar.current
        var comps = cal.dateComponents([.year, .month], from: Date())
        comps.day = 1
        return cal.date(from: comps) ?? Date()
    }()

    private var currentMonthYear: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        return formatter.string(from: currentMonth)
    }

    private var monthExpenses: [Expense] {
        allExpenses.filter { $0.monthYear == currentMonthYear && $0.category?.isHiddenFromStats != true }
    }

    private var totalSpent: Double {
        monthExpenses.reduce(0) { $0 + $1.amount }
    }

    private var budgetIncome: Double {
        let budget = MonthlyBudget.fetchOrCreate(monthYear: currentMonthYear, in: modelContext)
        return budget.income
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                MonthPickerView(currentMonth: $currentMonth)
                    .padding(.horizontal, DesignTokens.Padding.outer)
                    .padding(.bottom, DesignTokens.Padding.inner)

                if monthExpenses.isEmpty {
                    DashboardEmptyState(onAddExpense: {
                        showingAddExpense = true
                    })
                } else {
                    ScrollView {
                        VStack(spacing: DesignTokens.Padding.outer) {
                            MonthlySummaryCard(
                                income: budgetIncome,
                                totalSpent: totalSpent
                            )
                            CategoryBreakdownCard(expenses: monthExpenses)
                            DailySpendingCard(expenses: monthExpenses, currentMonth: currentMonth)
                        }
                        .padding(.horizontal, DesignTokens.Padding.outer)
                        .padding(.bottom, 100)
                    }
                }
            }
            .navigationTitle("Dashboard")
        }
    }
}
