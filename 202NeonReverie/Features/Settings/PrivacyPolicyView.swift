import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var markdownContent = ""

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                ScrollView {
                    if let attributed = try? AttributedString(markdown: markdownContent) {
                        Text(attributed)
                            .foregroundStyle(Color("AppTextPrimary"))
                            .tint(Color("AppPrimary"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(16)
                    } else {
                        Text(markdownContent)
                            .foregroundStyle(Color("AppTextPrimary"))
                            .padding(16)
                    }
                }
            }
            .navigationTitle("Privacy Policy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") {
                        FeedbackManager.lightTap()
                        dismiss()
                    }
                    .foregroundStyle(Color("AppPrimary"))
                }
            }
            .onAppear {
                markdownContent = Self.loadPolicyText()
            }
        }
    }

    private static func loadPolicyText() -> String {
        if let url = Bundle.main.url(forResource: "privacy_policy", withExtension: "md"),
           let text = try? String(contentsOf: url, encoding: .utf8) {
            return text
        }
        return "# Privacy Policy\nThis app does NOT collect, store, or transmit any personal data."
    }
}
