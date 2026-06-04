import Combine
import SwiftUI

struct ProgressGoalsSection: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var showAddGoal = false
    @State private var newTitle = ""
    @State private var newTarget = 12

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 14) {
                AppSectionHeader(
                    icon: "flag.fill",
                    title: "Goals",
                    subtitle: "Step-based progress",
                    actionIcon: "plus",
                    action: { showAddGoal = true }
                )

                if store.progressGoals.isEmpty {
                    Text("Set a step-based goal, e.g. 12 weeks of budget tracking.")
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                } else {
                    ForEach(store.progressGoals) { goal in
                        GoalProgressCell(
                            goal: goal,
                            onIncrement: { store.incrementGoal(id: goal.id) },
                            onDelete: { store.deleteProgressGoal(id: goal.id) }
                        )
                    }
                }
            }
        }
        .sheet(isPresented: $showAddGoal) {
            NavigationStack {
                ZStack {
                    Color("AppBackground").ignoresSafeArea()
                    Form {
                        TextField("Goal title", text: $newTitle)
                        Stepper("Target steps: \(newTarget)", value: $newTarget, in: 1...52)
                    }
                    .scrollContentBackground(.hidden)
                }
                .navigationTitle("New Goal")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { showAddGoal = false }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            let trimmed = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
                            guard !trimmed.isEmpty else { return }
                            store.addProgressGoal(ProgressGoal(title: trimmed, targetSteps: newTarget))
                            newTitle = ""
                            newTarget = 12
                            showAddGoal = false
                        }
                        .foregroundStyle(Color("AppPrimary"))
                    }
                }
            }
            .presentationDetents([.medium])
        }
    }
}
