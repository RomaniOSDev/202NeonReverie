import Combine
import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var pageIndex = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            imageName: "HomeHero",
            icon: "bolt.fill",
            tag: "Tasks",
            headline: "Boost Efficiency",
            description: "Streamline your financial tasks with ease.",
            highlights: [
                ("checklist", "Organize tasks with filters and search"),
                ("doc.on.doc", "Start faster with built-in templates"),
                ("target", "Track goals and daily checklists")
            ]
        ),
        OnboardingPage(
            imageName: "HomeFocusArt",
            icon: "timer",
            tag: "Focus",
            headline: "Set Your Focus",
            description: "Utilize the focus timer to maintain concentration on financial activities.",
            highlights: [
                ("timer", "Pomodoro-style work and break sessions"),
                ("pause.circle", "Pause, resume, and stay on track"),
                ("link", "Link a focus session to any task")
            ]
        ),
        OnboardingPage(
            imageName: "HomeHabitsArt",
            icon: "checklist",
            tag: "Habits",
            headline: "Get Started Now",
            description: "Add your first task to begin your productivity journey.",
            highlights: [
                ("hand.thumbsup", "Build habits with daily check-ins"),
                ("chart.bar.fill", "Review insights and streaks"),
                ("plus.circle.fill", "Add your first task in seconds")
            ]
        )
    ]

    var body: some View {
        ZStack {
            AppBackgroundView()
            VStack(spacing: 0) {
                onboardingHeader
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 8)

                TabView(selection: $pageIndex) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        onboardingPage(page: page, index: index)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: pageIndex)

                footerControls
                    .padding(.horizontal, 16)
                    .padding(.bottom, 28)
            }
        }
    }

    // MARK: - Header

    private var onboardingHeader: some View {
        HStack(spacing: 12) {
            AppIconBadge(systemName: "chart.line.uptrend.xyaxis", tint: Color("AppPrimary"), size: 44)
            VStack(alignment: .leading, spacing: 4) {
                Text("Neon Reverie")
                    .font(.headline)
                    .foregroundStyle(Color("AppTextPrimary"))
                AppTagChip(text: "Financial productivity", accent: Color("AppAccent"))
            }
            Spacer()
            AppTagChip(text: "\(pageIndex + 1)/\(pages.count)", accent: Color("AppPrimary"))
        }
    }

    // MARK: - Page

    @ViewBuilder
    private func onboardingPage(page: OnboardingPage, index: Int) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                OnboardingHeroBanner(
                    imageName: page.imageName,
                    tag: page.tag,
                    headline: page.headline
                )
                .padding(.horizontal, 16)

                AppCard(cached: true) {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(alignment: .top, spacing: 12) {
                            AppIconBadge(systemName: page.icon, tint: Color("AppPrimary"), size: 40)
                            Text(page.description)
                                .font(.body)
                                .foregroundStyle(Color("AppTextSecondary"))
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        VStack(spacing: 0) {
                            ForEach(Array(page.highlights.enumerated()), id: \.offset) { itemIndex, item in
                                OnboardingHighlightRow(icon: item.icon, text: item.text)
                                if itemIndex < page.highlights.count - 1 {
                                    onboardingRowDivider
                                }
                            }
                        }
                        .appListCellSurface(cornerRadius: 14)
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.bottom, 12)
        }
        .id(index)
    }

    private var onboardingRowDivider: some View {
        Rectangle()
            .fill(Color("AppBackground").opacity(0.85))
            .frame(height: 1)
            .padding(.leading, 44)
    }

    // MARK: - Footer

    private var footerControls: some View {
        AppCard(padding: 14, elevation: .medium, cached: true) {
            VStack(spacing: 14) {
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Capsule()
                            .fill(
                                index == pageIndex
                                    ? AnyShapeStyle(AppVisualStyle.primaryGradient(start: .leading, end: .trailing))
                                    : AnyShapeStyle(Color("AppTextSecondary").opacity(0.25))
                            )
                            .frame(width: index == pageIndex ? 28 : 8, height: 8)
                            .animation(.spring(response: 0.4, dampingFraction: 0.75), value: pageIndex)
                    }
                }
                .frame(maxWidth: .infinity)

                HStack(spacing: 10) {
                    if pageIndex > 0 {
                        Button("Back") {
                            goBack()
                        }
                        .buttonStyle(SecondaryButtonStyle())
                        .frame(maxWidth: .infinity)
                    }

                    Button(action: advance) {
                        Text(pageIndex == pages.count - 1 ? "Get Started" : "Next")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }

    // MARK: - Actions

    private func goBack() {
        FeedbackManager.lightTap()
        withAnimation(.easeInOut(duration: 0.3)) {
            pageIndex = max(0, pageIndex - 1)
        }
    }

    private func advance() {
        FeedbackManager.lightTap()
        if pageIndex < pages.count - 1 {
            withAnimation(.easeInOut(duration: 0.3)) { pageIndex += 1 }
        } else {
            store.completeOnboarding()
        }
    }
}

// MARK: - Models

private struct OnboardingPage {
    let imageName: String
    let icon: String
    let tag: String
    let headline: String
    let description: String
    let highlights: [(icon: String, text: String)]
}

// MARK: - Components

private struct OnboardingHeroBanner: View {
    let imageName: String
    let tag: String
    let headline: String

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 200)
                .clipped()

            LinearGradient(
                colors: [Color("AppBackground").opacity(0.05), Color("AppBackground").opacity(0.94)],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 8) {
                AppTagChip(text: tag, accent: Color("AppAccent"))
                Text(headline)
                    .font(.title.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
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

private struct OnboardingHighlightRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color("AppAccent"))
                .frame(width: 28, height: 28)
                .background(Color("AppPrimary").opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            Text(text)
                .font(.subheadline)
                .foregroundStyle(Color("AppTextPrimary"))
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 11)
    }
}
