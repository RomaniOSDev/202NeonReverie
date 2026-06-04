import Combine
import SwiftUI

struct GoalProgressCell: View {
    let goal: ProgressGoal
    let onIncrement: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                AppIconBadge(systemName: "flag.fill", tint: Color("AppPrimary"), size: 36)
                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color("AppTextPrimary"))
                    Text("\(Int(goal.progress * 100))% complete")
                        .font(.caption)
                        .foregroundStyle(Color("AppTextSecondary"))
                }
                Spacer()
                Text("\(goal.currentSteps)/\(goal.targetSteps)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color("AppAccent"))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color("AppBackground"))
                    .clipShape(Capsule())
            }

            AppProgressBar(progress: goal.progress)

            HStack(spacing: 12) {
                Button(action: onIncrement) {
                    Label("Add Step", systemImage: "plus")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color("AppTextPrimary"))
                        .frame(maxWidth: .infinity, minHeight: 40)
                        .background(Color("AppPrimary"))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundStyle(Color("AppTextSecondary"))
                        .frame(width: 44, height: 40)
                        .background(Color("AppBackground"))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
        .padding(14)
        .appTopGlow(cornerRadius: 14)
        .appSurface(cornerRadius: 14, elevation: .low)
    }
}
