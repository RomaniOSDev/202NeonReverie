import Combine
import SwiftUI

struct SettingsActionCell: View {
    let icon: String
    let title: String
    var subtitle: String?
    var isDestructive: Bool = false
    var showChevron: Bool = true
    let action: () -> Void

    var body: some View {
        Button {
            FeedbackManager.lightTap()
            action()
        } label: {
            HStack(spacing: 14) {
                AppIconBadge(
                    systemName: icon,
                    tint: isDestructive ? Color("AppPrimary") : Color("AppAccent"),
                    size: 38
                )
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(isDestructive ? Color.red : Color("AppTextPrimary"))
                    if let subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundStyle(Color("AppTextSecondary"))
                    }
                }
                Spacer()
                if showChevron {
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color("AppTextSecondary"))
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(minHeight: 56)
        }
    }
}

struct AchievementGridCell: View {
    let title: String
    let description: String
    let systemImage: String
    let isUnlocked: Bool

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(isUnlocked ? Color("AppPrimary").opacity(0.2) : Color("AppBackground"))
                    .frame(width: 52, height: 52)
                Image(systemName: systemImage)
                    .font(.title2)
                    .foregroundStyle(isUnlocked ? Color("AppAccent") : Color("AppTextSecondary").opacity(0.45))
            }
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(Color("AppTextPrimary"))
                .lineLimit(2)
                .minimumScaleFactor(0.7)
                .multilineTextAlignment(.center)
            Text(description)
                .font(.caption2)
                .foregroundStyle(Color("AppTextSecondary"))
                .lineLimit(2)
                .minimumScaleFactor(0.7)
                .multilineTextAlignment(.center)
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 130)
        .appTopGlow(cornerRadius: 14)
        .appSurface(cornerRadius: 14, elevation: isUnlocked ? .low : .flat)
        .overlay {
            if isUnlocked {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(AppVisualStyle.primaryGradient(), lineWidth: 1.5)
            }
        }
        .opacity(isUnlocked ? 1 : 0.75)
    }
}

struct TemplateListCell: View {
    let template: TaskTemplate
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                AppIconBadge(systemName: "doc.text.fill", tint: Color("AppPrimary"), size: 44)
                VStack(alignment: .leading, spacing: 6) {
                    Text(template.title)
                        .font(.headline)
                        .foregroundStyle(Color("AppTextPrimary"))
                    HStack(spacing: 6) {
                        AppTagChip(text: template.category.rawValue, accent: Color("AppPrimary"))
                        AppTagChip(text: template.priority.rawValue, accent: Color("AppAccent"))
                    }
                }
                Spacer()
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundStyle(Color("AppAccent"))
            }
            .padding(16)
            .appTopGlow(cornerRadius: 16)
            .appSurface(cornerRadius: 16, elevation: .low)
        }
    }
}
