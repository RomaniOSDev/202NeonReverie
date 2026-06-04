import Combine
import Foundation

@MainActor
final class TasksViewModel: ObservableObject {
    @Published var showingAddSheet = false
    @Published var showingTemplates = false
    @Published var editingTask: TaskItem?
    @Published var successPulseID: UUID?

    func filteredTasks(from store: AppDataStore) -> [TaskItem] {
        var list = store.tasks

        switch store.filterStatus {
        case "Active":
            list = list.filter { !$0.completed }
        case "Completed":
            list = list.filter { $0.completed }
        default:
            break
        }

        if store.showOverdueOnly {
            list = list.filter { $0.isOverdue }
        }

        if store.taskCategoryFilter != "All" {
            list = list.filter { $0.category.rawValue == store.taskCategoryFilter }
        }

        let query = store.taskSearchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        if !query.isEmpty {
            list = list.filter { $0.title.localizedCaseInsensitiveContains(query) }
        }

        switch store.taskSortOrder {
        case "Priority":
            list.sort { priorityRank($0.priority) < priorityRank($1.priority) }
        case "Title":
            list.sort { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        default:
            list.sort { $0.dueDate < $1.dueDate }
        }
        return list
    }

    private func priorityRank(_ priority: TaskPriority) -> Int {
        switch priority {
        case .high: return 0
        case .medium: return 1
        case .low: return 2
        }
    }
}
