import Combine
import SwiftUI

struct CustomAchievementsSection: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var showAdd = false
    @State private var title = ""
    @State private var description = ""
    @State private var metric: AchievementMetric = .tasksCompleted
    @State private var targetValue = 5

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 14) {
                AppSectionHeader(
                    icon: "star.circle.fill",
                    title: "Custom Achievements",
                    subtitle: "Personal milestones",
                    actionIcon: "plus",
                    action: { showAdd = true }
                )

                if store.customAchievements.isEmpty {
                    Text("Create personal milestones tied to your progress.")
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                } else {
                    ForEach(store.customAchievements) { achievement in
                        HStack(spacing: 12) {
                            AchievementGridCell(
                                title: achievement.title,
                                description: achievement.description,
                                systemImage: "star.circle.fill",
                                isUnlocked: store.isCustomAchievementUnlocked(achievement)
                            )
                            .frame(width: 140)
                            VStack(alignment: .leading, spacing: 8) {
                                Text("\(achievement.currentValue(in: store))/\(achievement.targetValue)")
                                    .font(.title3.weight(.bold))
                                    .foregroundStyle(Color("AppAccent"))
                                Text(achievement.metric.rawValue)
                                    .font(.caption)
                                    .foregroundStyle(Color("AppTextSecondary"))
                                Button("Remove") {
                                    store.deleteCustomAchievement(id: achievement.id)
                                }
                                .font(.caption)
                                .foregroundStyle(.red)
                                .frame(minHeight: 44, alignment: .leading)
                            }
                            Spacer(minLength: 0)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showAdd) {
            NavigationStack {
                ZStack {
                    Color("AppBackground").ignoresSafeArea()
                    Form {
                        TextField("Title", text: $title)
                        TextField("Description", text: $description)
                        Picker("Metric", selection: $metric) {
                            ForEach(AchievementMetric.allCases) { m in
                                Text(m.rawValue).tag(m)
                            }
                        }
                        Stepper("Target: \(targetValue)", value: $targetValue, in: 1...500)
                    }
                    .scrollContentBackground(.hidden)
                }
                .navigationTitle("New Achievement")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) { Button("Cancel") { showAdd = false } }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") { saveAchievement() }
                            .foregroundStyle(Color("AppPrimary"))
                    }
                }
            }
            .presentationDetents([.medium, .large])
        }
    }

    private func saveAchievement() {
        let t = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let d = description.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else { return }
        store.addCustomAchievement(
            CustomAchievement(
                title: t,
                description: d.isEmpty ? "Personal milestone" : d,
                metric: metric,
                targetValue: targetValue
            )
        )
        title = ""
        description = ""
        targetValue = 5
        showAdd = false
    }
}
