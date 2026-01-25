import SwiftUI

struct PowerLawLayout: View {
    @Environment(CalendarViewModel.self) private var calendarViewModel
    @Environment(AppSettings.self) private var appSettings
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @Binding var selectedDate: Date?
    let onDateTap: (Date) -> Void
    
    private let today = Date()
    private let panelCount = 5
    
    var body: some View {
        GeometryReader { geometry in
            let panelSpacing: CGFloat = isCompactPhone ? 0 : 1

            Group {
                if isCompactPhone {
                    ScrollView(.horizontal, showsIndicators: false) {
                        panelStack(for: geometry, spacing: panelSpacing)
                            .scrollTargetLayout()
                    }
                    .scrollTargetBehavior(.paging)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        panelStack(for: geometry, spacing: panelSpacing)
                    }
                }
            }
        }
        .background(Color.gray.opacity(0.1))
    }
    
    private func panelWidth(for geometry: GeometryProxy, index: Int, spacing: CGFloat) -> CGFloat {
        let totalWidth = geometry.size.width
        let minPanelWidth: CGFloat = 240
        let isLandscape = geometry.size.width > geometry.size.height
        
        #if os(iOS)
        if isCompactPhone {
            return totalWidth
        }
        if !isLandscape {
            if totalWidth < minPanelWidth * 2 {
                return totalWidth * 0.85
            } else if totalWidth < minPanelWidth * 5 {
                return totalWidth / 2.5
            }
        }
        #endif
        
        let availableWidth = max(totalWidth - spacing * CGFloat(panelCount - 1), 0)
        let weights: [CGFloat] = [1.1, 1.0, 1.0, 1.0, 1.1]
        let totalWeight = weights.reduce(0, +)
        return (availableWidth / totalWeight) * weights[index]
    }

    @ViewBuilder
    private func panelStack(for geometry: GeometryProxy, spacing: CGFloat) -> some View {
        LazyHStack(alignment: .top, spacing: spacing) {
            // TODAY Panel
            TodayPanel(
                date: today,
                events: calendarViewModel.events(for: today),
                onEventTap: { _ in onDateTap(today) },
                height: geometry.size.height
            )
            .frame(width: panelWidth(for: geometry, index: 0, spacing: spacing), height: geometry.size.height, alignment: .top)
            .background(Color.white)
            .id(0)

            // THIS WEEK Panel
            ThisWeekPanel(
                startDate: today,
                calendarViewModel: calendarViewModel,
                onDateTap: onDateTap,
                height: geometry.size.height
            )
            .frame(width: panelWidth(for: geometry, index: 1, spacing: spacing), height: geometry.size.height, alignment: .top)
            .background(Color.white)
            .id(1)

            // THIS MONTH Panel
            ThisMonthPanel(
                startDate: today,
                calendarViewModel: calendarViewModel,
                appSettings: appSettings,
                onDateTap: onDateTap
            )
            .frame(width: panelWidth(for: geometry, index: 2, spacing: spacing), height: geometry.size.height, alignment: .top)
            .background(Color.white)
            .id(2)

            // THIS QUARTER Panel
            ThisQuarterPanel(
                calendarViewModel: calendarViewModel,
                appSettings: appSettings,
                onDateTap: onDateTap,
                height: geometry.size.height
            )
            .frame(width: panelWidth(for: geometry, index: 3, spacing: spacing), height: geometry.size.height, alignment: .top)
            .background(Color.white)
            .id(3)

            // THIS YEAR Panel
            ThisYearPanel(
                calendarViewModel: calendarViewModel,
                onDateTap: onDateTap,
                height: geometry.size.height
            )
            .frame(width: panelWidth(for: geometry, index: 4, spacing: spacing), height: geometry.size.height, alignment: .top)
            .background(Color.white)
            .id(4)
        }
    }

    private var isCompactPhone: Bool {
        #if os(iOS)
        return horizontalSizeClass == .compact
        #else
        return false
        #endif
    }
}

// MARK: - Panel Header

private struct PanelHeader: View {
    let icon: String
    let title: String
    let subtitle: String?
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
            
            if let subtitle {
                Text(subtitle)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
    }
}

// MARK: - TODAY Panel

private struct TodayPanel: View {
    let date: Date
    let events: [CalendarEvent]
    let onEventTap: (CalendarEvent) -> Void
    let height: CGFloat
    
