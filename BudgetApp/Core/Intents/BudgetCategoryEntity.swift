import AppIntents
import SwiftData
import Foundation

struct BudgetCategoryEntity: AppEntity {
    static var defaultQuery = BudgetCategoryQuery()
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Category")

    var id: UUID
    var name: String
    var symbol: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)", image: .init(systemName: symbol))
    }
}

struct BudgetCategoryQuery: EntityQuery {
    func entities(for identifiers: [UUID]) async throws -> [BudgetCategoryEntity] {
        let all = try await allCategories()
        return all.filter { identifiers.contains($0.id) }
    }

    func suggestedEntities() async throws -> [BudgetCategoryEntity] {
        try await allCategories()
    }

    private func allCategories() async throws -> [BudgetCategoryEntity] {
        let container = SharedModelContainer.shared
        let context = ModelContext(container)
        let descriptor = FetchDescriptor<BudgetCategory>(
            sortBy: [SortDescriptor(\.sortOrder)]
        )
        let categories = try context.fetch(descriptor)
        return categories.map {
            BudgetCategoryEntity(id: $0.id, name: $0.name, symbol: $0.symbol)
        }
    }
}
