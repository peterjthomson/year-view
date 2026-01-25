import SwiftUI

/// Calendar.app-style year view: each month is one row, displayed as a strip.
/// The start of each month is offset so weekdays align across all months.
/// The total width is trimmed to the last column that contains an actual day.
struct YearMonthRowLayout: View {
    let months: [MonthData]
    @Binding var selectedDate: Date?
    let onDateTap: (Date) -> Void

    @Environment(CalendarViewModel.self) private var calendarViewModel
    @Environment(AppSettings.self) private var appSettings
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private let daysPerWeek = 7
    private let outerPadding: CGFloat = 12
    private let rowSpacing: CGFloat = 0 // Spacing handled by padding/dividers
    private let headerBottomPadding: CGFloat = 8
    private let minCellWidth: CGFloat = 20
    private let floatingPanelHeight: CGFloat = 60 // Height of floating mode panel on mobile
    private let monthRowVerticalPadding: CGFloat = 4
    private let rowDividerHeight: CGFloat = 1
    
    /// Use appSettings calendar for consistent week start
    private var calendar: Calendar { appSettings.calendar }
    
    /// Calculate the minimum number of columns needed to display all months.
    /// This is the maximum of (offset + days_in_month) across all months.
    private var totalColumns: Int {
        var maxExtent = 0
        for month in months {
            guard let firstDay = month.days.first?.date else { continue }
            let firstDayWeekday = calendar.component(.weekday, from: firstDay)
            let offset = (firstDayWeekday - calendar.firstWeekday + 7) % 7
            let extent = offset + month.days.count
            maxExtent = max(maxExtent, extent)
        }
        return maxExtent
    }
    
    /// Returns the weekday number (1-7) for a given column index
    private func weekdayForColumn(_ index: Int) -> Int {
        let columnInWeek = index % 7
        // Map column to absolute weekday (1=Sun, 7=Sat)
        return (calendar.firstWeekday - 1 + columnInWeek) % 7 + 1
    }

    /// Calculate month label width based on format setting
    private var monthLabelWidth: CGFloat {
        appSettings.monthLabelFormat.suggestedWidth
    }
    
    var body: some View {
        GeometryReader { geometry in
            let columns = CGFloat(totalColumns)
            
            // Height sizing: fill vertical space with 12 month rows plus header
            // On mobile, account for floating mode panel that overlays bottom of view
            let isCompactLandscape = horizontalSizeClass == .compact && geometry.size.width > geometry.size.height
            let headerHeight: CGFloat = isCompactLandscape ? 16 : 20
            let headerSpacing: CGFloat = isCompactLandscape ? 4 : headerBottomPadding
            let rowVerticalPadding: CGFloat = isCompactLandscape ? 1 : monthRowVerticalPadding
            let panelInset: CGFloat = horizontalSizeClass == .compact ? floatingPanelHeight : 0
            let chromeHeight = (outerPadding * 2) + headerHeight + headerSpacing + panelInset
            let availableHeight = max(0, geometry.size.height - chromeHeight)
            
            let monthCount = CGFloat(max(1, months.count))
            let dividerCount = CGFloat(max(0, months.count - 1))
            let totalRowPaddingHeight = monthCount * (rowVerticalPadding * 2)
            let totalDividerHeight = dividerCount * rowDividerHeight
            
            // MonthRow's total height is cellHeight + (verticalPadding*2), plus dividers between rows.
            // Solve for cellHeight so all 12 months are visible without vertical clipping.
            let availableCellHeight = max(0, availableHeight - totalRowPaddingHeight - totalDividerHeight)
            let cellHeight = max(0, availableCellHeight / monthCount)

            // Width sizing: fill the available width when possible, otherwise fall back to a minimum and allow scroll.
            let availableGridWidth = max(0, geometry.size.width - (outerPadding * 2) - monthLabelWidth)
            let idealCellWidth = availableGridWidth / columns
            let cellWidth = max(minCellWidth, idealCellWidth)
            
            let cellSize = CGSize(width: cellWidth, height: cellHeight)

            ScrollView(.horizontal, showsIndicators: true) {
                VStack(alignment: .leading, spacing: 0) {
                    weekdayHeader(cellSize: CGSize(width: cellWidth, height: headerHeight), monthLabelWidth: monthLabelWidth)
                        .padding(.bottom, headerSpacing)

                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(Array(months.enumerated()), id: \.element.id) { index, month in
                            MonthRow(
                                month: month,
                                cellSize: cellSize,
                                monthLabelWidth: monthLabelWidth,
                                totalColumns: totalColumns,
                                selectedDate: selectedDate,
                                calendarViewModel: calendarViewModel,
                                appSettings: appSettings,
                                verticalPadding: rowVerticalPadding,
                                onDateTap: onDateTap
                            )
                            
                            if index < months.count - 1 {
                                Divider()
                            }
                        }
                    }
                }
                .padding(outerPadding)
                .frame(minWidth: geometry.size.width, alignment: .topLeading)
            }
            .background(appSettings.pageBackgroundColor)
        }
    }

    @ViewBuilder
    private func weekdayHeader(cellSize: CGSize, monthLabelWidth: CGFloat) -> some View {
        // Get symbols ordered by firstWeekday
        let allSymbols = calendar.veryShortWeekdaySymbols // 0-indexed (0=Sun)
        
        HStack(spacing: 0) {
            Color.clear
                .frame(width: monthLabelWidth, height: cellSize.height)

            ForEach(0..<totalColumns, id: \.self) { index in
                let weekday = weekdayForColumn(index)
                let symbolIndex = weekday - 1 // Convert 1-indexed weekday to 0-indexed symbol
                let isWeekend = appSettings.isWeekend(weekday: weekday)
                
                Text(allSymbols[symbolIndex].uppercased())
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(isWeekend ? appSettings.columnHeadingColor.opacity(0.7) : appSettings.columnHeadingColor)
                    .frame(width: cellSize.width, height: cellSize.height)
            }
        }
    }
}

