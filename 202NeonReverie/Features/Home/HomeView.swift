import Combine
import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: AppDataStore
    @Binding var selectedTab: MainTab
    @Binding var toolsSegment: Int

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        HomeHeroBanner(greeting: greetingText, subtitle: heroSubtitle)

                        statsGrid

                        quickActionsRow

                        focusWidget
                        habitsWidget

                        todayWidget
                        goalsWidget
                        weekWidget
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Greeting

    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        case 17..<22: return "Good Evening"
        default: return "Good Night"
        }
    }

    private var heroSubtitle: String {
        if store.streakDays > 0 {
            return "Day \(store.streakDays) of your productivity streak — keep going."
        }
        return "Your financial productivity dashboard for today."
    }

    // MARK: - Stats

    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
            HomeStatWidget(
                icon: "checkmark.circle.fill",
                value: "\(activeTasksCount)",
                label: "Active Tasks",
                tint: Color("AppPrimary")
            ) { goToTasks() }

            HomeStatWidget(
                icon: "flame.fill",
                value: "\(store.streakDays)",
                label: "Day Streak",
                tint: Color("AppAccent")
            ) { goToSettings() }

            HomeStatWidget(
                icon: "timer",
                value: "\(store.focusMinutesThisWeek)",
                label: "Focus Min (7d)",
                tint: Color("AppPrimary")
            ) { goToFocus() }

            HomeStatWidget(
                icon: "hand.thumbsup.fill",
                value: "\(store.habitsPendingTodayCount)",
                label: "Habits Due Today",
                tint: Color("AppAccent")
            ) { goToHabits() }
        }
    }

    private var activeTasksCount: Int {
        store.tasks.filter { !$0.completed }.count
    }

    // MARK: - Quick actions

    private var quickActionsRow: some View {
        AppCard(padding: 12) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Quick Actions")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color("AppTextPrimary"))
                HStack(spacing: 8) {
                    HomeQuickAction(icon: "plus.circle.fill", title: "Add Task") {
                        goToTasks()
                    }
                    HomeQuickAction(icon: "play.fill", title: "Focus") {
                        goToFocus()
                    }
                    HomeQuickAction(icon: "calendar", title: "Habits") {
                        goToHabits()
                    }
                    HomeQuickAction(icon: "chart.bar.fill", title: "Insights") {
                        goToInsights()
                    }
                }
            }
        }
    }

    // MARK: - Feature widgets

    private var focusWidget: some View {
        HomeFeatureWidget(
            imageName: "HomeFocusArt",
            icon: "timer",
            title: "Focus Timer",
            subtitle: lastFocusSubtitle,
            metric: "\(store.workDurationSec / 60)",
            metricLabel: "min work",
            actionTitle: "Start session →"
        ) { goToFocus() }
    }

    private var lastFocusSubtitle: String {
        if let last = store.focusHistory.first {
            return "Last: \(last.type.rawValue) · \(last.durationSeconds / 60) min"
        }
        return "Stay concentrated on financial work."
    }

    private var habitsWidget: some View {
        HomeFeatureWidget(
            imageName: "HomeHabitsArt",
            icon: "leaf.fill",
            title: "Daily Habits",
            subtitle: habitsSubtitle,
            metric: "\(habitsDoneToday)",
            metricLabel: "done today",
            actionTitle: "Check in →"
        ) { goToHabits() }
    }

    private var habitsSubtitle: String {
        let pending = store.habitsPendingTodayCount
        if pending > 0 {
            return "\(pending) habit\(pending == 1 ? "" : "s") waiting for today."
        }
        return "All daily habits completed. Great job!"
    }

    private var habitsDoneToday: Int {
        let key = HabitItem.dateKey(for: Date())
        return store.habits.filter { $0.completedDates.contains(key) }.count
    }

    // MARK: - Today checklist

    private var todayWidget: some View {
        HomeListWidget(
            icon: "sun.max.fill",
            title: "Today",
            subtitle: todayChecklistSubtitle,
            actionTitle: "Tasks"
        ) {
            goToTasks()
        } content: {
            if store.todayDailyNotes.isEmpty {
                Text("Add quick items for today in Tasks.")
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
            } else {
                ForEach(store.todayDailyNotes.prefix(3)) { note in
                    DailyNoteCell(
                        note: note,
                        onToggle: { store.toggleDailyNote(id: note.id) },
                        onDelete: { store.deleteDailyNote(id: note.id) }
                    )
                }
                if store.todayDailyNotes.count > 3 {
                    Text("+\(store.todayDailyNotes.count - 3) more")
                        .font(.caption)
                        .foregroundStyle(Color("AppAccent"))
                }
            }
        }
    }

    private var todayChecklistSubtitle: String {
        let done = store.todayDailyNotes.filter(\.isCompleted).count
        let total = store.todayDailyNotes.count
        return total == 0 ? "No items yet" : "\(done)/\(total) completed"
    }

    // MARK: - Goals

    private var goalsWidget: some View {
        HomeListWidget(
            icon: "flag.fill",
            title: "Goals",
            subtitle: goalsSubtitle,
            actionTitle: "Manage"
        ) {
            goToTasks()
        } content: {
            if store.progressGoals.isEmpty {
                Text("Create a step-based goal in Tasks.")
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
            } else {
                ForEach(store.progressGoals.prefix(2)) { goal in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(goal.title)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Color("AppTextPrimary"))
                            Spacer()
                            Text("\(goal.currentSteps)/\(goal.targetSteps)")
                                .font(.caption2)
                                .foregroundStyle(Color("AppAccent"))
                        }
                        AppProgressBar(progress: goal.progress, height: 8)
                    }
                }
            }
        }
    }

    private var goalsSubtitle: String {
        guard !store.progressGoals.isEmpty else { return "Track your progress" }
        let avg = store.progressGoals.map(\.progress).reduce(0, +) / Double(store.progressGoals.count)
        return "\(Int(avg * 100))% average progress"
    }

    // MARK: - Week

    private var weekWidget: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 14) {
                AppSectionHeader(
                    icon: "chart.bar.fill",
                    title: "This Week",
                    subtitle: "Tasks \(store.tasksCompletedThisWeek) · Focus \(store.focusMinutesThisWeek)m"
                )
                HomeWeekMiniChart(data: store.focusMinutesByDay())
                Button {
                    goToInsights()
                } label: {
                    Text("Open full insights")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color("AppAccent"))
                        .frame(maxWidth: .infinity, minHeight: 44)
                }
            }
        }
    }

    // MARK: - Navigation

    private func goToTasks() {
        withAnimation(.easeInOut(duration: 0.25)) { selectedTab = .tasks }
    }

    private func goToFocus() {
        toolsSegment = 0
        withAnimation(.easeInOut(duration: 0.25)) { selectedTab = .tools }
    }

    private func goToHabits() {
        toolsSegment = 1
        withAnimation(.easeInOut(duration: 0.25)) { selectedTab = .tools }
    }

    private func goToInsights() {
        toolsSegment = 2
        withAnimation(.easeInOut(duration: 0.25)) { selectedTab = .tools }
    }

    private func goToSettings() {
        withAnimation(.easeInOut(duration: 0.25)) { selectedTab = .settings }
    }
}
