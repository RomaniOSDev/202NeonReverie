import Combine
import SwiftUI

enum MainTab: Int, CaseIterable {
    case home
    case tasks
    case tools
    case settings

    var title: String {
        switch self {
        case .home: return "Home"
        case .tasks: return "Tasks"
        case .tools: return "Tools"
        case .settings: return "Settings"
        }
    }

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .tasks: return "checklist"
        case .tools: return "timer"
        case .settings: return "gearshape"
        }
    }
}

struct MainTabView: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var selectedTab: MainTab = .home
    @State private var toolsSegment = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            AppBackgroundView()
            Group {
                switch selectedTab {
                case .home:
                    HomeView(selectedTab: $selectedTab, toolsSegment: $toolsSegment)
                case .tasks:
                    TasksView()
                case .tools:
                    ToolsContainerView(selectedSegment: $toolsSegment)
                case .settings:
                    SettingsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.bottom, 84)

            customTabBar
        }
        .overlay(alignment: .top) {
            AchievementBannerContainer()
                .padding(.top, 8)
        }
    }

    private var customTabBar: some View {
        HStack(spacing: 6) {
            ForEach(MainTab.allCases, id: \.self) { tab in
                tabButton(tab)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 10)
        .appTopGlow(cornerRadius: 22)
        .appSurface(cornerRadius: 22, elevation: .medium)
        .padding(.horizontal, 12)
        .padding(.bottom, 10)
        .appCachedIfStatic(true)
    }

    private func tabButton(_ tab: MainTab) -> some View {
        let isSelected = selectedTab == tab
        let badge = tab == .tools ? store.habitsPendingTodayCount : 0
        return Button {
            FeedbackManager.lightTap()
            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 4) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: tab.icon)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(isSelected ? Color("AppTextPrimary") : Color("AppTextSecondary"))
                        .frame(width: 34, height: 34)
                        .background {
                            if isSelected {
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(AppVisualStyle.primaryGradient())
                            } else {
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(Color("AppBackground").opacity(0.5))
                            }
                        }
                        .shadow(
                            color: isSelected ? Color("AppPrimary").opacity(0.35) : .clear,
                            radius: isSelected ? 4 : 0,
                            y: isSelected ? 2 : 0
                        )
                    if badge > 0 {
                        Text(badge > 9 ? "9+" : "\(badge)")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundStyle(Color("AppTextPrimary"))
                            .frame(width: 15, height: 15)
                            .background(Color("AppPrimary"))
                            .clipShape(Circle())
                            .offset(x: 5, y: -5)
                    }
                }
                Text(tab.title)
                    .font(.system(size: 10, weight: isSelected ? .bold : .medium))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .foregroundStyle(isSelected ? Color("AppTextPrimary") : Color("AppTextSecondary"))
            }
            .frame(maxWidth: .infinity, minHeight: 50)
        }
        .buttonStyle(.plain)
    }
}