private struct MonthRow: View {
    let month: MonthData
    let cellSize: CGSize
    let monthLabelWidth: CGFloat
    let totalColumns: Int
    let selectedDate: Date?
    let calendarViewModel: CalendarViewModel
    let appSettings: AppSettings
    let verticalPadding: CGFloat
    let onDateTap: (Date) -> Void

    private var calendar: Calendar { appSettings.calendar }
    
    /// Returns the weekday number (1-7) for a given column index
    private func weekdayForColumn(_ index: Int) -> Int {
        let columnInWeek = index % 7
        return (calendar.firstWeekday - 1 + columnInWeek) % 7 + 1
    }

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            // Month Label - format based on settings
            monthLabel
                .frame(width: monthLabelWidth, alignment: .leading)
                .padding(.vertical, verticalPadding)

            // Grid
            ZStack(alignment: .topLeading) {
                // Cell Backgrounds (weekday/weekend/unused) with gridlines - fill entire row height
                cellBackgrounds
                
                // Days - with vertical padding to center content
                HStack(spacing: 0) {
                    ForEach(paddedDays.indices, id: \.self) { index in
                        MonthRowDayCell(
                            day: paddedDays[index],
                            cellSize: cellSize,
                            isSelected: isSelected(paddedDays[index]?.date),
                            hasEvents: hasEvents(paddedDays[index]),
                            appSettings: appSettings,
                            onTap: { date in onDateTap(date) }
                        )
                    }
                }
                .padding(.vertical, verticalPadding)
                
                if appSettings.showMonthRowEvents {
                    FeaturedEventOverlay(
                        segments: featuredEventSegments,
                        cellSize: cellSize,
                        totalColumns: totalColumns
                    )
                    .padding(.vertical, verticalPadding)
                } else {
                    // Event Bars Overlay
                    EventBarsOverlay(
                        month: month,
                        events: appSettings.filterEvents(calendarViewModel.filteredEvents),
                        cellSize: cellSize,
                        totalColumns: totalColumns,
                        appSettings: appSettings
                    )
                    .padding(.vertical, verticalPadding)
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Month \(month.name)")
    }

    /// Full row height including vertical padding
    private var fullRowHeight: CGFloat {
        cellSize.height + (verticalPadding * 2)
    }
    
    private var cellBackgrounds: some View {
        HStack(spacing: 0) {
            ForEach(0..<totalColumns, id: \.self) { index in
                let weekday = weekdayForColumn(index)
                let isWeekend = appSettings.isWeekend(weekday: weekday)
                let day = paddedDays[index]
                let hasDay = day != nil
                let isToday = day?.isToday == true
                
                Group {
                    if hasDay {
                        if isToday {
                            appSettings.todayColor
                        } else {
                            appSettings.backgroundColor(isWeekend: isWeekend)
                        }
                    } else {
                        // Weekend shading takes priority over unused cell shading
                        appSettings.unusedCellBackgroundColor(forWeekday: weekday)
                    }
                }
                .frame(width: cellSize.width, height: fullRowHeight)
                .overlay(alignment: .trailing) {
                    if appSettings.showGridlinesMonthRows && index < totalColumns - 1 {
                        Rectangle()
                            .fill(appSettings.gridlineColor)
                            .frame(width: 1)
                    }
                }
            }
        }
    }

    /// Creates a flat array of days padded to totalColumns.
    /// The month's first day is placed at the correct weekday offset.
    private var paddedDays: [DayData?] {
        guard let firstDay = month.days.first?.date else {
            return Array(repeating: nil, count: totalColumns)
        }
        
        let firstDayWeekday = calendar.component(.weekday, from: firstDay)
        let offset = (firstDayWeekday - calendar.firstWeekday + 7) % 7
        
        var result: [DayData?] = Array(repeating: nil, count: totalColumns)
        
        for (index, day) in month.days.enumerated() {
            let position = offset + index
            if position < totalColumns {
                result[position] = day
            }
        }
        
        return result
    }
    
    private func hasEvents(_ day: DayData?) -> Bool {
        guard let day else { return false }
        let events = calendarViewModel.events(for: day.date)
        return !appSettings.filterEvents(events).isEmpty
    }

    /// Calculate featured event segments using date math (matching EventBarsOverlay approach)
    private var featuredEventSegments: [FeaturedEventSegment] {
        guard appSettings.showMonthRowEvents,
              let firstDayDate = month.days.first?.date,
              let lastDayDate = month.days.last?.date else { return [] }
        
        // Normalize to start of day for consistent calculations
        let monthStart = calendar.startOfDay(for: firstDayDate)
        let monthEnd = calendar.startOfDay(for: lastDayDate)
        
        // Get events that overlap this month
        let monthEvents = appSettings.filterEvents(calendarViewModel.filteredEvents).filter { event in
            let eStart = calendar.startOfDay(for: event.startDate)
            let eEnd = calendar.startOfDay(for: event.endDate)
            // For all-day events, endDate is exclusive (day after event ends)
            let effectiveEnd = event.isAllDay ? eEnd.addingTimeInterval(-1) : eEnd
            return eStart <= monthEnd && effectiveEnd >= monthStart
        }
        
        // Sort by priority: longest duration, all-day, earliest start, then title
        let sortedEvents = monthEvents.sorted { lhs, rhs in
            if lhs.duration != rhs.duration { return lhs.duration > rhs.duration }
            if lhs.isAllDay != rhs.isAllDay { return lhs.isAllDay && !rhs.isAllDay }
            if lhs.startDate != rhs.startDate { return lhs.startDate < rhs.startDate }
            return lhs.title.localizedCaseInsensitiveCompare(rhs.title) == .orderedAscending
        }
        
        // Calculate grid offset for this month (weekday offset for first day)
        let firstDayWeekday = calendar.component(.weekday, from: monthStart)
        let offset = (firstDayWeekday - calendar.firstWeekday + 7) % 7
        
        // Track which column has been claimed by an event
        var columnEvent: [CalendarEvent?] = Array(repeating: nil, count: totalColumns)
        
        // Assign events to columns (first event wins each column since sorted by priority)
        for event in sortedEvents {
            // Calculate start column from start date
            let eventStartDay = calendar.startOfDay(for: event.startDate)
            let startDist = calendar.dateComponents([.day], from: monthStart, to: eventStartDay).day ?? 0
            let colStart = max(0, startDist + offset)
            
            // Calculate day span using duration - this is robust regardless of endDate convention
            // EventKit all-day events: endDate is exclusive (day after), so duration = N * 86400 for N days
            // Even if endDate were inclusive (end of last day), ceil() handles it correctly
            let secondsPerDay: Double = 86400
            let daySpan: Int
            if event.isAllDay {
                daySpan = max(1, Int(ceil(event.duration / secondsPerDay)))
            } else {
                // For timed events, include both start and end days
                let eventEndDay = calendar.startOfDay(for: event.endDate)
                let dayDiff = calendar.dateComponents([.day], from: eventStartDay, to: eventEndDay).day ?? 0
                daySpan = max(1, dayDiff + 1)
            }
            
            let colEnd = min(totalColumns - 1, colStart + daySpan - 1)
            
            guard colStart <= colEnd else { continue }
            
            for col in colStart...colEnd {
                if columnEvent[col] == nil {
                    columnEvent[col] = event
                }
            }
        }
        
        // Build segments from consecutive columns with the same event
        var segments: [FeaturedEventSegment] = []
        var currentEvent: CalendarEvent?
        var currentStart = 0
        
        for col in 0..<totalColumns {
            let event = columnEvent[col]
            
            if let event = event {
                if let current = currentEvent, current.id == event.id {
                    // Same event continues
                    continue
                } else {
                    // Close previous segment
                    if let current = currentEvent {
                        segments.append(FeaturedEventSegment(event: current, startIndex: currentStart, span: col - currentStart))
                    }
                    // Start new segment
                    currentEvent = event
                    currentStart = col
                }
            } else {
                // No event - close any open segment
                if let current = currentEvent {
                    segments.append(FeaturedEventSegment(event: current, startIndex: currentStart, span: col - currentStart))
                    currentEvent = nil
                }
            }
        }
        
        // Close final segment
        if let current = currentEvent {
            segments.append(FeaturedEventSegment(event: current, startIndex: currentStart, span: totalColumns - currentStart))
        }
        
        return segments
    }

    private func isSelected(_ date: Date?) -> Bool {
        guard let date, let selectedDate else { return false }
        return calendar.isDate(date, inSameDayAs: selectedDate)
    }
    
    @ViewBuilder
    private var monthLabel: some View {
        switch appSettings.monthLabelFormat {
        case .dual:
            VStack(alignment: .leading, spacing: 2) {
                Text(month.name)
                    .font(appSettings.monthLabelFontSize.font)
                    .fontWeight(.bold)
                    .foregroundStyle(appSettings.rowHeadingColor)
                Text(month.shortName.uppercased())
                    .font(appSettings.monthLabelFontSize.secondaryFont)
                    .foregroundStyle(appSettings.rowHeadingColor.opacity(0.6))
            }
        case .full:
            Text(month.name)
                .font(appSettings.monthLabelFontSize.font)
                .fontWeight(.bold)
                .foregroundStyle(appSettings.rowHeadingColor)
        case .abbreviated:
            Text(month.shortName)
                .font(appSettings.monthLabelFontSize.font)
                .fontWeight(.bold)
                .foregroundStyle(appSettings.rowHeadingColor)
        case .letter:
            Text(String(month.name.prefix(1)))
                .font(appSettings.monthLabelFontSize.font)
                .fontWeight(.bold)
                .foregroundStyle(appSettings.rowHeadingColor)
        }
    }
}

private struct EventBarsOverlay: View {
    let month: MonthData
    let events: [CalendarEvent]
    let cellSize: CGSize
    let totalColumns: Int
    let appSettings: AppSettings
    
