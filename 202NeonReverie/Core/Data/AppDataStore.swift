import Combine
import Foundation
import UIKit

@MainActor
final class AppDataStore: ObservableObject {
    private enum Keys {
        static let hasSeenOnboarding = "hasSeenOnboarding"
        static let totalSessionsCompleted = "totalSessionsCompleted"
        static let totalMinutesUsed = "totalMinutesUsed"
        static let streakDays = "streakDays"
        static let longestAppStreak = "longestAppStreak"
        static let longestTaskStreak = "longestTaskStreak"
        static let currentTaskStreak = "currentTaskStreak"
        static let lastActivityDate = "lastActivityDate"
        static let achievementsUnlocked = "achievementsUnlocked"
        static let tasks = "tasks"
        static let filterStatus = "filterStatus"
        static let focusSessionCount = "focusSessionCount"
        static let workDurationSec = "workDurationSec"
        static let breakDurationSec = "breakDurationSec"
        static let focusHistory = "focusHistory"
        static let habits = "habits"
        static let lastCheckInDate = "lastCheckInDate"
        static let tasksCompleted = "tasksCompleted"
        static let habitCheckIns = "habitCheckIns"
        static let taskSortOrder = "taskSortOrder"
        static let dailyNotes = "dailyNotes"
        static let progressGoals = "progressGoals"
        static let customAchievements = "customAchievements"
        static let taskSearchQuery = "taskSearchQuery"
        static let taskCategoryFilter = "taskCategoryFilter"
        static let showOverdueOnly = "showOverdueOnly"
        static let autoWorkBreakTransition = "autoWorkBreakTransition"
        static let autoStartBreakSession = "autoStartBreakSession"
        static let linkedFocusTaskId = "linkedFocusTaskId"
        static let habitGroupFilter = "habitGroupFilter"
        static let customAchievementsUnlocked = "customAchievementsUnlocked"
    }

    private let defaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private var cancellables = Set<AnyCancellable>()

    @Published var hasSeenOnboarding: Bool {
        didSet { defaults.set(hasSeenOnboarding, forKey: Keys.hasSeenOnboarding) }
    }

    @Published var totalSessionsCompleted: Int {
        didSet { defaults.set(totalSessionsCompleted, forKey: Keys.totalSessionsCompleted) }
    }

    @Published var totalMinutesUsed: Int {
        didSet { defaults.set(totalMinutesUsed, forKey: Keys.totalMinutesUsed) }
    }

    @Published var streakDays: Int {
        didSet { defaults.set(streakDays, forKey: Keys.streakDays) }
    }

    @Published var longestAppStreak: Int {
        didSet { defaults.set(longestAppStreak, forKey: Keys.longestAppStreak) }
    }

    @Published var longestTaskStreak: Int {
        didSet { defaults.set(longestTaskStreak, forKey: Keys.longestTaskStreak) }
    }

    @Published var currentTaskStreak: Int {
        didSet { defaults.set(currentTaskStreak, forKey: Keys.currentTaskStreak) }
    }

    @Published var lastActivityDate: Date? {
        didSet {
            if let date = lastActivityDate {
                defaults.set(date, forKey: Keys.lastActivityDate)
            } else {
                defaults.removeObject(forKey: Keys.lastActivityDate)
            }
        }
    }

    @Published var achievementsUnlocked: [String: Date] {
        didSet { saveAchievements() }
    }

    @Published var customAchievementsUnlocked: [String: Date] {
        didSet { saveCustomAchievementsUnlocked() }
    }

    @Published var tasks: [TaskItem] {
        didSet { saveTasks() }
    }

    @Published var filterStatus: String {
        didSet { defaults.set(filterStatus, forKey: Keys.filterStatus) }
    }

    @Published var focusSessionsCompleted: Int {
        didSet { defaults.set(focusSessionsCompleted, forKey: Keys.focusSessionCount) }
    }

    @Published var workDurationSec: Int {
        didSet { defaults.set(workDurationSec, forKey: Keys.workDurationSec) }
    }

    @Published var breakDurationSec: Int {
        didSet { defaults.set(breakDurationSec, forKey: Keys.breakDurationSec) }
    }

