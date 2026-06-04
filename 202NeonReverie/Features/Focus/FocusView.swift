import Combine
import SwiftUI

struct FocusView: View {
    @EnvironmentObject private var store: AppDataStore
    @StateObject private var viewModel = FocusViewModel()
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                timerHeroCard
                setupCards
                controlButton
                historySection
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
        .onAppear { viewModel.configure(store: store) }
        .onChange(of: scenePhase) { phase in
            viewModel.isActiveScene = phase == .active
            if phase != .active {
                viewModel.pauseForBackground()
            } else {
                viewModel.resumeIfNeeded(store: store)
            }
        }
    }

    private var timerHeroCard: some View {
        AppCard(cached: true) {
            VStack(spacing: 16) {
                HStack {
                    AppTagChip(
                        text: viewModel.sessionType == .work ? "Work Session" : "Break Session",
                        accent: viewModel.sessionType == .work ? Color("AppPrimary") : Color("AppAccent")
                    )
                    Spacer()
                    if viewModel.phase == .running {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color("AppAccent"))
                                .frame(width: 8, height: 8)
                            Text("Live")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(Color("AppAccent"))
                        }
                    }
                }

                if store.focusSessionsCompleted == 0 && viewModel.phase == .idle {
                    AppEmptyStateView(
                        icon: "timer",
                        title: "Ready to focus",
                        message: "Start your first focus session below."
                    )
                } else {
                    TimelineView(.periodic(from: .now, by: 1)) { context in
                        timerRing
                            .onChange(of: context.date) { _ in handleTimelineTick() }
                    }
                }
            }
        }
    }

    private var setupCards: some View {
        VStack(spacing: 12) {
            AppCard {
                VStack(alignment: .leading, spacing: 12) {
                    AppSectionHeader(icon: "link", title: "Linked Task", subtitle: "Track what you work on")
                    Picker("Task", selection: Binding(
                        get: { store.linkedFocusTaskId },
                        set: { store.linkedFocusTaskId = $0 }
                    )) {
                        Text("None").tag(Optional<UUID>.none)
                        ForEach(store.tasks.filter { !$0.completed }) { task in
                            Text(task.title).tag(Optional(task.id))
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(Color("AppAccent"))
                    .disabled(viewModel.phase != .idle)
                }
            }

            AppCard {
                VStack(alignment: .leading, spacing: 12) {
                    AppSectionHeader(icon: "bolt.fill", title: "Presets", subtitle: "One-tap durations")
                    HStack(spacing: 8) {
                        ForEach(FocusPreset.builtIn) { preset in
                            Button {
                                store.applyFocusPreset(preset)
                                viewModel.configure(store: store)
                            } label: {
                                VStack(spacing: 4) {
                                    Text(preset.name)
                                        .font(.caption.weight(.bold))
                                    Text("\(preset.workMinutes)m")
                                        .font(.caption2)
                                }
                                .foregroundStyle(Color("AppTextPrimary"))
                                .frame(maxWidth: .infinity, minHeight: 52)
                                .appSurface(cornerRadius: 10, elevation: .flat)
                            }
                            .disabled(viewModel.phase != .idle)
                        }
                    }
                }
            }

            AppCard {
                HStack(spacing: 12) {
                    sessionTypeButton(.work, store: store)
                    sessionTypeButton(.breakTime, store: store)
                }
            }

            if viewModel.phase == .idle {
                AppCard {
                    VStack(alignment: .leading, spacing: 14) {
                        AppSectionHeader(icon: "slider.horizontal.3", title: "Durations")
                        durationSlider(title: "Work", value: Binding(
                            get: { Double(store.workDurationSec) / 60 },
                            set: { store.workDurationSec = Int($0) * 60; viewModel.configure(store: store) }
                        ), range: 5...60, step: 5, tint: Color("AppPrimary"))
                        durationSlider(title: "Break", value: Binding(
                            get: { Double(store.breakDurationSec) / 60 },
                            set: { store.breakDurationSec = Int($0) * 60; viewModel.configure(store: store) }
                        ), range: 1...30, step: 1, tint: Color("AppAccent"))
                    }
                }
            }

            AppCard {
                VStack(alignment: .leading, spacing: 10) {
                    AppSectionHeader(icon: "arrow.triangle.2.circlepath", title: "Automation")
                    Toggle("Auto switch Work → Break", isOn: $store.autoWorkBreakTransition)
                        .tint(Color("AppPrimary"))
                    Toggle("Auto-start break session", isOn: $store.autoStartBreakSession)
                        .tint(Color("AppAccent"))
                }
                .font(.subheadline)
                .foregroundStyle(Color("AppTextPrimary"))
            }
        }
    }

    private func sessionTypeButton(_ type: FocusSessionType, store: AppDataStore) -> some View {
        let isWork = type == .work
        let selected = viewModel.sessionType == type
        return Button {
            FeedbackManager.lightTap()
            viewModel.setSessionType(type, store: store)
        } label: {
            VStack(spacing: 6) {
                Image(systemName: isWork ? "briefcase.fill" : "cup.and.saucer.fill")
                    .font(.title3)
                Text(isWork ? "Work" : "Break")
                    .font(.subheadline.weight(.semibold))
                Text("\((isWork ? store.workDurationSec : store.breakDurationSec) / 60) min")
                    .font(.caption)
            }
            .foregroundStyle(selected ? Color("AppTextPrimary") : Color("AppTextSecondary"))
            .frame(maxWidth: .infinity, minHeight: 72)
            .background {
                if selected {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(AppVisualStyle.primaryGradient())
                } else {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color("AppBackground").opacity(0.5))
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(AppVisualStyle.borderGradient(opacity: selected ? 0 : 0.8), lineWidth: 1)
            )
            .shadow(color: selected ? Color("AppPrimary").opacity(0.35) : .clear, radius: 6, y: 3)
        }
        .disabled(viewModel.phase != .idle)
    }

    private func durationSlider(title: String, value: Binding<Double>, range: ClosedRange<Double>, step: Double, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("\(title): \(Int(value.wrappedValue)) min")
                .font(.caption)
                .foregroundStyle(Color("AppTextSecondary"))
            Slider(value: value, in: range, step: step)
                .tint(tint)
        }
    }

    private var timerRing: some View {
        ZStack {
            Circle()
                .stroke(Color("AppBackground"), lineWidth: 16)
                .frame(width: 220, height: 220)
            Circle()
                .trim(from: 0, to: viewModel.progress(store: store))
                .stroke(
                    AppVisualStyle.primaryGradient(start: UnitPoint.top, end: UnitPoint.bottom),
                    style: StrokeStyle(lineWidth: 16, lineCap: .round)
                )
                .shadow(color: Color("AppPrimary").opacity(0.4), radius: 6, x: 0, y: 0)
                .frame(width: 220, height: 220)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.3), value: viewModel.progress(store: store))
            VStack(spacing: 8) {
                Text(viewModel.formattedTime(viewModel.remainingSeconds))
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .foregroundStyle(Color("AppTextPrimary"))
                if let task = store.linkedFocusTask {
                    Text(task.title)
                        .font(.caption)
                        .foregroundStyle(Color("AppAccent"))
                        .lineLimit(1)
                        .padding(.horizontal, 16)
                }
            }
        }
        .padding(.vertical, 8)
    }

    private func handleTimelineTick() {
        guard viewModel.isActiveScene, viewModel.phase == .running else { return }
        viewModel.updateRemainingFromTimeline()
        if viewModel.remainingSeconds <= 0 {
            viewModel.completeSession(store: store)
        }
    }

    private var controlButton: some View {
        Button {
            switch viewModel.phase {
            case .idle, .paused:
                viewModel.start(store: store)
            case .running:
                viewModel.stop(store: store)
            }
        } label: {
            Label(viewModel.phase == .running ? "Stop Session" : "Start Session", systemImage: viewModel.phase == .running ? "stop.fill" : "play.fill")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(PrimaryButtonStyle())
    }

    @ViewBuilder
    private var historySection: some View {
        if !store.focusHistory.isEmpty {
            AppCard {
                VStack(alignment: .leading, spacing: 12) {
                    AppSectionHeader(icon: "clock.arrow.circlepath", title: "Session History", subtitle: "Recent sessions")
                    ForEach(store.focusHistory.prefix(8)) { session in
                        FocusSessionCell(session: session)
                    }
                }
            }
        }
    }
}