    private var calendar: Calendar { appSettings.calendar }
    
    var body: some View {
        GeometryReader { geometry in
            let monthEvents = eventsForMonth
            let laidOutEvents = layoutEvents(monthEvents)
            
            ForEach(laidOutEvents, id: \.event.id) { (event, row, startCol, span) in
                let width = CGFloat(span) * cellSize.width - 2
                let x = CGFloat(startCol) * cellSize.width + 1
                let y = CGFloat(row) * 6 + 24 // Offset below date number (increased spacing)
                
                if y < cellSize.height {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(event.calendarColor)
                        .frame(width: max(4, width), height: 4)
                        .position(x: x + width/2, y: y + 2)
                }
            }
        }
    }
    
    private var eventsForMonth: [CalendarEvent] {
        guard let firstDay = month.days.first?.date,
              let lastDay = month.days.last?.date else { return [] }
        
        return events.filter { event in
            let eStart = calendar.startOfDay(for: event.startDate)
            let eEnd = calendar.startOfDay(for: event.endDate)
            let effectiveEnd = event.isAllDay ? eEnd.addingTimeInterval(-1) : eEnd
            
            return eStart <= lastDay && effectiveEnd >= firstDay
        }
    }
    
    private func layoutEvents(_ events: [CalendarEvent]) -> [(event: CalendarEvent, row: Int, colStart: Int, colSpan: Int)] {
        let sorted = events.sorted {
            if $0.startDate != $1.startDate { return $0.startDate < $1.startDate }
            return $0.duration > $1.duration
        }
        
        var result: [(event: CalendarEvent, row: Int, colStart: Int, colSpan: Int)] = []
        // Max 5 rows of events to fit in cell height
        var occupied: [[Bool]] = Array(repeating: Array(repeating: false, count: totalColumns), count: 5)
        
        guard let firstDayDate = month.days.first?.date else { return [] }
        // Normalize to start of day for consistent calculations
        let monthStart = calendar.startOfDay(for: firstDayDate)
        let firstDayWeekday = calendar.component(.weekday, from: monthStart)
        // Adjust offset logic to match MonthRow's padded grid
        // MonthRow puts first day at: (weekday - firstWeekday + 7) % 7
        let offset = (firstDayWeekday - calendar.firstWeekday + 7) % 7
        
        for event in sorted {
            // Calculate start column from start date
            let eventStartDay = calendar.startOfDay(for: event.startDate)
            let startDist = calendar.dateComponents([.day], from: monthStart, to: eventStartDay).day ?? 0
            let colStart = max(0, startDist + offset)
            
            // Calculate day span using duration - robust regardless of endDate convention
            let secondsPerDay: Double = 86400
            let daySpan: Int
            if event.isAllDay {
                daySpan = max(1, Int(ceil(event.duration / secondsPerDay)))
            } else {
                let eventEndDay = calendar.startOfDay(for: event.endDate)
                let dayDiff = calendar.dateComponents([.day], from: eventStartDay, to: eventEndDay).day ?? 0
                daySpan = max(1, dayDiff + 1)
            }
            
            let colEnd = min(totalColumns - 1, colStart + daySpan - 1)
            
            if colStart > colEnd { continue }
            let span = daySpan
            
            for r in 0..<occupied.count {
                var fits = true
                for c in colStart...colEnd {
                    if c >= 0 && c < totalColumns {
                        if occupied[r][c] {
                            fits = false
                            break
                        }
                    }
                }
                
                if fits {
                    for c in colStart...colEnd {
                        if c >= 0 && c < totalColumns {
                            occupied[r][c] = true
                        }
                    }
                    result.append((event, r, colStart, span))
                    break
                }
            }
        }
        
        return result
    }
}

private struct MonthRowDayCell: View {
    let day: DayData?
    let cellSize: CGSize
    let isSelected: Bool
    let hasEvents: Bool
    let appSettings: AppSettings
    let onTap: (Date) -> Void

