# Roadmap: BudgetApp

## Overview

Three phases deliver the app from nothing to a fully functional iOS budget tracker. Phase 1 builds the foundation: data models, CloudKit sync, Xcode scaffolding, and the visual system. Phase 2 delivers the core user loop — logging an expense and seeing the dashboard reflect it immediately. Phase 3 completes the app by building the remaining three tabs: Expenses list, Insights visualizations, and Settings with data management.

## Phases

**Phase Numbering:**
- Integer phases (1, 2, 3): Planned milestone work
- Decimal phases (2.1, 2.2): Urgent insertions (marked with INSERTED)

Decimal phases appear between their surrounding integers in numeric order.

- [x] **Phase 1: Foundation** - Data models, CloudKit sync, Xcode project scaffolding, and the visual design system (completed 2026-03-04)
- [x] **Phase 2: Core Loop** - Add Expense sheet and Dashboard tab delivering the primary "log and check budget" workflow (completed 2026-03-04)
- [ ] **Phase 3: Full App** - Expenses tab, Insights tab, and Settings tab completing the four-tab experience

## Phase Details

### Phase 1: Foundation
**Goal**: A buildable Xcode project exists with all data models, CloudKit sync, and the design system in place — ready to render UI
**Depends on**: Nothing (first phase)
**Requirements**: DATA-01, DATA-02, DATA-03, DATA-04, DATA-05, DATA-06, APP-01, APP-02, APP-03, APP-04, UX-01, UX-02, UX-03, UX-04, UX-05, UX-06
**Success Criteria** (what must be TRUE):
  1. The Xcode project opens, compiles without errors, and runs on an iOS 17+ simulator showing a 4-tab shell
  2. The app icon appears (black background, green dollar sign) and the accent color is #004225 dark green throughout
  3. A test expense can be inserted via Swift code and appears persisted in SwiftData with the correct EUR/de_DE formatted amount
  4. The app runs in dark mode only — no light mode appearance at any point
  5. A .cardStyle() view modifier exists and applies correctly to any wrapped view
**Plans**: 2 plans

Plans:
- [x] 01-01-PLAN.md — Xcode project skeleton, SwiftData models (Expense, MonthlyBudget, ExpenseCategory), CloudKit entitlements, Wave 0 XCTest stubs
- [x] 01-02-PLAN.md — Design system (CardStyle, CategoryIconView), full ContentView tab shell with FAB, placeholder feature views, app icon, human-verify checkpoint

### Phase 2: Core Loop
**Goal**: Users can log an expense from any tab and immediately see their monthly budget status on the Dashboard
**Depends on**: Phase 1
**Requirements**: ADD-01, ADD-02, ADD-03, ADD-04, DASH-01, DASH-02, DASH-03, DASH-04, DASH-05, DASH-06
**Success Criteria** (what must be TRUE):
  1. Tapping the floating + button opens a sheet with the custom numpad where a user can enter an amount, pick a category, and pick a date
  2. After saving, the Dashboard immediately reflects the new expense in the MonthlySummaryCard (income, spent, net, progress bar)
  3. The Dashboard donut chart shows spending broken down by category for the selected month
  4. The Dashboard bar chart shows daily spending totals for the selected month
  5. Swiping left/right or tapping chevrons on the month picker changes the displayed month and all cards update accordingly
**Plans**: 2 plans

Plans:
- [ ] 02-01-PLAN.md — Add Expense sheet: custom numpad (ATM-style cents-first), category picker grid, date picker with month label, save to SwiftData
- [ ] 02-02-PLAN.md — Dashboard: month picker with swipe, MonthlySummaryCard, CategoryBreakdownCard (donut), DailySpendingCard (bar chart), empty state

### Phase 3: Full App
**Goal**: All four tabs are fully functional — users can browse and manage expenses, explore spending insights, and configure settings with export/import
**Depends on**: Phase 2
**Requirements**: EXP-01, EXP-02, EXP-03, EXP-04, EXP-05, INS-01, INS-02, INS-03, INS-04, INS-05, INS-06, SET-01, SET-02, SET-03, SET-04, SET-05
**Success Criteria** (what must be TRUE):
  1. The Expenses tab shows all expenses grouped by day with a working search bar; tapping a row opens a detail view to edit or delete it
  2. Bulk delete works — selecting Day, Week, or Month scope removes the matching expenses after confirmation
  3. The Insights tab shows a pie chart, trend chart, and 6-month comparison in Charts view, and a heat-map calendar with tappable days in Calendar view
  4. The Settings tab lets the user set monthly income; export produces a valid JSON file via ShareLink; import reads a JSON file, skips duplicates, and reports the count added
  5. Delete All Data in Settings removes all expenses and budgets after a confirmation dialog
**Plans**: 4 plans

Plans:
- [ ] 03-01-PLAN.md — Expenses tab: grouped-by-day list with search, ExpenseRowView, ExpenseDetailView (edit date/notes, delete), BulkDeleteSheet (Day/Week/Month scope)
- [ ] 03-02-PLAN.md — Insights tab: Charts view (pie chart, spending trend, 6-month comparison), Calendar view (heat-map month grid, week view, day detail sheet)
- [ ] 03-03-PLAN.md — Settings tab: monthly income input, DataManagementView (export JSON via ShareLink, import with dedup, delete all data)
- [ ] 03-04-PLAN.md — Human verification checkpoint: end-to-end testing of all four tabs on simulator

## Progress

**Execution Order:**
Phases execute in numeric order: 1 → 2 → 3

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Foundation | 2/2 | Complete   | 2026-03-04 |
| 2. Core Loop | 2/2 | Complete   | 2026-03-04 |
| 3. Full App | 1/4 | In Progress|  |
