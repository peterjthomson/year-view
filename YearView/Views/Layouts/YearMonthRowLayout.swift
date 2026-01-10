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

    private let daysPerWeek = 7
    private let outerPadding: CGFloat = 12
    private let rowSpacing: CGFloat = 0 // Spacing handled by padding/dividers
    private let headerBottomPadding: CGFloat = 8
    private let minCellWidth: CGFloat = 20
    private let minRowHeight: CGFloat = 32
    
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
            let headerHeight: CGFloat = 20
            let availableHeight = geometry.size.height - (outerPadding * 2) - headerHeight - headerBottomPadding
            let rowHeight = max(minRowHeight, availableHeight / 12)

            // Width sizing: fill the available width when possible, otherwise fall back to a minimum and allow scroll.
            let availableGridWidth = max(0, geometry.size.width - (outerPadding * 2) - monthLabelWidth)
            let idealCellWidth = availableGridWidth / columns
            let cellWidth = max(minCellWidth, idealCellWidth)
            
            let cellSize = CGSize(width: cellWidth, height: rowHeight)

            ScrollView(.horizontal, showsIndicators: true) {
                VStack(alignment: .leading, spacing: 0) {
                    weekdayHeader(cellSize: CGSize(width: cellWidth, height: headerHeight), monthLabelWidth: monthLabelWidth)
                        .padding(.bottom, headerBottomPadding)

                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(months) { month in
                            MonthRow(
                                month: month,
                                cellSize: cellSize,
                                monthLabelWidth: monthLabelWidth,
                                totalColumns: totalColumns,
                                selectedDate: selectedDate,
                                calendarViewModel: calendarViewModel,
                                appSettings: appSettings,
                                onDateTap: onDateTap
                            )
                            Divider()
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
    let onDateTap: (Date) -> Void

    private var calendar: Calendar { appSettings.calendar }
    
    /// Returns the weekday number (1-7) for a given column index
    private func weekdayForColumn(_ index: Int) -> Int {
        let columnInWeek = index % 7
        return (calendar.firstWeekday - 1 + columnInWeek) % 7 + 1
    }

    private let verticalPadding: CGFloat = 4
    
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
                            appSettings: appSettings,
                            onTap: { date in onDateTap(date) }
                        )
                    }
                }
                .padding(.vertical, verticalPadding)
                
                // Event Bars Overlay
                EventBarsOverlay(
                    month: month,
                    events: appSettings.filterEvents(calendarViewModel.events),
                    cellSize: cellSize,
                    totalColumns: totalColumns,
                    appSettings: appSettings
                )
                .padding(.vertical, verticalPadding)
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
                let hasDay = paddedDays[index] != nil
                
                Group {
                    if hasDay {
                        appSettings.backgroundColor(isWeekend: isWeekend)
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
        let firstDayWeekday = calendar.component(.weekday, from: firstDayDate)
        // Adjust offset logic to match MonthRow's padded grid
        // MonthRow puts first day at: (weekday - firstWeekday + 7) % 7
        let offset = (firstDayWeekday - calendar.firstWeekday + 7) % 7
        
        for event in sorted {
            let startDist = calendar.dateComponents([.day], from: firstDayDate, to: event.startDate).day ?? 0
            let endDist = calendar.dateComponents([.day], from: firstDayDate, to: event.endDate).day ?? 0
            let effectiveEndDist = event.isAllDay ? endDist - 1 : endDist
            
            let colStart = max(0, startDist + offset)
            let colEnd = min(totalColumns - 1, effectiveEndDist + offset)
            
            if colStart > colEnd { continue }
            let span = colEnd - colStart + 1
            
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
    let appSettings: AppSettings
    let onTap: (Date) -> Void

    var body: some View {
        Group {
            if let day {
                Button {
                    onTap(day.date)
                } label: {
                    ZStack(alignment: .top) {
                        // Today gets a full cell background color instead of a circle
                        if day.isToday {
                            Rectangle()
                                .fill(appSettings.todayColor.opacity(0.3))
                        }
                        
                        if isSelected && !day.isToday {
                            Rectangle()
                                .stroke(appSettings.todayColor, lineWidth: 2)
                        }

                        Text("\(day.dayNumber)")
                            .font(.system(size: 11))
                            .fontWeight(day.isToday ? .bold : .medium)
                            .foregroundStyle(day.isToday ? appSettings.todayColor : appSettings.dateLabelColor)
                            .frame(width: cellSize.width, alignment: .center)
                            .padding(.top, 6)
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
