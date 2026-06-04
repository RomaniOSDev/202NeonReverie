import Combine
import StoreKit
import SwiftUI
import UIKit

struct SettingsView: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var showResetAlert = false
    @State private var showExport = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                ScrollView {
                    VStack(spacing: 16) {
                        statsCard
                        AchievementsGridView()
                        CustomAchievementsSection()
                        summaryMetricsCard
                        settingsRows
                        versionFooter
                    }
                    .padding(16)
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showExport) {
                DataExportSheet().environmentObject(store)
            }
            .alert("Reset All Data?", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) { FeedbackManager.lightTap() }
                Button("Reset", role: .destructive) {
                    store.resetAllData()
                    FeedbackManager.warningNotification()
                }
            } message: {
                Text("This will permanently delete all tasks, habits, focus history, and progress.")
            }
        }
    }

    private var statsCard: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 14) {
                AppSectionHeader(icon: "chart.pie.fill", title: "Your Stats", subtitle: "Lifetime totals")
                HStack(spacing: 10) {
                    AppStatTile(icon: "tray.full", value: "\(store.totalEntriesCreated)", label: "Entries", tint: Color("AppPrimary"))
                    AppStatTile(icon: "clock.fill", value: "\(store.totalMinutesUsed)", label: "Minutes")
                    AppStatTile(icon: "flame.fill", value: "\(store.streakDays)", label: "Streak", tint: Color("AppPrimary"))
                }
            }
        }
    }

    private var summaryMetricsCard: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 10) {
                AppSectionHeader(icon: "list.bullet.rectangle", title: "Summary", subtitle: "Detailed counts")
                AppMetricRow(icon: "checkmark.circle", title: "Tasks completed", value: "\(store.tasksCompleted)")
                AppMetricRow(icon: "timer", title: "Focus sessions", value: "\(store.focusSessionsCompleted)")
                AppMetricRow(icon: "hand.thumbsup", title: "Habit check-ins", value: "\(store.habitCheckIns)")
                AppMetricRow(icon: "calendar", title: "Longest app streak", value: "\(store.longestAppStreak)")
                AppMetricRow(icon: "star", title: "Custom achievements", value: "\(store.customAchievements.count)")
            }
        }
    }

    private var settingsRows: some View {
        AppCard(padding: 8, elevation: .medium) {
            VStack(spacing: 0) {
                SettingsActionCell(icon: "square.and.arrow.up", title: "Export Data", subtitle: "JSON or CSV") {
                    showExport = true
                }
                divider
                SettingsActionCell(icon: "star.fill", title: "Rate Us", subtitle: "Enjoying the app?") {
                    rateApp()
                }
                divider
                SettingsActionCell(
                    icon: AppExternalLink.privacyPolicy.settingsIcon,
                    title: AppExternalLink.privacyPolicy.settingsTitle,
                    subtitle: AppExternalLink.privacyPolicy.settingsSubtitle
                ) {
                    openPrivacyPolicy()
                }
                divider
                SettingsActionCell(
                    icon: AppExternalLink.termsOfUse.settingsIcon,
                    title: AppExternalLink.termsOfUse.settingsTitle,
                    subtitle: AppExternalLink.termsOfUse.settingsSubtitle
                ) {
                    openLink(.termsOfUse)
                }
                divider
                SettingsActionCell(
                    icon: "trash.fill",
                    title: "Reset All Data",
                    subtitle: "Cannot be undone",
                    isDestructive: true,
                    showChevron: false
                ) {
                    showResetAlert = true
                }
            }
        }
    }

    private var divider: some View {
        Rectangle()
            .fill(Color("AppBackground").opacity(0.8))
            .frame(height: 1)
            .padding(.leading, 56)
    }

    private var versionFooter: some View {
        Text("Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")")
            .font(.caption)
            .foregroundStyle(Color("AppTextSecondary"))
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
    }

    // MARK: - Actions

    private func rateApp() {
        FeedbackManager.lightTap()
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }

    private func openPrivacyPolicy() {
        FeedbackManager.lightTap()
        if let url = URL(string: AppExternalLink.privacyPolicy.urlString) {
            UIApplication.shared.open(url)
        }
    }

    private func openLink(_ link: AppExternalLink) {
        FeedbackManager.lightTap()
        if let url = link.url {
            UIApplication.shared.open(url)
        }
    }
}