    private var dayViewModel: DayViewModel {
        DayViewModel(date: date, events: events)
    }
    
    // Hours from 6am to 10pm
    private let hours = Array(6...22)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            PanelHeader(icon: "sun.max", title: "TODAY", subtitle: nil)
            
            // Date
            VStack(alignment: .leading, spacing: 2) {
                Text(dayOfWeek)
                    .font(.system(size: 32, weight: .bold, design: .default))
                Text(dateString)
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)
            .padding(.bottom, 12)
            
            Divider()
                .padding(.horizontal)
            
            // Schedule - fills remaining height
            let headerHeight: CGFloat = 120
            let availableHeight = max(height - headerHeight, 400)
            let hourHeight = availableHeight / CGFloat(hours.count)
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(hours, id: \.self) { hour in
                        HStack(alignment: .top, spacing: 12) {
                            Text(hourString(hour))
                                .font(.caption)
                                .foregroundStyle(Color.secondary.opacity(0.6))
                                .frame(width: 44, alignment: .trailing)
                                .monospacedDigit()
                            
                            VStack(alignment: .leading, spacing: 0) {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.15))
                                    .frame(height: 1)
                                
                                // Show events that start at this hour
                                ForEach(eventsAtHour(hour)) { event in
                                    HStack(spacing: 8) {
                                        RoundedRectangle(cornerRadius: 2)
                                            .fill(event.calendarColor)
                                            .frame(width: 3)
                                        
                                        VStack(alignment: .leading, spacing: 1) {
                                            Text(event.title)
                                                .font(.caption)
                                                .fontWeight(.medium)
                                                .lineLimit(1)
                                            if let location = event.location, !location.isEmpty {
                                                Text(location)
                                                    .font(.caption2)
                                                    .foregroundStyle(.secondary)
                                                    .lineLimit(1)
                                            }
                                        }
                                    }
                                    .padding(.top, 4)
                                    .onTapGesture { onEventTap(event) }
                                }
                            }
                        }
                        .frame(height: hourHeight)
                        .padding(.horizontal)
                    }
                }
            }
        }
        .padding(.top, 8)
    }
    
    private var dayOfWeek: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }
    
    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d"
        return formatter.string(from: date)
    }
    
    private func hourString(_ hour: Int) -> String {
        let h = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour)
        let ampm = hour >= 12 ? "PM" : "AM"
        return "\(h) \(ampm)"
    }
    
    private func eventsAtHour(_ hour: Int) -> [CalendarEvent] {
        let calendar = Calendar.current
        return events.filter { event in
            guard !event.isAllDay else { return false }
            let eventHour = calendar.component(.hour, from: event.startDate)
            return eventHour == hour
        }
    }
}

// MARK: - THIS WEEK Panel

private struct ThisWeekPanel: View {
    let startDate: Date
    let calendarViewModel: CalendarViewModel
    let onDateTap: (Date) -> Void
    let height: CGFloat
    
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            PanelHeader(icon: "calendar", title: "THIS WEEK", subtitle: "Next 6 days")
            
            let headerHeight: CGFloat = 50
            let availableHeight = max(height - headerHeight, 0)
            let minRowHeight: CGFloat = 72
            let dayCount = max(1, upcomingDays.count)
            let dayHeight = max(minRowHeight, availableHeight / CGFloat(dayCount))
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(upcomingDays, id: \.self) { date in
                        WeekDayRow(
                            date: date,
                            events: calendarViewModel.events(for: date),
                            onTap: { onDateTap(date) }
                        )
                        .frame(height: dayHeight)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            .frame(height: availableHeight)
        }
        .padding(.top, 8)
    }
    
    private var upcomingDays: [Date] {
        (1...6).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: calendar.startOfDay(for: startDate))
        }
    }
}

private struct WeekDayRow: View {
    let date: Date
    let events: [CalendarEvent]
    let onTap: () -> Void
    
