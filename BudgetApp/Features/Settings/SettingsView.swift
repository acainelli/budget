import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) var modelContext
    @Query var budgets: [MonthlyBudget]

    @State private var incomeText: String = ""
    @State private var hasLoaded = false

    private var currentMonthYear: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        return formatter.string(from: Date())
    }

    private var currentMonthFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: Date())
    }

    private var currentBudget: MonthlyBudget? {
        budgets.first { $0.monthYear == currentMonthYear }
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Monthly Budget") {
                    HStack {
                        Text("Income")
                        Spacer()
                        TextField("0,00", text: $incomeText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    Text("Set your monthly income for \(currentMonthFormatted)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Button("Save Income") {
                        saveIncome()
                    }
                }

                Section("Data") {
                    NavigationLink("Data Management") {
                        DataManagementView()
                    }
                }

                Section(footer: Text("BudgetApp — Track your spending").foregroundStyle(.secondary)) {
                    EmptyView()
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Settings")
            .onAppear {
                if !hasLoaded {
                    if let budget = currentBudget {
                        let formatted = String(format: "%.2f", budget.income)
                            .replacingOccurrences(of: ".", with: ",")
                        incomeText = formatted
                    }
                    hasLoaded = true
                }
            }
        }
    }

    private func saveIncome() {
        let normalized = incomeText.replacingOccurrences(of: ",", with: ".")
        guard let value = Double(normalized) else { return }
        let budget = MonthlyBudget.fetchOrCreate(monthYear: currentMonthYear, in: modelContext)
        budget.income = value
        try? modelContext.save()
        HapticManager.success()
    }
}
