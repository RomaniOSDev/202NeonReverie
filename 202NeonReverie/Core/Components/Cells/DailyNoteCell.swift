import Combine
import SwiftUI

struct DailyNoteCell: View {
    let note: DailyNoteItem
    let onToggle: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onToggle) {
                Image(systemName: note.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(note.isCompleted ? Color("AppAccent") : Color("AppTextSecondary"))
                    .frame(width: 44, height: 44)
            }
            Text(note.text)
                .font(.subheadline)
                .foregroundStyle(Color("AppTextPrimary"))
                .strikethrough(note.isCompleted)
                .frame(maxWidth: .infinity, alignment: .leading)
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .frame(width: 44, height: 44)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .appSurface(cornerRadius: 12, elevation: .flat, bordered: true)
    }
}
