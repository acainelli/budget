# Changelog

## 1.0.0 (2026-03-05)


### Features

* **01-01:** add SwiftData models, app entry point, and placeholder views ([c9d8644](https://github.com/acainelli/budget/commit/c9d8644e569e528c45f576e5077266f8f22c2b44))
* **01-01:** add XCTest stubs and design system utility implementations ([59cd5e2](https://github.com/acainelli/budget/commit/59cd5e2fd199a32cd5d8e41546ea784f4e9656b2))
* **01-01:** create Xcode project skeleton with test target ([0dc6d07](https://github.com/acainelli/budget/commit/0dc6d07815a8187606342deffd9d886ceca6aa9b))
* **01-02:** full ContentView TabView+FAB and NavigationStack placeholder views ([9fb6a15](https://github.com/acainelli/budget/commit/9fb6a159ffe200803a561829bc7f92d9cd7752a6))
* **01-02:** generate 1024x1024 app icon PNG via CoreGraphics/CoreText ([9558d21](https://github.com/acainelli/budget/commit/9558d2102090a908e99402061d47496a910f7aec))
* **01-02:** update CardStyle and CategoryIconView to use DesignTokens constants ([7afb56a](https://github.com/acainelli/budget/commit/7afb56a1d39d8834773a755d71127b70062cb23b))
* **02-01:** add CategoryPickerView subview ([1e974dd](https://github.com/acainelli/budget/commit/1e974dd1bf62688ed3f343a500f1bb375f459294))
* **02-01:** add NumpadView and AmountDisplayView subviews ([6b56fcf](https://github.com/acainelli/budget/commit/6b56fcfe2b78bf22860456a55252820fecce94e7))
* **02-01:** complete AddExpenseView with save logic and pbxproj registration ([655007c](https://github.com/acainelli/budget/commit/655007cc4b014940f08924d2aea227b082d3e33c))
* **02-02:** CategoryBreakdownCard (donut) and DailySpendingCard (bar chart) ([bc22af8](https://github.com/acainelli/budget/commit/bc22af8f633303d1ffdd9f4764a8dd1722569559))
* **02-02:** DashboardView container, SwiftData queries, and pbxproj registration ([00e8e74](https://github.com/acainelli/budget/commit/00e8e74850e047fd42027b934b5cf545a28ed5be))
* **02-02:** MonthPickerView, MonthlySummaryCard, and DashboardEmptyState ([65b7f2f](https://github.com/acainelli/budget/commit/65b7f2f885b98a1ff72d8fe4203a7bbe619775de))
* **03-01:** add ExpenseRowView and ExpenseDetailView ([a8db26e](https://github.com/acainelli/budget/commit/a8db26ec00da87c83db7d5be0e31bd13b79e311e))
* **03-01:** add ExpensesView grouped list, BulkDeleteSheet, pbxproj registration ([f0cfd91](https://github.com/acainelli/budget/commit/f0cfd91daef8159764626ff24bb610e30f9f6000))
* **03-02:** calendar heat-map, week view, day sheet, pbxproj registration ([dcd9cd8](https://github.com/acainelli/budget/commit/dcd9cd8fdedebc919e81cbf802da2a0138ca9f20))
* **03-02:** InsightsView container and charts views ([daf995d](https://github.com/acainelli/budget/commit/daf995d5defba5a08b671dfc21bd7965fafb78ff))
* **03-03:** add DataManagementView with export, import, and delete all ([d4a6ee4](https://github.com/acainelli/budget/commit/d4a6ee4e6b030eda2eff3e4746196da12f523ffe))
* **03-03:** implement SettingsView with monthly income input ([e9612ab](https://github.com/acainelli/budget/commit/e9612ab645d40b1909967e59ace3e2d5c63e8c10))
* replace hardcoded ExpenseCategory enum with custom BudgetCategory model ([174e7aa](https://github.com/acainelli/budget/commit/174e7aaa4138d93a2001cc47fbb4f4c1e1136058))


### Bug Fixes

* **03-04:** use .sheet(item:) to prevent blank day expenses sheet ([f6e5bfb](https://github.com/acainelli/budget/commit/f6e5bfb8731ab81bb7cc91ef2005dc219e24706d))
* **app:** fall back to local storage when CloudKit unavailable in simulator ([8145a32](https://github.com/acainelli/budget/commit/8145a32be745b4e678b9f54fbd4264dd03f78d15))
* **app:** match working app patterns — simple modelContainer, ZStack alignment, colorScheme placement ([bbc1c01](https://github.com/acainelli/budget/commit/bbc1c016a3818703fcdad68c9bf5e2c5a4cba49a))
* **app:** remove CloudKit entitlements for local-only development ([663a067](https://github.com/acainelli/budget/commit/663a067f01b23c41cdc5edec8d2ea7bec04ddc43))
* **app:** use local-only storage and modern Tab API ([8ba581a](https://github.com/acainelli/budget/commit/8ba581a09785b5f8a836772737be1697d6103d98))
* **app:** use plain ModelContainer as local fallback ([0f6ce83](https://github.com/acainelli/budget/commit/0f6ce831919daca1b7107ee0a35103197365cf5b))
* **models:** add default values to all properties for CloudKit compatibility ([5be45e6](https://github.com/acainelli/budget/commit/5be45e6df78cf31fd8ed6f04dedbd366a5f979d8))
* **ui:** restore full tab shell with NavigationStack and FAB overlay ([c975e5a](https://github.com/acainelli/budget/commit/c975e5a6897dff66a24841dc7a12e7c90d4f83d2))
* **ui:** revert to iOS 17 compatible TabView API ([d4d16e2](https://github.com/acainelli/budget/commit/d4d16e216f63ad514de062188dd522ad7724fa11))
* **ui:** use overlay instead of ZStack for FAB to fix TabView rendering ([dcd101b](https://github.com/acainelli/budget/commit/dcd101bea5f4238537793cc4fc867e4dc8fd0dfe))
