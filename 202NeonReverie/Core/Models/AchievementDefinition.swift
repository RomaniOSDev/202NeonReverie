import Foundation

struct AchievementDefinition: Identifiable {
    let id: String
    let title: String
    let description: String
    let systemImage: String

    init(id: String, title: String, description: String, systemImage: String) {
        self.id = id
        self.title = title
        self.description = description
        self.systemImage = systemImage
    }

    static let all: [AchievementDefinition] = [
        AchievementDefinition(
            id: "first_task",
            title: "First Task",
            description: "Completed the first task.",
            systemImage: "checkmark.circle"
        ),
        AchievementDefinition(
            id: "focus_starter",
            title: "Focus Starter",
            description: "Completed a focus session.",
            systemImage: "timer"
        ),
        AchievementDefinition(
            id: "habit_initiator",
            title: "Habit Initiator",
            description: "Checked in a habit for the first time.",
            systemImage: "list.bullet"
        ),
        AchievementDefinition(
            id: "daily_streak",
            title: "Daily Streak",
            description: "Achieved a 7-day completion streak of daily tasks.",
            systemImage: "flame"
        ),
        AchievementDefinition(
            id: "getting_going",
            title: "Getting Going",
            description: "Reached 10 items.",
            systemImage: "star"
        ),
        AchievementDefinition(
            id: "power_user",
            title: "Power User",
            description: "Reached 50 items.",
            systemImage: "bolt"
        ),
        AchievementDefinition(
            id: "three_day_streak",
            title: "Three-Day Streak",
            description: "Used the app 3 days in a row.",
            systemImage: "calendar"
        ),
        AchievementDefinition(
            id: "week_long_habit",
            title: "Week-Long Habit",
            description: "Used the app 7 days in a row.",
            systemImage: "calendar.badge.clock"
        )
    ]

    func isUnlocked(in store: AppDataStore) -> Bool {
        switch id {
        case "first_task":
            return store.tasksCompleted >= 1
        case "focus_starter":
            return store.focusSessionsCompleted >= 1
        case "habit_initiator":
            return store.habitCheckIns >= 1
        case "daily_streak":
            return store.longestTaskStreak >= 7
        case "getting_going":
            return store.tasksCompleted >= 10
        case "power_user":
            return store.tasksCompleted >= 50
        case "three_day_streak":
            return store.longestAppStreak >= 3
        case "week_long_habit":
            return store.longestAppStreak >= 7
        default:
            return false
        }
    }
}
