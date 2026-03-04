import SwiftUI
import SwiftData
import UniformTypeIdentifiers

// MARK: - Codable export/import structs

struct ExportData: Codable {
    let version: Int
    let exportDate: String
    let budgets: [BudgetExport]
    let expenses: [ExpenseExport]
}

struct BudgetExport: Codable {
    let monthYear: String
    let income: Double
}

struct ExpenseExport: Codable {
    let amount: Double
    let category: String
    let date: String
    let notes: String
    let monthYear: String
}

// MARK: - DataManagementView

struct DataManagementView: View {
    @Environment(\.modelContext) var modelContext
    @Query var allExpenses: [Expense]
    @Query var allBudgets: [MonthlyBudget]

    @State private var showDeleteConfirmation = false
    @State private var showImporter = false
    @State private var importResult: String? = nil
    @State private var showImportAlert = false

    // MARK: Export helpers

    private var exportData: Data {
        let isoFormatter = ISO8601DateFormatter()

        let budgetExports = allBudgets.map { BudgetExport(monthYear: $0.monthYear, income: $0.income) }
        let expenseExports = allExpenses.map {
            ExpenseExport(
                amount: $0.amount,
                category: $0.category.rawValue,
                date: isoFormatter.string(from: $0.date),
                notes: $0.notes,
                monthYear: $0.monthYear
            )
        }

        let dateFormatter = ISO8601DateFormatter()
        let exportPayload = ExportData(
            version: 1,
            exportDate: dateFormatter.string(from: Date()),
            budgets: budgetExports,
            expenses: expenseExports
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return (try? encoder.encode(exportPayload)) ?? Data()
    }

    private var exportFileURL: URL {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let fileName = "BudgetApp-Export-\(dateFormatter.string(from: Date())).json"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        try? exportData.write(to: url)
        return url
    }

    // MARK: Import logic

    private func handleImport(result: Result<URL, Error>) {
        guard case .success(let url) = result else { return }

        let accessing = url.startAccessingSecurityScopedResource()
        defer {
            if accessing { url.stopAccessingSecurityScopedResource() }
        }

        guard let data = try? Data(contentsOf: url) else {
            importResult = "Failed to read file"
            showImportAlert = true
            return
        }

        guard let decoded = try? JSONDecoder().decode(ExportData.self, from: data) else {
            importResult = "Invalid export file format"
            showImportAlert = true
            return
        }

        // Import budgets
        for budgetExport in decoded.budgets {
            let budget = MonthlyBudget.fetchOrCreate(monthYear: budgetExport.monthYear, in: modelContext)
            budget.income = budgetExport.income
        }

        // Build existing expense signatures for deduplication
        let existingSignatures = Set(allExpenses.map { expense in
            "\(expense.monthYear)-\(Int(expense.amount * 100))-\(expense.notes)"
        })

        var addedCount = 0
        var skippedCount = 0
        let isoFormatter = ISO8601DateFormatter()

        for exp in decoded.expenses {
            let signature = "\(exp.monthYear)-\(Int(exp.amount * 100))-\(exp.notes)"
            if existingSignatures.contains(signature) {
                skippedCount += 1
                continue
            }

            let date = isoFormatter.date(from: exp.date) ?? Date()
            let category = ExpenseCategory(rawValue: exp.category) ?? .groceries
            let expense = Expense(amount: exp.amount, category: category, date: date, notes: exp.notes)
            modelContext.insert(expense)
            addedCount += 1
        }

        try? modelContext.save()
        HapticManager.success()
        importResult = "Imported \(addedCount) expenses (\(skippedCount) duplicates skipped)"
        showImportAlert = true
    }

    // MARK: Delete all

    private func deleteAllData() {
        for expense in allExpenses {
            modelContext.delete(expense)
        }
        for budget in allBudgets {
            modelContext.delete(budget)
        }
        try? modelContext.save()
        HapticManager.warning()
    }

    // MARK: Body

    var body: some View {
        List {
            Section("Export") {
                ShareLink(item: exportFileURL) {
                    Label("Export Data", systemImage: "square.and.arrow.up")
                }
                Text("\(allExpenses.count) expenses, \(allBudgets.count) budgets")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("Import") {
                Button {
                    showImporter = true
                } label: {
                    Label("Import Data", systemImage: "square.and.arrow.down")
                }
            }

            Section(header: Text("Danger Zone").foregroundStyle(.red)) {
                Button("Delete All Data") {
                    showDeleteConfirmation = true
                }
                .foregroundStyle(.red)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Data Management")
        .fileImporter(
            isPresented: $showImporter,
            allowedContentTypes: [.json]
        ) { result in
            handleImport(result: result)
        }
        .confirmationDialog(
            "Delete All Data?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete All", role: .destructive) {
                deleteAllData()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently delete all expenses and budgets.")
        }
        .alert("Import Complete", isPresented: $showImportAlert) {
            Button("OK") {}
        } message: {
            Text(importResult ?? "")
        }
    }
}
