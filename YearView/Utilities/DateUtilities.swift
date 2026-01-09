import Foundation

extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay) ?? self
    }

    var startOfMonth: Date {
        let components = Calendar.current.dateComponents([.year, .month], from: self)
        return Calendar.current.date(from: components) ?? self
    }

    var endOfMonth: Date {
        var components = DateComponents()
        components.month = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfMonth) ?? self
    }

    var startOfYear: Date {
        let components = Calendar.current.dateComponents([.year], from: self)
        return Calendar.current.date(from: components) ?? self
    }

    var endOfYear: Date {
        var components = DateComponents()
        components.year = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfYear) ?? self
    }

    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    var isWeekend: Bool {
        let weekday = Calendar.current.component(.weekday, from: self)
        return weekday == 1 || weekday == 7
    }

    func isSameDay(as other: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: other)
    }

    func isSameMonth(as other: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.component(.year, from: self) == calendar.component(.year, from: other) &&
               calendar.component(.month, from: self) == calendar.component(.month, from: other)
    }

    func isSameYear(as other: Date) -> Bool {
        Calendar.current.component(.year, from: self) == Calendar.current.component(.year, from: other)
    }

    func adding(days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: self) ?? self
    }

    func adding(months: Int) -> Date {
        Calendar.current.date(byAdding: .month, value: months, to: self) ?? self
    }

    func adding(years: Int) -> Date {
        Calendar.current.date(byAdding: .year, value: years, to: self) ?? self
    }

    var dayOfMonth: Int {
        Calendar.current.component(.day, from: self)
    }

    var month: Int {
        Calendar.current.component(.month, from: self)
    }

    var year: Int {
        Calendar.current.component(.year, from: self)
    }

    var weekday: Int {
        Calendar.current.component(.weekday, from: self)
    }

    var weekOfYear: Int {
        Calendar.current.component(.weekOfYear, from: self)
    }

    static func from(year: Int, month: Int, day: Int) -> Date? {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        return Calendar.current.date(from: components)
    }
}

extension Calendar {
    func daysInMonth(for date: Date) -> Int {
        range(of: .day, in: .month, for: date)?.count ?? 30
    }

    func firstDayOfMonth(for date: Date) -> Date {
        let components = dateComponents([.year, .month], from: date)
        return self.date(from: components) ?? date
    }

    func allDays(in month: Date) -> [Date] {
        guard let range = range(of: .day, in: .month, for: month) else { return [] }
        let firstDay = firstDayOfMonth(for: month)

        return range.compactMap { day -> Date? in
            self.date(byAdding: .day, value: day - 1, to: firstDay)
        }
    }

    func allMonths(in year: Int) -> [Date] {
        (1...12).compactMap { month in
            Date.from(year: year, month: month, day: 1)
        }
    }
}

struct DateRange {
    let start: Date
    let end: Date

    var days: [Date] {
        var dates: [Date] = []
        var current = start

        while current <= end {
            dates.append(current)
            current = current.adding(days: 1)
        }

        return dates
    }

    func contains(_ date: Date) -> Bool {
        date >= start && date <= end
    }

    static func month(containing date: Date) -> DateRange {
        DateRange(start: date.startOfMonth, end: date.endOfMonth)
    }

    static func year(containing date: Date) -> DateRange {
        DateRange(start: date.startOfYear, end: date.endOfYear)
    }

    static func year(_ year: Int) -> DateRange {
        let calendar = Calendar.current
        var startComponents = DateComponents()
        startComponents.year = year
        startComponents.month = 1
        startComponents.day = 1

        var endComponents = DateComponents()
        endComponents.year = year
        endComponents.month = 12
        endComponents.day = 31

        let start = calendar.date(from: startComponents) ?? Date()
        let end = calendar.date(from: endComponents) ?? Date()

        return DateRange(start: start, end: end)
    }
}
