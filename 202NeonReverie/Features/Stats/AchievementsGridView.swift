import Combine
import SwiftUI

struct AchievementsGridView: View {
    @EnvironmentObject private var store: AppDataStore

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 14) {
                AppSectionHeader(
                    icon: "star.fill",
                    title: "Achievements",
                    subtitle: "\(unlockedCount) unlocked"
                )

                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(AchievementDefinition.all) { achievement in
                        AchievementGridCell(
                            title: achievement.title,
                            description: achievement.description,
                            systemImage: achievement.systemImage,
                            isUnlocked: achievement.isUnlocked(in: store)
                        )
                    }
                    ForEach(store.customAchievements) { custom in
                        AchievementGridCell(
                            title: custom.title,
                            description: custom.description,
                            systemImage: "star.circle.fill",
                            isUnlocked: store.isCustomAchievementUnlocked(custom)
                        )
                    }
                }
            }
        }
    }

    private var unlockedCount: Int {
        let builtIn = AchievementDefinition.all.filter { $0.isUnlocked(in: store) }.count
        let custom = store.customAchievements.filter { store.isCustomAchievementUnlocked($0) }.count
        return builtIn + custom
    }
}
