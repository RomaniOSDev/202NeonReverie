import Combine
import SwiftUI

struct RootView: View {
    @EnvironmentObject private var store: AppDataStore

    var body: some View {
        Group {
            if store.hasSeenOnboarding {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
        .preferredColorScheme(.dark)
    }
}
