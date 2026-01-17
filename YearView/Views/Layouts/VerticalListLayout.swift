import SwiftUI

struct VerticalListLayout: View {
    let months: [MonthData]
    @Binding var selectedDate: Date?
    let onDateTap: (Date) -> Void

    @Environment(AppSettings.self) private var appSettings
    @State private var scrollPosition: Int?

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            LazyVStack(spacing: 32, pinnedViews: [.sectionHeaders]) {
                ForEach(Array(months.enumerated()), id: \.element.id) { index, month in
                    Section {
                        MonthListView(
                            month: month,
                            selectedDate: selectedDate,
                            appSettings: appSettings,
                            onDateTap: onDateTap
                        )
                    } header: {
                        MonthSectionHeader(month: month, appSettings: appSettings)
                    }
                    .id(index)
                }
            }
            .padding(.horizontal)
            .scrollTargetLayout()
        }
        .scrollPosition(id: $scrollPosition)
        .background(appSettings.pageBackgroundColor)
        .onAppear {
            // Scroll to current month
            let currentMonth = Calendar.current.component(.month, from: Date()) - 1
            scrollPosition = currentMonth
        }
    }
}

struct MonthSectionHeader: View {
    let month: MonthData
    let appSettings: AppSettings

    var body: some View {
        HStack {
            Text(month.name)
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(appSettings.rowHeadingColor)

            Spacer()
        }
        .padding(.vertical, 12)
        .padding(.horizontal)
        .background(.ultraThinMaterial)
    }
}

struct MonthListView: View {
    let month: MonthData
    let selectedDate: Date?
    let appSettings: AppSettings
    let onDateTap: (Date) -> Void

    @Environment(CalendarViewModel.self) private var calendarViewModel

    var body: some View {
        VStack(spacing: 0) {
            // Horizontal day strip for each week
            ForEach(month.weeks.indices, id: \.self) { weekIndex in
                WeekStripView(
                    days: month.weeks[weekIndex],
                    weekdayNumbers: month.weekdayNumbers,
                    selectedDate: selectedDate,
                    appSettings: appSettings,
                    onDateTap: onDateTap
                )

                if weekIndex < month.weeks.count - 1 {
                    if appSettings.showGridlinesList {
                        Rectangle()
                            .fill(appSettings.gridlineColor)
                            .frame(height: 1)
                            .padding(.vertical, 8)
                    } else {
                        Divider()
                            .padding(.vertical, 8)
                    }
                }
            }
        }
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.background)
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .overlay {
            if appSettings.showGridlinesList {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(appSettings.gridlineColor, lineWidth: 1)
            }
        }
    }
}

struct WeekStripView: View {
    let days: [DayData?]
    let weekdayNumbers: [Int]
    let selectedDate: Date?
    let appSettings: AppSettings
    let onDateTap: (Date) -> Void

    @Environment(CalendarViewModel.self) private var calendarViewModel

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<7, id: \.self) { index in
                if let day = days[index] {
                    DayStripCell(
                        day: day,
                        isSelected: isSelected(day.date),
                        eventColors: filteredEventColors(for: day.date),
                        appSettings: appSettings,
                        onTap: { onDateTap(day.date) }
                    )
                } else {
                    // Unused cell - weekend shading takes priority
                    let weekday = weekdayNumbers.indices.contains(index) ? weekdayNumbers[index] : (index + 1)
                    appSettings.unusedCellBackgroundColor(forWeekday: weekday)
                        .frame(maxWidth: .infinity)
                        .aspectRatio(1, contentMode: .fit)
                        .clipShape(Circle())
                }
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

struct DayStripCell: View {
    let day: DayData
    let isSelected: Bool
    let eventColors: [Color]
    let appSettings: AppSettings
    let onTap: () -> Void
    
    private var isWeekend: Bool { appSettings.isWeekend(weekday: day.weekday) }

    var body: some View {
        WobbleTapButton(hasEvents: !eventColors.isEmpty, action: onTap) {
            VStack(spacing: 4) {
                // Weekday
                Text(weekdayAbbreviation)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundStyle(isWeekend ? appSettings.columnHeadingColor.opacity(0.7) : appSettings.columnHeadingColor)

                // Day number
                ZStack {
                    if day.isToday {
                        Circle()
                            .fill(appSettings.todayColor)
                    } else if isSelected {
                        Circle()
                            .stroke(appSettings.todayColor, lineWidth: 2)
                    } else {
                        Circle()
                            .fill(appSettings.backgroundColor(isWeekend: isWeekend))
                    }

                    Text("\(day.dayNumber)")
                        .font(.system(.callout, design: .rounded))
                        .fontWeight(day.isToday ? .bold : .regular)
                        .foregroundStyle(appSettings.dateLabelColor)
                }
                .frame(width: 36, height: 36)

                // Event indicators
                HStack(spacing: 2) {
                    ForEach(eventColors.prefix(3), id: \.self) { color in
                        Circle()
                            .fill(color)
                            .frame(width: 5, height: 5)
                    }
                }
                .frame(height: 8)
            }
            .frame(maxWidth: .infinity)
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
        VerticalListLayout(
            months: months,
            selectedDate: .constant(Date()),
            onDateTap: { _ in }
        )
        .navigationTitle("2026")
    }
    .environment(CalendarViewModel())
    .environment(AppSettings())
}
