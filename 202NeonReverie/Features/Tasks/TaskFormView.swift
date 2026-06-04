import Combine
import SwiftUI

struct TaskFormView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: AppDataStore

    let existingTask: TaskItem?

    @State private var title = ""
    @State private var dueDate = Date()
    @State private var category: TaskCategory = .financialPlanning
    @State private var priority: TaskPriority = .medium
    @State private var recurrence: TaskRecurrence = .none
    @State private var errorMessage: String?
    @State private var shakeTrigger = 0

    init(existingTask: TaskItem? = nil) {
        self.existingTask = existingTask
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                Form {
                    Section {
                        TextField("Title", text: $title)
                            .foregroundStyle(Color("AppTextPrimary"))
                            .shake(trigger: shakeTrigger)
                        if let errorMessage {
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundStyle(.red)
                        }
                        DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                        Picker("Category", selection: $category) {
                            ForEach(TaskCategory.allCases) { cat in
                                Text(cat.rawValue).tag(cat)
                            }
                        }
                        Picker("Priority", selection: $priority) {
                            ForEach(TaskPriority.allCases) { p in
                                Text(p.rawValue).tag(p)
                            }
                        }
                        Picker("Repeat", selection: $recurrence) {
                            ForEach(TaskRecurrence.allCases) { r in
                                Text(r.rawValue).tag(r)
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(existingTask == nil ? "New Task" : "Edit Task")
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
                if let task = existingTask {
                    title = task.title
                    dueDate = task.dueDate
                    category = task.category
                    priority = task.priority
                    recurrence = task.recurrence
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func save() {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            errorMessage = "Please enter a title."
            shakeTrigger += 1
            FeedbackManager.warningNotification()
            return
        }
        errorMessage = nil
        if var task = existingTask {
            task.title = trimmed
            task.dueDate = dueDate
            task.category = category
            task.priority = priority
            task.recurrence = recurrence
            task.nextDueDate = dueDate
            store.updateTask(task)
            FeedbackManager.mediumImpact()
            FeedbackManager.playSuccessSound()
        } else {
            let task = TaskItem(
                title: trimmed,
                dueDate: dueDate,
                category: category,
                priority: priority,
                recurrence: recurrence,
                nextDueDate: dueDate
            )
            store.addTask(task)
        }
        dismiss()
    }
}
