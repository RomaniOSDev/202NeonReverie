import Combine
import SwiftUI

struct HabitFormView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: AppDataStore

    let existingHabit: HabitItem?

    @State private var name = ""
    @State private var frequency: HabitFrequency = .daily
    @State private var group: HabitGroup = .general
    @State private var errorMessage: String?
    @State private var shakeTrigger = 0

    init(existingHabit: HabitItem? = nil) {
        self.existingHabit = existingHabit
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                Form {
                    Section {
                        TextField("Habit name", text: $name)
                            .foregroundStyle(Color("AppTextPrimary"))
                            .shake(trigger: shakeTrigger)
                        if let errorMessage {
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundStyle(.red)
                        }
                        Picker("Group", selection: $group) {
                            ForEach(HabitGroup.allCases) { g in
                                Text(g.rawValue).tag(g)
                            }
                        }
                        Picker("Frequency", selection: $frequency) {
                            ForEach(HabitFrequency.allCases) { f in
                                Text(f.rawValue).tag(f)
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(existingHabit == nil ? "New Habit" : "Edit Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        FeedbackManager.lightTap()
                        dismiss()
                    }
                    .foregroundStyle(Color("AppTextSecondary"))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .foregroundStyle(Color("AppPrimary"))
                }
            }
            .onAppear {
                if let habit = existingHabit {
                    name = habit.name
                    frequency = habit.frequency
                    group = habit.group
                }
            }
        }
        .presentationDetents([.medium])
    }

    private func save() {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            errorMessage = "Please enter a habit name."
            shakeTrigger += 1
            FeedbackManager.warningNotification()
            return
        }
        errorMessage = nil
        if var habit = existingHabit {
            habit.name = trimmed
            habit.frequency = frequency
            habit.group = group
            store.updateHabit(habit)
            FeedbackManager.mediumImpact()
            FeedbackManager.playSuccessSound()
        } else {
            store.addHabit(HabitItem(name: trimmed, frequency: frequency, group: group))
        }
        dismiss()
    }
}
