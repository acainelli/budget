import SwiftUI

enum CalendarViewMode: String, CaseIterable {
    case month = "Month"
    case week = "Week"
}

struct IdentifiableDate: Identifiable {
    let id: TimeInterval
    let date: Date
    init(_ date: Date) { self.date = date; self.id = date.timeIntervalSinceReferenceDate }
}

struct InsightsCalendarView: View {
    let expenses: [Expense]
    let currentMonth: Date

    @State private var selectedDay: IdentifiableDate? = nil
    @State private var viewMode: CalendarViewMode = .month

    private let weekdaySymbols = ["M", "T", "W", "T", "F", "S", "S"]
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)

    private var cal: Calendar { Calendar.current }

    private var firstDayOfMonth: Date {
        cal.date(from: cal.dateComponents([.year, .month], from: currentMonth)) ?? currentMonth
    }

    private var daysInMonth: Int {
        cal.range(of: .day, in: .month, for: currentMonth)?.count ?? 30
    }

    /// Leading blank cells to align Monday as first column (1=Sun, 2=Mon, ..., 7=Sat)
    private var leadingBlanks: Int {
        let weekday = cal.component(.weekday, from: firstDayOfMonth)
        // Convert to Monday-first: Mon=0, Tue=1, ..., Sun=6
        return (weekday + 5) % 7
    }

    /// Daily expense totals for the current month
    private var dailyTotals: [Date: Double] {
        var result: [Date: Double] = [:]
        for expense in expenses {
            let day = cal.startOfDay(for: expense.date)
            result[day, default: 0] += expense.amount
        }
        return result
    }

    private var maxDailyTotal: Double {
        dailyTotals.values.max() ?? 1
    }

    private func opacity(for date: Date) -> Double {
        let day = cal.startOfDay(for: date)
        guard let total = dailyTotals[day], total > 0 else { return 0 }
        let ratio = total / maxDailyTotal
        return max(0.1, ratio)
    }

    private func expensesForDay(_ day: Date) -> [Expense] {
        let dayStart = cal.startOfDay(for: day)
        return expenses.filter { cal.startOfDay(for: $0.date) == dayStart }
    }

    var body: some View {
        VStack(spacing: 12) {
            // Mode picker
            Picker("View Mode", selection: $viewMode) {
                ForEach(CalendarViewMode.allCases, id: \.self) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, DesignTokens.Padding.outer)

            if viewMode == .month {
                monthView
            } else {
                CalendarWeekView(expenses: expenses)
            }

            Spacer()
        }
        .sheet(item: $selectedDay) { item in
            DayExpensesSheet(day: item.date, expenses: expensesForDay(item.date))
        }
    }

    private var monthView: some View {
        ScrollView {
            VStack(spacing: 8) {
                // Weekday header
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(weekdaySymbols, id: \.self) { symbol in
                        Text(symbol)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                            .frame(height: 20)
                    }
                }

                // Day cells
                LazyVGrid(columns: columns, spacing: 8) {
                    // Leading blanks
                    ForEach(0..<leadingBlanks, id: \.self) { _ in
                        Color.clear
                            .frame(height: 44)
                    }

                    // Day cells
                    ForEach(1...daysInMonth, id: \.self) { day in
                        if let date = cal.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) {
                            DayCell(
                                day: day,
                                accentOpacity: opacity(for: date)
                            )
                            .onTapGesture {
                                selectedDay = IdentifiableDate(date)
                                HapticManager.selection()
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, DesignTokens.Padding.outer)
        }
    }
}

private struct DayCell: View {
    let day: Int
    let accentOpacity: Double

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.categoryIcon)
                .fill(Color.accentColor.opacity(accentOpacity))

            Text("\(day)")
                .font(.subheadline)
                .foregroundStyle(accentOpacity > 0.5 ? .white : .primary)
        }
        .frame(height: 44)
    }
}
