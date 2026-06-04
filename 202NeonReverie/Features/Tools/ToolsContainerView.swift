import Combine
import SwiftUI

struct ToolsContainerView: View {
    @EnvironmentObject private var store: AppDataStore
    @Binding var selectedSegment: Int

    private var segmentItems: [String] {
        let pending = store.habitsPendingTodayCount
        let habitsLabel = pending > 0 ? "Habits (\(pending))" : "Habits"
        return ["Focus", habitsLabel, "Insights"]
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                VStack(spacing: 12) {
                    AppSegmentedBar(items: segmentItems, selection: $selectedSegment)
                        .padding(.horizontal, 16)
                        .padding(.top, 8)

                    switch selectedSegment {
                    case 0:
                        FocusView()
                    case 1:
                        HabitsView()
                    default:
                        WeekOverviewView()
                    }
                }
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var navigationTitle: String {
        switch selectedSegment {
        case 0: return "Focus"
        case 1: return "Habits"
        default: return "Insights"
        }
    }
}
