import SwiftUI
import Observation

enum YearLayoutStyle: String, CaseIterable, Identifiable {
    case monthRows = "Months"       // Calendar.app-style: each month is one row - DEFAULT
    case bigYear = "Year"           // Continuous week rows (Big Year style)
    case standardGrid = "Grid"      // Traditional 4×3 month grid
    case continuousRow = "Row"      // Horizontal month scroll
    case verticalList = "List"      // Vertical month list

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .bigYear:
            return "calendar"
        case .monthRows:
            return "rectangle.grid.1x2"
        case .standardGrid:
            return "square.grid.3x3"
        case .continuousRow:
            return "rectangle.split.3x1"
        case .verticalList:
            return "list.bullet"
        }
    }

    var description: String {
        switch self {
        case .bigYear:
            return "Continuous week rows"
        case .monthRows:
            return "Month rows"
        case .standardGrid:
            return "Month grid"
        case .continuousRow:
            return "Horizontal scroll"
        case .verticalList:
            return "Vertical list"
        }
    }
}

@Observable
final class YearViewModel {
    var layoutStyle: YearLayoutStyle = .monthRows  // Default to month rows style
    var showWeekends: Bool = true
    var showWeekNumbers: Bool = false
    var zoomLevel: CGFloat = 1.0

    func months(for year: Int, using appSettings: AppSettings) -> [MonthData] {
        let calendar = appSettings.calendar
        return (1...12).compactMap { month in
            var components = DateComponents()
            components.year = year
            components.month = month
            components.day = 1

            guard let date = calendar.date(from: components) else { return nil }
            return MonthData(date: date, calendar: calendar, appSettings: appSettings)
        }
    }
    
    // Legacy method for compatibility
    func months(for year: Int) -> [MonthData] {
        let calendar = Calendar.current
        return (1...12).compactMap { month in
            var components = DateComponents()
            components.year = year
            components.month = month
            components.day = 1

            guard let date = calendar.date(from: components) else { return nil }
            return MonthData(date: date, calendar: calendar, appSettings: nil)
        }
    }
}

struct MonthData: Identifiable {
    let date: Date
    let name: String
    let shortName: String
    let days: [DayData]
    let weeks: [[DayData?]]
    let weekdayHeaders: [String]
    /// Weekday numbers (1-7) for each column, respecting firstWeekday
    let weekdayNumbers: [Int]
    
    var id: Date { date }

    init(date: Date, calendar: Calendar, appSettings: AppSettings? = nil) {
        self.date = date

        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        self.name = formatter.string(from: date)

        formatter.dateFormat = "MMM"
        self.shortName = formatter.string(from: date)

        // Generate weekday headers respecting firstWeekday
        let allSymbols = calendar.veryShortWeekdaySymbols // 0=Sun, 1=Mon, etc. (0-indexed)
        let firstWeekday = calendar.firstWeekday // 1=Sun, 2=Mon, etc. (1-indexed)
        
        // Reorder symbols based on firstWeekday
        var orderedSymbols: [String] = []
        var orderedWeekdays: [Int] = []
        for i in 0..<7 {
            let index = (firstWeekday - 1 + i) % 7
            orderedSymbols.append(allSymbols[index])
            orderedWeekdays.append(index + 1) // Convert back to 1-indexed weekday
        }
        self.weekdayHeaders = orderedSymbols
        self.weekdayNumbers = orderedWeekdays

        // Generate days for the month
        guard let range = calendar.range(of: .day, in: .month, for: date) else {
            self.days = []
            self.weeks = []
            return
        }

        var days: [DayData] = []
        for day in range {
            var components = calendar.dateComponents([.year, .month], from: date)
            components.day = day
            if let dayDate = calendar.date(from: components) {
                days.append(DayData(date: dayDate, calendar: calendar))
            }
        }
        self.days = days

        // Organize into weeks
        var weeks: [[DayData?]] = []
        var currentWeek: [DayData?] = Array(repeating: nil, count: 7)

        if let firstDay = days.first {
            let weekday = calendar.component(.weekday, from: firstDay.date)
            let offset = weekday - calendar.firstWeekday
            let adjustedOffset = offset >= 0 ? offset : offset + 7

            for (index, day) in days.enumerated() {
                let position = (adjustedOffset + index) % 7
                currentWeek[position] = day

                if position == 6 || index == days.count - 1 {
                    weeks.append(currentWeek)
                    currentWeek = Array(repeating: nil, count: 7)
                }
            }
        }

        self.weeks = weeks
    }
    
    /// Returns weeks with single-day weeks collapsed (for compact display)
    /// If a week has only one day at the start of month, it's merged with the next week
    /// If a week has only one day at the end of month, it's merged with the previous week
    var collapsedWeeks: [[DayData?]] {
        guard weeks.count > 1 else { return weeks }
        
        var result = weeks
        
        // Check first week - if it has only 1 day, we don't show it separately
        if let firstWeek = result.first {
            let daysInFirstWeek = firstWeek.compactMap { $0 }.count
            if daysInFirstWeek == 1 {
                // Remove the first week (it will naturally flow into calendar view)
                result.removeFirst()
            }
        }
        
        // Check last week - if it has only 1 day, we don't show it separately  
        if let lastWeek = result.last {
            let daysInLastWeek = lastWeek.compactMap { $0 }.count
            if daysInLastWeek == 1 && result.count > 1 {
                // Remove the last week
                result.removeLast()
            }
        }
        
        return result
    }
}

struct DayData: Identifiable {
    let date: Date
    let dayNumber: Int
    let isToday: Bool
    let isWeekend: Bool
    let weekday: Int
    
    var id: Date { date }

    init(date: Date, calendar: Calendar) {
        self.date = date
        self.dayNumber = calendar.component(.day, from: date)
        self.isToday = calendar.isDateInToday(date)
        self.weekday = calendar.component(.weekday, from: date)
        // Weekend is always Saturday (7) and Sunday (1)
        self.isWeekend = weekday == 1 || weekday == 7
    }
}
