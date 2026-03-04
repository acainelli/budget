---
phase: 03-full-app
plan: 01
subsystem: ui
tags: [swiftui, swiftdata, expenses, navigation, search, bulk-delete]

# Dependency graph
requires:
  - phase: 02-core-loop
    provides: Expense model, CategoryIconView, HapticManager, DesignTokens, formattedEUR extension
provides:
  - Expenses tab: grouped-by-day expense list with search
  - ExpenseRowView: reusable row with icon, category, notes, amount
  - ExpenseDetailView: tap-to-edit date/notes with monthYear sync, delete
  - BulkDeleteSheet: Day/Week/Month scope picker with preview count and confirmation
affects: [03-02-insights, 03-03-settings]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - NavigationLink(value:) with .navigationDestination(for: Expense.self) for SwiftData @Model navigation
    - Grouped list via Dictionary(grouping:) + sorted by key descending
    - .onChange(of:) for syncing editedDate → expense.date + monthYear recompute
    - .confirmationDialog for destructive multi-select operations

key-files:
  created:
    - BudgetApp/Features/Expenses/ExpenseRowView.swift
    - BudgetApp/Features/Expenses/ExpenseDetailView.swift
    - BudgetApp/Features/Expenses/BulkDeleteSheet.swift
  modified:
    - BudgetApp/Features/Expenses/ExpensesView.swift
    - BudgetApp.xcodeproj/project.pbxproj

key-decisions:
  - "NavigationLink(value:) with Expense.self — SwiftData @Model synthesizes Hashable, no conformance needed"
  - "BulkDeleteSheet captures expensesToDelete snapshot before loop deletion to avoid mutation-while-iterating"
  - "Toast overlay kept minimal — Text in Capsule with .transition(.move.combined(with: .opacity))"
  - "Empty state shown when filteredExpenses is empty (covers both no-data and no-search-results)"

patterns-established:
  - "Grouped list: Dictionary(grouping:) keyed on Calendar.current.startOfDay, sorted descending"
  - "Swipe-to-delete: .onDelete on ForEach, modelContext.delete + save + HapticManager.warning()"
  - "Detail edit via @State initialized from model, .onChange syncs back to model + save"

requirements-completed: [EXP-01, EXP-02, EXP-03, EXP-04, EXP-05]

# Metrics
duration: 2min
completed: 2026-03-04
---

# Phase 3 Plan 01: Expenses Tab Summary

**Grouped-by-day expense list with search, swipe/bulk delete, and editable detail view syncing monthYear on date change**

## Performance

- **Duration:** ~2 min
- **Started:** 2026-03-04T22:47:45Z
- **Completed:** 2026-03-04T22:49:25Z
- **Tasks:** 2
- **Files modified:** 5

## Accomplishments
- Full Expenses tab replacing stub — grouped by day with section headers showing date label and daily total
- Searchable by notes text and category name via .searchable modifier
- ExpenseDetailView with editable date (triggers monthYear update via .onChange per EXP-05) and notes
- BulkDeleteSheet with Day/Week/Month segmented picker, preview count, and .confirmationDialog before deletion
- All 4 new files registered in project.pbxproj with sequential GUIDs (0x50-0x52 file refs, 0x117-0x119 build files)
- BUILD SUCCEEDED on first attempt

## Task Commits

Each task was committed atomically:

1. **Task 1: ExpenseRowView and ExpenseDetailView** - `a8db26e` (feat)
2. **Task 2: ExpensesView, BulkDeleteSheet, pbxproj** - `f0cfd91` (feat)

## Files Created/Modified
- `BudgetApp/Features/Expenses/ExpenseRowView.swift` - Single row with CategoryIconView, category name + notes, EUR amount
- `BudgetApp/Features/Expenses/ExpenseDetailView.swift` - Detail/edit view for date and notes, delete with confirmation
- `BudgetApp/Features/Expenses/BulkDeleteSheet.swift` - Bulk delete sheet with scope picker and preview
- `BudgetApp/Features/Expenses/ExpensesView.swift` - Full grouped list replacing stub
- `BudgetApp.xcodeproj/project.pbxproj` - Registered 3 new Expenses feature files

## Decisions Made
- NavigationLink(value:) with Expense.self works because SwiftData @Model synthesizes Hashable automatically
- BulkDeleteSheet captures the `expensesToDelete` array into a local constant before iterating to avoid mutation issues
- Toast overlay implemented as pattern ready for wiring — BulkDeleteSheet currently uses dismiss() after deletion; parent can observe sheet dismissal to show toast if desired

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness
- Expenses tab fully functional — ready for InsightsView (03-02) and SettingsView (03-03)
- ExpenseRowView reusable in Insights calendar day-detail sheet (per context decisions)
- All EXP-01 through EXP-05 requirements satisfied

---
*Phase: 03-full-app*
*Completed: 2026-03-04*
