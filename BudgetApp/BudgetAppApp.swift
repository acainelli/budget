import SwiftUI
import SwiftData

@main
struct BudgetAppApp: App {
    let container: ModelContainer

    init() {
        // Use local-only storage during development.
        // Switch to CloudKit when you have a real bundle ID and provisioning profile:
        //   let config = ModelConfiguration(cloudKitDatabase: .private("iCloud.com.YOUR_BUNDLE_ID"))
        do {
            container = try ModelContainer(for: Expense.self, MonthlyBudget.self)
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
