import Foundation

enum AchievementMetric: String, Codable, CaseIterable, Identifiable {
    case tasksCompleted = "Tasks Completed"
    case focusSessions = "Focus Sessions"
    case habitCheckIns = "Habit Check-ins"
    case streakDays = "App Streak Days"

    var id: String { rawValue }
}

struct CustomAchievement: Codable, Identifiable, Equatable {
    var id: UUID
    var title: String
    var description: String
    var metric: AchievementMetric
    var targetValue: Int

    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        metric: AchievementMetric,
        targetValue: Int
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.metric = metric
        self.targetValue = max(1, targetValue)
    }

    func currentValue(in store: AppDataStore) -> Int {
        switch metric {
        case .tasksCompleted: return store.tasksCompleted
        case .focusSessions: return store.focusSessionsCompleted
        case .habitCheckIns: return store.habitCheckIns
        case .streakDays: return store.streakDays
        }
    }

    func isUnlocked(in store: AppDataStore) -> Bool {
        currentValue(in: store) >= targetValue
    }
}
