# Phase 2: Core Loop - Context

**Gathered:** 2026-03-04
**Status:** Ready for planning

<domain>
## Phase Boundary

Users can log an expense via the Add Expense sheet (custom numpad, category picker, date picker) and immediately see their monthly budget status on the Dashboard (summary card, donut chart, daily bar chart, month navigation). This is the primary "log and check budget" workflow.

</domain>

<decisions>
## Implementation Decisions

### Custom numpad experience
- Cents-first (ATM-style) input: typing 4-5-8-0 produces €0,04 → €0,45 → €4,58 → €45,80
- Always 2 decimal places, digits shift left
- Large centered amount display at top of sheet, updates live as digits are typed (Apple Pay / Venmo style)
- 4x3 grid: [1,2,3] [4,5,6] [7,8,9] [00, 0, ⌫] — no comma key needed since decimal is implied
- Cap at €99.999,99 (7 digits max) to prevent accidental extreme entries

### Add Expense flow & layout
- All visible at once: amount display + numpad on top half, category/date/notes below in scrollable form, save button at bottom
- Category picker: 2x4 grid of tappable colored icon tiles with category name labels. Selected one gets highlight/border
- Notes field: optional, always visible with placeholder "Add a note..." — user can skip it
- Date defaults to today, shown as compact DatePicker (tappable label that expands inline)
- Requirement ADD-04: show which month the expense will land in (e.g. "March 2026" label near date picker)
- Save button triggers haptic .notification(.success), dismisses sheet
- Cancel button in navigation toolbar (already exists in skeleton)

### Dashboard card behavior
- MonthlySummaryCard: vertical stack — Income → Total Spent → Net Saved — with horizontal progress bar showing % budget used
- Progress bar: green when under budget, red when over
- When income is 0 ("Not set"): show "Not set" for income, hide progress bar (per DASH-03)
- Overspent state: Net Saved turns red text, shows negative amount (e.g. "-€120,00") labeled "Overspent". Progress bar at 100%, red
- Donut chart: only show categories that have expenses. No empty/zero slices. Legend lists active categories only
- Bar chart: one bar per day of the month. Days with no spending show no bar (gap)
- Empty state: friendly illustration (SF Symbol like tray or banknote) + "No expenses yet this month" message + "Add your first expense" CTA button that opens Add sheet

### Month picker interaction
- Swipe entire Dashboard ScrollView left/right to change month. Cards animate as page transition
- Display format: full month + year ("March 2026") between chevrons
- No hard limits on navigation — can go to any month past or future
- "Today" pill/button appears when not viewing current month — tapping jumps back
- Haptic .selection() feedback on month change (consistent with Phase 1 haptic pattern)

### Claude's Discretion
- Exact numpad button styling and spacing
- Donut chart center label content (total spent? percentage?)
- Bar chart Y-axis labeling
- Animation transitions between months
- Save button disabled state when amount is €0,00
- Exact empty state illustration choice

</decisions>

<code_context>
## Existing Code Insights

### Reusable Assets
- `CategoryIconView`: renders category SF Symbol in colored rounded square — reuse in category picker grid
- `DesignTokens`: corner radius (20/12/8), padding (16/8), FAB size (56) — use for all new card/form layouts
- `.cardStyle()` ViewModifier: padding + secondarySystemBackground + cornerRadius 20 — wrap all Dashboard cards
- `HapticManager`: `.impact()`, `.notification(.success/.warning)`, `.selection()` — already established patterns
- `NumberFormatter.eurGerman` / `Double.formattedEUR`: EUR formatting ready to use for all amount displays
- `ExpenseCategory`: has `.symbol`, `.color`, `.displayName` — powers the category picker grid directly

### Established Patterns
- Feature-based folder structure: `Features/AddExpense/`, `Features/Dashboard/` — add new views in these folders
- NavigationStack wrapping each tab view (DashboardView already has one)
- FAB in ContentView triggers `showingAddExpense` → `AddExpenseView` sheet (already wired)
- `@Model` classes with explicit `modelContext.save()` after mutations
- Dark mode only via `.preferredColorScheme(.dark)` on root

### Integration Points
- `ContentView.swift`: FAB already triggers `AddExpenseView` sheet — needs `@Environment(\.modelContext)` to pass down
- `AddExpenseView.swift`: skeleton exists with NavigationStack + Cancel button — needs full implementation
- `DashboardView.swift`: skeleton exists with NavigationStack — needs month state, query, and card subviews
- `Expense.init(amount:category:date:notes:)`: creates expense with auto-set monthYear — Add sheet calls this directly
- `MonthlyBudget` model: queried by monthYear for income display on Dashboard

</code_context>

<specifics>
## Specific Ideas

- The numpad should feel snappy — no keyboard animation delay, digits appear instantly
- Category grid should show the same colored icon squares that will appear throughout the app (using CategoryIconView)
- Dashboard cards should be vertically scrollable in case content exceeds screen height
- Month picker sits at the top of the Dashboard, pinned above the scrollable card content

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope.

</deferred>

---

*Phase: 02-core-loop*
*Context gathered: 2026-03-04*
