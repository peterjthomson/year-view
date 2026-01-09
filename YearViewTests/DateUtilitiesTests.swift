import XCTest
@testable import YearView

final class DateUtilitiesTests: XCTestCase {

    let calendar = Calendar.current

    // MARK: - Date Extension Tests

    func testStartOfDay() {
        let date = Date()
        let startOfDay = date.startOfDay

        let components = calendar.dateComponents([.hour, .minute, .second], from: startOfDay)
        XCTAssertEqual(components.hour, 0)
        XCTAssertEqual(components.minute, 0)
        XCTAssertEqual(components.second, 0)
    }

    func testStartOfMonth() {
        let date = Date.from(year: 2026, month: 6, day: 15)!
        let startOfMonth = date.startOfMonth

        let components = calendar.dateComponents([.year, .month, .day], from: startOfMonth)
        XCTAssertEqual(components.year, 2026)
        XCTAssertEqual(components.month, 6)
        XCTAssertEqual(components.day, 1)
    }

    func testStartOfYear() {
        let date = Date.from(year: 2026, month: 6, day: 15)!
        let startOfYear = date.startOfYear

        let components = calendar.dateComponents([.year, .month, .day], from: startOfYear)
        XCTAssertEqual(components.year, 2026)
        XCTAssertEqual(components.month, 1)
        XCTAssertEqual(components.day, 1)
    }

    func testIsToday() {
        let today = Date()
        let yesterday = today.adding(days: -1)
        let tomorrow = today.adding(days: 1)

        XCTAssertTrue(today.isToday)
        XCTAssertFalse(yesterday.isToday)
        XCTAssertFalse(tomorrow.isToday)
    }

    func testIsWeekend() {
        // Create a known Saturday (Jan 3, 2026 is a Saturday)
        let saturday = Date.from(year: 2026, month: 1, day: 3)!
        let sunday = Date.from(year: 2026, month: 1, day: 4)!
        let monday = Date.from(year: 2026, month: 1, day: 5)!
        let friday = Date.from(year: 2026, month: 1, day: 2)!

        XCTAssertTrue(saturday.isWeekend)
        XCTAssertTrue(sunday.isWeekend)
        XCTAssertFalse(monday.isWeekend)
        XCTAssertFalse(friday.isWeekend)
    }

    func testIsSameDay() {
        let date1 = Date.from(year: 2026, month: 1, day: 15)!
        let date2 = Date.from(year: 2026, month: 1, day: 15)!.addingTimeInterval(3600)
        let date3 = Date.from(year: 2026, month: 1, day: 16)!

        XCTAssertTrue(date1.isSameDay(as: date2))
        XCTAssertFalse(date1.isSameDay(as: date3))
    }

    func testIsSameMonth() {
        let date1 = Date.from(year: 2026, month: 3, day: 1)!
        let date2 = Date.from(year: 2026, month: 3, day: 31)!
        let date3 = Date.from(year: 2026, month: 4, day: 1)!
        let date4 = Date.from(year: 2025, month: 3, day: 15)!

        XCTAssertTrue(date1.isSameMonth(as: date2))
        XCTAssertFalse(date1.isSameMonth(as: date3))
        XCTAssertFalse(date1.isSameMonth(as: date4)) // Different year
    }

    func testIsSameYear() {
        let date1 = Date.from(year: 2026, month: 1, day: 1)!
        let date2 = Date.from(year: 2026, month: 12, day: 31)!
        let date3 = Date.from(year: 2025, month: 6, day: 15)!

        XCTAssertTrue(date1.isSameYear(as: date2))
        XCTAssertFalse(date1.isSameYear(as: date3))
    }

    // MARK: - Adding Time Tests

    func testAddingDays() {
        let date = Date.from(year: 2026, month: 1, day: 15)!
        let result = date.adding(days: 10)

        XCTAssertEqual(result.dayOfMonth, 25)
    }

