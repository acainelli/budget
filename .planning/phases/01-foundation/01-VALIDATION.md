---
phase: 1
slug: foundation
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-03-04
---

# Phase 1 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | XCTest (built into Xcode, no install needed) |
| **Config file** | Xcode test target (BudgetAppTests — added to .xcodeproj in Wave 0) |
| **Quick run command** | `xcodebuild build -scheme BudgetApp -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest'` |
| **Full suite command** | `xcodebuild test -scheme BudgetApp -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest'` |
| **Estimated runtime** | ~60 seconds (build) / ~90 seconds (full suite) |

---

## Sampling Rate

- **After every task commit:** Run `xcodebuild build -scheme BudgetApp -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest'`
- **After every plan wave:** Run full suite `xcodebuild test -scheme BudgetApp -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest'`
- **Before `/gsd:verify-work`:** Full suite must be green + simulator shows 4-tab shell in dark mode
- **Max feedback latency:** ~90 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 1-01-01 | 01 | 0 | DATA-01 | Unit | `xcodebuild test ... -only-testing BudgetAppTests/ExpenseModelTests` | ❌ W0 | ⬜ pending |
| 1-01-02 | 01 | 0 | DATA-02 | Unit | `xcodebuild test ... -only-testing BudgetAppTests/MonthlyBudgetTests` | ❌ W0 | ⬜ pending |
| 1-01-03 | 01 | 0 | DATA-03 | Unit | `xcodebuild test ... -only-testing BudgetAppTests/ExpenseCategoryTests` | ❌ W0 | ⬜ pending |
| 1-01-04 | 01 | 0 | DATA-04 | Integration | `xcodebuild test ... -only-testing BudgetAppTests/ContainerTests` | ❌ W0 | ⬜ pending |
| 1-01-05 | 01 | 0 | DATA-05 | Unit | `xcodebuild test ... -only-testing BudgetAppTests/FormatterTests` | ❌ W0 | ⬜ pending |
| 1-01-06 | 01 | 1 | DATA-06 | Manual | — code review | N/A | ⬜ pending |
| 1-02-01 | 02 | 1 | APP-01 | Smoke | `xcodebuild build -scheme BudgetApp ...` | ❌ W0 | ⬜ pending |
| 1-02-02 | 02 | 1 | APP-02 | Manual | — visual check in simulator | N/A | ⬜ pending |
| 1-02-03 | 02 | 1 | APP-03 | Smoke | `xcodebuild build -scheme BudgetApp ...` | ❌ W0 | ⬜ pending |
| 1-02-04 | 02 | 1 | APP-04 | Manual | — visual check in simulator | N/A | ⬜ pending |
| 1-03-01 | 03 | 1 | UX-01 | Manual | — dark mode visual check | N/A | ⬜ pending |
| 1-03-02 | 03 | 1 | UX-02 | Manual | — accent color visual check | N/A | ⬜ pending |
| 1-03-03 | 03 | 1 | UX-03 | Unit | `xcodebuild test ... -only-testing BudgetAppTests/DesignSystemTests` | ❌ W0 | ⬜ pending |
| 1-03-04 | 03 | 1 | UX-04 | Unit | `xcodebuild test ... -only-testing BudgetAppTests/DesignSystemTests` | ❌ W0 | ⬜ pending |
| 1-03-05 | 03 | 1 | UX-05 | Smoke | `xcodebuild build -scheme BudgetApp ...` | ❌ W0 | ⬜ pending |
| 1-03-06 | 03 | 1 | UX-06 | Unit | `xcodebuild test ... -only-testing BudgetAppTests/HapticManagerTests` | ❌ W0 | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `BudgetApp/BudgetAppTests/ExpenseModelTests.swift` — DATA-01: Expense insert, fetch, correct monthYear stored
- [ ] `BudgetApp/BudgetAppTests/MonthlyBudgetTests.swift` — DATA-02: fetch-or-create idempotency
- [ ] `BudgetApp/BudgetAppTests/ExpenseCategoryTests.swift` — DATA-03: all 8 categories have valid symbol + color
- [ ] `BudgetApp/BudgetAppTests/ContainerTests.swift` — DATA-04: ModelContainer init (in-memory config in tests, not CloudKit)
- [ ] `BudgetApp/BudgetAppTests/FormatterTests.swift` — DATA-05: `45.8.formattedEUR == "€45,80"` assertion
- [ ] `BudgetApp/BudgetAppTests/DesignSystemTests.swift` — UX-03, UX-04: cardStyle compiles, token values match spec
- [ ] `BudgetApp/BudgetAppTests/HapticManagerTests.swift` — UX-06: all four haptic calls execute without crash
- [ ] Test target `BudgetAppTests` added to `project.pbxproj` with correct GUID references

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| DATA-06: explicit save() called | DATA-06 | Code pattern review, not runtime observable | Read all mutation sites; confirm try? modelContext.save() present after every insert/delete |
| APP-02: FAB visible tabs 0-1 only | APP-02 | SwiftUI conditional rendering | Run in simulator; tap each tab; confirm FAB appears on Dashboard and Expenses, hidden on Insights and Settings |
| APP-04: App icon correct | APP-04 | Asset catalog visual verification | Build and run; check app icon on simulator home screen |
| UX-01: Dark mode enforced | UX-01 | System appearance | Run in simulator; device appearance set to Light; confirm app remains dark |
| UX-02: Accent color correct | UX-02 | Visual verification | Tap interactive elements; confirm green #004225 tint throughout |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 90s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
