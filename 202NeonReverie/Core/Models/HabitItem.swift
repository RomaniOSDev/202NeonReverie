import Foundation

enum HabitFrequency: String, Codable, CaseIterable, Identifiable {
    case daily = "Daily"
    case weekly = "Weekly"

    var id: String { rawValue }
}

struct HabitItem: Codable, Identifiable, Equatable {
    var id: UUID
    var name: String
    var frequency: HabitFrequency
    var streak: Int
    var completedDates: [String]
    var group: HabitGroup

    init(
        id: UUID = UUID(),
        name: String,
        frequency: HabitFrequency,
        streak: Int = 0,
        completedDates: [String] = [],
        group: HabitGroup = .general
    ) {
        self.id = id
        self.name = name
        self.frequency = frequency
        self.streak = streak
        self.completedDates = completedDates
        self.group = group
    }

    enum CodingKeys: String, CodingKey {
        case id, name, frequency, streak, completedDates, group
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        frequency = try container.decode(HabitFrequency.self, forKey: .frequency)
        streak = try container.decode(Int.self, forKey: .streak)
        completedDates = try container.decode([String].self, forKey: .completedDates)
        group = try container.decodeIfPresent(HabitGroup.self, forKey: .group) ?? .general
    }

    static func dateKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    func isCompletedToday(referenceDate: Date = Date()) -> Bool {
        completedDates.contains(Self.dateKey(for: referenceDate))
    }

    func isCompleted(on date: Date) -> Bool {
        completedDates.contains(Self.dateKey(for: date))
    }
}
