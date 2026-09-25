import SwiftUI

/// Main year view matching Big Year reference - continuous week rows spanning the entire year
struct BigYearLayout: View {
    let year: Int
    @Binding var selectedDate: Date?
    let onDateTap: (Date) -> Void

    @Environment(CalendarViewModel.self) private var calendarViewModel
    @Environment(AppSettings.self) private var appSettings

    private var calendar: Calendar { appSettings.calendar }
    private let dayColumnWidth: CGFloat = 140
    private let rowHeight: CGFloat = 80

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView([.vertical, .horizontal], showsIndicators: true) {
                LazyVStack(spacing: 0) {
                    ForEach(weeksInYear, id: \.self) { weekStart in
                        WeekRowView(
                            weekStart: weekStart,
                            year: year,
                            selectedDate: selectedDate,
                            onDateTap: onDateTap,
                            dayColumnWidth: dayColumnWidth,
                            rowHeight: rowHeight,
                            appSettings: appSettings
                        )
                        .id(weekStart)
                    }
                }
            }
            .defaultScrollAnchor(.topLeading)
            .background(appSettings.pageBackgroundColor)
            .onChange(of: calendarViewModel.scrollToTodayToken) {
                guard let week = todayWeekStart else { return }
                withAnimation(.easeInOut(duration: 0.3)) {
                    proxy.scrollTo(week, anchor: .center)
                }
            }
        }
    }

    /// Week-row anchor containing today, if today is in the displayed year
    private var todayWeekStart: Date? {
        let today = Date()
        guard calendar.component(.year, from: today) == year else { return nil }
        let target = startOfWeek(for: today)
        return weeksInYear.first { calendar.isDate($0, inSameDayAs: target) }
    }

    /// All weeks that have at least one day in the target year
    private var weeksInYear: [Date] {
        var weeks: [Date] = []

        // Start from the first day of the year
        guard let startOfYear = calendar.date(from: DateComponents(year: year, month: 1, day: 1)),
              let endOfYear = calendar.date(from: DateComponents(year: year, month: 12, day: 31)) else {
            return weeks
        }

        // Find the start of the week containing Jan 1
        var currentWeekStart = startOfWeek(for: startOfYear)

        // Include the previous week if it contains days from last year that show in our view
        if let prevWeek = calendar.date(byAdding: .weekOfYear, value: -1, to: currentWeekStart) {
            currentWeekStart = prevWeek
        }

        while currentWeekStart <= endOfYear {
            weeks.append(currentWeekStart)
            guard let nextWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: currentWeekStart) else {
                break
            }
            currentWeekStart = nextWeek
        }

        return weeks
    }

    private var currentWeekStart: Date? {
        let today = Date()
        guard calendar.component(.year, from: today) == year else { return nil }
        return startOfWeek(for: today)
    }

    private func startOfWeek(for date: Date) -> Date {
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        components.weekday = calendar.firstWeekday
        return calendar.date(from: components) ?? date
    }
}

struct WeekRowView: View {
    let weekStart: Date
    let year: Int
    let selectedDate: Date?
    let onDateTap: (Date) -> Void
    let dayColumnWidth: CGFloat
    let rowHeight: CGFloat
    let appSettings: AppSettings

    @Environment(CalendarViewModel.self) private var calendarViewModel

    private var calendar: Calendar { appSettings.calendar }

    var body: some View {
        ZStack(alignment: .topLeading) {
            // Day cells row
            HStack(spacing: 0) {
                ForEach(Array(daysInWeek.enumerated()), id: \.element) { index, date in
                    let isWeekend = appSettings.isWeekend(date: date)
                    let hasEvents = hasEvents(on: date)
                    DayCellBigYear(
                        date: date,
                        isInYear: calendar.component(.year, from: date) == year,
                        isToday: calendar.isDateInToday(date),
                        isSelected: selectedDate.map { calendar.isDate($0, inSameDayAs: date) } ?? false,
                        showMonthLabel: shouldShowMonthLabel(for: date),
                        isWeekend: isWeekend,
                        hasEvents: hasEvents,
                        appSettings: appSettings,
                        onTap: { onDateTap(date) }
                    )
                    .frame(width: dayColumnWidth, height: rowHeight)
                    .overlay(alignment: .trailing) {
                        if appSettings.showGridlinesBigYear && index < daysInWeek.count - 1 {
                            Rectangle()
                                .fill(appSettings.gridlineColor)
                                .frame(width: 1)
                        }
                    }
                }
            }

            // Event bars overlay
            BigYearEventBarsOverlay(
                daysInWeek: daysInWeek,
                events: eventsForWeek,
                dayColumnWidth: dayColumnWidth,
                rowHeight: rowHeight,
                fontSize: appSettings.eventFontSize
            )
        }
        .frame(height: rowHeight)
        .overlay(alignment: .bottom) {
            if appSettings.showGridlinesBigYear {
                Rectangle()
                    .fill(appSettings.gridlineColor)
                    .frame(height: 1)
            }
        }
    }

