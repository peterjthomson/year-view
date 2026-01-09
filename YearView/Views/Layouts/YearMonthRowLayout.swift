import SwiftUI

/// Calendar.app-style year view: each month is one row, displayed as a 6-week (42 cell) strip.
/// The start of each month is offset so weekdays align across all months.
struct YearMonthRowLayout: View {
    let months: [MonthData]
    @Binding var selectedDate: Date?
    let onDateTap: (Date) -> Void

    @Environment(CalendarViewModel.self) private var calendarViewModel

    // 6 weeks is enough to display any month.
    private let weeksPerMonth = 6
    private let daysPerWeek = 7
    private let outerPadding: CGFloat = 12
    private let rowSpacing: CGFloat = 0 // Spacing handled by padding/dividers
    private let headerBottomPadding: CGFloat = 8
    private let minCellWidth: CGFloat = 20
    private let minRowHeight: CGFloat = 32

    var body: some View {
        GeometryReader { geometry in
            let monthLabelWidth = max(64, min(140, geometry.size.width * 0.12))
            let columns = CGFloat(weeksPerMonth * daysPerWeek) // 42

            // Width sizing: fill the available width when possible, otherwise fall back to a minimum and allow scroll.
            let availableGridWidth = max(0, geometry.size.width - (outerPadding * 2) - monthLabelWidth)
            let idealCellWidth = availableGridWidth / columns
            let cellWidth = max(minCellWidth, idealCellWidth)
            
            // Height sizing
            let headerHeight: CGFloat = 20
            
            // Allow row height to grow for events
            let cellSize = CGSize(width: cellWidth, height: max(minRowHeight, cellWidth * 1.5))

            ScrollView([.vertical, .horizontal]) {
                VStack(alignment: .leading, spacing: 0) {
                    weekdayHeader(cellSize: CGSize(width: cellWidth, height: headerHeight), monthLabelWidth: monthLabelWidth)
                        .padding(.bottom, headerBottomPadding)

                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(months) { month in
                            MonthRow(
                                month: month,
                                cellSize: cellSize,
                                monthLabelWidth: monthLabelWidth,
                                selectedDate: selectedDate,
                                calendarViewModel: calendarViewModel,
                                onDateTap: onDateTap
                            )
                            Divider()
                        }
                    }
                }
                .padding(outerPadding)
                .frame(minWidth: geometry.size.width, minHeight: geometry.size.height, alignment: .topLeading)
            }
            .background(Color.white)
        }
    }

    @ViewBuilder
    private func weekdayHeader(cellSize: CGSize, monthLabelWidth: CGFloat) -> some View {
        let symbols = Calendar.current.veryShortWeekdaySymbols
        
        HStack(spacing: 0) {
            Color.clear
                .frame(width: monthLabelWidth, height: cellSize.height)

            ForEach(0..<weeksPerMonth, id: \.self) { _ in
                ForEach(symbols, id: \.self) { symbol in
                    Text(symbol.uppercased())
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                        .frame(width: cellSize.width, height: cellSize.height)
                }
            }
        }
    }
}

private struct MonthRow: View {
    let month: MonthData
    let cellSize: CGSize
    let monthLabelWidth: CGFloat
    let selectedDate: Date?
    let calendarViewModel: CalendarViewModel
    let onDateTap: (Date) -> Void