    func testAddingMonths() {
        let date = Date.from(year: 2026, month: 3, day: 15)!
        let result = date.adding(months: 2)

        XCTAssertEqual(result.month, 5)
    }

    func testAddingYears() {
        let date = Date.from(year: 2026, month: 6, day: 15)!
        let result = date.adding(years: 3)

        XCTAssertEqual(result.year, 2029)
    }

    func testAddingNegativeDays() {
        let date = Date.from(year: 2026, month: 1, day: 15)!
        let result = date.adding(days: -10)

        XCTAssertEqual(result.dayOfMonth, 5)
    }

    // MARK: - Date Component Tests

    func testDayOfMonth() {
        let date = Date.from(year: 2026, month: 5, day: 23)!
        XCTAssertEqual(date.dayOfMonth, 23)
    }

    func testMonth() {
        let date = Date.from(year: 2026, month: 8, day: 15)!
        XCTAssertEqual(date.month, 8)
    }

    func testYear() {
        let date = Date.from(year: 2026, month: 1, day: 1)!
        XCTAssertEqual(date.year, 2026)
    }

    func testWeekday() {
        // Jan 1, 2026 is a Thursday (weekday = 5)
        let date = Date.from(year: 2026, month: 1, day: 1)!
        XCTAssertEqual(date.weekday, 5)
    }

    // MARK: - Date Factory Tests

    func testDateFromComponents() {
        let date = Date.from(year: 2026, month: 7, day: 4)

        XCTAssertNotNil(date)
        XCTAssertEqual(date?.year, 2026)
        XCTAssertEqual(date?.month, 7)
        XCTAssertEqual(date?.dayOfMonth, 4)
    }

    // MARK: - Calendar Extension Tests

    func testDaysInMonth() {
        let january = Date.from(year: 2026, month: 1, day: 1)!
        let february = Date.from(year: 2026, month: 2, day: 1)! // Not a leap year
        let february2024 = Date.from(year: 2024, month: 2, day: 1)! // Leap year

        XCTAssertEqual(calendar.daysInMonth(for: january), 31)
        XCTAssertEqual(calendar.daysInMonth(for: february), 28)
        XCTAssertEqual(calendar.daysInMonth(for: february2024), 29)
    }

    func testAllDaysInMonth() {
        let january = Date.from(year: 2026, month: 1, day: 15)!
        let days = calendar.allDays(in: january)

        XCTAssertEqual(days.count, 31)
        XCTAssertEqual(days.first?.dayOfMonth, 1)
        XCTAssertEqual(days.last?.dayOfMonth, 31)
    }

    func testAllMonthsInYear() {
        let months = calendar.allMonths(in: 2026)

        XCTAssertEqual(months.count, 12)
        XCTAssertEqual(months.first?.month, 1)
        XCTAssertEqual(months.last?.month, 12)
    }

    // MARK: - DateRange Tests

    func testDateRangeDays() {
        let start = Date.from(year: 2026, month: 1, day: 1)!
        let end = Date.from(year: 2026, month: 1, day: 5)!
        let range = DateRange(start: start, end: end)

        let days = range.days
        XCTAssertEqual(days.count, 5)
    }

    func testDateRangeContains() {
        let start = Date.from(year: 2026, month: 1, day: 1)!
        let end = Date.from(year: 2026, month: 1, day: 31)!
        let range = DateRange(start: start, end: end)

        let inside = Date.from(year: 2026, month: 1, day: 15)!
        let outside = Date.from(year: 2026, month: 2, day: 1)!

        XCTAssertTrue(range.contains(inside))
        XCTAssertFalse(range.contains(outside))
    }

    func testDateRangeYear() {
        let range = DateRange.year(2026)

        XCTAssertEqual(range.start.year, 2026)
        XCTAssertEqual(range.start.month, 1)
        XCTAssertEqual(range.start.dayOfMonth, 1)
        XCTAssertEqual(range.end.year, 2026)
        XCTAssertEqual(range.end.month, 12)
        XCTAssertEqual(range.end.dayOfMonth, 31)
    }
}
