import SwiftUI
import Observation

enum YearLayoutStyle: String, CaseIterable, Identifiable {
    case bigYear = "Year"           // Continuous week rows (Big Year style) - DEFAULT
    case monthRows = "Months"       // Calendar.app-style: each month is one row (6-week strip)
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
    var layoutStyle: YearLayoutStyle = .bigYear  // Default to Big Year style
    var showWeekends: Bool = true
    var showWeekNumbers: Bool = false
    var firstDayOfWeek: Int = 1 // 1 = Sunday, 2 = Monday
    var zoomLevel: CGFloat = 1.0

    private let calendar = Calendar.current

    var months: [MonthData] {
        (1...12).compactMap { month in
            var components = DateComponents()
            components.year = Calendar.current.component(.year, from: Date())
            components.month = month
            components.day = 1

            guard let date = calendar.date(from: components) else { return nil }
            return MonthData(date: date, calendar: calendar)
        }
    }

    func months(for year: Int) -> [MonthData] {
        (1...12).compactMap { month in
            var components = DateComponents()
            components.year = year
            components.month = month
            components.day = 1

            guard let date = calendar.date(from: components) else { return nil }
            return MonthData(date: date, calendar: calendar)
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
    
    var id: Date { date }

    init(date: Date, calendar: Calendar) {
        self.date = date

        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        self.name = formatter.string(from: date)

        formatter.dateFormat = "MMM"
        self.shortName = formatter.string(from: date)

        // Generate weekday headers
        let symbols = calendar.veryShortWeekdaySymbols
        self.weekdayHeaders = symbols

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

        // Add leading empty days
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
        self.isWeekend = weekday == 1 || weekday == 7 // Sunday or Saturday
    }
}
