import SwiftUI

struct ContinuousRowLayout: View {
    let months: [MonthData]
    @Binding var selectedDate: Date?
    let onDateTap: (Date) -> Void

    @Environment(AppSettings.self) private var appSettings
    @State private var scrollPosition: Int?

    var body: some View {
        GeometryReader { geometry in
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 0) {
                    ForEach(Array(months.enumerated()), id: \.element.id) { index, month in
                        MonthColumnView(
                            month: month,
                            selectedDate: selectedDate,
                            appSettings: appSettings,
                            onDateTap: onDateTap,
                            height: geometry.size.height,
                            width: geometry.size.width
                        )
                        .id(index)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.paging)
            .scrollPosition(id: $scrollPosition)
        }
        .background(appSettings.pageBackgroundColor)
        .onAppear {
            // Scroll to current month
            let currentMonth = Calendar.current.component(.month, from: Date()) - 1
            scrollPosition = currentMonth
        }
    }
}

struct MonthColumnView: View {
    let month: MonthData
    let selectedDate: Date?
    let appSettings: AppSettings
    let onDateTap: (Date) -> Void
    let height: CGFloat
    let width: CGFloat

    @Environment(CalendarViewModel.self) private var calendarViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Month header
            Text(month.name)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(appSettings.rowHeadingColor)
                .padding(.bottom, 4)
                .padding(.horizontal, 16)

            // Days in vertical list
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 4) {
                    ForEach(month.days) { day in
                        let filteredEvents = appSettings.filterEvents(calendarViewModel.events(for: day.date))
                        DayRowView(
                            day: day,
                            events: filteredEvents,
                            isSelected: isSelected(day.date),
                            appSettings: appSettings,
                            onTap: { onDateTap(day.date) }
                        )
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .frame(width: width)
        .padding(.vertical)
    }

    private func isSelected(_ date: Date) -> Bool {
        guard let selectedDate else { return false }
        return Calendar.current.isDate(date, inSameDayAs: selectedDate)
    }
}

struct DayRowView: View {
    let day: DayData
    let events: [CalendarEvent]
    let isSelected: Bool
    let appSettings: AppSettings
    let onTap: () -> Void
    
    private var isWeekend: Bool { appSettings.isWeekend(weekday: day.weekday) }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Day number and weekday
                VStack(alignment: .center, spacing: 2) {
                    Text(weekdayAbbreviation)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundStyle(isWeekend ? appSettings.columnHeadingColor.opacity(0.7) : appSettings.columnHeadingColor)

                    ZStack {
                        if day.isToday {
                            Circle()
                                .fill(appSettings.todayColor)
                                .frame(width: 32, height: 32)
                        } else if isSelected {
                            Circle()
                                .stroke(appSettings.todayColor, lineWidth: 2)
                                .frame(width: 32, height: 32)
                        }

                        Text("\(day.dayNumber)")
                            .font(.system(.body, design: .rounded))
                            .fontWeight(day.isToday ? .bold : .regular)
                            .foregroundStyle(appSettings.dateLabelColor)
                    }
                    .frame(width: 32, height: 32)
                }
                .frame(width: 40)

                // Events
                if events.isEmpty {
                    Spacer()
                } else {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(events.prefix(3)) { event in
                            EventRowCompact(event: event)
                        }

                        if events.count > 3 {
                            Text("+\(events.count - 3) more")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                    Spacer()
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .fill(appSettings.backgroundColor(isWeekend: isWeekend))
            }
            .overlay {
                if appSettings.showGridlinesRow {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(appSettings.gridlineColor, lineWidth: 1)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var weekdayAbbreviation: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: day.date)
    }
}

#Preview {
    let calendar = Calendar.current
    let months = (1...12).compactMap { month -> MonthData? in
        var components = DateComponents()
        components.year = 2026
        components.month = month
        components.day = 1
        guard let date = calendar.date(from: components) else { return nil }
        return MonthData(date: date, calendar: calendar)
    }

    return NavigationStack {
        ContinuousRowLayout(
            months: months,
            selectedDate: .constant(Date()),
            onDateTap: { _ in }
        )
        .navigationTitle("2026")
    }
    .environment(CalendarViewModel())
    .environment(AppSettings())
}
