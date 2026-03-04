# Phase 1: Foundation - Context

**Gathered:** 2026-03-04
**Status:** Ready for planning

<domain>
## Phase Boundary

A buildable Xcode project exists with all SwiftData models, CloudKit sync configured, the 4-tab shell rendering, the design system in place (tokens, modifiers, haptics), and the app icon. No user flows are implemented. This is the skeleton every subsequent phase builds on.

</domain>

<decisions>
## Implementation Decisions

### Project structure
- Full Xcode project (.xcodeproj) — not SPM package or Swift Playgrounds
- Feature-based folder organization: Features/Dashboard/, Features/Expenses/, Features/Insights/, Features/Settings/, Features/AddExpense/
- Shared code under: Core/Models/, Core/Extensions/, Core/DesignSystem/
- App entry point named BudgetApp

### Bundle ID & CloudKit
- Bundle identifier placeholder: `com.placeholder.BudgetApp` (user replaces with their own)
- iCloud container: `iCloud.com.placeholder.BudgetApp` (matches bundle ID)
- CloudKit capability added to .entitlements file
- Background Modes: Remote notifications enabled (required for CloudKit push sync)

### SwiftData models
- Expense: amount (Double), category (ExpenseCategory), date (Date), notes (String), monthYear (stored String "yyyy-MM" — set at init from date, NOT computed)
- MonthlyBudget: monthYear (String, unique), income (Double), default 0
- Both marked @Model
- Explicit try? modelContext.save() after every insert and delete — never rely on autosave

### Categories (all 8, fully locked)
- groceries → cart.fill → systemGreen
- restaurants → fork.knife → systemOrange
- car → car.fill → systemBlue
- mealVoucher → creditcard.fill → systemPurple
- pharmacy → cross.case.fill → systemRed
- bills → doc.text.fill → systemGray
- chico → teddybear.fill → brown
- shopping → bag.fill → systemPink
- Each icon: SF Symbol inside a small rounded square (corner radius 8), square size ~36pt, symbol size ~18pt (SF font size .body equivalent)

### Tab shell
- 4 tabs: Dashboard (house.fill), Expenses (list.bullet), Insights (chart.bar.xaxis), Settings (gearshape.fill)
- Default selected tab: 0 (Dashboard)
- FAB: ZStack overlay pinned to bottom-right above tab bar, using safeAreaInsets to position correctly; appears only on tabs 0 and 1; no animation on tab switch (instant show/hide)
- FAB visual: green (#004225) circle, 56pt diameter, "+" system image, white foreground, shadow

### Design system
- AccentColor asset: #004225 (dark green hex)
- .cardStyle() view modifier: .padding(16) + .background(Color(uiColor: .secondarySystemBackground)) + .cornerRadius(20)
- Corner radius tokens: 20 for cards, 12 for small elements
- Padding tokens: 16 (outer), 8 (inner/between elements)
- Amount font: .font(.system(.title2, design: .rounded).weight(.semibold)).monospacedDigit()
- Currency formatter: Locale(identifier: "de_DE"), currency code EUR, NumberFormatter.Style.currency → produces "€45,80" format

### Theme
- Dark mode only: .preferredColorScheme(.dark) on root ContentView
- Accent color via AccentColor asset catalog

### Haptics
- UIImpactFeedbackGenerator(.medium) for taps
- UINotificationFeedbackGenerator(.success) for saves
- UINotificationFeedbackGenerator(.warning) for deletes
- UISelectionFeedbackGenerator for pickers and navigation

### App icon
- Black background, #004225 green dollar sign ($), 1024×1024
- Provided as AppIcon asset catalog entry

### Claude's Discretion
- Exact Xcode project settings (Swift version flag, deployment target set to 17.0)
- Whether to use @Observable or ObservableObject for any view models (prefer @Observable / @Bindable since iOS 17+)
- Exact SwiftData ModelContainer setup (in-memory vs persisted toggle for previews)
- CloudKit container initialization pattern
- Whether to create a HapticManager helper struct or call generators inline

</decisions>

<specifics>
## Specific Ideas

- Amount formatting must produce German-locale output: comma decimal separator, euro sign prefix, e.g. "€45,80" — not "€45.80"
- .cardStyle() is a view modifier shared across all tabs — define it once in DesignSystem, never duplicate
- monthYear stored property is critical for SwiftData query performance — must never be computed
- "Always call try? modelContext.save() explicitly" is a hard rule from the spec — no exceptions

</specifics>

<code_context>
## Existing Code Insights

### Reusable Assets
- None — greenfield project, no existing code

### Established Patterns
- None yet — Phase 1 establishes all patterns that subsequent phases will follow

### Integration Points
- Phase 2 builds AddExpense sheet and Dashboard on top of Phase 1's models and tab shell
- Phase 3 builds Expenses, Insights, Settings tabs on top of the same shell

</code_context>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope.

</deferred>

---

*Phase: 01-foundation*
*Context gathered: 2026-03-04*
