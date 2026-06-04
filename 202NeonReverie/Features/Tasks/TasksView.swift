import Combine
import SwiftUI

struct TasksView: View {
    @EnvironmentObject private var store: AppDataStore
    @StateObject private var viewModel = TasksViewModel()
    @State private var showSuccessCheck = false

    private let filterOptions = ["All", "Active", "Completed"]
    private let sortOptions = ["Due Date", "Priority", "Title"]

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                VStack(spacing: 0) {
                    searchAndFilters

                    List {
                        Section {
                            DailyChecklistSection()
                                .appListCellInsets()
                        }
                        Section {
                            ProgressGoalsSection()
                                .appListCellInsets()
                        }
                        if viewModel.filteredTasks(from: store).isEmpty {
                            Section {
                                AppEmptyStateView(
                                    icon: "checklist",
                                    title: "No tasks added yet",
                                    message: "Tap + to add your first financial task or use a template.",
                                    buttonTitle: "Templates",
                                    action: { viewModel.showingTemplates = true }
                                )
                                .appListCellInsets()
                            }
                        } else {
                            Section {
                                ForEach(viewModel.filteredTasks(from: store)) { task in
                                    TaskListCell(
                                        task: task,
                                        isPulsing: viewModel.successPulseID == task.id,
                                        onTap: {
                                            FeedbackManager.lightTap()
                                            viewModel.editingTask = task
                                        }
                                    )
                                    .appListCellInsets()
                                    .swipeActions(edge: .leading) {
                                        Button {
                                            store.toggleTaskCompletion(id: task.id)
                                            viewModel.successPulseID = task.id
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                showSuccessCheck = true
                                            }
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                                showSuccessCheck = false
                                                viewModel.successPulseID = nil
                                            }
                                        } label: {
                                            Label(task.completed ? "Undo" : "Done", systemImage: "checkmark")
                                        }
                                        .tint(Color("AppPrimary"))
                                    }
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button(role: .destructive) {
                                            store.deleteTask(id: task.id)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .listStyle(.plain)

                    bottomSortBar
                }
                .successCheckmark(trigger: $showSuccessCheck)
            }
            .navigationTitle("Tasks")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    AppToolbarIconButton(systemName: "doc.on.doc", tint: Color("AppAccent")) {
                        viewModel.showingTemplates = true
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    AppToolbarIconButton(systemName: "plus") {
                        viewModel.showingAddSheet = true
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingAddSheet) {
                TaskFormView().environmentObject(store)
            }
            .sheet(item: $viewModel.editingTask) { task in
                TaskFormView(existingTask: task).environmentObject(store)
            }
            .sheet(isPresented: $viewModel.showingTemplates) {
                TaskTemplatesSheet().environmentObject(store)
            }
        }
    }

    private var searchAndFilters: some View {
        VStack(spacing: 10) {
            AppSearchField(placeholder: "Search tasks", text: $store.taskSearchQuery)
                .padding(.horizontal, 16)
                .padding(.top, 8)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(filterOptions, id: \.self) { option in
                        AppFilterChip(title: option, isSelected: store.filterStatus == option) {
                            store.filterStatus = option
                        }
                    }
                }
                .padding(.horizontal, 16)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    AppFilterChip(title: "All Categories", isSelected: store.taskCategoryFilter == "All") {
                        store.taskCategoryFilter = "All"
                    }
                    ForEach(TaskCategory.allCases) { cat in
                        AppFilterChip(title: cat.rawValue, isSelected: store.taskCategoryFilter == cat.rawValue) {
                            store.taskCategoryFilter = cat.rawValue
                        }
                    }
                    AppFilterChip(title: "Overdue", isSelected: store.showOverdueOnly) {
                        store.showOverdueOnly.toggle()
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.bottom, 6)
        }
    }

    private var bottomSortBar: some View {
        HStack {
            Image(systemName: "arrow.up.arrow.down")
                .foregroundStyle(Color("AppAccent"))
            Text("Sort")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Color("AppTextSecondary"))
            Picker("Sort", selection: $store.taskSortOrder) {
                ForEach(sortOptions, id: \.self) { option in
                    Text(option).tag(option)
                }
            }
            .pickerStyle(.menu)
            .tint(Color("AppPrimary"))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .appTopGlow(cornerRadius: 0)
        .background(AppVisualStyle.surfaceGradient())
        .overlay(alignment: .top) {
            Rectangle()
                .fill(AppVisualStyle.borderGradient())
                .frame(height: 1)
        }
        .shadow(color: AppVisualStyle.shadowColor, radius: 8, x: 0, y: -2)
    }
}
