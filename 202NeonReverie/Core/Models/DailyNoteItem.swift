import Foundation

struct DailyNoteItem: Codable, Identifiable, Equatable {
    var id: UUID
    var text: String
    var dateKey: String
    var isCompleted: Bool

    init(id: UUID = UUID(), text: String, dateKey: String, isCompleted: Bool = false) {
        self.id = id
        self.text = text
        self.dateKey = dateKey
        self.isCompleted = isCompleted
    }
}
