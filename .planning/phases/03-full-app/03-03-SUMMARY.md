---
phase: 03-full-app
plan: "03"
subsystem: ui
tags: [swiftui, swiftdata, sharelink, fileimporter, json, settings]

# Dependency graph
requires:
  - phase: 03-full-app
    provides: MonthlyBudget.fetchOrCreate and Expense models used by Settings

provides:
  - SettingsView with monthly income form persisting via MonthlyBudget
  - DataManagementView with JSON export via ShareLink
  - JSON import with deduplication by monthYear-amountCents-notes signature
  - Delete All Data with confirmation dialog

affects: [03-full-app]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - ShareLink with temporary file URL for exporting JSON data
    - fileImporter with security-scoped resource access for JSON import
    - Codable ExportData/BudgetExport/ExpenseExport structs for versioned JSON
    - Deduplication signature pattern: monthYear-amountCents-notes

key-files:
  created:
    - BudgetApp/Features/Settings/DataManagementView.swift
  modified:
    - BudgetApp/Features/Settings/SettingsView.swift
    - BudgetApp.xcodeproj/project.pbxproj

key-decisions:
  - "ShareLink uses temporary file URL (FileManager.default.temporaryDirectory) to share typed JSON file with .json extension"
  - "Income TextField uses comma-to-dot normalization for European decimal input"
  - "Export deduplication signature is monthYear-amountCents-notes to uniquely identify expenses across imports"

patterns-established:
  - "ShareLink with temp URL: write Data to FileManager.default.temporaryDirectory, pass URL to ShareLink(item:)"
  - "fileImporter: startAccessingSecurityScopedResource / stopAccessingSecurityScopedResource around Data read"

requirements-completed: [SET-01, SET-02, SET-03, SET-04, SET-05]

# Metrics
duration: 8min
completed: 2026-03-04
---

# Phase 3 Plan 03: Settings Summary

**Full Settings tab with monthly income form, ShareLink JSON export, fileImporter import with dedup, and Delete All Data confirmation**

## Performance

- **Duration:** 8 min
- **Started:** 2026-03-04T22:47:56Z
- **Completed:** 2026-03-04T22:55:56Z
- **Tasks:** 2
- **Files modified:** 3

## Accomplishments
- SettingsView replaced stub with income TextField, comma decimal support, and NavigationLink to DataManagementView
- DataManagementView exports all data as versioned JSON (version/exportDate/budgets/expenses) via ShareLink with temp file URL
- JSON import with security-scoped resource access, budget upsert, and expense deduplication by signature
- Delete All Data removes all Expense and MonthlyBudget records after confirmationDialog

## Task Commits

Each task was committed atomically:

1. **Task 1: SettingsView with monthly income input** - `e9612ab` (feat)
2. **Task 2: DataManagementView with export, import, delete all, and pbxproj** - `d4a6ee4` (feat)

## Files Created/Modified
- `BudgetApp/Features/Settings/SettingsView.swift` - Monthly income form with fetchOrCreate integration and DataManagementView navigation
- `BudgetApp/Features/Settings/DataManagementView.swift` - Export via ShareLink, import via fileImporter with dedup, delete all with confirmation
- `BudgetApp.xcodeproj/project.pbxproj` - DataManagementView.swift registered (file ref AA...059, build file AA...120)

## Decisions Made
- ShareLink receives a URL (temp file) rather than a raw String, so the system share sheet recognizes it as a .json file with a meaningful filename
- Income TextField uses comma-to-period normalization before Double parsing to handle European locale input
- Deduplication signature `monthYear-amountCents-notes` chosen to match PROJECT.md specification exactly

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None.

## User Setup Required

None - no external service configuration required.

## Self-Check: PASSED

All files verified present, all commits verified in git log.

## Next Phase Readiness
- Settings tab fully functional with income persistence and data management
- All SET requirements satisfied: SET-01 through SET-05
- Ready for final phase completion and app polish

---
*Phase: 03-full-app*
*Completed: 2026-03-04*