    var body: some View {
        WobbleTapButton(hasEvents: !events.isEmpty, action: onTap) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline) {
                    Text(dayName)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Text(dayNumber)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
                
                if !events.isEmpty {
                    VStack(alignment: .leading, spacing: 2) {
                        ForEach(events.prefix(3)) { event in
                            HStack(spacing: 6) {
                                Text("•")
                                    .foregroundStyle(event.calendarColor)
                                Text(event.title)
                                    .font(.subheadline)
                                    .foregroundStyle(.primary)
                                    .lineLimit(1)
                            }
                        }
                        
                        if events.count > 3 {
                            Text("+\(events.count - 3) more")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                                .padding(.leading, 14)
                        }
                    }
                }
                
                Spacer(minLength: 0)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(events.isEmpty ? Color.clear : Color.gray.opacity(0.03))
        }
        .buttonStyle(.plain)
    }
    
    private var dayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
}

// MARK: - THIS MONTH Panel

private struct ThisMonthPanel: View {
    let startDate: Date
    let calendarViewModel: CalendarViewModel
    let appSettings: AppSettings
    let onDateTap: (Date) -> Void
    
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            PanelHeader(icon: "calendar.badge.clock", title: "THIS MONTH", subtitle: dateRangeString)
            
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(remainingDays, id: \.self) { date in
                        MonthDayRow(
                            date: date,
                            events: calendarViewModel.events(for: date),
                            isWeekend: appSettings.isWeekend(date: date),
                            weekendColor: appSettings.weekendBackgroundColor,
                            onTap: { onDateTap(date) }
                        )
                    }
                }
                .padding(.horizontal)
            }
            
            Spacer()
        }
        .padding(.top, 8)
    }
    
    private var remainingDays: [Date] {
        let startOffset = 7
        guard let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: startDate)),
              let monthEnd = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: monthStart) else {
            return []
        }
        
        let daysInMonth = calendar.component(.day, from: monthEnd)
        let currentDay = calendar.component(.day, from: startDate)
        let endDay = min(currentDay + 30, daysInMonth)
        let endOffset = max(0, endDay - currentDay)
        let offsets: ClosedRange<Int>
        if endOffset >= startOffset {
            offsets = startOffset...endOffset
        } else if endOffset > 0 {
            offsets = 1...endOffset
        } else {
            offsets = 0...0
        }
        
        return offsets.compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: calendar.startOfDay(for: startDate))
        }
    }
    
    private var dateRangeString: String {
        guard let first = remainingDays.first, let last = remainingDays.last else {
            return ""
        }
        let startDay = calendar.component(.day, from: first)
        let endDay = calendar.component(.day, from: last)
        return "Days \(startDay)-\(endDay)"
    }
}

private struct MonthDayRow: View {
    let date: Date
    let events: [CalendarEvent]
    let isWeekend: Bool
    let weekendColor: Color
    let onTap: () -> Void
    
    var body: some View {
        WobbleTapButton(hasEvents: !events.isEmpty, action: onTap) {
            HStack(alignment: .top, spacing: 10) {
                VStack(alignment: .leading, spacing: 0) {
                    Text(dayNumber)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(isWeekend ? .secondary : .primary)
                    Text(dayName)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                }
                .frame(width: 32, alignment: .leading)
                
                if !events.isEmpty {
                    VStack(alignment: .leading, spacing: 2) {
                        ForEach(events.prefix(2)) { event in
                            HStack(spacing: 5) {
                                Circle()
                                    .fill(event.calendarColor)
                                    .frame(width: 5, height: 5)
                                Text(event.title)
                                    .font(.caption)
                                    .lineLimit(1)
                            }
                        }
                        
                        if events.count > 2 {
                            Text("+\(events.count - 2)")
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                                .padding(.leading, 10)
                        }
                    }
                }
                
                Spacer()
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 4)
            .background(isWeekend ? weekendColor : Color.clear)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    private var dayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
}

// MARK: - THIS QUARTER Panel

private struct ThisQuarterPanel: View {
    let calendarViewModel: CalendarViewModel
    let appSettings: AppSettings
    let onDateTap: (Date) -> Void
    let height: CGFloat
    
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            PanelHeader(icon: "chart.bar", title: "THIS QUARTER", subtitle: quarterName)
            
            let headerHeight: CGFloat = 50
            let availableHeight = max(height - headerHeight, 0)
            let minMonthHeight: CGFloat = 140
            let monthHeight = max(minMonthHeight, availableHeight / 3)
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(quarterMonths, id: \.self) { month in
                        QuarterMonthSection(
                            month: month,
                            events: eventsForMonth(month),
                            appSettings: appSettings,
                            height: monthHeight
                        )
                    }
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            .frame(height: availableHeight)
        }
        .padding(.top, 8)
    }
    
