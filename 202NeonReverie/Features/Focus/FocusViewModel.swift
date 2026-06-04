import Combine
import Foundation
import SwiftUI

@MainActor
final class FocusViewModel: ObservableObject {
    enum SessionPhase {
        case idle
        case running
        case paused
    }

    @Published var sessionType: FocusSessionType = .work
    @Published var phase: SessionPhase = .idle
    @Published var remainingSeconds: Int = 1500
    @Published var endDate: Date?
    @Published var isActiveScene = true

    private var tickTimer: Timer?

    func configure(store: AppDataStore) {
        remainingSeconds = sessionType == .work ? store.workDurationSec : store.breakDurationSec
    }

    func duration(for type: FocusSessionType, store: AppDataStore) -> Int {
        type == .work ? store.workDurationSec : store.breakDurationSec
    }

    func setSessionType(_ type: FocusSessionType, store: AppDataStore) {
        guard phase == .idle else { return }
        sessionType = type
        remainingSeconds = duration(for: type, store: store)
    }

    func start(store: AppDataStore) {
        guard phase == .idle || phase == .paused else { return }
        let total = duration(for: sessionType, store: store)
        if phase == .idle {
            remainingSeconds = total
        }
        endDate = Date().addingTimeInterval(TimeInterval(remainingSeconds))
        phase = .running
        FeedbackManager.mediumImpact()
        startTicking()
    }

    func stop(store: AppDataStore) {
        tickTimer?.invalidate()
        tickTimer = nil
        phase = .idle
        endDate = nil
        remainingSeconds = duration(for: sessionType, store: store)
        FeedbackManager.lightTap()
    }

    func completeSession(store: AppDataStore) {
        guard phase == .running else { return }
        let completedType = sessionType
        let sessionDuration = duration(for: completedType, store: store)
        store.completeFocusSession(type: completedType, durationSeconds: sessionDuration)
        tickTimer?.invalidate()
        tickTimer = nil
        phase = .idle
        endDate = nil
        if completedType == .work && store.autoWorkBreakTransition {
            sessionType = .breakTime
            remainingSeconds = duration(for: .breakTime, store: store)
            if store.autoStartBreakSession {
                start(store: store)
            }
        } else {
            sessionType = completedType == .work ? .breakTime : .work
            remainingSeconds = duration(for: sessionType, store: store)
        }
    }

    func pauseForBackground() {
        guard phase == .running, let end = endDate else { return }
        remainingSeconds = max(0, Int(end.timeIntervalSinceNow))
        tickTimer?.invalidate()
        tickTimer = nil
        phase = .paused
        endDate = nil
    }

    func resumeIfNeeded(store: AppDataStore) {
        guard phase == .paused, isActiveScene, remainingSeconds > 0 else { return }
        endDate = Date().addingTimeInterval(TimeInterval(remainingSeconds))
        phase = .running
        startTicking()
    }

    func updateRemainingFromTimeline() {
        guard phase == .running, let end = endDate else { return }
        remainingSeconds = max(0, Int(ceil(end.timeIntervalSinceNow)))
        if remainingSeconds <= 0 {
            remainingSeconds = 0
        }
    }

    func progress(store: AppDataStore) -> Double {
        let total = Double(duration(for: sessionType, store: store))
        guard total > 0 else { return 0 }
        return 1 - Double(remainingSeconds) / total
    }

    func formattedTime(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }

    private func startTicking() {
        tickTimer?.invalidate()
        tickTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tick()
            }
        }
    }

    private func tick() {
        updateRemainingFromTimeline()
        if remainingSeconds <= 0 {
            // completion handled by view observing
        }
    }
}
