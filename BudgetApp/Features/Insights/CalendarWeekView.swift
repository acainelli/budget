import SwiftUI

struct CalendarWeekView: View {
    let expenses: [Expense]

    @State private var weekStart: Date = {
        let cal = Calendar.current
        let today = Date()
        // Get start of week (Monday-first)
        let weekday = cal.component(.weekday, from: today)
        let daysFromMonday = (weekday + 5) % 7
        return cal.date(byAdding: .day, value: -daysFromMonday, to: cal.startOfDay(for: today)) ?? today
    }()

    private let cal = Calendar.current
    private let weekdaySymbols = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

    private var weekDays: [Date] {
        (0..<7).compactMap { offset in
            cal.date(byAdding: .day, value: offset, to: weekStart)
        }
    }

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

    private var weekRangeLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        guard let endDate = cal.date(byAdding: .day, value: 6, to: weekStart) else {
            return formatter.string(from: weekStart)
        }
        return "\(formatter.string(from: weekStart)) – \(formatter.string(from: endDate))"
    }

    var body: some View {
        VStack(spacing: 12) {
            // Week navigation
            HStack {
                Button {
                    shiftWeek(by: -1)
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.primary)
                        .frame(width: 36, height: 36)
                        .contentShape(Rectangle())
                }

                Spacer()

                Text(weekRangeLabel)
                    .font(.subheadline.weight(.medium))

                Spacer()

                Button {
                    shiftWeek(by: 1)
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.primary)
                        .frame(width: 36, height: 36)
                        .contentShape(Rectangle())
                }
            }
            .padding(.horizontal, DesignTokens.Padding.outer)

            // Day row
            HStack(spacing: 8) {
                ForEach(Array(weekDays.enumerated()), id: \.offset) { index, date in
                    let dayTotal = dailyTotals[cal.startOfDay(for: date)] ?? 0
                    let hasExpenses = dayTotal > 0
                    let opacity = hasExpenses ? max(0.1, dayTotal / maxDailyTotal) : 0

                    VStack(spacing: 4) {
                        Text(weekdaySymbols[index])
                            .font(.caption2)
                            .foregroundStyle(.secondary)

                        Text("\(cal.component(.day, from: date))")
                            .font(.subheadline)
                            .foregroundStyle(opacity > 0.5 ? .white : .primary)
                            .frame(width: 36, height: 36)
                            .background(
                                RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.categoryIcon)
                                    .fill(Color.accentColor.opacity(opacity))
                            )

                        Circle()
                            .fill(hasExpenses ? Color.accentColor : Color.clear)
                            .frame(width: 5, height: 5)
                    }
                }
            }
            .padding(.horizontal, DesignTokens.Padding.outer)
        }
    }

    private func shiftWeek(by value: Int) {
        if let newStart = cal.date(byAdding: .day, value: value * 7, to: weekStart) {
            weekStart = newStart
            HapticManager.selection()
        }
    }
}
