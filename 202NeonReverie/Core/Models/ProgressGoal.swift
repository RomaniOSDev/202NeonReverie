import Foundation

struct ProgressGoal: Codable, Identifiable, Equatable {
    var id: UUID
    var title: String
    var targetSteps: Int
    var currentSteps: Int

    init(id: UUID = UUID(), title: String, targetSteps: Int, currentSteps: Int = 0) {
        self.id = id
        self.title = title
        self.targetSteps = max(1, targetSteps)
        self.currentSteps = currentSteps
    }

    var progress: Double {
        guard targetSteps > 0 else { return 0 }
        return min(1, Double(currentSteps) / Double(targetSteps))
    }
}
