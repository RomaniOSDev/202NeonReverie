import Combine
import SwiftUI

struct AchievementBannerView: View {
    let achievement: AchievementDefinition
    let onDismiss: () -> Void

    @State private var offset: CGFloat = -140

    var body: some View {
        HStack(spacing: 14) {
            AppIconBadge(systemName: achievement.systemImage, tint: Color("AppPrimary"), size: 44)
            VStack(alignment: .leading, spacing: 4) {
                Text("Achievement Unlocked")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color("AppAccent"))
                Text(achievement.title)
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))
            }
            Spacer()
        }
        .padding(16)
        .appTopGlow(cornerRadius: 16)
        .appSurface(cornerRadius: 16, elevation: .medium)
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(AppVisualStyle.primaryGradient(start: .leading, end: .trailing), lineWidth: 1.5)
        )
        .padding(.horizontal, 16)
        .offset(y: offset)
        .appCachedIfStatic(true)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) { offset = 0 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation(.easeInOut(duration: 0.3)) { offset = -140 }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { onDismiss() }
            }
        }
    }
}

struct AchievementBannerContainer: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var currentBanner: AchievementDefinition?

    var body: some View {
        VStack {
            if let banner = currentBanner {
                AchievementBannerView(achievement: banner) {
                    currentBanner = nil
                    showNextIfNeeded()
                }
            }
            Spacer()
        }
        .onChange(of: store.pendingAchievementBanners.count) { _ in showNextIfNeeded() }
        .onAppear { showNextIfNeeded() }
    }

    private func showNextIfNeeded() {
        guard currentBanner == nil else { return }
        if let next = store.dequeueAchievementBanner() {
            currentBanner = next
        }
    }
}
