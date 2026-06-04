import Combine
import SwiftUI

struct HabitsView: View {
    @EnvironmentObject private var store: AppDataStore
    @StateObject private var viewModel = HabitsViewModel()
    @State private var checkmarkHabitID: UUID?

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                weekHeader
                groupFilter
                HabitCalendarView()

                if store.habits.isEmpty {
                    AppEmptyStateView(
                        icon: "list.bullet",
                        title: "Track your first habit",
                        message: "Start building your financial habits today!",
                        buttonTitle: "Add Habit",
                        action: { viewModel.showingAddSheet = true }
                    )
                } else if viewModel.filteredHabits(from: store).isEmpty {
                    AppEmptyStateView(
                        icon: "line.3.horizontal.decrease.circle",
                        title: "No habits here",
                        message: "Try another group filter or add a new habit."
                    )
                } else {
                    ForEach(viewModel.filteredHabits(from: store)) { habit in
                        HabitListCell(
                            habit: habit,
                            isChecked: habit.isCompletedToday(),
                            animateCheck: checkmarkHabitID == habit.id,
                            onToggle: {
                                store.toggleHabitCheckIn(id: habit.id)
                                checkmarkHabitID = habit.id
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    checkmarkHabitID = nil
                                }
                            },
                            onTap: {
                                FeedbackManager.lightTap()
                                viewModel.editingHabit = habit
                            }
                        )
                        .contextMenu {
                            Button("Edit") { viewModel.editingHabit = habit }
                            Button("Delete", role: .destructive) { store.deleteHabit(id: habit.id) }
                        }
                    }
                }

                Button {
                    FeedbackManager.lightTap()
                    viewModel.showingAddSheet = true
                } label: {
                    Label("Add Habit", systemImage: "plus.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonStyle())
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
        }
        .sheet(isPresented: $viewModel.showingAddSheet) {
            HabitFormView().environmentObject(store)
        }
        .sheet(item: $viewModel.editingHabit) { habit in
            HabitFormView(existingHabit: habit).environmentObject(store)
        }
    }

    private var groupFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                AppFilterChip(title: "All", isSelected: store.habitGroupFilter == "All") {
                    store.habitGroupFilter = "All"
                }
                ForEach(HabitGroup.allCases) { group in
                    AppFilterChip(title: group.rawValue, isSelected: store.habitGroupFilter == group.rawValue) {
                        store.habitGroupFilter = group.rawValue
                    }
                }
            }
        }
    }

    private var weekHeader: some View {
        AppCard(padding: 12) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(viewModel.weekDates(), id: \.self) { date in
                        VStack(spacing: 6) {
                            Text(viewModel.weekdayLabel(date))
                                .font(.caption2.weight(.medium))
                            Text(viewModel.dayNumber(date))
                                .font(.headline)
                        }
                        .foregroundStyle(viewModel.isToday(date) ? Color("AppTextPrimary") : Color("AppTextSecondary"))
                        .frame(width: 48, height: 58)
                        .background(
                            viewModel.isToday(date)
                                ? AnyShapeStyle(LinearGradient(
                                    colors: [Color("AppPrimary"), Color("AppAccent")],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ))
                                : AnyShapeStyle(Color("AppBackground").opacity(0.55))
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
        }
    }
}