    @Published var focusHistory: [FocusSessionRecord] {
        didSet { saveFocusHistory() }
    }

    @Published var habits: [HabitItem] {
        didSet { saveHabits() }
    }

    @Published var lastCheckInDate: Date? {
        didSet {
            if let date = lastCheckInDate {
                defaults.set(date, forKey: Keys.lastCheckInDate)
            } else {
                defaults.removeObject(forKey: Keys.lastCheckInDate)
            }
        }
    }

    @Published var tasksCompleted: Int {
        didSet { defaults.set(tasksCompleted, forKey: Keys.tasksCompleted) }
    }

    @Published var habitCheckIns: Int {
        didSet { defaults.set(habitCheckIns, forKey: Keys.habitCheckIns) }
    }

    @Published var taskSortOrder: String {
        didSet { defaults.set(taskSortOrder, forKey: Keys.taskSortOrder) }
    }

    @Published var dailyNotes: [DailyNoteItem] {
        didSet { saveDailyNotes() }
    }

    @Published var progressGoals: [ProgressGoal] {
        didSet { saveProgressGoals() }
    }

    @Published var customAchievements: [CustomAchievement] {
        didSet { saveCustomAchievements() }
    }

    @Published var taskSearchQuery: String {
        didSet { defaults.set(taskSearchQuery, forKey: Keys.taskSearchQuery) }
    }

    @Published var taskCategoryFilter: String {
        didSet { defaults.set(taskCategoryFilter, forKey: Keys.taskCategoryFilter) }
    }

    @Published var showOverdueOnly: Bool {
        didSet { defaults.set(showOverdueOnly, forKey: Keys.showOverdueOnly) }
    }

    @Published var autoWorkBreakTransition: Bool {
        didSet { defaults.set(autoWorkBreakTransition, forKey: Keys.autoWorkBreakTransition) }
    }

    @Published var autoStartBreakSession: Bool {
        didSet { defaults.set(autoStartBreakSession, forKey: Keys.autoStartBreakSession) }
    }

    @Published var linkedFocusTaskId: UUID? {
        didSet {
            if let id = linkedFocusTaskId {
                defaults.set(id.uuidString, forKey: Keys.linkedFocusTaskId)
            } else {
                defaults.removeObject(forKey: Keys.linkedFocusTaskId)
            }
        }
    }

    @Published var habitGroupFilter: String {
        didSet { defaults.set(habitGroupFilter, forKey: Keys.habitGroupFilter) }
    }

    @Published var pendingAchievementBanners: [AchievementDefinition] = []

