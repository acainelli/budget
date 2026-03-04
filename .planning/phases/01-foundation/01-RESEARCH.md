# Phase 1: Foundation - Research

**Researched:** 2026-03-04
**Domain:** SwiftUI / SwiftData / CloudKit / iOS project structure
**Confidence:** HIGH

---

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

**Project structure**
- Full Xcode project (.xcodeproj) — not SPM package or Swift Playgrounds
- Feature-based folder organization: Features/Dashboard/, Features/Expenses/, Features/Insights/, Features/Settings/, Features/AddExpense/
- Shared code under: Core/Models/, Core/Extensions/, Core/DesignSystem/
- App entry point named BudgetApp

**Bundle ID & CloudKit**
- Bundle identifier placeholder: `com.placeholder.BudgetApp`
- iCloud container: `iCloud.com.placeholder.BudgetApp` (matches bundle ID)
- CloudKit capability added to .entitlements file
- Background Modes: Remote notifications enabled (required for CloudKit push sync)

**SwiftData models**
- Expense: amount (Double), category (ExpenseCategory), date (Date), notes (String), monthYear (stored String "yyyy-MM" — set at init from date, NOT computed)
- MonthlyBudget: monthYear (String, unique), income (Double), default 0
- Both marked @Model
- Explicit try? modelContext.save() after every insert and delete — never rely on autosave

**Categories (all 8, fully locked)**
- groceries → cart.fill → systemGreen
- restaurants → fork.knife → systemOrange
- car → car.fill → systemBlue
- mealVoucher → creditcard.fill → systemPurple
- pharmacy → cross.case.fill → systemRed
- bills → doc.text.fill → systemGray
- chico → teddybear.fill → brown
- shopping → bag.fill → systemPink
- Each icon: SF Symbol inside a small rounded square (corner radius 8), square size ~36pt, symbol size ~18pt (SF font size .body equivalent)

