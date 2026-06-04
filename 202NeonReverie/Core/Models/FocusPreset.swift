import Foundation

struct FocusPreset: Identifiable {
    let id: String
    let name: String
    let workMinutes: Int
    let breakMinutes: Int

    static let builtIn: [FocusPreset] = [
        FocusPreset(id: "deep_work", name: "Deep Work", workMinutes: 45, breakMinutes: 10),
        FocusPreset(id: "admin", name: "Admin", workMinutes: 25, breakMinutes: 5),
        FocusPreset(id: "short_break", name: "Quick Break", workMinutes: 15, breakMinutes: 5)
    ]
}
