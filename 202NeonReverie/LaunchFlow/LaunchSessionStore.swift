//
//  LaunchSessionStore.swift
//  157Countdown
//

import Foundation

/// Launch-flow persistence (`LastUrl`, native shell flag, validated web entry).
final class LaunchSessionStore {
    static let shared = LaunchSessionStore()

    private let defaults = UserDefaults.standard
    private var lastURLKey: String { LaunchFlowSecrets.persistedNavigationURLKey }
    private var nativeShellKey: String { LaunchFlowSecrets.nativeShellPresentedKey }
    private var validatedWebKey: String { LaunchFlowSecrets.validatedWebEntryKey }

    /// Persisted document URL after validated WebView load (`LastUrl`).
    var savedLastURL: URL? {
        get {
            if let url = defaults.url(forKey: lastURLKey) {
                return url
            }
            if let legacy = defaults.string(forKey: lastURLKey),
               let url = URL(string: legacy) {
                defaults.set(url, forKey: lastURLKey)
                return url
            }
            return nil
        }
        set {
            defaults.set(newValue, forKey: lastURLKey)
        }
    }

    var hasShownNativeShell: Bool {
        get { defaults.bool(forKey: nativeShellKey) }
        set { defaults.set(newValue, forKey: nativeShellKey) }
    }

    /// Set only after WebView content passes validation (non-empty body, meaningful text).
    var hasValidatedWebEntry: Bool {
        get { defaults.bool(forKey: validatedWebKey) }
        set { defaults.set(newValue, forKey: validatedWebKey) }
    }

    func markWebEntryValidated(url: URL) {
        savedLastURL = url
        hasValidatedWebEntry = true
    }

    func clearWebEntryState() {
        savedLastURL = nil
        hasValidatedWebEntry = false
    }

    /// Drops legacy URLs saved before content validation existed.
    func reconcileLegacyWebPersistence() {
        if savedLastURL != nil && !hasValidatedWebEntry {
            clearWebEntryState()
        }
    }

    private init() {}
}
