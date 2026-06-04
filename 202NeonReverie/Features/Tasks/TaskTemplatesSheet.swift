import Combine
import SwiftUI

struct TaskTemplatesSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: AppDataStore

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                ScrollView {
                    VStack(spacing: 12) {
                        Text("Tap a template to create a pre-filled task instantly.")
                            .font(.subheadline)
                            .foregroundStyle(Color("AppTextSecondary"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.bottom, 4)

                        ForEach(TaskTemplate.builtIn) { template in
                            TemplateListCell(template: template) {
                                store.addTaskFromTemplate(template)
                                dismiss()
                            }
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Task Templates")
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
        }
    }
}
