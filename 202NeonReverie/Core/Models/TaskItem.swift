import Foundation

enum TaskCategory: String, Codable, CaseIterable, Identifiable {
    case financialPlanning = "Financial Planning"
    case budgeting = "Budgeting"
    case investment = "Investment"

    var id: String { rawValue }
}

enum TaskPriority: String, Codable, CaseIterable, Identifiable {
    case high = "High"
    case medium = "Medium"
    case low = "Low"

    var id: String { rawValue }
}

struct TaskItem: Codable, Identifiable, Equatable {
    var id: UUID
    var title: String
    var dueDate: Date
    var category: TaskCategory
    var priority: TaskPriority
    var completed: Bool
    var recurrence: TaskRecurrence
    var nextDueDate: Date?

    init(
        id: UUID = UUID(),
        title: String,
        dueDate: Date,
        category: TaskCategory,
        priority: TaskPriority,
        completed: Bool = false,
        recurrence: TaskRecurrence = .none,
        nextDueDate: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.dueDate = dueDate
        self.category = category
        self.priority = priority
        self.completed = completed
        self.recurrence = recurrence
        self.nextDueDate = nextDueDate ?? dueDate
    }

    enum CodingKeys: String, CodingKey {
        case id, title, dueDate, category, priority, completed, recurrence, nextDueDate
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        dueDate = try container.decode(Date.self, forKey: .dueDate)
        category = try container.decode(TaskCategory.self, forKey: .category)
        priority = try container.decode(TaskPriority.self, forKey: .priority)
        completed = try container.decode(Bool.self, forKey: .completed)
        recurrence = try container.decodeIfPresent(TaskRecurrence.self, forKey: .recurrence) ?? .none
        nextDueDate = try container.decodeIfPresent(Date.self, forKey: .nextDueDate) ?? dueDate
    }

    var isOverdue: Bool {
        !completed && Calendar.current.startOfDay(for: dueDate) < Calendar.current.startOfDay(for: Date())
    }
}