    var body: some View {
        Group {
            if let day {
                WobbleTapButton(hasEvents: hasEvents, wobbleScale: 1.1, wobbleRotation: 2.5, action: { onTap(day.date) }) {
                    ZStack(alignment: .topLeading) {
                        if isSelected && !day.isToday {
                            Rectangle()
                                .stroke(appSettings.todayColor, lineWidth: 2)
                        }

                        Text("\(day.dayNumber)")
                            .font(.system(size: 11))
                            .fontWeight(day.isToday ? .bold : .medium)
                            .foregroundStyle(appSettings.dateLabelColor)
                            .frame(width: cellSize.width, alignment: .center)
                            .padding(.top, dayNumberTopPadding)
                    }
                    .frame(width: cellSize.width, height: cellSize.height, alignment: .top)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            } else {
                // Unused cell - background is handled by cellBackgrounds
                Color.clear
                    .frame(width: cellSize.width, height: cellSize.height)
            }
        }
    }

    private var dayNumberTopPadding: CGFloat {
        max(1, min(6, cellSize.height * 0.2))
    }
}

private struct FeaturedEventSegment: Identifiable {
    let event: CalendarEvent
    let startIndex: Int
    let span: Int

    var id: String { "\(event.id)-\(startIndex)" }
}

private struct FeaturedEventOverlay: View {
    let segments: [FeaturedEventSegment]
    let cellSize: CGSize
    let totalColumns: Int

