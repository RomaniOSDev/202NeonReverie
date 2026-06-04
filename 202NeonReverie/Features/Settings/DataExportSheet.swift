import Combine
import SwiftUI

struct DataExportSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: AppDataStore
    @State private var exportURL: URL?

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                ScrollView {
                    VStack(spacing: 16) {
                        AppCard {
                            VStack(alignment: .leading, spacing: 12) {
                                AppSectionHeader(
                                    icon: "square.and.arrow.up",
                                    title: "Export Data",
                                    subtitle: "Local backup only"
                                )
                                Text("Export your data as JSON or CSV. Nothing is sent to a server.")
                                    .font(.subheadline)
                                    .foregroundStyle(Color("AppTextSecondary"))
                            }
                        }

                        exportOptionCell(
                            icon: "doc.text.fill",
                            title: "Export JSON",
                            subtitle: "Structured full backup"
                        ) { exportJSON() }

                        exportOptionCell(
                            icon: "tablecells",
                            title: "Export CSV",
                            subtitle: "Spreadsheet-friendly"
                        ) { exportCSV() }

                        if let exportURL {
                            AppCard {
                                ShareLink(item: exportURL) {
                                    Label("Share File", systemImage: "square.and.arrow.up")
                                        .font(.headline)
                                        .foregroundStyle(Color("AppTextPrimary"))
                                        .frame(maxWidth: .infinity, minHeight: 48)
                                }
                            }
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Export")
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

    private func exportOptionCell(icon: String, title: String, subtitle: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                AppIconBadge(systemName: icon, tint: Color("AppPrimary"), size: 44)
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(Color("AppTextPrimary"))
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(Color("AppTextSecondary"))
            }
            .padding(16)
            .appTopGlow(cornerRadius: 16)
            .appSurface(cornerRadius: 16, elevation: .low)
        }
    }

    private func exportJSON() {
        guard let data = DataExportService.makeJSON(from: store),
              let url = DataExportService.writeTemporaryFile(data: data, filename: "finance_export.json") else { return }
        exportURL = url
        FeedbackManager.mediumImpact()
        FeedbackManager.playSuccessSound()
    }

    private func exportCSV() {
        let csv = DataExportService.makeCSV(from: store)
        guard let url = DataExportService.writeTemporaryCSV(csv, filename: "finance_export.csv") else { return }
        exportURL = url
        FeedbackManager.mediumImpact()
        FeedbackManager.playSuccessSound()
    }
}