    private let calendar = Calendar.current
    private let weeksPerMonth = 6

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            // Month Label
            VStack(alignment: .leading, spacing: 2) {
                Text(month.name)
                    .font(.subheadline)
                    .fontWeight(.bold)
                Text(month.shortName.uppercased())
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(width: monthLabelWidth, height: cellSize.height, alignment: .leading)
            .padding(.vertical, 4)

            // Grid
            ZStack(alignment: .topLeading) {
                // Weekend Backgrounds
                weekendBackgrounds
                
                // Days
                HStack(spacing: 0) {
                    ForEach(paddedWeeks.indices, id: \.self) { weekIndex in
                        let week = paddedWeeks[weekIndex]
                        ForEach(0..<7, id: \.self) { dayIndex in
                            MonthRowDayCell(
                                day: week[dayIndex],
                                cellSize: cellSize,
                                isSelected: isSelected(week[dayIndex]?.date),
                                onTap: { date in onDateTap(date) }
                            )
                        }
                    }
                }
                
                // Event Bars Overlay
                EventBarsOverlay(
                    month: month,
                    events: calendarViewModel.events,
                    cellSize: cellSize,
                    totalColumns: weeksPerMonth * 7
                )
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Month \(month.name)")
    }

    private var weekendBackgrounds: some View {
        HStack(spacing: 0) {
            ForEach(0..<(weeksPerMonth * 7), id: \.self) { index in
                // Calculate weekday: (index + firstWeekday - 1) % 7 gives 0..6
                // But we need to match Calendar.component(.weekday) logic where Sunday=1, Saturday=7 (usually)
                // Symbol index 0 corresponds to firstWeekday.
                // If firstWeekday=1 (Sun), index 0 is Sun.
                // If firstWeekday=2 (Mon), index 0 is Mon.
                
                // We want to highlight weekends.
                // Standard: Sun=1, Sat=7.
                // So we need to map column index back to absolute weekday.
                
                let currentWeekday = (index + calendar.firstWeekday - 1) % 7 + 1
                let isWeekend = currentWeekday == 1 || currentWeekday == 7
                
                if isWeekend {
                    Color.secondarySystemGroupedBackground.opacity(0.5)
                        .frame(width: cellSize.width, height: cellSize.height)
                } else {
                    Color.clear
                        .frame(width: cellSize.width, height: cellSize.height)
                }
            }
        }
    }

    private var paddedWeeks: [[DayData?]] {
        if month.weeks.count >= weeksPerMonth {
            return Array(month.weeks.prefix(weeksPerMonth))
        }
        let emptyWeek: [DayData?] = Array(repeating: nil, count: 7)
        let padding: [[DayData?]] = Array(repeating: emptyWeek, count: weeksPerMonth - month.weeks.count)
        return month.weeks + padding
    }

    private func isSelected(_ date: Date?) -> Bool {
        guard let date, let selectedDate else { return false }
        return calendar.isDate(date, inSameDayAs: selectedDate)
    }
}

private struct EventBarsOverlay: View {
    let month: MonthData
    let events: [CalendarEvent]
    let cellSize: CGSize
    let totalColumns: Int
    
    private let calendar = Calendar.current
    
    var body: some View {
        GeometryReader { geometry in
            let monthEvents = eventsForMonth
            let laidOutEvents = layoutEvents(monthEvents)
            
            ForEach(laidOutEvents, id: \.event.id) { (event, row, startCol, span) in
                let width = CGFloat(span) * cellSize.width - 2
                let x = CGFloat(startCol) * cellSize.width + 1
                let y = CGFloat(row) * 6 + 18 // Offset below date number
                
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
            
            var placed = false
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
                    placed = true
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
    let onTap: (Date) -> Void

    var body: some View {
        Group {
            if let day {
                Button {
                    onTap(day.date)
                } label: {
                    ZStack(alignment: .top) {
                        if day.isToday {
                            Circle()
                                .fill(Color.accentColor)
                                .frame(width: 20, height: 20)
                                .padding(.top, 4)
                        } else if isSelected {
                            Circle()
                                .stroke(Color.accentColor, lineWidth: 2)
                                .frame(width: 20, height: 20)
                                .padding(.top, 4)
                        }

                        Text("\(day.dayNumber)")
                            .font(.system(size: 11))
                            .fontWeight(day.isToday ? .bold : .medium)
                            .foregroundStyle(day.isToday ? .white : .primary)
                            .frame(width: cellSize.width, alignment: .center)
                            .padding(.top, 6)
                    }
                    .frame(width: cellSize.width, height: cellSize.height, alignment: .top)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            } else {
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
}
