import Combine
import SwiftUI

struct TaskListCell: View {
    let task: TaskItem
    var isPulsing: Bool = false
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(priorityStripe)
                    .frame(width: 4)
                    .padding(.vertical, 12)

                HStack(alignment: .top, spacing: 12) {
                    AppIconBadge(
                        systemName: task.completed ? "checkmark.seal.fill" : categoryIcon,
                        tint: task.completed ? Color("AppAccent") : Color("AppPrimary"),
                        size: 44
                    )

                    VStack(alignment: .leading, spacing: 8) {
                        HStack(alignment: .top) {
                            Text(task.title)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Color("AppTextPrimary"))
                                .strikethrough(task.completed)
                                .multilineTextAlignment(.leading)
                            Spacer(minLength: 8)
                            if task.isOverdue && !task.completed {
                                AppTagChip(text: "Overdue", accent: Color("AppPrimary"))
                            }
                        }

                        HStack(spacing: 6) {
                            AppTagChip(text: task.category.rawValue, accent: Color("AppPrimary"))
                            AppTagChip(text: task.priority.rawValue, accent: priorityColor)
                            if task.recurrence != .none {
                                AppTagChip(text: task.recurrence.rawValue, accent: Color("AppAccent"))
                            }
                        }

                        HStack(spacing: 6) {
                            Image(systemName: "calendar")
                                .font(.caption2)
                            Text(task.dueDate, style: .date)
                                .font(.caption)
                        }
                        .foregroundStyle(Color("AppTextSecondary"))
                    }
                }
                .padding(.leading, 12)
                .padding(.trailing, 14)
                .padding(.vertical, 14)
            }
            .appTopGlow(cornerRadius: 16)
            .appListCellSurface(cornerRadius: 16)
            .overlay {
                if isPulsing {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color("AppAccent"), lineWidth: 2)
                }
            }
            .scaleEffect(isPulsing ? 1.008 : 1)
            .animation(.spring(response: 0.35, dampingFraction: 0.7), value: isPulsing)
        }
        .buttonStyle(.plain)
    }

    private var categoryIcon: String {
        switch task.category {
        case .financialPlanning: return "chart.line.uptrend.xyaxis"
        case .budgeting: return "dollarsign.circle"
        case .investment: return "building.columns"
        }
    }

    private var priorityStripe: Color {
        switch task.priority {
        case .high: return Color("AppPrimary")
        case .medium: return Color("AppAccent")
        case .low: return Color("AppTextSecondary")
        }
    }

    private var priorityColor: Color {
        priorityStripe
    }
}
