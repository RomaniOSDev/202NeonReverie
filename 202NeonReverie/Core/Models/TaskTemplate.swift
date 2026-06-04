import Foundation

struct TaskTemplate: Identifiable {
    let id: String
    let title: String
    let category: TaskCategory
    let priority: TaskPriority

    static let builtIn: [TaskTemplate] = [
        TaskTemplate(
            id: "monthly_budget",
            title: "Monthly Budget Review",
            category: .budgeting,
            priority: .high
        ),
        TaskTemplate(
            id: "taxes",
            title: "Tax Preparation",
            category: .financialPlanning,
            priority: .high
        ),
        TaskTemplate(
            id: "rebalance",
            title: "Portfolio Rebalance",
            category: .investment,
            priority: .medium
        )
    ]
}