    private var currentQuarter: Int {
        let month = calendar.component(.month, from: Date())
        return (month - 1) / 3 + 1
    }
    
    private var quarterName: String {
        let startMonth = (currentQuarter - 1) * 3 + 1
        let endMonth = currentQuarter * 3
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        
        guard let start = Date.from(year: calendar.component(.year, from: Date()), month: startMonth, day: 1),
              let end = Date.from(year: calendar.component(.year, from: Date()), month: endMonth, day: 1) else {
            return "Q\(currentQuarter)"
        }
        
        return "\(formatter.string(from: start).uppercased()) - \(formatter.string(from: end).uppercased())"
    }
    
    private var quarterMonths: [Date] {
        let year = calendar.component(.year, from: Date())
        let startMonth = (currentQuarter - 1) * 3 + 1
        
        return (0..<3).compactMap { offset in
            Date.from(year: year, month: startMonth + offset, day: 1)
        }
    }
    
    private func eventsForMonth(_ month: Date) -> [CalendarEvent] {
        guard let monthEnd = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: month) else {
            return []
        }
        return calendarViewModel.events(from: month, to: monthEnd)
    }
}

private struct QuarterMonthSection: View {
    let month: Date
    let events: [CalendarEvent]
    let appSettings: AppSettings
    let height: CGFloat
    
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(monthName)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
            
            if events.isEmpty {
                // Show mini calendar grid
                MiniMonthGrid(month: month, appSettings: appSettings)
            } else {
                ForEach(events.prefix(4)) { event in
                    HStack(spacing: 6) {
                        RoundedRectangle(cornerRadius: 1)
                            .fill(event.calendarColor.opacity(0.6))
                            .frame(width: 2, height: 14)
                        Text(event.title)
                            .font(.caption)
                            .lineLimit(1)
                    }
                }
                
                if events.count > 4 {
                    Text("+\(events.count - 4) more")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .padding(.leading, 8)
                }
            }
            
            Spacer(minLength: 0)
        }
        .frame(height: height)
        .padding(.horizontal)
    }
    
    private var monthName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter.string(from: month)
    }
}

private struct MiniMonthGrid: View {
    let month: Date
    let appSettings: AppSettings
    
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(spacing: 2) {
            // Weekday headers
            HStack(spacing: 2) {
                ForEach(weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.system(size: 8))
                        .foregroundStyle(Color.secondary.opacity(0.5))
                        .frame(width: 14)
                }
            }
            
            // Days grid
            ForEach(weeks, id: \.self) { week in
                HStack(spacing: 2) {
                    ForEach(0..<7, id: \.self) { index in
                        if let day = week[safe: index], let dayDate = day {
                            let dayNum = calendar.component(.day, from: dayDate)
                            let isWeekend = appSettings.isWeekend(date: dayDate)
                            Text("\(dayNum)")
                                .font(.system(size: 8))
                                .foregroundStyle(isWeekend ? Color.secondary.opacity(0.4) : Color.secondary.opacity(0.6))
                                .frame(width: 14, height: 12)
                        } else {
                            Color.clear
                                .frame(width: 14, height: 12)
                        }
                    }
                }
            }
        }
    }
    
    private var weekdaySymbols: [String] {
        let symbols = calendar.veryShortWeekdaySymbols
        let firstWeekday = appSettings.weekStartsOn.rawValue - 1
        return Array(symbols[firstWeekday...]) + Array(symbols[..<firstWeekday])
    }
    
    private var weeks: [[Date?]] {
        guard let range = calendar.range(of: .day, in: .month, for: month),
              let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: month)) else {
            return []
        }

        var weeks: [[Date?]] = []
        var currentWeek: [Date?] = []

        // Get first day of month
        let firstWeekday = calendar.component(.weekday, from: firstDay)
        let offset = (firstWeekday - appSettings.weekStartsOn.rawValue + 7) % 7
        
        // Add empty cells for offset
        for _ in 0..<offset {
            currentWeek.append(nil)
        }
        
        // Add days
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDay) {
                currentWeek.append(date)
                if currentWeek.count == 7 {
                    weeks.append(currentWeek)
                    currentWeek = []
                }
            }
        }
        
        // Add remaining days
        if !currentWeek.isEmpty {
            while currentWeek.count < 7 {
                currentWeek.append(nil)
            }
            weeks.append(currentWeek)
        }
        
        return weeks
    }
}

