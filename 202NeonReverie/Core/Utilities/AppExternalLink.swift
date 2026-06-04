import Foundation

enum AppExternalLink {
    case privacyPolicy
    case termsOfUse

    var urlString: String {
        switch self {
        case .privacyPolicy:
            return "https://neonreverie202.site/privacy/236"
        case .termsOfUse:
            return "https://neonreverie202.site/terms/236"
        }
    }

    var url: URL? {
        URL(string: urlString)
    }

    var settingsTitle: String {
        switch self {
        case .privacyPolicy:
            return "Privacy"
        case .termsOfUse:
            return "Terms"
        }
    }

    var settingsSubtitle: String {
        switch self {
        case .privacyPolicy:
            return "Privacy policy"
        case .termsOfUse:
            return "Terms of use"
        }
    }

    var settingsIcon: String {
        switch self {
        case .privacyPolicy:
            return "hand.raised.fill"
        case .termsOfUse:
            return "doc.text.fill"
        }
    }
}
