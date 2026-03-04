import SwiftUI

struct MonthlySummaryCard: View {
    let income: Double
    let totalSpent: Double

    private var netSaved: Double { income - totalSpent }
    private var percentUsed: Double {
        guard income > 0 else { return 0 }
        return min(totalSpent / income, 1.0)
    }
    private var isOverBudget: Bool { netSaved < 0 }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Income row
            HStack {
                Text("Income")
                    .foregroundStyle(.secondary)
                Spacer()
                if income == 0 {
                    Text("Not set")
                        .foregroundStyle(.secondary)
                        .italic()
                } else {
                    Text(income.formattedEUR)
                }
            }
            .font(.subheadline)

            // Total Spent row
            HStack {
                Text("Total Spent")
                    .foregroundStyle(.secondary)
                Spacer()
                Text(totalSpent.formattedEUR)
            }
            .font(.subheadline)

            Divider()

            // Net row
            HStack {
                Text(isOverBudget ? "Overspent" : "Net Saved")
                    .fontWeight(.semibold)
                    .foregroundStyle(isOverBudget ? .red : .green)
                Spacer()
                Text(isOverBudget ? "-\(abs(netSaved).formattedEUR)" : netSaved.formattedEUR)
                    .fontWeight(.semibold)
                    .foregroundStyle(isOverBudget ? .red : .green)
            }
            .font(.subheadline)

            // Progress bar (only when income > 0)
            if income > 0 {
                VStack(alignment: .leading, spacing: 4) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.secondary.opacity(0.2))
                                .frame(height: 8)

                            RoundedRectangle(cornerRadius: 4)
                                .fill(percentUsed >= 1.0 ? Color.red : Color.green)
                                .frame(width: geo.size.width * percentUsed, height: 8)
                        }
                    }
                    .frame(height: 8)

                    Text("\(Int(percentUsed * 100))% of budget used")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .cardStyle()
    }
}
