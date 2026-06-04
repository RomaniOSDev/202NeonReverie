import Combine
import SwiftUI

// MARK: - Visual style (gradients, elevation, surfaces)

enum AppElevation: Equatable {
    case flat
    case low
    case medium

    var shadowRadius: CGFloat {
        switch self {
        case .flat: return 0
        case .low: return 4
        case .medium: return 8
        }
    }

    var shadowY: CGFloat {
        switch self {
        case .flat: return 0
        case .low: return 2
        case .medium: return 4
        }
    }
}

enum AppVisualStyle {
    static func primaryGradient(start: UnitPoint = .topLeading, end: UnitPoint = .bottomTrailing) -> LinearGradient {
        LinearGradient(
            colors: [Color("AppPrimary"), Color("AppAccent")],
            startPoint: start,
            endPoint: end
        )
    }

    static func surfaceGradient() -> LinearGradient {
        LinearGradient(
            colors: [Color("AppSurface"), Color("AppBackground").opacity(0.4)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static func borderGradient(opacity: Double = 1) -> LinearGradient {
        LinearGradient(
            colors: [
                Color("AppAccent").opacity(0.35 * opacity),
                Color("AppPrimary").opacity(0.12 * opacity)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var shadowColor: Color {
        Color("AppBackground").opacity(0.55)
    }
}

private struct AppSurfaceModifier: ViewModifier {
    let cornerRadius: CGFloat
    let elevation: AppElevation
    let bordered: Bool

    func body(content: Content) -> some View {
        let shaped = content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(AppVisualStyle.surfaceGradient())
            )
            .overlay {
                if bordered {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(AppVisualStyle.borderGradient(), lineWidth: 1)
                }
            }

        if elevation == .flat {
            shaped
        } else {
            shaped.shadow(
                color: AppVisualStyle.shadowColor,
                radius: elevation.shadowRadius,
                x: 0,
                y: elevation.shadowY
            )
        }
    }
}

private struct AppGlowOverlay: ViewModifier {
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content.overlay {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color("AppTextPrimary").opacity(0.07), Color.clear],
                        startPoint: .top,
                        endPoint: .center
                    )
                )
                .allowsHitTesting(false)
        }
    }
}

extension View {
    func appSurface(
        cornerRadius: CGFloat = 16,
        elevation: AppElevation = .medium,
        bordered: Bool = true
    ) -> some View {
        modifier(AppSurfaceModifier(cornerRadius: cornerRadius, elevation: elevation, bordered: bordered))
    }

    func appListCellSurface(cornerRadius: CGFloat = 16) -> some View {
        modifier(AppSurfaceModifier(cornerRadius: cornerRadius, elevation: .flat, bordered: true))
    }

    func appTopGlow(cornerRadius: CGFloat = 16) -> some View {
        modifier(AppGlowOverlay(cornerRadius: cornerRadius))
    }

    func appCachedIfStatic(_ enabled: Bool = true) -> some View {
        Group {
            if enabled {
                self.drawingGroup(opaque: false)
            } else {
                self
            }
        }
    }
}

// MARK: - Card & layout

struct AppCard<Content: View>: View {
    var padding: CGFloat = 16
    var elevation: AppElevation = .medium
    var cached: Bool = false
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .appTopGlow(cornerRadius: 16)
            .appSurface(cornerRadius: 16, elevation: elevation)
            .appCachedIfStatic(cached)
    }
}

struct AppSectionHeader: View {
    let icon: String
    let title: String
    var subtitle: String?
    var actionIcon: String?
    var action: (() -> Void)?

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            AppIconBadge(systemName: icon, tint: Color("AppPrimary"))
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))
                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
            }
            Spacer()
            if let actionIcon, let action {
                Button(action: {
                    FeedbackManager.lightTap()
                    action()
                }) {
                    Image(systemName: actionIcon)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Color("AppAccent"))
                        .frame(width: 44, height: 44)
                        .appSurface(cornerRadius: 22, elevation: .low)
                }
            }
        }
    }
}

struct AppIconBadge: View {
    let systemName: String
    var tint: Color = Color("AppAccent")
    var size: CGFloat = 40

    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: size * 0.42, weight: .semibold))
            .foregroundStyle(Color("AppTextPrimary"))
            .frame(width: size, height: size)
            .background(AppVisualStyle.primaryGradient())
            .overlay {
                RoundedRectangle(cornerRadius: size * 0.28, style: .continuous)
                    .stroke(Color("AppTextPrimary").opacity(0.2), lineWidth: 0.5)
            }
            .clipShape(RoundedRectangle(cornerRadius: size * 0.28, style: .continuous))
            .shadow(
                color: size >= 38 ? tint.opacity(0.3) : .clear,
                radius: size >= 38 ? 3 : 0,
                x: 0,
                y: size >= 38 ? 2 : 0
            )
    }
}

struct AppTagChip: View {
    let text: String
    var accent: Color = Color("AppPrimary")

