import Combine
import Foundation

@MainActor
final class HabitsViewModel: ObservableObject {
    @Published var showingAddSheet = false
    @Published var editingHabit: HabitItem?

    func filteredHabits(from store: AppDataStore) -> [HabitItem] {
        guard store.habitGroupFilter != "All" else { return store.habits }
        return store.habits.filter { $0.group.rawValue == store.habitGroupFilter }
    }

    func weekDates(reference: Date = Date()) -> [Date] {
        let calendar = Calendar.current
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: reference)?.start ?? reference
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: startOfWeek) }
    }

    func weekdayLabel(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }

    func dayNumber(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }

    func isToday(_ date: Date) -> Bool {
        Calendar.current.isDateInToday(date)
    }
}
