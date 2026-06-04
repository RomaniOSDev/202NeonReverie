import Charts
import Combine
import SwiftUI

struct WeekOverviewView: View {
    @EnvironmentObject private var store: AppDataStore

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                AppSectionHeader(
                    icon: "chart.bar.fill",
                    title: "Week Overview",
                    subtitle: "Your last 7 days at a glance"
                )
                .padding(.horizontal, 4)

                HStack(spacing: 10) {
                    AppStatTile(icon: "checkmark.circle", value: "\(store.tasksCompletedThisWeek)", label: "Tasks Done")
                    AppStatTile(icon: "timer", value: "\(store.focusMinutesThisWeek)", label: "Focus Min", tint: Color("AppPrimary"))
                    AppStatTile(icon: "hand.thumbsup", value: "\(store.habitCheckInsThisWeek)", label: "Habits")
                }

                AppCard {
                    AppMetricRow(
                        icon: "note.text",
                        title: "Daily notes completed",
                        value: "\(store.dailyNotesCompletedThisWeek)"
                    )
                }

                FocusStatsChartView()
            }
            .padding(16)
            .padding(.bottom, 24)
        }
    }
}

struct FocusStatsChartView: View {
    @EnvironmentObject private var store: AppDataStore

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 14) {
                AppSectionHeader(icon: "chart.xyaxis.line", title: "Focus Minutes", subtitle: "Last 7 days")

                let data = store.focusMinutesByDay()
                if data.allSatisfy({ $0.minutes == 0 }) {
                    AppEmptyStateView(
                        icon: "timer",
                        title: "No data yet",
                        message: "Complete focus sessions to see your chart."
                    )
                } else {
                    Chart(data) { item in
                        BarMark(
                            x: .value("Day", item.date, unit: .day),
                            y: .value("Minutes", item.minutes)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color("AppPrimary"), Color("AppAccent")],
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        )
                        .cornerRadius(6)
                    }
                    .chartXAxis {
                        AxisMarks(values: .stride(by: .day)) { _ in
                            AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                                .foregroundStyle(Color("AppTextSecondary").opacity(0.3))
                            AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                                .foregroundStyle(Color("AppTextSecondary"))
                        }
                    }
                    .chartYAxis {
                        AxisMarks { _ in
                            AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                                .foregroundStyle(Color("AppTextSecondary").opacity(0.3))
                            AxisValueLabel()
                                .foregroundStyle(Color("AppTextSecondary"))
                        }
                    }
                    .frame(height: 200)
                }
            }
        }
    }
}