    private var daysInWeek: [Date] {
        (0..<7).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: weekStart)
        }
    }

    private var eventsForWeek: [CalendarEvent] {
        let start = calendar.startOfDay(for: weekStart)
        guard let end = calendar.date(byAdding: .day, value: 7, to: start) else { return [] }
        let interval = DateInterval(start: start, end: end)
        return appSettings.filterEvents(calendarViewModel.filteredEvents).filter {
            $0.displayedDayOffsets(in: interval, calendar: calendar) != nil
        }
    }

    private func shouldShowMonthLabel(for date: Date) -> Bool {
        // Show month label on the 1st of each month
        return calendar.component(.day, from: date) == 1
    }
    
    private func hasEvents(on date: Date) -> Bool {
        let events = calendarViewModel.events(for: date)
        return !appSettings.filterEvents(events).isEmpty
    }
}

struct DayCellBigYear: View {
    let date: Date
    let isInYear: Bool
    let isToday: Bool
    let isSelected: Bool
    let showMonthLabel: Bool
    let isWeekend: Bool
    let hasEvents: Bool
    let appSettings: AppSettings
    let onTap: () -> Void

    private var calendar: Calendar { appSettings.calendar }

    var body: some View {
        WobbleTapButton(hasEvents: hasEvents, action: onTap) {
            VStack(alignment: .leading, spacing: 2) {
                // Header: weekday + day number + month label
                HStack(spacing: 4) {
                    Text(weekdayAbbrev)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundStyle(isWeekend ? appSettings.columnHeadingColor.opacity(0.7) : appSettings.columnHeadingColor)

                    Text("\(calendar.component(.day, from: date))")
                        .font(.subheadline)
                        .fontWeight(isToday ? .bold : .regular)
                        .foregroundStyle(isToday ? appSettings.dateLabelColor : (isInYear ? appSettings.dateLabelColor : appSettings.dateLabelColor.opacity(0.3)))

                    if showMonthLabel {
                        Text(monthAbbrev)
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(appSettings.rowHeadingColor)
                    }

                    Spacer()
                }
                .padding(.horizontal, 6)
                .padding(.top, 4)

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(backgroundColor)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }

    private var backgroundColor: Color {
        if isToday {
            return appSettings.todayColor
        } else if isSelected {
            return appSettings.todayColor.opacity(0.1)
        } else if !isInYear {
            // Days outside the current year - weekend shading takes priority
            return appSettings.unusedCellBackgroundColor(forWeekday: calendar.component(.weekday, from: date))
        } else {
            return appSettings.backgroundColor(isWeekend: isWeekend)
        }
    }

    private var weekdayAbbrev: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date).uppercased()
    }

    private var monthAbbrev: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter.string(from: date).uppercased()
    }

    private var accessibilityLabel: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        var label = formatter.string(from: date)
        if isToday {
            label = "Today, " + label
        }
        return label
    }
}

struct BigYearEventBarsOverlay: View {
    let daysInWeek: [Date]
    let events: [CalendarEvent]
    let dayColumnWidth: CGFloat
    let rowHeight: CGFloat

    let fontSize: Double

    private var barHeight: CGFloat { EventBarMetrics(fontSize: CGFloat(fontSize), cellHeight: rowHeight).barHeight }
    private let barSpacing: CGFloat = 2
    private let topOffset: CGFloat = 24

    private let calendar = Calendar.current