    init() {
        hasSeenOnboarding = defaults.bool(forKey: Keys.hasSeenOnboarding)
        totalSessionsCompleted = defaults.integer(forKey: Keys.totalSessionsCompleted)
        totalMinutesUsed = defaults.integer(forKey: Keys.totalMinutesUsed)
        streakDays = defaults.integer(forKey: Keys.streakDays)
        longestAppStreak = defaults.integer(forKey: Keys.longestAppStreak)
        longestTaskStreak = defaults.integer(forKey: Keys.longestTaskStreak)
        currentTaskStreak = defaults.integer(forKey: Keys.currentTaskStreak)
        lastActivityDate = defaults.object(forKey: Keys.lastActivityDate) as? Date
        achievementsUnlocked = Self.loadDictionary(key: Keys.achievementsUnlocked, decoder: decoder) ?? [:]
        customAchievementsUnlocked = Self.loadDictionary(key: Keys.customAchievementsUnlocked, decoder: decoder) ?? [:]
        tasks = Self.loadArray(key: Keys.tasks, decoder: decoder) ?? []
        filterStatus = defaults.string(forKey: Keys.filterStatus) ?? "All"
        focusSessionsCompleted = defaults.integer(forKey: Keys.focusSessionCount)
        workDurationSec = defaults.object(forKey: Keys.workDurationSec) as? Int ?? 1500
        breakDurationSec = defaults.object(forKey: Keys.breakDurationSec) as? Int ?? 300
        focusHistory = Self.loadArray(key: Keys.focusHistory, decoder: decoder) ?? []
        habits = Self.loadArray(key: Keys.habits, decoder: decoder) ?? []
        lastCheckInDate = defaults.object(forKey: Keys.lastCheckInDate) as? Date
        tasksCompleted = defaults.integer(forKey: Keys.tasksCompleted)
        habitCheckIns = defaults.integer(forKey: Keys.habitCheckIns)
        taskSortOrder = defaults.string(forKey: Keys.taskSortOrder) ?? "Due Date"
        dailyNotes = Self.loadArray(key: Keys.dailyNotes, decoder: decoder) ?? []
        progressGoals = Self.loadArray(key: Keys.progressGoals, decoder: decoder) ?? []
        customAchievements = Self.loadArray(key: Keys.customAchievements, decoder: decoder) ?? []
        taskSearchQuery = defaults.string(forKey: Keys.taskSearchQuery) ?? ""
        taskCategoryFilter = defaults.string(forKey: Keys.taskCategoryFilter) ?? "All"
        showOverdueOnly = defaults.bool(forKey: Keys.showOverdueOnly)
        autoWorkBreakTransition = defaults.object(forKey: Keys.autoWorkBreakTransition) as? Bool ?? true
        autoStartBreakSession = defaults.object(forKey: Keys.autoStartBreakSession) as? Bool ?? false
        if let taskIdString = defaults.string(forKey: Keys.linkedFocusTaskId) {
            linkedFocusTaskId = UUID(uuidString: taskIdString)
        } else {
            linkedFocusTaskId = nil
        }
        habitGroupFilter = defaults.string(forKey: Keys.habitGroupFilter) ?? "All"

        NotificationCenter.default.publisher(for: .dataReset)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.reloadFromDefaults()
            }
            .store(in: &cancellables)
    }

    var totalEntriesCreated: Int {
        tasks.count + habits.count + focusHistory.count + dailyNotes.count
    }

    var linkedFocusTask: TaskItem? {
        guard let id = linkedFocusTaskId else { return nil }
        return tasks.first { $0.id == id && !$0.completed }
    }

    var habitsPendingTodayCount: Int {
        let todayKey = HabitItem.dateKey(for: Date())
        return habits.filter { habit in
            habit.frequency == .daily && !habit.completedDates.contains(todayKey)
        }.count
    }

    var todayDailyNotes: [DailyNoteItem] {
        let key = HabitItem.dateKey(for: Date())
        return dailyNotes.filter { $0.dateKey == key }
    }

    func recordMeaningfulActivity() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        if let last = lastActivityDate {
            let lastDay = calendar.startOfDay(for: last)
            let dayDiff = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0
            if dayDiff == 1 {
                streakDays += 1
            } else if dayDiff > 1 {
                streakDays = 1
            }
        } else {
            streakDays = 1
        }

        lastActivityDate = Date()
        if streakDays > longestAppStreak {
            longestAppStreak = streakDays
        }
        evaluateAchievements()
    }

    // MARK: - Onboarding

    func completeOnboarding() {
        hasSeenOnboarding = true
        FeedbackManager.mediumImpact()
        FeedbackManager.playSuccessSound()
    }

    // MARK: - Daily notes

    func addDailyNote(text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let key = HabitItem.dateKey(for: Date())
        let todayNotes = dailyNotes.filter { $0.dateKey == key }
        guard todayNotes.count < 5 else { return }
        dailyNotes.append(DailyNoteItem(text: trimmed, dateKey: key))
        recordMeaningfulActivity()
        FeedbackManager.mediumImpact()
        FeedbackManager.playSuccessSound()
    }

    func toggleDailyNote(id: UUID) {
        guard let index = dailyNotes.firstIndex(where: { $0.id == id }) else { return }
        dailyNotes[index].isCompleted.toggle()
        if dailyNotes[index].isCompleted {
            FeedbackManager.successNotification()
            FeedbackManager.playSuccessSound()
            incrementGoalsOnCheckIn()
        } else {
            FeedbackManager.lightTap()
        }
    }

    func deleteDailyNote(id: UUID) {
        dailyNotes.removeAll { $0.id == id }
        FeedbackManager.lightTap()
    }

    // MARK: - Tasks

    func addTaskFromTemplate(_ template: TaskTemplate) {
        let due = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
        let task = TaskItem(
            title: template.title,
            dueDate: due,
            category: template.category,
            priority: template.priority
        )
        addTask(task)
    }

    func addTask(_ task: TaskItem) {
        tasks.append(task)
        recordMeaningfulActivity()
        FeedbackManager.mediumImpact()
        FeedbackManager.playSuccessSound()
        evaluateAchievements()
    }

    func updateTask(_ task: TaskItem) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[index] = task
        saveTasks()
    }

    func deleteTask(id: UUID) {
        tasks.removeAll { $0.id == id }
        if linkedFocusTaskId == id {
            linkedFocusTaskId = nil
        }
        FeedbackManager.lightTap()
    }

    func toggleTaskCompletion(id: UUID) {
        guard let index = tasks.firstIndex(where: { $0.id == id }) else { return }
        let wasCompleted = tasks[index].completed
        tasks[index].completed.toggle()

        if tasks[index].completed && !wasCompleted {
            tasksCompleted += 1
            updateTaskStreakOnCompletion()
            handleRecurringTask(at: index)
            recordMeaningfulActivity()
            incrementGoalsOnTaskComplete()
            FeedbackManager.successNotification()
            FeedbackManager.playTaskCompleteVibrate()
            FeedbackManager.playTickSound()
        } else if !tasks[index].completed && wasCompleted {
            tasksCompleted = max(0, tasksCompleted - 1)
        }
        evaluateAchievements()
    }

    private func handleRecurringTask(at index: Int) {
        var task = tasks[index]
        guard task.recurrence != .none else { return }
        let calendar = Calendar.current
        task.completed = false
        switch task.recurrence {
        case .weekly:
            task.dueDate = calendar.date(byAdding: .day, value: 7, to: task.dueDate) ?? task.dueDate
        case .monthly:
            task.dueDate = calendar.date(byAdding: .month, value: 1, to: task.dueDate) ?? task.dueDate
        case .none:
            break
        }
        task.nextDueDate = task.dueDate
        tasks[index] = task
    }

    private func updateTaskStreakOnCompletion() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let key = "lastTaskCompletionDay"
        if let last = defaults.object(forKey: key) as? Date {
            let lastDay = calendar.startOfDay(for: last)
            let diff = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0
            if diff == 0 {
                return
            } else if diff == 1 {
                currentTaskStreak += 1
            } else {
                currentTaskStreak = 1
            }
        } else {
            currentTaskStreak = 1
        }
        defaults.set(Date(), forKey: key)
        if currentTaskStreak > longestTaskStreak {
            longestTaskStreak = currentTaskStreak
        }
    }

    func applyFocusPreset(_ preset: FocusPreset) {
        workDurationSec = preset.workMinutes * 60
        breakDurationSec = preset.breakMinutes * 60
        FeedbackManager.lightTap()
    }

    func completeFocusSession(type: FocusSessionType, durationSeconds: Int) {
        let task = linkedFocusTask
        let record = FocusSessionRecord(
            type: type,
            durationSeconds: durationSeconds,
            linkedTaskId: task?.id,
            linkedTaskTitle: task?.title
        )
        focusHistory.insert(record, at: 0)
        focusSessionsCompleted += 1
        totalSessionsCompleted += 1
        totalMinutesUsed += max(1, durationSeconds / 60)
        recordMeaningfulActivity()
        FeedbackManager.mediumImpact()
        FeedbackManager.playFocusCompleteSound()
        evaluateAchievements()
    }

    // MARK: - Habits

    func addHabit(_ habit: HabitItem) {
        habits.append(habit)
        recordMeaningfulActivity()
        FeedbackManager.mediumImpact()
        FeedbackManager.playSuccessSound()
        evaluateAchievements()
    }

    func updateHabit(_ habit: HabitItem) {
        guard let index = habits.firstIndex(where: { $0.id == habit.id }) else { return }
        habits[index] = habit
        saveHabits()
    }

    func deleteHabit(id: UUID) {
        habits.removeAll { $0.id == id }
        FeedbackManager.lightTap()
    }

    func toggleHabitCheckIn(id: UUID) {
        guard let index = habits.firstIndex(where: { $0.id == id }) else { return }
        let todayKey = HabitItem.dateKey(for: Date())
        var habit = habits[index]

        if habit.completedDates.contains(todayKey) {
            habit.completedDates.removeAll { $0 == todayKey }
            habit.streak = max(0, habit.streak - 1)
        } else {
            habit.completedDates.append(todayKey)
            habit.streak += 1
            habitCheckIns += 1
            lastCheckInDate = Date()
            recordMeaningfulActivity()
            incrementGoalsOnCheckIn()
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            FeedbackManager.playFocusCompleteSound()
        }
        habits[index] = habit
        evaluateAchievements()
    }

    // MARK: - Goals

    func addProgressGoal(_ goal: ProgressGoal) {
        progressGoals.append(goal)
        FeedbackManager.mediumImpact()
        FeedbackManager.playSuccessSound()
    }

    func updateProgressGoal(_ goal: ProgressGoal) {
        guard let index = progressGoals.firstIndex(where: { $0.id == goal.id }) else { return }
        progressGoals[index] = goal
        saveProgressGoals()
    }

    func deleteProgressGoal(id: UUID) {
        progressGoals.removeAll { $0.id == id }
        FeedbackManager.lightTap()
    }

    func incrementGoal(id: UUID) {
        guard let index = progressGoals.firstIndex(where: { $0.id == id }) else { return }
        guard progressGoals[index].currentSteps < progressGoals[index].targetSteps else { return }
        progressGoals[index].currentSteps += 1
        FeedbackManager.successNotification()
        FeedbackManager.playSuccessSound()
        evaluateAchievements()
    }

    private func incrementGoalsOnTaskComplete() {
        for index in progressGoals.indices {
            if progressGoals[index].currentSteps < progressGoals[index].targetSteps {
                progressGoals[index].currentSteps += 1
            }
        }
    }

    private func incrementGoalsOnCheckIn() {
        for index in progressGoals.indices where progressGoals[index].currentSteps < progressGoals[index].targetSteps {
            progressGoals[index].currentSteps += 1
        }
    }

    // MARK: - Custom achievements

    func addCustomAchievement(_ achievement: CustomAchievement) {
        customAchievements.append(achievement)
        FeedbackManager.mediumImpact()
        FeedbackManager.playSuccessSound()
        evaluateAchievements()
    }

    func deleteCustomAchievement(id: UUID) {
        customAchievements.removeAll { $0.id == id }
        customAchievementsUnlocked.removeValue(forKey: id.uuidString)
        FeedbackManager.lightTap()
    }

    // MARK: - Week insights

    struct DayFocusMinutes: Identifiable {
        let id: String
        let date: Date
        let minutes: Int
    }

    var weekInterval: DateInterval {
        let calendar = Calendar.current
        let end = calendar.startOfDay(for: Date())
        let start = calendar.date(byAdding: .day, value: -6, to: end) ?? end
        return DateInterval(start: start, end: calendar.date(byAdding: .day, value: 1, to: end) ?? end)
    }

    var tasksCompletedThisWeek: Int {
        let interval = weekInterval
        return tasks.filter { $0.completed && interval.contains($0.dueDate) }.count
    }

    var focusMinutesThisWeek: Int {
        let interval = weekInterval
        return focusHistory
            .filter { interval.contains($0.completedAt) }
            .reduce(0) { $0 + max(1, $1.durationSeconds / 60) }
    }

    var habitCheckInsThisWeek: Int {
        let interval = weekInterval
        let keys = habitDateKeys(in: interval)
        return habits.reduce(0) { count, habit in
            count + habit.completedDates.filter { keys.contains($0) }.count
        }
    }

    var dailyNotesCompletedThisWeek: Int {
        let interval = weekInterval
        let keys = habitDateKeys(in: interval)
        return dailyNotes.filter { keys.contains($0.dateKey) && $0.isCompleted }.count
    }

    func focusMinutesByDay(lastDays: Int = 7) -> [DayFocusMinutes] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return (0..<lastDays).reversed().compactMap { offset -> DayFocusMinutes? in
            guard let day = calendar.date(byAdding: .day, value: -offset, to: today) else { return nil }
            let nextDay = calendar.date(byAdding: .day, value: 1, to: day) ?? day
            let minutes = focusHistory
                .filter { $0.completedAt >= day && $0.completedAt < nextDay }
                .reduce(0) { $0 + max(1, $1.durationSeconds / 60) }
            let key = HabitItem.dateKey(for: day)
            return DayFocusMinutes(id: key, date: day, minutes: minutes)
        }
    }

    private func habitDateKeys(in interval: DateInterval) -> Set<String> {
        var keys = Set<String>()
        var date = interval.start
        let calendar = Calendar.current
        while date < interval.end {
            keys.insert(HabitItem.dateKey(for: date))
            guard let next = calendar.date(byAdding: .day, value: 1, to: date) else { break }
            date = next
        }
        return keys
    }

    // MARK: - Achievements

    func evaluateAchievements() {
        var newlyUnlocked: [AchievementDefinition] = []
        for achievement in AchievementDefinition.all {
            guard achievement.isUnlocked(in: self) else { continue }
            if achievementsUnlocked[achievement.id] == nil {
                achievementsUnlocked[achievement.id] = Date()
                newlyUnlocked.append(achievement)
            }
        }
        for custom in customAchievements {
            let key = custom.id.uuidString
            guard custom.isUnlocked(in: self) else { continue }
            if customAchievementsUnlocked[key] == nil {
                customAchievementsUnlocked[key] = Date()
                newlyUnlocked.append(
                    AchievementDefinition(
                        id: key,
                        title: custom.title,
                        description: custom.description,
                        systemImage: "star.circle"
                    )
                )
            }
        }
        if !newlyUnlocked.isEmpty {
            FeedbackManager.successNotification()
            pendingAchievementBanners.append(contentsOf: newlyUnlocked)
        }
    }

    func dequeueAchievementBanner() -> AchievementDefinition? {
        guard !pendingAchievementBanners.isEmpty else { return nil }
        return pendingAchievementBanners.removeFirst()
    }

    func isCustomAchievementUnlocked(_ achievement: CustomAchievement) -> Bool {
        customAchievementsUnlocked[achievement.id.uuidString] != nil
    }

    // MARK: - Reset

    func resetAllData() {
        let allKeys: [String] = [
            Keys.hasSeenOnboarding, Keys.totalSessionsCompleted, Keys.totalMinutesUsed,
            Keys.streakDays, Keys.longestAppStreak, Keys.longestTaskStreak, Keys.currentTaskStreak,
            Keys.lastActivityDate, Keys.achievementsUnlocked, Keys.customAchievementsUnlocked,
            Keys.tasks, Keys.filterStatus, Keys.focusSessionCount, Keys.workDurationSec,
            Keys.breakDurationSec, Keys.focusHistory, Keys.habits, Keys.lastCheckInDate,
            Keys.tasksCompleted, Keys.habitCheckIns, Keys.taskSortOrder, Keys.dailyNotes,
            Keys.progressGoals, Keys.customAchievements, Keys.taskSearchQuery,
            Keys.taskCategoryFilter, Keys.showOverdueOnly, Keys.autoWorkBreakTransition,
            Keys.autoStartBreakSession, Keys.linkedFocusTaskId, Keys.habitGroupFilter,
            "lastTaskCompletionDay"
        ]
        allKeys.forEach { defaults.removeObject(forKey: $0) }
        if let bundleID = Bundle.main.bundleIdentifier {
            defaults.removePersistentDomain(forName: bundleID)
        }
        defaults.synchronize()
        reloadFromDefaults()
        NotificationCenter.default.post(name: .dataReset, object: nil)
    }

    private func reloadFromDefaults() {
        hasSeenOnboarding = defaults.bool(forKey: Keys.hasSeenOnboarding)
        totalSessionsCompleted = defaults.integer(forKey: Keys.totalSessionsCompleted)
        totalMinutesUsed = defaults.integer(forKey: Keys.totalMinutesUsed)
        streakDays = defaults.integer(forKey: Keys.streakDays)
        longestAppStreak = defaults.integer(forKey: Keys.longestAppStreak)
        longestTaskStreak = defaults.integer(forKey: Keys.longestTaskStreak)
        currentTaskStreak = defaults.integer(forKey: Keys.currentTaskStreak)
        lastActivityDate = defaults.object(forKey: Keys.lastActivityDate) as? Date
        achievementsUnlocked = Self.loadDictionary(key: Keys.achievementsUnlocked, decoder: decoder) ?? [:]
        customAchievementsUnlocked = Self.loadDictionary(key: Keys.customAchievementsUnlocked, decoder: decoder) ?? [:]
        tasks = Self.loadArray(key: Keys.tasks, decoder: decoder) ?? []
        filterStatus = defaults.string(forKey: Keys.filterStatus) ?? "All"
        focusSessionsCompleted = defaults.integer(forKey: Keys.focusSessionCount)
        workDurationSec = defaults.object(forKey: Keys.workDurationSec) as? Int ?? 1500
        breakDurationSec = defaults.object(forKey: Keys.breakDurationSec) as? Int ?? 300
        focusHistory = Self.loadArray(key: Keys.focusHistory, decoder: decoder) ?? []
        habits = Self.loadArray(key: Keys.habits, decoder: decoder) ?? []
        lastCheckInDate = defaults.object(forKey: Keys.lastCheckInDate) as? Date
        tasksCompleted = defaults.integer(forKey: Keys.tasksCompleted)
        habitCheckIns = defaults.integer(forKey: Keys.habitCheckIns)
        taskSortOrder = defaults.string(forKey: Keys.taskSortOrder) ?? "Due Date"
        dailyNotes = Self.loadArray(key: Keys.dailyNotes, decoder: decoder) ?? []
        progressGoals = Self.loadArray(key: Keys.progressGoals, decoder: decoder) ?? []
        customAchievements = Self.loadArray(key: Keys.customAchievements, decoder: decoder) ?? []
        taskSearchQuery = defaults.string(forKey: Keys.taskSearchQuery) ?? ""
        taskCategoryFilter = defaults.string(forKey: Keys.taskCategoryFilter) ?? "All"
        showOverdueOnly = defaults.bool(forKey: Keys.showOverdueOnly)
        autoWorkBreakTransition = defaults.object(forKey: Keys.autoWorkBreakTransition) as? Bool ?? true
        autoStartBreakSession = defaults.object(forKey: Keys.autoStartBreakSession) as? Bool ?? false
        if let taskIdString = defaults.string(forKey: Keys.linkedFocusTaskId) {
            linkedFocusTaskId = UUID(uuidString: taskIdString)
        } else {
            linkedFocusTaskId = nil
        }
        habitGroupFilter = defaults.string(forKey: Keys.habitGroupFilter) ?? "All"
        pendingAchievementBanners = []
    }

    private func saveTasks() {
        Self.save(tasks, key: Keys.tasks, encoder: encoder, defaults: defaults)
    }

    private func saveHabits() {
        Self.save(habits, key: Keys.habits, encoder: encoder, defaults: defaults)
    }

    private func saveFocusHistory() {
        Self.save(focusHistory, key: Keys.focusHistory, encoder: encoder, defaults: defaults)
    }

    private func saveDailyNotes() {
        Self.save(dailyNotes, key: Keys.dailyNotes, encoder: encoder, defaults: defaults)
    }

    private func saveProgressGoals() {
        Self.save(progressGoals, key: Keys.progressGoals, encoder: encoder, defaults: defaults)
    }

    private func saveCustomAchievements() {
        Self.save(customAchievements, key: Keys.customAchievements, encoder: encoder, defaults: defaults)
    }

    private func saveAchievements() {
        if let data = try? encoder.encode(achievementsUnlocked) {
            defaults.set(data, forKey: Keys.achievementsUnlocked)
        }
    }

    private func saveCustomAchievementsUnlocked() {
        if let data = try? encoder.encode(customAchievementsUnlocked) {
            defaults.set(data, forKey: Keys.customAchievementsUnlocked)
        }
    }

    private static func save<T: Encodable>(_ value: T, key: String, encoder: JSONEncoder, defaults: UserDefaults) {
        if let data = try? encoder.encode(value) {
            defaults.set(data, forKey: key)
        }
    }

    private static func loadArray<T: Decodable>(key: String, decoder: JSONDecoder) -> [T]? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? decoder.decode([T].self, from: data)
    }

    private static func loadDictionary(key: String, decoder: JSONDecoder) -> [String: Date]? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? decoder.decode([String: Date].self, from: data)
    }
}
