import Foundation

enum HabitGroup: String, Codable, CaseIterable, Identifiable {
    case morning = "Morning"
    case evening = "Evening"
    case weekly = "Weekly"
    case general = "General"

    var id: String { rawValue }
}
