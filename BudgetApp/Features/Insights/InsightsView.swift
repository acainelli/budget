import SwiftUI
import SwiftData

enum InsightsSegment: String, CaseIterable {
    case charts = "Charts"
    case calendar = "Calendar"
}

struct InsightsView: View {
    @Query(sort: \Expense.date) var allExpenses: [Expense]
    @State private var currentMonth: Date = {
        let cal = Calendar.current
        var comps = cal.dateComponents([.year, .month], from: Date())
        comps.day = 1
        return cal.date(from: comps) ?? Date()
    }()
    @State private var selectedSegment: InsightsSegment = .charts

    private var currentMonthYear: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        return formatter.string(from: currentMonth)
    }

    private var visibleExpenses: [Expense] {
        allExpenses.filter { $0.category?.isHiddenFromStats != true }
    }

    private var monthExpenses: [Expense] {
        visibleExpenses.filter { $0.monthYear == currentMonthYear }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                MonthPickerView(currentMonth: $currentMonth)
                    .padding(.horizontal, DesignTokens.Padding.outer)
                    .padding(.vertical, DesignTokens.Padding.inner)

                Picker("View", selection: $selectedSegment) {
                    ForEach(InsightsSegment.allCases, id: \.self) { segment in
                        Text(segment.rawValue).tag(segment)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, DesignTokens.Padding.outer)
                .padding(.bottom, DesignTokens.Padding.inner)

                switch selectedSegment {
                case .charts:
                    InsightsChartsView(
                        expenses: monthExpenses,
                        allExpenses: visibleExpenses,
                        currentMonth: currentMonth
                    )
                case .calendar:
                    InsightsCalendarView(
                        expenses: monthExpenses,
                        currentMonth: currentMonth
                    )
                }
            }
            .navigationTitle("Insights")
        }
    }
}
