# Phase 3: Full App - Context

**Gathered:** 2026-03-04
**Status:** Ready for planning

<domain>
## Phase Boundary

Complete the remaining three tabs: Expenses (grouped list with search, detail/edit, bulk delete), Insights (charts view with pie/trend/comparison + calendar heat map with tappable days), and Settings (monthly income, export/import JSON, delete all data). After this phase, all four tabs are fully functional.

</domain>

<decisions>
## Implementation Decisions

### Expense list & detail view
- Row layout per EXP-02: left = CategoryIconView (colored rounded square), middle = category name (top) + notes (below, gray, truncated), right = EUR amount
- Day group headers: date label on left + daily total amount on right (quick spending glance)
- ExpenseDetailView: editable fields are date and notes only (per EXP-03 spec). Category and amount are locked after creation
- When editing date, monthYear updates via .onChange (per EXP-05)
- Delete: both swipe-to-delete on list rows AND red "Delete Expense" button at bottom of detail view with confirmation alert
- Search: filters expenses by notes text and category name
- Delete haptic: .notification(.warning) per established pattern

### Bulk delete
- Trigger: toolbar button (trash icon) in Expenses tab navigation bar
- Scope picker: bottom sheet with segmented control — Day | Week | Month
- Shows preview count of how many expenses will be deleted before confirming
- "Week" scope targets the current calendar week (Monday-Sunday based on locale)
- "Day" = today, "Month" = current month
- Confirmation: destructive button in the sheet ("Delete X expenses")
- After deletion: brief toast/snackbar overlay showing "Deleted X expenses" — disappears after 2-3 seconds
- Haptic: .notification(.warning) on delete

### Insights charts & calendar
- Segmented picker at top: Charts | Calendar (per INS-01)
- Charts view shares monthYear state with rest of Insights (per INS-01)
- Category pie chart: reuse same SectorMark donut style from Dashboard's CategoryBreakdownCard for consistency. Slightly larger in Insights
- Spending trend chart: LineMark showing daily spending totals for the selected month (spending patterns within a month)
- Monthly comparison: BarMark showing last 6 months of total spending side by side (per INS-02)
- Charts view shows ALL expenses, no filtering; no own NavigationStack (per INS-03)
- Calendar month view: 7-column grid, heat map uses accent color (#004225) at varying opacity — no spending = transparent, high spending = full opacity. Monochrome, stays within palette
- Calendar day tap (INS-05): sheet shows day total at top + flat list of that day's expenses (icon, category, notes, amount). View only — no editing
- Calendar week view (INS-06): horizontal 7-day row with left/right navigation

### Settings & data management
- Monthly income: text field with EUR formatting. When submitted, creates/updates MonthlyBudget for current month. Shows current value or placeholder
- NavigationLink to DataManagementView (per SET-02) — separate view for export/import/delete
- Export filename: "BudgetApp-Export-YYYY-MM-DD.json" — includes date, sortable, identifiable
- Export format: { version: 1, exportDate, budgets: [...], expenses: [...] } per PROJECT.md spec
- Export via ShareLink (per SET-03)
- Import via .fileImporter (per SET-04). Deduplication by signature "monthYear-amountCents-notes"
- Import feedback: alert showing "Imported X expenses (Y duplicates skipped)" — simple, clear
- Delete All Data: standard iOS .confirmationDialog with red destructive "Delete All" button. One tap to confirm. Deletes all expenses and budgets (per SET-05)
- Haptic: .notification(.warning) on delete all, .notification(.success) on import

### Claude's Discretion
- Exact search bar implementation (SwiftUI .searchable modifier vs custom)
- Toast/snackbar implementation for bulk delete feedback
- Exact chart sizing and spacing in Insights
- Calendar grid cell sizing and layout
- Week view navigation animation
- DataManagementView section grouping
- Whether to share MonthPickerView with Insights or create separate month state

</decisions>

<code_context>
## Existing Code Insights

### Reusable Assets
- `CategoryIconView`: colored rounded square with SF Symbol — reuse in expense rows and day-detail sheet
- `CategoryBreakdownCard`: SectorMark donut chart — extract chart logic for Insights pie chart reuse
- `MonthPickerView`: month navigation with chevrons, swipe, Today pill — potentially reusable for Insights month navigation
- `DesignTokens`: corner radius (20/12/8), padding (16/8) — use across all new views
- `.cardStyle()`: wrap all card-style containers
- `HapticManager`: `.impact()`, `.notification(.success/.warning)`, `.selection()` — established patterns
- `Double.formattedEUR`: EUR formatting for all amounts
- `ExpenseCategory`: `.symbol`, `.color`, `.displayName` — powers all category displays
- `NumpadView` + `AmountDisplayView`: ATM-style input — available if income input reuses numpad

### Established Patterns
- `@Query` all expenses + in-memory filter by `monthYear` string (DashboardView pattern)
- `MonthlyBudget.fetchOrCreate(monthYear:in:)` for income lookup
- Feature-based folders: `Features/Expenses/`, `Features/Insights/`, `Features/Settings/`
- NavigationStack wrapping each tab (stubs exist)
- Explicit `try? modelContext.save()` after every insert/delete
- Expense.init sets monthYear from date automatically

### Integration Points
- `ExpensesView.swift`: stub exists — needs full implementation
- `InsightsView.swift`: stub exists — needs full implementation
- `SettingsView.swift`: stub exists — needs full implementation
- `ContentView.swift`: FAB shows on tab 0 and 1 (Expenses is tab 1 — FAB appears here too)
- `Expense` model: all fields accessible, monthYear for filtering
- `MonthlyBudget` model: income field for Settings, fetchOrCreate pattern
- `project.pbxproj`: new files must be registered

</code_context>

<specifics>
## Specific Ideas

- Expense rows should feel familiar — same CategoryIconView squares used throughout the app
- Insights donut should look consistent with Dashboard donut (same SectorMark, same colors, same legend style)
- Calendar heat map should feel native — monochrome with accent color, not jarring new colors
- Export JSON must match the format specified in PROJECT.md exactly (version: 1, exportDate, budgets array, expenses array)
- Import deduplication signature is "monthYear-amountCents-notes" — convert amount to integer cents for reliable matching

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope.

</deferred>

---

*Phase: 03-full-app*
*Context gathered: 2026-03-04*
