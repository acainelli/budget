---
phase: 03-full-app
plan: 02
subsystem: ui
tags: [swiftui, charts, swiftdata, ios, insights]

# Dependency graph
requires:
  - phase: 02-core-loop
    provides: Expense SwiftData model, CategoryBreakdownCard donut pattern, MonthPickerView, cardStyle modifier, HapticManager

provides:
  - InsightsView with segmented Charts/Calendar picker and shared monthYear state
  - InsightsChartsView with donut pie, spending trend LineMark, 6-month comparison BarMark
  - SpendingTrendChart with daily totals, catmullRom interpolation, AreaMark fill
  - MonthlyComparisonChart for last 6 months with accent-color highlight on current month
  - InsightsCalendarView with 7-column heat-map month grid and tappable day cells
  - CalendarWeekView with horizontal 7-day row and left/right week navigation
  - DayExpensesSheet showing daily total and flat expense list with dismiss button

affects: [03-full-app]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "InsightsSegment enum for Charts/Calendar tab switching"
    - "Heat-map opacity: dailyTotal / maxDailyTotal clamped to 0.1 minimum when spending exists"
    - "CalendarViewMode enum for Month/Week toggle within Calendar segment"
    - "Monday-first weekday alignment: (weekday + 5) % 7"

key-files:
  created:
    - BudgetApp/Features/Insights/InsightsChartsView.swift
    - BudgetApp/Features/Insights/SpendingTrendChart.swift
    - BudgetApp/Features/Insights/MonthlyComparisonChart.swift
    - BudgetApp/Features/Insights/InsightsCalendarView.swift
    - BudgetApp/Features/Insights/CalendarWeekView.swift
    - BudgetApp/Features/Insights/DayExpensesSheet.swift
  modified:
    - BudgetApp/Features/Insights/InsightsView.swift
    - BudgetApp.xcodeproj/project.pbxproj

key-decisions:
  - "InsightsCalendarView uses separate showDaySheet Bool + selectedDay Date to avoid Date Identifiable conformance requirement for .sheet(item:)"
  - "CalendarWeekView initializes weekStart to Monday of current week using (weekday+5)%7 formula consistent with month grid alignment"
  - "MonthlyComparisonChart uses Color.secondary.opacity(0.5) for non-current months to avoid needing custom annotation"

patterns-established:
  - "Heat-map opacity pattern: max(0.1, total/maxTotal) for visibility — any spending = at least 10% opacity"
  - "7-column LazyVGrid with leading blank cells for Monday-first calendar alignment"

requirements-completed: [INS-01, INS-02, INS-03, INS-04, INS-05, INS-06]

# Metrics
duration: 2min
completed: 2026-03-04
---

# Phase 3 Plan 02: Insights Tab Summary

**Full Insights tab with segmented Charts/Calendar views: donut pie chart, daily spending trend LineMark, 6-month comparison BarMark, heat-map calendar month grid with tappable day detail sheet, and horizontal week view with navigation**

## Performance

- **Duration:** ~2 min
- **Started:** 2026-03-04T22:48:04Z
- **Completed:** 2026-03-04T22:50:14Z
- **Tasks:** 2
- **Files modified:** 8

## Accomplishments
- Replaced InsightsView stub with full segmented Charts/Calendar container sharing MonthPickerView and monthYear state
- Delivered three charts in InsightsChartsView: SectorMark donut (reused from Dashboard), SpendingTrendChart with LineMark+AreaMark, MonthlyComparisonChart with 6-month BarMark
- Built InsightsCalendarView with 7-column Monday-first heat-map grid where accent color opacity encodes spending intensity; tapping any day opens DayExpensesSheet
- Added CalendarWeekView with horizontal 7-day row, heat-map circles, and chevron week navigation
- Registered all 6 new files in project.pbxproj with unique GUIDs (file refs 0x053-0x058, build files 0x11A-0x11F)

## Task Commits

Each task was committed atomically:

1. **Task 1: InsightsView container, ChartsView with pie/trend/comparison charts** - `daf995d` (feat)
2. **Task 2: Calendar heat-map view, week view, day detail sheet, and pbxproj registration** - `dcd9cd8` (feat)

## Files Created/Modified
- `BudgetApp/Features/Insights/InsightsView.swift` - Container with segmented picker, MonthPickerView, shared monthYear state
- `BudgetApp/Features/Insights/InsightsChartsView.swift` - Scrollable pie + trend + comparison charts
- `BudgetApp/Features/Insights/SpendingTrendChart.swift` - LineMark daily spending trend with AreaMark fill
- `BudgetApp/Features/Insights/MonthlyComparisonChart.swift` - BarMark last 6 months totals
- `BudgetApp/Features/Insights/InsightsCalendarView.swift` - 7-column heat-map grid with sheet trigger
- `BudgetApp/Features/Insights/CalendarWeekView.swift` - Horizontal 7-day row with week navigation
- `BudgetApp/Features/Insights/DayExpensesSheet.swift` - Day total + expense list with presentationDetents
- `BudgetApp.xcodeproj/project.pbxproj` - Registered 6 new Insights files

## Decisions Made
- InsightsCalendarView uses `@State var showDaySheet: Bool` alongside `@State var selectedDay: Date?` because `Date` doesn't conform to `Identifiable`, avoiding `.sheet(item:)` requirement
- CalendarWeekView initializes `weekStart` to the Monday of the current week using `(weekday + 5) % 7` — consistent with month grid column alignment
- MonthlyComparisonChart colors non-current bars with `Color.secondary.opacity(0.5)` for clear visual differentiation without custom chart annotations

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness
- All INS-01 through INS-06 requirements complete
- Insights tab fully functional with Charts and Calendar segments
- Ready for Phase 3 Plan 03 (Expenses tab full feature set)

---
*Phase: 03-full-app*
*Completed: 2026-03-04*
