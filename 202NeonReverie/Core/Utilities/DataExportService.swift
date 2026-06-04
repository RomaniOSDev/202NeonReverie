import Foundation

enum DataExportService {
    static func makeJSON(from store: AppDataStore) -> Data? {
        let payload = ExportPayload(
            tasks: store.tasks,
            habits: store.habits,
            focusHistory: store.focusHistory,
            dailyNotes: store.dailyNotes,
            progressGoals: store.progressGoals,
            customAchievements: store.customAchievements,
            stats: ExportStats(
                tasksCompleted: store.tasksCompleted,
                focusSessionsCompleted: store.focusSessionsCompleted,
                habitCheckIns: store.habitCheckIns,
                streakDays: store.streakDays,
                totalMinutesUsed: store.totalMinutesUsed
            )
        )
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return try? encoder.encode(payload)
    }

    static func makeCSV(from store: AppDataStore) -> String {
        var lines: [String] = []
        lines.append("Type,Title,Date,Category,Priority,Completed,Extra")
        for task in store.tasks {
            let date = ISO8601DateFormatter().string(from: task.dueDate)
            lines.append("Task,\(csvEscape(task.title)),\(date),\(task.category.rawValue),\(task.priority.rawValue),\(task.completed),\(task.recurrence.rawValue)")
        }
        for habit in store.habits {
            lines.append("Habit,\(csvEscape(habit.name)),,\(habit.group.rawValue),,,\(habit.streak)")
        }
        for session in store.focusHistory {
            let date = ISO8601DateFormatter().string(from: session.completedAt)
            let taskTitle = session.linkedTaskTitle ?? ""
            lines.append("Focus,\(session.type.rawValue),\(date),,,\(session.durationSeconds),\(csvEscape(taskTitle))")
        }
        for note in store.dailyNotes {
            lines.append("DailyNote,\(csvEscape(note.text)),\(note.dateKey),,,,\(note.isCompleted)")
        }
        return lines.joined(separator: "\n")
    }

    static func writeTemporaryFile(data: Data, filename: String) -> URL? {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        do {
            try data.write(to: url)
            return url
        } catch {
            return nil
        }
    }

    static func writeTemporaryCSV(_ csv: String, filename: String) -> URL? {
        writeTemporaryFile(data: Data(csv.utf8), filename: filename)
    }

    private static func csvEscape(_ value: String) -> String {
        let escaped = value.replacingOccurrences(of: "\"", with: "\"\"")
        if escaped.contains(",") || escaped.contains("\"") || escaped.contains("\n") {
            return "\"\(escaped)\""
        }
        return escaped
    }
}

private struct ExportPayload: Encodable {
    let tasks: [TaskItem]
    let habits: [HabitItem]
    let focusHistory: [FocusSessionRecord]
    let dailyNotes: [DailyNoteItem]
    let progressGoals: [ProgressGoal]
    let customAchievements: [CustomAchievement]
    let stats: ExportStats
}

private struct ExportStats: Encodable {
    let tasksCompleted: Int
    let focusSessionsCompleted: Int
    let habitCheckIns: Int
    let streakDays: Int
    let totalMinutesUsed: Int
}