// MARK: - THIS YEAR Panel

private struct ThisYearPanel: View {
    let calendarViewModel: CalendarViewModel
    let onDateTap: (Date) -> Void
    let height: CGFloat
    
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            PanelHeader(icon: "calendar.circle", title: "THIS YEAR", subtitle: String(currentYear))
            
            let headerHeight: CGFloat = 50
            let availableHeight = max(height - headerHeight, 0)
            let minQuarterHeight: CGFloat = 110
            let quarterCount = max(1, quarters.count)
            let quarterHeight = max(minQuarterHeight, availableHeight / CGFloat(quarterCount))
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(quarters, id: \.name) { quarter in
                        YearQuarterSection(
                            name: quarter.name,
                            dateRange: quarter.dateRange,
                            months: quarter.months,
                            events: quarter.events,
                            height: quarterHeight
                        )
                    }
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            .frame(height: availableHeight)
        }
        .padding(.top, 8)
    }
    
    private var currentYear: Int {
        calendar.component(.year, from: Date())
    }
    
    private var quarters: [(name: String, dateRange: String, months: [String], events: [CalendarEvent])] {
        let year = currentYear
        let currentMonth = calendar.component(.month, from: Date())
        
        let quarterDefs: [(name: String, range: String, startMonth: Int, endMonth: Int, monthNames: [String])] = [
            ("Q1", "JAN - MAR", 1, 3, ["January", "February", "March"]),
            ("Q2", "APR - JUN", 4, 6, ["April", "May", "June"]),
            ("Q3", "JUL - SEP", 7, 9, ["July", "August", "September"]),
            ("Q4", "OCT - DEC", 10, 12, ["October", "November", "December"])
        ]
        
        return quarterDefs.compactMap { q -> (name: String, dateRange: String, months: [String], events: [CalendarEvent])? in
            guard q.endMonth >= currentMonth else { return nil }
            
            guard let startDate = Date.from(year: year, month: q.startMonth, day: 1),
                  let endDate = calendar.date(byAdding: DateComponents(month: q.endMonth - q.startMonth + 1, day: -1), to: startDate) else {
                return nil
            }
            
            let events = calendarViewModel.events(from: startDate, to: endDate)
            return (name: q.name, dateRange: q.range, months: q.monthNames, events: events)
        }
    }
}

private struct YearQuarterSection: View {
    let name: String
    let dateRange: String
    let months: [String]
    let events: [CalendarEvent]
    let height: CGFloat
    
    var body: some View {
        let maxRows = maxContentRows
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Text(name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text("(\(dateRange))")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            
            if events.isEmpty {
                // Show months in lighter font when empty
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(months.prefix(maxRows), id: \.self) { month in
                        Text(month)
                            .font(.caption)
                            .foregroundStyle(Color.secondary.opacity(0.4))
                    }
                }
            } else {
                let showMoreLabel = events.count > maxRows && maxRows > 1
                let visibleCount = showMoreLabel ? max(1, maxRows - 1) : maxRows

                VStack(alignment: .leading, spacing: 2) {
                    ForEach(events.prefix(visibleCount)) { event in
                        HStack(spacing: 6) {
                            RoundedRectangle(cornerRadius: 1)
                                .fill(Color.secondary.opacity(0.3))
                                .frame(width: 2, height: 14)
                            Text(event.title)
                                .font(.caption)
                                .lineLimit(1)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    if showMoreLabel {
                        Text("+\(events.count - visibleCount) more")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                            .padding(.leading, 8)
                    }
                }
            }
        }
        .frame(height: height, alignment: .topLeading)
        .padding(.horizontal)
        .clipped()
    }

    private var maxContentRows: Int {
        let headerHeight: CGFloat = 22
        let headerSpacing: CGFloat = 6
        let rowHeight: CGFloat = 16
        let rowSpacing: CGFloat = 2
        let availableHeight = max(0, height - headerHeight - headerSpacing)
        let rows = Int((availableHeight + rowSpacing) / (rowHeight + rowSpacing))
        return max(1, rows)
    }
}

// MARK: - Helpers

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

// MARK: - Preview

#Preview {
    PowerLawLayout(
        selectedDate: .constant(nil),
        onDateTap: { _ in }
    )
    .environment(CalendarViewModel())
    .environment(AppSettings())
}
