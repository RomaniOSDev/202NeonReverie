import Combine
import SwiftUI

struct DailyChecklistSection: View {
    @EnvironmentObject private var store: AppDataStore
    @State private var newNoteText = ""

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 14) {
                AppSectionHeader(
                    icon: "sun.max.fill",
                    title: "Today",
                    subtitle: "\(store.todayDailyNotes.filter { $0.isCompleted }.count)/\(store.todayDailyNotes.count) done"
                )

                if store.todayDailyNotes.isEmpty {
                    Text("Add up to 5 quick items for today.")
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                } else {
                    ForEach(store.todayDailyNotes) { note in
                        DailyNoteCell(
                            note: note,
                            onToggle: { store.toggleDailyNote(id: note.id) },
                            onDelete: { store.deleteDailyNote(id: note.id) }
                        )
                    }
                }

                if store.todayDailyNotes.count < 5 {
                    HStack(spacing: 10) {
                        TextField("Quick item for today", text: $newNoteText)
                            .foregroundStyle(Color("AppTextPrimary"))
                            .padding(12)
                            .background(Color("AppBackground").opacity(0.6))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        Button {
                            store.addDailyNote(text: newNoteText)
                            newNoteText = ""
                        } label: {
                            Image(systemName: "plus")
                                .font(.headline)
                                .foregroundStyle(Color("AppTextPrimary"))
                                .frame(width: 44, height: 44)
                                .background(Color("AppPrimary"))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                } else {
                    Label("Maximum 5 items for today", systemImage: "info.circle")
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
            }
        }
    }
}
