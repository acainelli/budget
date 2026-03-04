# BudgetApp

## What This Is

A dark-mode-only iOS budget tracking app built with SwiftUI and SwiftData, targeting iOS 17+. Users track expenses by category, set monthly income, and visualize spending through charts and a calendar heat map. All amounts displayed in EUR with German locale formatting (de_DE, comma decimal: €45,80). iCloud-synced via CloudKit-backed SwiftData.

## Core Value

Users can quickly log expenses and see at a glance how much of their monthly budget remains.

## Requirements

### Validated

(None yet — ship to validate)

### Active

- [ ] 4-tab layout: Dashboard, Expenses, Insights, Settings
- [ ] Floating action button (green circle with +) on Dashboard and Expenses tabs
- [ ] Expense model: amount (Double), category (ExpenseCategory enum), date (Date), notes (String), monthYear (stored String "yyyy-MM")
- [ ] MonthlyBudget model: monthYear (String, unique), income (Double), default 0
- [ ] 8 expense categories with specific SF Symbols and colors
- [ ] Dashboard: month picker with chevrons + swipe, summary card, donut chart, daily bar chart, empty state
- [ ] Expenses: grouped-by-day list with search, detail/edit view, bulk delete (day/week/month scope)
- [ ] Insights: segmented Charts/Calendar, pie chart, trend chart, 6-month comparison, calendar heat map with day tap
- [ ] Settings: monthly income input, data management (export/import JSON, delete all)
- [ ] Custom numpad for amount entry in add-expense sheet
- [ ] Dark mode only, accent color #004225
- [ ] Swift Charts for all chart visualizations
- [ ] iCloud sync via CloudKit-backed SwiftData
- [ ] EUR currency, German locale (de_DE)
- [ ] Haptic feedback on all interactions
- [ ] Full Xcode project (.xcodeproj), ready to build and run
- [ ] App icon: black background, green (#004225) dollar sign, 1024x1024

### Out of Scope

- Light mode — dark mode only by design
- Multiple currencies — EUR only
- Multiple budgets per month — one MonthlyBudget per monthYear
- Recurring expenses — manual entry only
- Widgets / App Intents — v1 is the main app only
- Localization — German locale formatting but UI in English

## Context

- SwiftUI + SwiftData stack (iOS 17+)
- Swift Charts framework for all visualizations (no third-party chart libs)
- CloudKit container needed for iCloud sync
- Expense.monthYear is a stored property set from date at init; must be manually updated via .onChange when date is edited
- Category icons are SF Symbols inside small colored rounded squares
- Shared .cardStyle() view modifier: padding + secondarySystemBackground + corner radius 20
- Amount font: semibold, rounded, monospaced design
- Corner radius: 20 (cards), 12 (small elements). Padding: 16 / 8
- Haptics: .impact(.medium) taps, .notification(.success) saves, .notification(.warning) deletes, .selection() pickers/navigation
- Export JSON format: { version: 1, exportDate, budgets: [{monthYear, income}], expenses: [{amount, category, date, notes, monthYear}] }
- Import deduplication by signature: "monthYear-amountCents-notes"
- Always call try? modelContext.save() explicitly after inserts/deletes

## Constraints

- **Platform**: iOS 17+ only — leverages SwiftData and Swift Charts
- **Currency**: EUR with de_DE locale — hardcoded, not configurable
- **Theme**: Dark mode only — no light mode support
- **Dependencies**: Zero third-party dependencies — Apple frameworks only
- **Sync**: iCloud via CloudKit — requires CloudKit container configuration

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| SwiftData over Core Data | Modern persistence, iOS 17+ target allows it | — Pending |
| Swift Charts over third-party | No dependencies, native look and feel | — Pending |
| Stored monthYear over computed | SwiftData query performance, explicit control | — Pending |
| iCloud sync via CloudKit | Multi-device support without custom backend | — Pending |
| Full Xcode project output | Ready to open and run immediately | — Pending |

---
*Last updated: 2026-03-04 after initialization*
