import Combine
import SwiftUI

struct HabitCalendarView: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var displayedMonth = Date()
    @State private var selectedHabitId: UUID?

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    private let weekdays = ["S", "M", "T", "W", "T", "F", "S"]

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 14) {
                AppSectionHeader(icon: "calendar", title: "Habit Calendar", subtitle: monthTitle(displayedMonth))

                if !store.habits.isEmpty {
                    Picker("Habit", selection: $selectedHabitId) {
                        ForEach(store.habits) { habit in
                            Text(habit.name).tag(Optional(habit.id))
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(Color("AppAccent"))
                }

                HStack {
                    Button { changeMonth(-1) } label: {
                        Image(systemName: "chevron.left.circle.fill")
                            .font(.title3)
                            .foregroundStyle(Color("AppAccent"))
                            .frame(width: 44, height: 44)
                    }
                    Spacer()
                    Button { changeMonth(1) } label: {
                        Image(systemName: "chevron.right.circle.fill")
                            .font(.title3)
                            .foregroundStyle(Color("AppAccent"))
                            .frame(width: 44, height: 44)
                    }
                }

                LazyVGrid(columns: columns, spacing: 6) {
                    ForEach(weekdays, id: \.self) { day in
                        Text(day)
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                    ForEach(daysInMonth(displayedMonth), id: \.self) { day in
                        calendarCell(for: day)
                    }
                }
            }
        }
        .onAppear {
            if selectedHabitId == nil {
                selectedHabitId = store.habits.first?.id
            }
        }
    }

    @ViewBuilder
    private func calendarCell(for date: Date?) -> some View {
        if let date {
            let completed = isCompleted(on: date)
            let isToday = Calendar.current.isDateInToday(date)
            Text("\(Calendar.current.component(.day, from: date))")
                .font(.caption2.weight(.semibold))
                .frame(maxWidth: .infinity, minHeight: 34)
                .foregroundStyle(completed || isToday ? Color("AppTextPrimary") : Color("AppTextSecondary"))
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            completed
                                ? Color("AppPrimary")
                                : (isToday ? Color("AppAccent").opacity(0.35) : Color("AppBackground"))
                        )
                )
        } else {
            Color.clear.frame(minHeight: 34)
        }
    }

    private func changeMonth(_ delta: Int) {
        FeedbackManager.lightTap()
        displayedMonth = Calendar.current.date(byAdding: .month, value: delta, to: displayedMonth) ?? displayedMonth
    }

    private func isCompleted(on date: Date) -> Bool {
        guard let habitId = selectedHabitId,
              let habit = store.habits.first(where: { $0.id == habitId }) else {
            return store.habits.contains { $0.isCompleted(on: date) }
        }
        return habit.isCompleted(on: date)
    }

    private func monthTitle(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }

    private func daysInMonth(_ date: Date) -> [Date?] {
        let calendar = Calendar.current
        guard let interval = calendar.dateInterval(of: .month, for: date),
              let firstWeekday = calendar.dateComponents([.weekday], from: interval.start).weekday else {
            return []
        }
        var days: [Date?] = Array(repeating: nil, count: firstWeekday - 1)
        var current = interval.start
        while current < interval.end {
            days.append(current)
            current = calendar.date(byAdding: .day, value: 1, to: current) ?? current
        }
        while days.count % 7 != 0 { days.append(nil) }
        return days
    }
}
