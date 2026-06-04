import Combine
import SwiftUI

struct FocusSessionCell: View {
    let session: FocusSessionRecord

    var body: some View {
        HStack(spacing: 14) {
            AppIconBadge(
                systemName: session.type == .work ? "briefcase.fill" : "cup.and.saucer.fill",
                tint: session.type == .work ? Color("AppPrimary") : Color("AppAccent"),
                size: 44
            )
            VStack(alignment: .leading, spacing: 4) {
                Text(session.type.rawValue)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color("AppTextPrimary"))
                if let title = session.linkedTaskTitle, !title.isEmpty {
                    Text(title)
                        .font(.caption)
                        .foregroundStyle(Color("AppAccent"))
                        .lineLimit(1)
                }
                Text(session.completedAt, style: .date)
                    .font(.caption2)
                    .foregroundStyle(Color("AppTextSecondary"))
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(session.durationSeconds / 60)")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Color("AppTextPrimary"))
                Text("min")
                    .font(.caption2)
                    .foregroundStyle(Color("AppTextSecondary"))
            }
        }
        .padding(14)
        .appTopGlow(cornerRadius: 14)
        .appListCellSurface(cornerRadius: 14)
    }
}
