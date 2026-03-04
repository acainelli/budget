import SwiftUI

struct MonthPickerView: View {
    @Binding var currentMonth: Date

    private var isCurrentMonth: Bool {
        let cal = Calendar.current
        return cal.isDate(currentMonth, equalTo: Date(), toGranularity: .month)
    }

    private var monthTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentMonth)
    }

    var body: some View {
        HStack {
            Button {
                changeMonth(by: -1)
            } label: {
                Image(systemName: "chevron.left")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.primary)
                    .frame(width: 36, height: 36)
                    .contentShape(Rectangle())
            }

            Spacer()

            VStack(spacing: 4) {
                Text(monthTitle)
                    .font(.headline)
                    .animation(.none, value: currentMonth)

                if !isCurrentMonth {
                    Button {
                        goToToday()
                    } label: {
                        Text("Today")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 3)
                            .background(Color.accentColor, in: Capsule())
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .animation(.spring(response: 0.3), value: isCurrentMonth)

            Spacer()

            Button {
                changeMonth(by: 1)
            } label: {
                Image(systemName: "chevron.right")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.primary)
                    .frame(width: 36, height: 36)
                    .contentShape(Rectangle())
            }
        }
        .gesture(
            DragGesture(minimumDistance: 50)
                .onEnded { value in
                    let horizontal = value.translation.width
                    if horizontal > 50 {
                        changeMonth(by: -1)
                    } else if horizontal < -50 {
                        changeMonth(by: 1)
                    }
                }
        )
    }

    private func changeMonth(by value: Int) {
        if let newDate = Calendar.current.date(byAdding: .month, value: value, to: currentMonth) {
            currentMonth = newDate
            HapticManager.selection()
        }
    }

    private func goToToday() {
        let cal = Calendar.current
        var comps = cal.dateComponents([.year, .month], from: Date())
        comps.day = 1
        if let firstOfMonth = cal.date(from: comps) {
            currentMonth = firstOfMonth
            HapticManager.selection()
        }
    }
}
