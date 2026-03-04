import SwiftUI
import SwiftData

struct ExpensesView: View {
    @Query(sort: \Expense.date, order: .reverse) private var allExpenses: [Expense]
    @Environment(\.modelContext) var modelContext

    @State private var searchText = ""
    @State private var showBulkDelete = false
    @State private var toastMessage: String? = nil

    private var filteredExpenses: [Expense] {
        if searchText.isEmpty { return allExpenses }
        return allExpenses.filter {
            $0.notes.localizedCaseInsensitiveContains(searchText) ||
            ($0.category?.name ?? "Uncategorized").localizedCaseInsensitiveContains(searchText)
        }
    }

    private var groupedByDay: [(key: Date, value: [Expense])] {
        let grouped = Dictionary(grouping: filteredExpenses) {
            Calendar.current.startOfDay(for: $0.date)
        }
        return grouped.sorted { $0.key > $1.key }
    }

    private let sectionDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .full
        f.timeStyle = .none
        return f
    }()

    var body: some View {
        NavigationStack {
            Group {
                if filteredExpenses.isEmpty {
                    emptyState
                } else {
                    expenseList
                }
            }
            .navigationTitle("Expenses")
            .searchable(text: $searchText, prompt: "Search expenses")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showBulkDelete = true
                    } label: {
                        Image(systemName: "trash")
                    }
                    .disabled(allExpenses.isEmpty)
                }
            }
            .sheet(isPresented: $showBulkDelete) {
                BulkDeleteSheet(allExpenses: allExpenses)
            }
            .overlay(alignment: .bottom) {
                if let message = toastMessage {
                    Text(message)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.white)
                        .padding(.horizontal, DesignTokens.Padding.outer)
                        .padding(.vertical, DesignTokens.Padding.inner)
                        .background(Color.black.opacity(0.8), in: Capsule())
                        .padding(.bottom, DesignTokens.Padding.outer)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .animation(.spring(), value: toastMessage)
                }
            }
        }
    }

    private var expenseList: some View {
        List {
            ForEach(groupedByDay, id: \.key) { day, expenses in
                Section {
                    ForEach(expenses) { expense in
                        NavigationLink(value: expense) {
                            ExpenseRowView(expense: expense)
                        }
                    }
                    .onDelete { indexSet in
                        deleteExpenses(at: indexSet, in: expenses)
                    }
                } header: {
                    HStack {
                        Text(sectionDateFormatter.string(from: day))
                            .font(.footnote)
                            .fontWeight(.medium)
                            .textCase(nil)
                        Spacer()
                        let dailyTotal = expenses.reduce(0) { $0 + $1.amount }
                        Text(dailyTotal.formattedEUR)
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .monospacedDigit()
                            .fontDesign(.rounded)
                            .textCase(nil)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationDestination(for: Expense.self) { expense in
            ExpenseDetailView(expense: expense)
        }
    }

    private var emptyState: some View {
        VStack(spacing: DesignTokens.Padding.inner) {
            Image(systemName: "list.bullet.rectangle.portrait")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text(searchText.isEmpty ? "No Expenses Yet" : "No Results")
                .font(.title3)
                .fontWeight(.semibold)
            Text(searchText.isEmpty ? "Your expenses will appear here." : "Try a different search term.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(DesignTokens.Padding.outer)
    }

    private func deleteExpenses(at indexSet: IndexSet, in expenses: [Expense]) {
        for index in indexSet {
            modelContext.delete(expenses[index])
        }
        try? modelContext.save()
        HapticManager.warning()
    }
}
