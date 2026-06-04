import Combine
import SwiftUI

struct HabitListCell: View {
    let habit: HabitItem
    let isChecked: Bool
    var animateCheck: Bool = false
    let onToggle: () -> Void
    let onTap: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onToggle) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isChecked ? Color("AppAccent").opacity(0.25) : Color("AppBackground"))
                        .frame(width: 48, height: 48)
                    Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                        .font(.title2)
                        .foregroundStyle(isChecked ? Color("AppAccent") : Color("AppTextSecondary"))
                        .scaleEffect(animateCheck ? 1.12 : 1)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: animateCheck)
                }
            }

            Button(action: onTap) {
                HStack(spacing: 12) {
                    AppIconBadge(systemName: groupIcon, tint: Color("AppPrimary"), size: 40)
                    VStack(alignment: .leading, spacing: 6) {
                        Text(habit.name)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color("AppTextPrimary"))
                        HStack(spacing: 6) {
                            AppTagChip(text: habit.group.rawValue, accent: Color("AppBackground"))
                            AppTagChip(text: habit.frequency.rawValue, accent: Color("AppAccent"))
                        }
                    }
                    Spacer()
                    VStack(spacing: 2) {
                        Image(systemName: "flame.fill")
                            .font(.caption)
                            .foregroundStyle(Color("AppPrimary"))
                        Text("\(habit.streak)")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color("AppTextPrimary"))
                    }
                    .padding(8)
                    .appSurface(cornerRadius: 10, elevation: .flat)
                }
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .appTopGlow(cornerRadius: 16)
        .appListCellSurface(cornerRadius: 16)
    }

    private var groupIcon: String {
        switch habit.group {
        case .morning: return "sunrise.fill"
        case .evening: return "moon.stars.fill"
        case .weekly: return "calendar"
        case .general: return "leaf.fill"
        }
    }
}
