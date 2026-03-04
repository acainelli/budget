# Requirements: BudgetApp

**Defined:** 2026-03-04
**Core Value:** Users can quickly log expenses and see at a glance how much of their monthly budget remains.

## v1 Requirements

### Models & Data

- [x] **DATA-01**: Expense model with amount (Double), category (ExpenseCategory enum), date (Date), notes (String), monthYear (stored String "yyyy-MM")
- [x] **DATA-02**: MonthlyBudget model with monthYear (String, unique), income (Double), default income 0
- [x] **DATA-03**: 8 expense categories (groceries, restaurants, car, mealVoucher, pharmacy, bills, chico, shopping) with SF Symbols and colors
- [x] **DATA-04**: iCloud sync via CloudKit-backed SwiftData
- [x] **DATA-05**: EUR currency formatted as German locale (de_DE, comma decimal: €45,80)
- [x] **DATA-06**: Explicit modelContext.save() after all inserts and deletes

### App Structure

- [x] **APP-01**: 4-tab layout: Dashboard (house.fill), Expenses (list.bullet), Insights (chart.bar.xaxis), Settings (gearshape.fill)
- [x] **APP-02**: Floating action button (green circle with +) on Dashboard and Expenses tabs to add expense
- [x] **APP-03**: Full Xcode project (.xcodeproj) ready to build and run
- [x] **APP-04**: App icon: black background, green (#004225) dollar sign, 1024x1024

### Dashboard

- [x] **DASH-01**: Month picker with left/right chevrons and swipe left/right gesture to change month
- [x] **DASH-02**: MonthlySummaryCard showing Income → Total Spent → Net Saved with progress bar (% budget used)
- [x] **DASH-03**: If income is 0, show "Not set" and hide the progress bar
- [x] **DASH-04**: CategoryBreakdownCard with donut chart of spending by category
- [x] **DASH-05**: DailySpendingCard with bar chart of daily spending for the month
- [x] **DASH-06**: Empty state when no expenses exist for selected month

### Expenses

- [ ] **EXP-01**: List of all expenses grouped by day with search
- [ ] **EXP-02**: Each row shows category icon (colored rounded square), category name, notes, amount
- [ ] **EXP-03**: Tap row → ExpenseDetailView to edit date, notes, and delete
- [ ] **EXP-04**: Bulk delete feature via sheet with Day/Week/Month scope
- [ ] **EXP-05**: When editing expense date, monthYear is updated via .onChange

### Insights

- [ ] **INS-01**: InsightsView with shared monthYear state and segmented picker: Charts / Calendar
- [ ] **INS-02**: Charts view: category pie chart, spending trend chart, monthly comparison chart (last 6 months)
- [ ] **INS-03**: Charts view shows all expenses, no filtering; no own NavigationStack
- [ ] **INS-04**: Calendar month view: 7-column grid with heat-map opacity based on daily totals
- [ ] **INS-05**: Calendar month view: tap a day → sheet showing flat list of that day's expenses
- [ ] **INS-06**: Calendar week view: horizontal 7-day row with navigation

### Add Expense

- [x] **ADD-01**: Custom numpad (4x3 grid) for amount input
- [x] **ADD-02**: Category picker for selecting expense category
- [x] **ADD-03**: Date picker for selecting expense date
- [x] **ADD-04**: Shows which month the expense will land in

### Settings

- [ ] **SET-01**: Monthly income input for current month (creates/updates MonthlyBudget)
- [ ] **SET-02**: NavigationLink to DataManagementView
- [ ] **SET-03**: Export all expenses + budgets to JSON via ShareLink with specified format
- [ ] **SET-04**: Import JSON via .fileImporter, skip duplicates by signature "monthYear-amountCents-notes", show import count
- [ ] **SET-05**: Delete All Data with confirmation dialog → delete all expenses and budgets

### Theme & UX

- [x] **UX-01**: Dark mode only
- [x] **UX-02**: Accent color #004225 (dark green) via AccentColor asset
- [x] **UX-03**: Shared .cardStyle() view modifier (padding + secondarySystemBackground + corner radius 20)
- [x] **UX-04**: Corner radius: 20 (cards), 12 (small elements). Padding: 16 / 8
- [x] **UX-05**: Amount font: semibold, rounded, monospaced design
- [x] **UX-06**: Haptics: .impact(.medium) taps, .notification(.success) saves, .notification(.warning) deletes, .selection() pickers/navigation

## v2 Requirements

### Enhancements

- **ENH-01**: Recurring expenses (auto-create monthly)
- **ENH-02**: Widgets for home screen (daily/monthly summary)
- **ENH-03**: Multiple currency support
- **ENH-04**: Light mode / system appearance toggle
- **ENH-05**: App Intents / Shortcuts integration

## Out of Scope

| Feature | Reason |
|---------|--------|
| Light mode | Dark mode only by design |
| Multiple currencies | EUR only, hardcoded |
| Multiple budgets per month | One MonthlyBudget per monthYear |
| Recurring expenses | Manual entry only for v1 |
| Widgets / App Intents | v1 is main app only |
| Localization | German locale formatting but UI in English |
| Third-party dependencies | Apple frameworks only |

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| DATA-01 | Phase 1 | Complete |
| DATA-02 | Phase 1 | Complete |
| DATA-03 | Phase 1 | Complete |
| DATA-04 | Phase 1 | Complete |
| DATA-05 | Phase 1 | Complete |
| DATA-06 | Phase 1 | Complete |
| APP-01 | Phase 1 | Complete |
| APP-02 | Phase 1 | Complete |
| APP-03 | Phase 1 | Complete |
| APP-04 | Phase 1 | Complete |
| UX-01 | Phase 1 | Complete |
| UX-02 | Phase 1 | Complete |
| UX-03 | Phase 1 | Complete |
| UX-04 | Phase 1 | Complete |
| UX-05 | Phase 1 | Complete |
| UX-06 | Phase 1 | Complete |
| ADD-01 | Phase 2 | Complete |
| ADD-02 | Phase 2 | Complete |
| ADD-03 | Phase 2 | Complete |
| ADD-04 | Phase 2 | Complete |
| DASH-01 | Phase 2 | Complete |
| DASH-02 | Phase 2 | Complete |
| DASH-03 | Phase 2 | Complete |
| DASH-04 | Phase 2 | Complete |
| DASH-05 | Phase 2 | Complete |
| DASH-06 | Phase 2 | Complete |
| EXP-01 | Phase 3 | Pending |
| EXP-02 | Phase 3 | Pending |
| EXP-03 | Phase 3 | Pending |
| EXP-04 | Phase 3 | Pending |
| EXP-05 | Phase 3 | Pending |
| INS-01 | Phase 3 | Pending |
| INS-02 | Phase 3 | Pending |
| INS-03 | Phase 3 | Pending |
| INS-04 | Phase 3 | Pending |
| INS-05 | Phase 3 | Pending |
| INS-06 | Phase 3 | Pending |
| SET-01 | Phase 3 | Pending |
| SET-02 | Phase 3 | Pending |
| SET-03 | Phase 3 | Pending |
| SET-04 | Phase 3 | Pending |
| SET-05 | Phase 3 | Pending |

**Coverage:**
- v1 requirements: 42 total
- Mapped to phases: 42
- Unmapped: 0

---
*Requirements defined: 2026-03-04*
*Last updated: 2026-03-04 after roadmap creation*
