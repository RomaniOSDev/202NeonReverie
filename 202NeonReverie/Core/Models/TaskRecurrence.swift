import Foundation

enum TaskRecurrence: String, Codable, CaseIterable, Identifiable {
    case none = "None"
    case weekly = "Weekly"
    case monthly = "Monthly"

    var id: String { rawValue }
}
