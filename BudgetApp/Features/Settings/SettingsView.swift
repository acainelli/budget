import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) var modelContext
    @Query var budgets: [MonthlyBudget]

    @State private var incomeText: String = ""
    @State private var hasLoaded = false
    @FocusState private var isIncomeFieldFocused: Bool
    @State private var selectedMonth: Date = {
        let cal = Calendar.current
        var comps = cal.dateComponents([.year, .month], from: Date())
        comps.day = 1
        return cal.date(from: comps) ?? Date()
    }()

    private var selectedMonthYear: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        return formatter.string(from: selectedMonth)
    }

    private var selectedMonthFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: selectedMonth)
    }

    private var selectedBudget: MonthlyBudget? {
        budgets.first { $0.monthYear == selectedMonthYear }
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Monthly Budget") {
                    HStack {
                        Button {
                            shiftMonth(by: -1)
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.body.weight(.semibold))
                                .frame(width: 44, height: 44)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.borderless)

                        Spacer()

                        Text(selectedMonthFormatted)
                            .font(.subheadline.weight(.medium))

                        Spacer()

                        Button {
                            shiftMonth(by: 1)
                        } label: {
                            Image(systemName: "chevron.right")
                                .font(.body.weight(.semibold))
                                .frame(width: 44, height: 44)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.borderless)
                    }

                    HStack {
                        Text("Income")
                        Spacer()
                        TextField("0,00", text: $incomeText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .focused($isIncomeFieldFocused)
                    }
                    Text("Set your monthly income for \(selectedMonthFormatted)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Button {
                        saveIncome()
                    } label: {
                        Text("Save Income")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.accentColor)
                            .cornerRadius(DesignTokens.CornerRadius.small)
                    }
                    .buttonStyle(.plain)
                }

                Section("Categories") {
                    NavigationLink("Manage Categories") {
                        ManageCategoriesView()
                    }
                }

                Section("Payment Templates") {
                    NavigationLink("Manage Templates") {
                        ManageTemplatesView()
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
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        isIncomeFieldFocused = false
                    }
                }
            }
            .onAppear {
                if !hasLoaded {
                    loadIncome()
                    hasLoaded = true
                }
            }
            .onChange(of: selectedMonth) {
                loadIncome()
            }
        }
    }

    private func loadIncome() {
        if let budget = selectedBudget {
            let formatted = String(format: "%.2f", budget.income)
                .replacingOccurrences(of: ".", with: ",")
            incomeText = formatted
        } else {
            incomeText = ""
        }
    }

    private func shiftMonth(by value: Int) {
        if let newMonth = Calendar.current.date(byAdding: .month, value: value, to: selectedMonth) {
            selectedMonth = newMonth
            HapticManager.selection()
        }
    }

    private func saveIncome() {
        let normalized = incomeText.replacingOccurrences(of: ",", with: ".")
        guard let value = Double(normalized) else { return }
        let budget = MonthlyBudget.fetchOrCreate(monthYear: selectedMonthYear, in: modelContext)
        budget.income = value
        try? modelContext.save()
        HapticManager.success()
    }
}