**Tab shell**
- 4 tabs: Dashboard (house.fill), Expenses (list.bullet), Insights (chart.bar.xaxis), Settings (gearshape.fill)
- Default selected tab: 0 (Dashboard)
- FAB: ZStack overlay pinned to bottom-right above tab bar, using safeAreaInsets to position correctly; appears only on tabs 0 and 1; no animation on tab switch (instant show/hide)
- FAB visual: green (#004225) circle, 56pt diameter, "+" system image, white foreground, shadow

**Design system**
- AccentColor asset: #004225 (dark green hex)
- .cardStyle() view modifier: .padding(16) + .background(Color(uiColor: .secondarySystemBackground)) + .cornerRadius(20)
- Corner radius tokens: 20 for cards, 12 for small elements
- Padding tokens: 16 (outer), 8 (inner/between elements)
- Amount font: .font(.system(.title2, design: .rounded).weight(.semibold)).monospacedDigit()
- Currency formatter: Locale(identifier: "de_DE"), currency code EUR, NumberFormatter.Style.currency — produces "€45,80" format

**Theme**
- Dark mode only: .preferredColorScheme(.dark) on root ContentView
- Accent color via AccentColor asset catalog

**Haptics**
- UIImpactFeedbackGenerator(.medium) for taps
- UINotificationFeedbackGenerator(.success) for saves
- UINotificationFeedbackGenerator(.warning) for deletes
- UISelectionFeedbackGenerator for pickers and navigation

**App icon**
- Black background, #004225 green dollar sign ($), 1024x1024
- Provided as AppIcon asset catalog entry

### Claude's Discretion
- Exact Xcode project settings (Swift version flag, deployment target set to 17.0)
- Whether to use @Observable or ObservableObject for any view models (prefer @Observable / @Bindable since iOS 17+)
- Exact SwiftData ModelContainer setup (in-memory vs persisted toggle for previews)
- CloudKit container initialization pattern
- Whether to create a HapticManager helper struct or call generators inline

### Deferred Ideas (OUT OF SCOPE)
None — discussion stayed within phase scope.
</user_constraints>

---

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| DATA-01 | Expense model with amount (Double), category (ExpenseCategory enum), date (Date), notes (String), monthYear (stored String "yyyy-MM") | SwiftData @Model class; monthYear set in init via DateFormatter("yyyy-MM") |
| DATA-02 | MonthlyBudget model with monthYear (String, unique), income (Double), default income 0 | @Model class; uniqueness enforced at app-logic level (not @Attribute(.unique)) due to CloudKit incompatibility |
| DATA-03 | 8 expense categories with SF Symbols and colors | Swift enum with rawValue String; each case carries symbol and color via computed properties |
| DATA-04 | iCloud sync via CloudKit-backed SwiftData | ModelConfiguration(cloudKitContainerIdentifier:) + iCloud entitlement + Background Modes: Remote Notifications |
| DATA-05 | EUR currency formatted as German locale (de_DE, comma decimal: €45,80) | NumberFormatter with .currency style, Locale("de_DE"), currencyCode = "EUR" |
| DATA-06 | Explicit modelContext.save() after all inserts and deletes | try? modelContext.save() called at every mutation site |
| APP-01 | 4-tab layout with named icons | TabView with selection binding; enum for tab identity |
| APP-02 | FAB on Dashboard and Expenses tabs only | ZStack overlay with conditional visibility tied to selectedTab state |
| APP-03 | Full Xcode project (.xcodeproj) ready to build | Manually authored .xcodeproj directory structure with correct pbxproj |
| APP-04 | App icon: black background, green dollar sign, 1024x1024 | AppIcon image set in Assets.xcassets |
| UX-01 | Dark mode only | .preferredColorScheme(.dark) on ContentView (root) |
| UX-02 | Accent color #004225 via AccentColor asset | AccentColor color set in Assets.xcassets |
| UX-03 | Shared .cardStyle() view modifier | ViewModifier protocol + View extension in Core/DesignSystem/ |
| UX-04 | Corner radius 20/12, padding 16/8 tokens | Constants enum or struct in DesignSystem |
| UX-05 | Amount font: semibold, rounded, monospaced | .font(.system(.title2, design: .rounded).weight(.semibold)).monospacedDigit() |
| UX-06 | Haptics: .impact(.medium), .notification(.success/.warning), .selection() | HapticManager struct wrapping UIKit feedback generators |
</phase_requirements>

---

## Summary

Phase 1 establishes every scaffold other phases build on: the Xcode project skeleton, SwiftData models, CloudKit wiring, the 4-tab shell with FAB, and the design system (tokens, view modifiers, haptics). Because this is a greenfield project with zero third-party dependencies, all artifacts must be authored from scratch using only Apple frameworks available in iOS 17+.

The most technically nuanced area is the SwiftData + CloudKit combination. CloudKit imposes strict constraints that conflict with some natural SwiftData patterns: `@Attribute(.unique)` cannot be used on any property that syncs to CloudKit, all properties must have defaults or be optional, and all relationships must be optional. The MonthlyBudget uniqueness requirement (one record per monthYear) must therefore be enforced at the application logic layer via a fetch-or-create pattern rather than a database constraint.

For the Xcode project itself, the output must be a hand-authored `.xcodeproj` bundle (a directory containing a `project.pbxproj` file) with all Swift source files, the entitlements file, and the asset catalog. The planner must produce each file as a concrete artifact — no build tool generates the project for us.

**Primary recommendation:** Author the project in a specific wave order — project skeleton first, then SwiftData models, then CloudKit wiring, then design system, then tab shell — so each wave produces a compilable app that incrementally gains capabilities.

---

## Standard Stack

### Core

| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| SwiftUI | iOS 17 | Declarative UI framework | Required by spec; @Observable, @Query, TabView, all available |
| SwiftData | iOS 17 | Persistence layer | Required by spec; replaces Core Data for new projects |
| CloudKit | iOS 17 | iCloud sync backend | Required by spec; zero-config sync via ModelContainer |
| Foundation | iOS 17 | NumberFormatter, DateFormatter, locale | Standard library; no alternative needed |
| UIKit | iOS 17 | UIFeedbackGenerator subclasses for haptics | .sensoryFeedback exists in iOS 17 SwiftUI but UIKit generators give fine-grained control matching spec |

### Supporting

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| Observation | iOS 17 | @Observable macro | Any view model that does NOT touch the database directly |
| SwiftData Query | iOS 17 | @Query property wrapper | Views that need filtered/sorted lists from the store |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| UIImpactFeedbackGenerator (UIKit) | .sensoryFeedback (SwiftUI, iOS 17) | .sensoryFeedback is cleaner but lacks .selection() equivalent and slightly less control; spec lists UIKit types explicitly |
| Manual .xcodeproj authoring | XcodeGen (YAML spec) | XcodeGen simplifies project file generation but is a third-party tool; spec forbids third-party dependencies |

**Installation:** No package installation needed. All frameworks are part of iOS 17 SDK.

---

## Architecture Patterns

### Recommended Project Structure

```
BudgetApp/
├── BudgetApp.xcodeproj/
│   └── project.pbxproj
├── BudgetApp/
│   ├── BudgetAppApp.swift          # @main entry point, ModelContainer, .preferredColorScheme
│   ├── ContentView.swift           # Root TabView + FAB overlay
│   ├── BudgetApp.entitlements      # com.apple.developer.icloud-container-identifiers
│   ├── Assets.xcassets/
│   │   ├── AccentColor.colorset/   # #004225 hex
│   │   └── AppIcon.appiconset/     # 1024x1024 PNG
│   ├── Core/
│   │   ├── Models/
│   │   │   ├── Expense.swift       # @Model Expense + ExpenseCategory enum
│   │   │   └── MonthlyBudget.swift # @Model MonthlyBudget
│   │   ├── Extensions/
│   │   │   └── NumberFormatter+Currency.swift
│   │   └── DesignSystem/
│   │       ├── DesignTokens.swift  # Constants for radius, padding
│   │       ├── CardStyle.swift     # ViewModifier + View extension
│   │       └── HapticManager.swift # Struct wrapping UIKit generators
│   └── Features/
│       ├── Dashboard/
│       │   └── DashboardView.swift # Placeholder view
│       ├── Expenses/
│       │   └── ExpensesView.swift  # Placeholder view
│       ├── Insights/
│       │   └── InsightsView.swift  # Placeholder view
│       ├── Settings/
│       │   └── SettingsView.swift  # Placeholder view
│       └── AddExpense/
│           └── AddExpenseView.swift # Placeholder (FAB destination)
```

### Pattern 1: SwiftData Model Declaration

**What:** @Model class with all properties having defaults or optional types; no @Attribute(.unique) for CloudKit compatibility.
**When to use:** All persistent model types in this project.

```swift
// Core/Models/Expense.swift
import SwiftData
import Foundation

@Model
final class Expense {
    var amount: Double
    var category: ExpenseCategory
    var date: Date
    var notes: String
    var monthYear: String  // "yyyy-MM" — stored, never computed

    init(amount: Double, category: ExpenseCategory, date: Date, notes: String = "") {
        self.amount = amount
        self.category = category
        self.date = date
        self.notes = notes
        // monthYear set explicitly at init time
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        self.monthYear = formatter.string(from: date)
    }
}

@Model
final class MonthlyBudget {
    var monthYear: String   // "yyyy-MM"; uniqueness enforced by app logic, NOT @Attribute(.unique)
    var income: Double

    init(monthYear: String, income: Double = 0) {
        self.monthYear = monthYear
        self.income = income
    }
}
```

### Pattern 2: CloudKit-backed ModelContainer Setup

**What:** ModelContainer created at app entry point with cloudKitContainerIdentifier explicitly specified.
**When to use:** App @main struct.

```swift
// BudgetAppApp.swift
import SwiftUI
import SwiftData

@main
struct BudgetAppApp: App {
    let container: ModelContainer

    init() {
        do {
            let config = ModelConfiguration(
                cloudKitContainerIdentifier: "iCloud.com.placeholder.BudgetApp"
            )
            container = try ModelContainer(
                for: Expense.self, MonthlyBudget.self,
                configurations: config
            )
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
        .modelContainer(container)
    }
}
```

### Pattern 3: In-Memory Container for Previews

**What:** ModelConfiguration(isStoredInMemoryOnly: true) prevents preview data from polluting the real store and avoids CloudKit calls.
**When to use:** All #Preview blocks.

```swift
// Usage in #Preview blocks
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Expense.self, MonthlyBudget.self,
                                        configurations: config)
    return DashboardView()
        .modelContainer(container)
}
```

### Pattern 4: Explicit Save After Mutations

**What:** Always call try? modelContext.save() after insert or delete. Never rely on autosave.
**When to use:** Every mutation site throughout the app.

```swift
// Correct pattern — always explicit
modelContext.insert(expense)
try? modelContext.save()

// Delete pattern
modelContext.delete(expense)
try? modelContext.save()
```

### Pattern 5: TabView with FAB Overlay

**What:** ZStack wraps TabView and the floating button, with the button's visibility driven by selectedTab state.
**When to use:** ContentView root.

```swift
// ContentView.swift
import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Int = 0
    @State private var showingAddExpense = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            TabView(selection: $selectedTab) {
                DashboardView()
                    .tabItem { Label("Dashboard", systemImage: "house.fill") }
                    .tag(0)
                ExpensesView()
                    .tabItem { Label("Expenses", systemImage: "list.bullet") }
                    .tag(1)
                InsightsView()
                    .tabItem { Label("Insights", systemImage: "chart.bar.xaxis") }
                    .tag(2)
                SettingsView()
                    .tabItem { Label("Settings", systemImage: "gearshape.fill") }
                    .tag(3)
            }

            if selectedTab == 0 || selectedTab == 1 {
                Button {
                    HapticManager.impact()
                    showingAddExpense = true
                } label: {
                    Image(systemName: "plus")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(width: 56, height: 56)
                        .background(Color(hex: "#004225"))
                        .clipShape(Circle())
                        .shadow(radius: 4, y: 2)
                }
                .padding(.trailing, 20)
                .padding(.bottom, 80)   // above tab bar; adjust with geometry reader if needed
            }
        }
        .sheet(isPresented: $showingAddExpense) {
            AddExpenseView()
        }
    }
}
```

### Pattern 6: MonthlyBudget Fetch-or-Create (Uniqueness Without @Attribute(.unique))

**What:** Query for an existing record before inserting; only create if none found.
**When to use:** Whenever a MonthlyBudget for a given monthYear is needed.

```swift
// Fetch-or-create pattern
func fetchOrCreateBudget(for monthYear: String, context: ModelContext) -> MonthlyBudget {
    let descriptor = FetchDescriptor<MonthlyBudget>(
        predicate: #Predicate { $0.monthYear == monthYear }
    )
    if let existing = try? context.fetch(descriptor).first {
        return existing
    }
    let budget = MonthlyBudget(monthYear: monthYear)
    context.insert(budget)
    try? context.save()
    return budget
}
```

### Pattern 7: Design System Components

**What:** ViewModifier + View extension for .cardStyle(); Constants enum for design tokens; HapticManager struct.
**When to use:** Across all feature views.

```swift
// Core/DesignSystem/CardStyle.swift
import SwiftUI

struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(Color(uiColor: .secondarySystemBackground))
            .cornerRadius(20)
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
}

// Core/DesignSystem/DesignTokens.swift
enum DesignTokens {
    enum CornerRadius {
        static let card: CGFloat = 20
        static let small: CGFloat = 12
        static let categoryIcon: CGFloat = 8
    }
    enum Padding {
        static let outer: CGFloat = 16
        static let inner: CGFloat = 8
    }
    enum FAB {
        static let size: CGFloat = 56
    }
}

// Core/DesignSystem/HapticManager.swift
import UIKit

struct HapticManager {
    static func impact() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }
    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    static func warning() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }
    static func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }
}

// Core/Extensions/NumberFormatter+Currency.swift
import Foundation

extension NumberFormatter {
    static let eurGerman: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.locale = Locale(identifier: "de_DE")
        f.currencyCode = "EUR"
        return f
    }()
}

extension Double {
    var formattedEUR: String {
        NumberFormatter.eurGerman.string(from: NSNumber(value: self)) ?? "€0,00"
    }
}
```

### Pattern 8: ExpenseCategory Enum

**What:** String-backed enum with associated SF Symbol name and SwiftUI Color.
**When to use:** Core/Models/Expense.swift alongside the Expense model.

```swift
enum ExpenseCategory: String, CaseIterable, Codable {
    case groceries
    case restaurants
    case car
    case mealVoucher
    case pharmacy
    case bills
    case chico
    case shopping

    var symbol: String {
        switch self {
        case .groceries:   return "cart.fill"
        case .restaurants: return "fork.knife"
        case .car:         return "car.fill"
        case .mealVoucher: return "creditcard.fill"
        case .pharmacy:    return "cross.case.fill"
        case .bills:       return "doc.text.fill"
        case .chico:       return "teddybear.fill"
        case .shopping:    return "bag.fill"
        }
    }

    var color: Color {
        switch self {
        case .groceries:   return .green
        case .restaurants: return .orange
        case .car:         return .blue
        case .mealVoucher: return .purple
        case .pharmacy:    return .red
        case .bills:       return .gray
        case .chico:       return Color(uiColor: .brown)
        case .shopping:    return .pink
        }
    }

    var displayName: String { rawValue.capitalized }
}
```

### Anti-Patterns to Avoid

- **@Attribute(.unique) on CloudKit-synced models:** The ModelContainer will refuse to load. Enforce uniqueness in app logic instead.
- **Computed monthYear property:** SwiftData cannot filter/sort on computed properties; monthYear must be stored and set at init.
- **Relying on SwiftData autosave:** Always call try? modelContext.save() explicitly per spec.
- **Relationship properties assigned in init:** SwiftData inserts objects first, then sets relationships; assigning in init can corrupt the graph.
- **All properties non-optional on CloudKit models:** CloudKit handles partial sync; properties without defaults and without optionality will block sync.
- **Using @ObservableObject instead of @Observable:** iOS 17+ use @Observable with @State/@Bindable; avoids the old ObservableObject/StateObject ceremony.
- **Placing .preferredColorScheme(.dark) on a non-root view:** Must be at the ContentView (root) level to affect the entire app including system chrome.

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Currency formatting | Custom string interpolation | NumberFormatter.eurGerman (static singleton) | Locale edge cases, group separators, sign handling |
| CloudKit sync | Custom CKRecord upload logic | ModelContainer(cloudKitContainerIdentifier:) | Full conflict resolution, push notifications, quota management handled by framework |
| Haptic timing | Custom Core Haptics AHAP files | UIImpactFeedbackGenerator / UINotificationFeedbackGenerator | Spec explicitly names these; simpler for the three defined patterns |
| Dark mode enforcement | Overriding trait collection | .preferredColorScheme(.dark) modifier | Single declarative modifier; works across sheets, popovers, and all child views |
| monthYear parsing | RegEx or ad-hoc substring | DateFormatter("yyyy-MM").string(from:) | Handles locale nuances and DST transitions correctly |

**Key insight:** SwiftData's ModelContainer does the heavy lifting for CloudKit sync. The entire sync setup is two lines of code — any custom CloudKit logic adds complexity without benefit for a private-database, single-user app.

---

## Common Pitfalls

### Pitfall 1: @Attribute(.unique) Breaks CloudKit ModelContainer

**What goes wrong:** Adding `@Attribute(.unique)` to MonthlyBudget.monthYear causes the ModelContainer to throw a fatal error at launch when CloudKit is enabled. The container simply will not load.
**Why it happens:** CloudKit cannot enforce atomic uniqueness constraints across distributed devices. The framework blocks setup rather than silently ignoring the constraint.
**How to avoid:** Never use `@Attribute(.unique)` on any model that is synced to CloudKit. Enforce uniqueness at the fetch-or-create call site.
**Warning signs:** App crashes at launch with a SwiftData schema validation error before any views appear.

### Pitfall 2: Non-Optional Properties Without Defaults Block CloudKit Sync

**What goes wrong:** CloudKit silently fails to sync records when a property is non-optional and has no default value. Data exists on one device but never arrives on others.
**Why it happens:** CloudKit syncs partial records during conflict resolution. If a required non-optional property is missing from a partial record, SwiftData refuses to materialize the object.
**How to avoid:** Give every property either a default value in its declaration or make it optional. Even `notes: String = ""` is sufficient.
**Warning signs:** Sync appears to work but data inconsistencies appear across devices over time.

### Pitfall 3: monthYear as Computed Property Breaks @Query Predicates

**What goes wrong:** If monthYear is `var monthYear: String { ... }` (computed), SwiftData `#Predicate` cannot filter on it and will throw a runtime error or silently return wrong results.
**Why it happens:** SwiftData predicates operate on stored columns, not computed Swift properties. There is no database column to filter against.
**How to avoid:** monthYear must be a stored `var monthYear: String` set in the initializer from the date using `DateFormatter("yyyy-MM")`.
**Warning signs:** #Predicate compilation errors or empty query results when filtering by month.

### Pitfall 4: FAB Positioned Below Tab Bar

**What goes wrong:** The FAB button appears hidden behind the system tab bar because bottom padding was calculated without accounting for the tab bar height (~49pt) plus safe area bottom inset.
**Why it happens:** The ZStack overlay does not automatically shrink to avoid the tab bar; it spans the full screen height.
**How to avoid:** Use `.padding(.bottom, 80)` as a starting value (49pt tab bar + ~20pt safe area + margin), or read the bottom safe area inset via `GeometryReader` / `@Environment(\.safeAreaInsets)` for precise positioning.
**Warning signs:** FAB invisible or partially clipped on devices with home indicator.

### Pitfall 5: de_DE NumberFormatter Position of Euro Sign

**What goes wrong:** German locale places the euro sign after the number by default (e.g., "45,80 €") rather than before (e.g., "€45,80") as specified.
**Why it happens:** The de_DE locale standard is suffix positioning. The spec mandates prefix positioning.
**How to avoid:** After setting locale and currencyCode, explicitly override the currency symbol position: set `f.currencySymbol = "€"` and verify with a test value. If needed, set `positiveFormat = "€#,##0.00"` or post-process the string. Test the formatter with a known input before shipping.
**Warning signs:** Amount strings have the euro sign at the end in the UI.

### Pitfall 6: Entitlements File Not Linked to Target

**What goes wrong:** CloudKit sync never activates even though the entitlements file exists. The app runs without iCloud capabilities.
**Why it happens:** The `.entitlements` file must be referenced in the Xcode target's build settings under `CODE_SIGN_ENTITLEMENTS`. In a manually authored `.xcodeproj`, this key is easy to omit.
**Warning signs:** No CloudKit container activity in the CloudKit dashboard; no push notifications received from CloudKit.

---

## Code Examples

Verified patterns from Apple documentation and authoritative sources:

### Amount Font (Per Spec)

```swift
// Source: spec decision + Apple system font API
Text(expense.amount.formattedEUR)
    .font(.system(.title2, design: .rounded).weight(.semibold))
    .monospacedDigit()
```

### Category Icon View

```swift
// Source: spec decision (36pt square, 8pt radius, 18pt symbol)
struct CategoryIconView: View {
    let category: ExpenseCategory

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(category.color.opacity(0.2))
                .frame(width: 36, height: 36)
            Image(systemName: category.symbol)
                .font(.body)
                .foregroundStyle(category.color)
        }
    }
}
```

### AccentColor Asset Configuration

The AccentColor color set in `Assets.xcassets/AccentColor.colorset/Contents.json`:

```json
{
  "colors": [
    {
      "color": {
        "color-space": "srgb",
        "components": { "alpha": "1.000", "blue": "0.145", "green": "0.259", "red": "0.000" }
      },
      "idiom": "universal"
    }
  ],
  "info": { "author": "xcode", "version": 1 }
}
```

(#004225 = R:0, G:66/255≈0.259, B:37/255≈0.145 in linear sRGB)

### Entitlements File (BudgetApp.entitlements)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.developer.icloud-container-identifiers</key>
    <array>
        <string>iCloud.com.placeholder.BudgetApp</string>
    </array>
    <key>com.apple.developer.icloud-services</key>
    <array>
        <string>CloudKit</string>
    </array>
    <key>com.apple.developer.ubiquity-kvstore-identifier</key>
    <string>$(TeamIdentifierPrefix)com.placeholder.BudgetApp</string>
    <key>UIBackgroundModes</key>
    <array>
        <string>remote-notification</string>
    </array>
</dict>
</plist>
```

Note: `UIBackgroundModes` is usually in Info.plist, not entitlements. The entitlements file handles the CloudKit identifiers; Background Modes is a separate Xcode capability that writes to Info.plist.

---

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| ObservableObject + @Published | @Observable macro | iOS 17 (WWDC 2023) | Simpler syntax; @State instead of @StateObject; automatic granular observation |
| @StateObject for view models | @State with @Observable class | iOS 17 | @StateObject still works but @Observable is preferred |
| Core Data + NSPersistentCloudKitContainer | SwiftData + ModelContainer(cloudKitContainerIdentifier:) | iOS 17 | Far less boilerplate; same CloudKit private database sync |
| .colorScheme environment value | .preferredColorScheme modifier | iOS 13+ | Modifier approach forces all child views including system chrome |

**Deprecated/outdated:**
- NSPersistentCloudKitContainer: Still works but not needed for new SwiftData projects on iOS 17+.
- @ObservedObject / @StateObject: Valid but superseded by @Observable for non-SwiftData state.

---

## Open Questions

1. **de_DE euro sign prefix vs. suffix**
   - What we know: German locale standard places euro sign after the number; spec mandates prefix ("€45,80").
   - What's unclear: Whether setting `currencySymbol = "€"` alone moves it to prefix or requires explicit format string.
   - Recommendation: The implementation plan should include a unit test that asserts `45.8.formattedEUR == "€45,80"` and fix the formatter if output differs. If positional override is needed, use `positiveFormat = "€#,##0.00"` and `negativeFormat = "-€#,##0.00"`.

2. **Manually authored .xcodeproj correctness**
   - What we know: A `.xcodeproj` is a directory containing `project.pbxproj`, a complex GUID-based text format.
   - What's unclear: Whether the planner/implementor will author the pbxproj directly (fragile) or use a simpler approach.
   - Recommendation: The implementation plan should generate minimal valid `project.pbxproj` content. A known-good template for a single-target iOS app with SwiftData and CloudKit capabilities should be the basis, with GUIDs regenerated. Alternatively, the plan can describe the Xcode project creation steps as manual user actions with the Swift files as the primary artifact.

3. **CloudKit schema initialization**
   - What we know: `initializeCloudKitSchema()` can be called in debug builds to push the SwiftData schema to CloudKit's development environment before first use.
   - What's unclear: Whether this is needed for Phase 1 or deferred to first real device test.
   - Recommendation: Include a commented-out `try? container.initializeCloudKitSchema()` call in the debug build section of the app entry point. Users will run this once against a development CloudKit environment.

---

## Validation Architecture

### Test Framework

| Property | Value |
|----------|-------|
| Framework | XCTest (built into Xcode, no install needed) |
| Config file | Xcode test target (added to .xcodeproj) |
| Quick run command | `xcodebuild test -scheme BudgetApp -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' -only-testing BudgetAppTests` |
| Full suite command | `xcodebuild test -scheme BudgetApp -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest'` |

Note: Phase 1 produces the first buildable app. Tests are integration-level (compile + run). Unit tests for formatters and model logic are the highest-value automated tests for this phase. UI tests are not required for Phase 1.

### Phase Requirements to Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| DATA-01 | Expense can be inserted and fetched with correct monthYear | Unit | `xcodebuild test ... -only-testing BudgetAppTests/ExpenseModelTests` | Wave 0 |
| DATA-02 | MonthlyBudget fetch-or-create returns same record on second call | Unit | `xcodebuild test ... -only-testing BudgetAppTests/MonthlyBudgetTests` | Wave 0 |
| DATA-03 | All 8 ExpenseCategory cases have non-empty symbol and non-nil color | Unit | `xcodebuild test ... -only-testing BudgetAppTests/ExpenseCategoryTests` | Wave 0 |
| DATA-04 | ModelContainer init does not throw with CloudKit identifier | Integration | `xcodebuild test ... -only-testing BudgetAppTests/ContainerTests` | Wave 0 |
| DATA-05 | 45.8.formattedEUR == "€45,80" | Unit | `xcodebuild test ... -only-testing BudgetAppTests/FormatterTests` | Wave 0 |
| DATA-06 | modelContext.save() called after insert (manual code review) | Manual | — | N/A |
| APP-01 | App compiles and shows 4-tab shell | Smoke | `xcodebuild build -scheme BudgetApp` | Wave 0 |
| APP-02 | FAB visible on tab 0 and 1, hidden on tab 2 and 3 | Manual/UI | — | N/A |
| APP-03 | xcodebuild build exits 0 | Smoke | `xcodebuild build -scheme BudgetApp -destination 'platform=iOS Simulator,...'` | Wave 0 |
| APP-04 | App icon asset exists and is 1024x1024 | Manual | — | N/A |
| UX-01 | App appears dark in simulator | Manual | — | N/A |
| UX-02 | AccentColor asset exists with correct hex | Manual | — | N/A |
| UX-03 | .cardStyle() compiles and applies to a test view | Unit | `xcodebuild test ... -only-testing BudgetAppTests/DesignSystemTests` | Wave 0 |
| UX-04 | DesignTokens constants match spec values | Unit | `xcodebuild test ... -only-testing BudgetAppTests/DesignSystemTests` | Wave 0 |
| UX-05 | Amount font modifier compiles (compile-time verification) | Smoke | `xcodebuild build ...` | Wave 0 |
| UX-06 | HapticManager.impact/success/warning/selection do not crash | Unit | `xcodebuild test ... -only-testing BudgetAppTests/HapticManagerTests` | Wave 0 |

### Sampling Rate

- **Per task commit:** `xcodebuild build -scheme BudgetApp -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest'`
- **Per wave merge:** Full test suite: `xcodebuild test -scheme BudgetApp -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest'`
- **Phase gate:** Full suite green + simulator runs showing 4-tab shell before `/gsd:verify-work`

### Wave 0 Gaps

- [ ] `BudgetAppTests/ExpenseModelTests.swift` — covers DATA-01: Expense insert, fetch, monthYear stored correctly
- [ ] `BudgetAppTests/MonthlyBudgetTests.swift` — covers DATA-02: fetch-or-create idempotency
- [ ] `BudgetAppTests/ExpenseCategoryTests.swift` — covers DATA-03: all 8 categories have valid symbol + color
- [ ] `BudgetAppTests/ContainerTests.swift` — covers DATA-04: ModelContainer init with CloudKit identifier (uses in-memory config in tests)
- [ ] `BudgetAppTests/FormatterTests.swift` — covers DATA-05: EUR German locale formatting
- [ ] `BudgetAppTests/DesignSystemTests.swift` — covers UX-03, UX-04: cardStyle compiles, token values match spec
- [ ] `BudgetAppTests/HapticManagerTests.swift` — covers UX-06: all four haptic calls execute without crash
- [ ] Test target added to Xcode project (`BudgetAppTests` target in project.pbxproj)

---

## Sources

### Primary (HIGH confidence)

- Apple Developer Documentation: `ModelConfiguration.cloudKitContainerIdentifier` — https://developer.apple.com/documentation/swiftdata/modelconfiguration/cloudkitcontaineridentifier
- Apple Developer Documentation: `ModelContainer` — https://developer.apple.com/documentation/swiftdata/modelcontainer
- Apple Developer Documentation: `ViewModifier` — https://developer.apple.com/documentation/swiftui/viewmodifier
- Apple Developer Documentation: `UIImpactFeedbackGenerator` — https://developer.apple.com/documentation/uikit/uiimpactfeedbackgenerator
- Apple Developer Documentation: `NumberFormatter.Style.currency` — https://developer.apple.com/documentation/foundation/numberformatter/style/currency

### Secondary (MEDIUM confidence)

- Hacking with Swift — How to sync SwiftData with iCloud: https://www.hackingwithswift.com/quick-start/swiftdata/how-to-sync-swiftdata-with-icloud
- Hacking with Swift — How to use SwiftData in SwiftUI previews: https://www.hackingwithswift.com/quick-start/swiftdata/how-to-use-swiftdata-in-swiftui-previews
- Fatbobman — Designing Models for CloudKit Sync: https://fatbobman.com/en/snippet/rules-for-adapting-data-models-to-cloudkit/
- Fatbobman — initializeCloudKitSchema: https://fatbobman.com/en/snippet/resolving-incomplete-icloud-data-sync-in-ios-development-using-initializecloudkitschema/
- Hacking with Swift forums — Best way to handle unique values with SwiftData and CloudKit: https://www.hackingwithswift.com/forums/swiftui/best-way-to-handle-unique-values-with-swiftdata-and-cloudkit/30145
- Alex Logan — SwiftData, meet iCloud: https://alexanderlogan.co.uk/blog/wwdc23/08-cloudkit-swift-data
- Sarunw — Floating Action Button in SwiftUI: https://sarunw.com/posts/floating-action-button-in-swiftui/
- Sarunw — Set SwiftUI app theme with AccentColor: https://sarunw.com/posts/swiftui-accentcolor/

### Tertiary (LOW confidence)

- Hacking with Swift — Syncing SwiftData with CloudKit (book chapter): https://www.hackingwithswift.com/books/ios-swiftui/syncing-swiftdata-with-cloudkit

---

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — all frameworks are iOS 17 built-ins; no version uncertainty
- Architecture: HIGH — SwiftData patterns verified against official docs and authoritative tutorials
- CloudKit constraints: HIGH — @Attribute(.unique) incompatibility is well-documented and consistent across sources
- Pitfalls: HIGH for DATA pitfalls (confirmed across multiple sources); MEDIUM for de_DE euro sign position (requires runtime verification)
- Code examples: MEDIUM — patterns are correct but full .xcodeproj pbxproj authoring not demonstrated (known-complex)

**Research date:** 2026-03-04
**Valid until:** 2026-09-04 (stable iOS 17 APIs; re-check if iOS 18 SwiftData changes emerge)