    var body: some View {
        let layouts = layoutEvents
        let metrics = EventBarMetrics(fontSize: CGFloat(fontSize), cellHeight: rowHeight, topInset: topOffset)
        let capacity = metrics.visibleCapacity(requiredRows: (layouts.map(\.row).max() ?? -1) + 1, cellWidth: dayColumnWidth)
        ZStack(alignment: .topLeading) {
            ForEach(layouts.filter { $0.row < capacity }, id: \.event.id) { eventLayout in
                EventBar(
                    event: eventLayout.event,
                    startOffset: eventLayout.startOffset,
                    width: eventLayout.width,
                    rowIndex: eventLayout.row,
                    barHeight: barHeight,
                    topOffset: topOffset,
                    barSpacing: barSpacing,
                    fontSize: CGFloat(fontSize)
                )
            }
            ForEach(Array(daysInWeek.enumerated()), id: \.element) { column, day in
                let dayStart = calendar.startOfDay(for: day)
                let count = layouts.filter { layout in
                    let interval = layout.event.displayedDayInterval(calendar: calendar)
                    return layout.row >= capacity && interval.start <= dayStart && dayStart < interval.end
                }.count
                if count > 0 {
                    EventOverflowIndicator(count: count, cellSize: CGSize(width: dayColumnWidth, height: rowHeight))
                        .offset(x: CGFloat(column) * dayColumnWidth)
                }
            }
        }
        .frame(width: CGFloat(daysInWeek.count) * dayColumnWidth, height: rowHeight, alignment: .topLeading)
    }

    var layoutEvents: [EventLayout] {
        var layouts: [EventLayout] = []
        var rowOccupancy: [[Bool]] = [] // Track which columns are occupied in each row

        let sortedEvents = events.sorted { e1, e2 in
            if e1.startDate != e2.startDate {
                return e1.startDate < e2.startDate
            }
            if e1.duration != e2.duration { return e1.duration > e2.duration }
            return e1.id < e2.id
        }

        guard let firstDay = daysInWeek.first, let lastDay = daysInWeek.last,
              let end = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: lastDay)) else { return [] }
        let interval = DateInterval(start: calendar.startOfDay(for: firstDay), end: end)

        for event in sortedEvents {
            guard let placement = event.displayedDayOffsets(in: interval, calendar: calendar) else { continue }
            let startCol = placement.start
            let endCol = startCol + placement.span - 1
            guard startCol >= 0 && endCol < daysInWeek.count else { continue }

            // Find first row where this event fits
            var row = 0
            while true {
                if row >= rowOccupancy.count {
                    rowOccupancy.append(Array(repeating: false, count: daysInWeek.count))
                }

                let canFit = (startCol...endCol).allSatisfy { !rowOccupancy[row][$0] }
                if canFit {
                    // Mark columns as occupied
                    for col in startCol...endCol {
                        rowOccupancy[row][col] = true
                    }
                    break
                }
                row += 1
            }

            let startOffset = CGFloat(startCol) * dayColumnWidth
            let width = CGFloat(endCol - startCol + 1) * dayColumnWidth - 4

            layouts.append(EventLayout(
                event: event,
                startOffset: startOffset + 2,
                width: width,
                row: row
            ))
        }

        return layouts
    }
}

struct EventLayout {
    let event: CalendarEvent
    let startOffset: CGFloat
    let width: CGFloat
    let row: Int
}

struct EventBar: View {
    let event: CalendarEvent
    let startOffset: CGFloat
    let width: CGFloat
    let rowIndex: Int
    let barHeight: CGFloat
    let topOffset: CGFloat
    let barSpacing: CGFloat
    let fontSize: CGFloat

    var body: some View {
        Text(fontSize <= 1 ? "" : event.title)
            .font(.system(size: fontSize))
            .fontWeight(.medium)
            .foregroundStyle(event.calendarColor.contrastingTextColor)
            .lineLimit(1)
            .padding(.horizontal, 6)
            .frame(width: width, height: barHeight, alignment: .leading)
            .background(event.calendarColor, in: RoundedRectangle(cornerRadius: min(4, barHeight / 2)))
            .clipped()
            .accessibilityLabel(event.title)
            .allowsHitTesting(false)
            .offset(
                x: startOffset,
                y: topOffset + CGFloat(rowIndex) * (barHeight + barSpacing)
            )
    }
}

#Preview {
    NavigationStack {
        BigYearLayout(
            year: 2026,
            selectedDate: .constant(Date()),
            onDateTap: { _ in }
        )
        .navigationTitle("2026")
    }
    .environment(CalendarViewModel())
    .environment(AppSettings())
}
