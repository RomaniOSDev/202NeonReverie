import AudioToolbox
import UIKit

enum FeedbackManager {
    static func lightTap() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func mediumImpact() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    static func successNotification() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    static func warningNotification() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }

    static func playSuccessSound() {
        AudioServicesPlaySystemSound(1057)
    }

    static func playTickSound() {
        AudioServicesPlaySystemSound(1003)
    }

    static func playFocusCompleteSound() {
        AudioServicesPlaySystemSound(1103)
    }

    static func playTaskCompleteVibrate() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
}
