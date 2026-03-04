import SwiftUI
import SwiftData

@main
struct BudgetAppApp: App {
    let container: ModelContainer

    init() {
        do {
            let config = ModelConfiguration(
                cloudKitDatabase: .private("iCloud.com.placeholder.BudgetApp")
            )
            container = try ModelContainer(
                for: Expense.self, MonthlyBudget.self,
                configurations: config
            )
        } catch {
            // CloudKit unavailable (simulator without signed entitlements, or placeholder bundle ID).
            // Fall back to local-only storage so the app runs during development.
            do {
                let localConfig = ModelConfiguration(cloudKitDatabase: .none)
                container = try ModelContainer(
                    for: Expense.self, MonthlyBudget.self,
                    configurations: localConfig
                )
            } catch {
                fatalError("Failed to create ModelContainer: \(error)")
            }
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
