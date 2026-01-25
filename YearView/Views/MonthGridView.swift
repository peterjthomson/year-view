import SwiftUI

struct MonthGridView: View {
    let month: MonthData
    let selectedDate: Date?
    let appSettings: AppSettings
    let onDateTap: (Date) -> Void

    @Environment(CalendarViewModel.self) private var calendarViewModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 7)
    
    /// Use collapsed weeks to avoid single-day weeks at month boundaries
    private var displayWeeks: [[DayData?]] {
        month.collapsedWeeks
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Month header - use short name on compact displays to avoid line breaks
            Text(horizontalSizeClass == .compact ? month.shortName : month.name)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(appSettings.rowHeadingColor)
                .accessibilityAddTraits(.isHeader)

            // Weekday headers - use the ordered headers from MonthData
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(Array(month.weekdayHeaders.enumerated()), id: \.offset) { index, header in
                    let weekdayNum = month.weekdayNumbers[index]
                    let isWeekendColumn = appSettings.isWeekend(weekday: weekdayNum)
                    Text(header)
                        .font(.system(size: 8, weight: .medium, design: .rounded))
                        .foregroundStyle(isWeekendColumn ? appSettings.columnHeadingColor.opacity(0.7) : appSettings.columnHeadingColor)
                        .frame(maxWidth: .infinity)
                }
            }

            // Calendar grid
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(displayWeeks.indices, id: \.self) { weekIndex in
                    ForEach(0..<7, id: \.self) { dayIndex in
                        if let day = displayWeeks[weekIndex][dayIndex] {
                            DayCell(
                                day: day,
                                isSelected: isSelected(day.date),
                                eventColors: filteredEventColors(for: day.date),
                                appSettings: appSettings,
                                onTap: { onDateTap(day.date) }
                            )
                        } else {
                            Color.clear
                                .aspectRatio(1, contentMode: .fit)
                        }
                    }
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.background)
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .overlay {
            if appSettings.showGridlinesGrid {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(appSettings.gridlineColor, lineWidth: 1)
            }
        }
    }

    private func isSelected(_ date: Date) -> Bool {
        guard let selectedDate else { return false }
        return Calendar.current.isDate(date, inSameDayAs: selectedDate)
    }
    
    private func filteredEventColors(for date: Date) -> [Color] {
        let dayEvents = calendarViewModel.events(for: date)
        let filtered = appSettings.filterEvents(dayEvents)
        var colors: [Color] = []
        var seenCalendarIDs: Set<String> = []
        
        for event in filtered {
            if !seenCalendarIDs.contains(event.calendarID) && colors.count < 3 {
                colors.append(event.calendarColor)
                seenCalendarIDs.insert(event.calendarID)
            }
        }
        
        return colors
    }
}

struct CompactMonthGridView: View {
    let month: MonthData
    let selectedDate: Date?
    let onDateTap: (Date) -> Void

    @Environment(CalendarViewModel.self) private var calendarViewModel

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 1), count: 7)

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(month.shortName)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)

            LazyVGrid(columns: columns, spacing: 1) {
                ForEach(month.weeks.indices, id: \.self) { weekIndex in
                    ForEach(0..<7, id: \.self) { dayIndex in
                        if let day = month.weeks[weekIndex][dayIndex] {
                            CompactDayCell(
                                day: day,
                                hasEvents: calendarViewModel.hasEvents(on: day.date),
                                eventColor: calendarViewModel.eventColors(for: day.date).first,
                                onTap: { onDateTap(day.date) }
                            )
                        } else {
                            Color.clear
                                .frame(width: 16, height: 16)
                        }
                    }
                }
            }
        }
        .padding(8)
    }
}

#Preview("Standard Month Grid") {
    let calendar = Calendar.current
    var components = DateComponents()
    components.year = 2026
    components.month = 1
    components.day = 1
    let date = calendar.date(from: components)!

    return MonthGridView(
        month: MonthData(date: date, calendar: calendar),
        selectedDate: Date(),
        appSettings: AppSettings(),
        onDateTap: { _ in }
    )
    .environment(CalendarViewModel())
    .padding()
}

#Preview("Compact Month Grid") {
    let calendar = Calendar.current
    var components = DateComponents()
    components.year = 2026
    components.month = 1
    components.day = 1
    let date = calendar.date(from: components)!

    return CompactMonthGridView(
        month: MonthData(date: date, calendar: calendar),
        selectedDate: Date(),
        onDateTap: { _ in }
    )
    .environment(CalendarViewModel())
    .environment(AppSettings())
    .padding()
}