    var body: some View {
        // Calculate explicit size for the overlay
        let totalWidth = CGFloat(totalColumns) * cellSize.width
        let barHeight: CGFloat = max(10, min(14, cellSize.height * 0.45))
        let fontSize: CGFloat = max(7, min(11, barHeight * 0.75))
        // Position at bottom of cell
        let y = cellSize.height - barHeight / 2 - 2

        ZStack(alignment: .topLeading) {
            // Invisible spacer to establish size
            Color.clear
                .frame(width: totalWidth, height: cellSize.height)

            ForEach(segments) { segment in
                let width = CGFloat(segment.span) * cellSize.width - 4
                let x = CGFloat(segment.startIndex) * cellSize.width + 2

                if width > 10 {
                    Text(segment.event.title)
                        .font(.system(size: fontSize))
                        .fontWeight(.semibold)
                        .foregroundStyle(segment.event.calendarColor.contrastingTextColor)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .padding(.horizontal, 3)
                        .frame(width: width, height: barHeight, alignment: .leading)
                        .background(segment.event.calendarColor, in: RoundedRectangle(cornerRadius: 4))
                        .position(x: x + width / 2, y: y)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        YearMonthRowLayout(
            months: YearViewModel().months(for: 2026),
            selectedDate: .constant(Date()),
            onDateTap: { _ in }
        )
        .navigationTitle("2026")
    }
    .environment(CalendarViewModel())
    .environment(AppSettings())
}
