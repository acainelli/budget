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
            // try? container.initializeCloudKitSchema()
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
