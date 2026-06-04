import Combine
import SwiftUI

// MARK: - Hero

struct HomeHeroBanner: View {
    let greeting: String
    let subtitle: String

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image("HomeHero")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 168)
                .clipped()

            LinearGradient(
                colors: [Color("AppBackground").opacity(0.1), Color("AppBackground").opacity(0.92)],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 6) {
                Text(greeting)
                    .font(.title2.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(Color("AppTextSecondary"))
            }
            .padding(16)
        }
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(AppVisualStyle.borderGradient(opacity: 1.2), lineWidth: 1)
        )
        .shadow(color: AppVisualStyle.shadowColor, radius: 10, x: 0, y: 5)
        .appCachedIfStatic(true)
    }
}

// MARK: - Stat widget

struct HomeStatWidget: View {
    let icon: String
    let value: String
    let label: String
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: {
            FeedbackManager.lightTap()
            action()
        }) {
            VStack(alignment: .leading, spacing: 10) {
                AppIconBadge(systemName: icon, tint: tint, size: 32)
                Text(value)
                    .font(.title3.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text(label)
                    .font(.caption2)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .appTopGlow(cornerRadius: 14)
            .appSurface(cornerRadius: 14, elevation: .low)
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(tint.opacity(0.3), lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Large feature widget

struct HomeFeatureWidget: View {
    let imageName: String
    let icon: String
    let title: String
    let subtitle: String
    let metric: String
    let metricLabel: String
    let actionTitle: String
    let action: () -> Void

    var body: some View {
        Button(action: {
            FeedbackManager.lightTap()
            action()
        }) {
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 8) {
                        Image(systemName: icon)
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color("AppAccent"))
                        Text(title)
                            .font(.headline)
                            .foregroundStyle(Color("AppTextPrimary"))
                    }
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text(metric)
                            .font(.title.bold())
                            .foregroundStyle(Color("AppTextPrimary"))
                        Text(metricLabel)
                            .font(.caption)
                            .foregroundStyle(Color("AppTextSecondary"))
                    }

                    Text(actionTitle)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color("AppAccent"))
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)

                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 110)
                    .clipped()
            }
            .frame(minHeight: 130)
            .appTopGlow(cornerRadius: 16)
            .appSurface(cornerRadius: 16, elevation: .medium)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - List widget

struct HomeListWidget<Content: View>: View {
    let icon: String
    let title: String
    let subtitle: String
    var actionTitle: String = "See all"
    let onSeeAll: () -> Void
    @ViewBuilder let content: () -> Content

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    AppSectionHeader(icon: icon, title: title, subtitle: subtitle)
                    Spacer(minLength: 0)
                    Button(actionTitle) {
                        FeedbackManager.lightTap()
                        onSeeAll()
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color("AppAccent"))
                    .frame(minHeight: 44)
                }
                content()
            }
        }
    }
}

// MARK: - Quick action

struct HomeQuickAction: View {
    let icon: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: {
            FeedbackManager.lightTap()
            action()
        }) {
            VStack(spacing: 8) {
                AppIconBadge(systemName: icon, tint: Color("AppPrimary"), size: 40)
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .appSurface(cornerRadius: 12, elevation: .flat)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Week mini chart bar

struct HomeWeekMiniChart: View {
    let data: [AppDataStore.DayFocusMinutes]

    var body: some View {
        HStack(alignment: .bottom, spacing: 6) {
            ForEach(data) { day in
                VStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(AppVisualStyle.primaryGradient(start: .bottom, end: .top))
                        .frame(width: 14, height: barHeight(for: day.minutes))
                    Text(shortWeekday(day.date))
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(Color("AppTextSecondary"))
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 72)
    }

    private func barHeight(for minutes: Int) -> CGFloat {
        let maxMinutes = max(data.map(\.minutes).max() ?? 1, 1)
        return CGFloat(max(8, (minutes * 50) / maxMinutes))
    }

    private func shortWeekday(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "EEE"
        return String(f.string(from: date).prefix(1))
    }
}