    var body: some View {
        Text(text)
            .font(.caption2.weight(.semibold))
            .lineLimit(1)
            .foregroundStyle(Color("AppTextPrimary"))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                LinearGradient(
                    colors: [accent.opacity(0.38), accent.opacity(0.18)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(Capsule().stroke(accent.opacity(0.45), lineWidth: 0.5))
            .clipShape(Capsule())
    }
}

struct AppSearchField: View {
    let placeholder: String
    @Binding var text: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Color("AppAccent"))
            TextField(placeholder, text: $text)
                .foregroundStyle(Color("AppTextPrimary"))
            if !text.isEmpty {
                Button {
                    FeedbackManager.lightTap()
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color("AppTextSecondary"))
                }
                .frame(width: 44, height: 44)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .appSurface(cornerRadius: 14, elevation: .low)
    }
}

struct AppFilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button {
            FeedbackManager.lightTap()
            action()
        } label: {
            Text(title)
                .font(.caption.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .foregroundStyle(isSelected ? Color("AppTextPrimary") : Color("AppTextSecondary"))
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background {
                    if isSelected {
                        Capsule().fill(AppVisualStyle.primaryGradient(start: .leading, end: .trailing))
                    } else {
                        Capsule().fill(Color("AppSurface"))
                    }
                }
                .overlay(
                    Capsule().stroke(
                        isSelected ? Color.clear : Color("AppTextSecondary").opacity(0.28),
                        lineWidth: 1
                    )
                )
                .shadow(
                    color: isSelected ? Color("AppPrimary").opacity(0.35) : .clear,
                    radius: isSelected ? 4 : 0,
                    y: isSelected ? 2 : 0
                )
        }
        .frame(minHeight: 44)
    }
}

struct AppEmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var buttonTitle: String?
    var action: (() -> Void)?

    var body: some View {
        VStack(spacing: 16) {
            AppIconBadge(systemName: icon, tint: Color("AppAccent"), size: 72)
            Text(title)
                .font(.title3.weight(.bold))
                .foregroundStyle(Color("AppTextPrimary"))
            Text(message)
                .font(.subheadline)
                .foregroundStyle(Color("AppTextSecondary"))
                .multilineTextAlignment(.center)
            if let buttonTitle, let action {
                Button(buttonTitle, action: {
                    FeedbackManager.lightTap()
                    action()
                })
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal, 32)
            }
        }
        .padding(.vertical, 32)
        .frame(maxWidth: .infinity)
    }
}

struct AppStatTile: View {
    let icon: String
    let value: String
    let label: String
    var tint: Color = Color("AppAccent")

    var body: some View {
        VStack(spacing: 10) {
            AppIconBadge(systemName: icon, tint: tint, size: 36)
            Text(value)
                .font(.title2.bold())
                .foregroundStyle(Color("AppTextPrimary"))
            Text(label)
                .font(.caption2)
                .foregroundStyle(Color("AppTextSecondary"))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .appTopGlow(cornerRadius: 12)
        .appSurface(cornerRadius: 12, elevation: .low)
    }
}

struct AppMetricRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(Color("AppAccent"))
                .frame(width: 28)
            Text(title)
                .foregroundStyle(Color("AppTextSecondary"))
            Spacer()
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color("AppTextPrimary"))
        }
        .padding(.vertical, 4)
    }
}

struct AppProgressBar: View {
    let progress: Double
    var height: CGFloat = 10

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Color("AppBackground"))
                Capsule()
                    .fill(AppVisualStyle.primaryGradient(start: .leading, end: .trailing))
                    .frame(width: max(0, geo.size.width * min(1, progress)))
            }
        }
        .frame(height: height)
    }
}

struct AppToolbarIconButton: View {
    let systemName: String
    var tint: Color = Color("AppPrimary")
    let action: () -> Void

    var body: some View {
        Button {
            FeedbackManager.lightTap()
            action()
        } label: {
            Image(systemName: systemName)
                .font(.body.weight(.semibold))
                .foregroundStyle(tint)
                .frame(width: 40, height: 40)
                .appSurface(cornerRadius: 10, elevation: .low)
        }
    }
}

struct AppSegmentedBar: View {
    let items: [String]
    @Binding var selection: Int

    var body: some View {
        HStack(spacing: 6) {
            ForEach(items.indices, id: \.self) { index in
                Button {
                    FeedbackManager.lightTap()
                    withAnimation(.easeInOut(duration: 0.25)) {
                        selection = index
                    }
                } label: {
                    Text(items[index])
                        .font(.caption.weight(.semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.65)
                        .foregroundStyle(selection == index ? Color("AppTextPrimary") : Color("AppTextSecondary"))
                        .frame(maxWidth: .infinity, minHeight: 40)
                        .background {
                            if selection == index {
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(AppVisualStyle.primaryGradient(start: .leading, end: .trailing))
                            } else {
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(Color("AppBackground").opacity(0.45))
                            }
                        }
                }
            }
        }
        .padding(4)
        .appSurface(cornerRadius: 14, elevation: .low)
        .appCachedIfStatic(true)
    }
}

extension View {
    func appListCellInsets() -> some View {
        listRowInsets(EdgeInsets(top: 5, leading: 16, bottom: 5, trailing: 16))
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
    }
}

struct SurfaceCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        AppCard { content }
    }
}

extension View {
    func surfaceCard() -> some View {
        modifier(SurfaceCardModifier())
    }
}
