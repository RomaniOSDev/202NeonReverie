import Foundation

enum FocusSessionType: String, Codable {
    case work = "Work"
    case breakTime = "Break"
}

struct FocusSessionRecord: Codable, Identifiable, Equatable {
    var id: UUID
    var type: FocusSessionType
    var durationSeconds: Int
    var completedAt: Date
    var linkedTaskId: UUID?
    var linkedTaskTitle: String?

    init(
        id: UUID = UUID(),
        type: FocusSessionType,
        durationSeconds: Int,
        completedAt: Date = Date(),
        linkedTaskId: UUID? = nil,
        linkedTaskTitle: String? = nil
    ) {
        self.id = id
        self.type = type
        self.durationSeconds = durationSeconds
        self.completedAt = completedAt
        self.linkedTaskId = linkedTaskId
        self.linkedTaskTitle = linkedTaskTitle
    }

    enum CodingKeys: String, CodingKey {
        case id, type, durationSeconds, completedAt, linkedTaskId, linkedTaskTitle
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        type = try container.decode(FocusSessionType.self, forKey: .type)
        durationSeconds = try container.decode(Int.self, forKey: .durationSeconds)
        completedAt = try container.decode(Date.self, forKey: .completedAt)
        linkedTaskId = try container.decodeIfPresent(UUID.self, forKey: .linkedTaskId)
        linkedTaskTitle = try container.decodeIfPresent(String.self, forKey: .linkedTaskTitle)
    }
}
