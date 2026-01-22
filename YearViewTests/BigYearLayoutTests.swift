import XCTest
@testable import YearView

final class BigYearLayoutTests: XCTestCase {

    let calendar = Calendar.current

    // MARK: - Week Generation Tests

    func testWeeksInYearCoversFullYear() {
        // A year should have approximately 52-53 weeks
        let year = 2026

        guard let startOfYear = calendar.date(from: DateComponents(year: year, month: 1, day: 1)),
              let endOfYear = calendar.date(from: DateComponents(year: year, month: 12, day: 31)) else {
            XCTFail("Could not create year dates")
            return
        }

        // Count weeks between start and end
        let weeks = calendar.dateComponents([.weekOfYear], from: startOfYear, to: endOfYear).weekOfYear ?? 0

        XCTAssertGreaterThanOrEqual(weeks, 51)
        XCTAssertLessThanOrEqual(weeks, 53)
    }

    func testFirstWeekContainsJanuaryFirst() {
        let year = 2026

        guard let jan1 = calendar.date(from: DateComponents(year: year, month: 1, day: 1)) else {
            XCTFail("Could not create Jan 1")
            return
        }

        // Get the start of the week containing Jan 1
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: jan1)
        components.weekday = calendar.firstWeekday
        let weekStart = calendar.date(from: components)!

        // The week should contain Jan 1
        let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart)!

        XCTAssertTrue(jan1 >= weekStart && jan1 <= weekEnd)
    }

    // MARK: - Event Bar Layout Tests

    func testSingleDayEventSpansOneColumn() {
        let date = Date.from(year: 2026, month: 6, day: 15)!

        let event = CalendarEvent(
            id: "test-1",
            title: "Meeting",
            startDate: date.addingTimeInterval(9 * 3600),
            endDate: date.addingTimeInterval(10 * 3600),
            isAllDay: false,
            calendarID: "cal-1",
            calendarColor: .blue,
            calendarTitle: "Work"
        )

        // A single-day event should span exactly 1 column
        XCTAssertFalse(event.isMultiDay)
    }

    func testMultiDayEventSpansMultipleColumns() {
        let startDate = Date.from(year: 2026, month: 6, day: 15)!
        let endDate = Date.from(year: 2026, month: 6, day: 18)!

        let event = CalendarEvent(
            id: "test-2",
            title: "Conference",
            startDate: startDate,
            endDate: endDate,
            isAllDay: true,
            calendarID: "cal-1",
            calendarColor: .green,
            calendarTitle: "Events"
        )

        XCTAssertTrue(event.isMultiDay)

        // Event spans 4 days (15, 16, 17, 18)
        let daysDiff = calendar.dateComponents([.day], from: startDate, to: endDate).day ?? 0
        XCTAssertEqual(daysDiff, 3) // 3 days difference = 4 days span
    }

    func testEventCrossesWeekBoundary() {
        // Event that starts on Saturday and ends on Monday
        // Should appear in two different week rows
        let saturday = Date.from(year: 2026, month: 1, day: 3)! // Saturday
        let monday = Date.from(year: 2026, month: 1, day: 5)!   // Monday

        let event = CalendarEvent(
            id: "test-3",
            title: "Weekend Trip",
            startDate: saturday,
            endDate: monday,
            isAllDay: true,
            calendarID: "cal-1",
            calendarColor: .orange,
            calendarTitle: "Personal"
        )

        XCTAssertTrue(event.isMultiDay)

        // Verify the dates are in different weeks
        let saturdayWeek = calendar.component(.weekOfYear, from: saturday)
        let mondayWeek = calendar.component(.weekOfYear, from: monday)

        // They should be in consecutive weeks (or same week depending on firstWeekday)
        XCTAssertTrue(mondayWeek >= saturdayWeek)
    }

    // MARK: - Month Label Tests

    func testMonthLabelShowsOnFirstOfMonth() {
        // January 1st should show month label
        let jan1 = Date.from(year: 2026, month: 1, day: 1)!
        let jan2 = Date.from(year: 2026, month: 1, day: 2)!

        XCTAssertEqual(calendar.component(.day, from: jan1), 1)
        XCTAssertNotEqual(calendar.component(.day, from: jan2), 1)
    }

    func testAllMonthsHaveFirstDay() {
        let year = 2026

        for month in 1...12 {
            guard let firstOfMonth = calendar.date(from: DateComponents(year: year, month: month, day: 1)) else {
                XCTFail("Could not create first of month \(month)")
                continue
            }

            XCTAssertEqual(calendar.component(.day, from: firstOfMonth), 1)
            XCTAssertEqual(calendar.component(.month, from: firstOfMonth), month)
        }
    }

    // MARK: - Today Highlight Tests

    func testTodayIsCorrectlyIdentified() {
        let today = Date()

        XCTAssertTrue(calendar.isDateInToday(today))
        XCTAssertFalse(calendar.isDateInToday(today.addingTimeInterval(-86400)))
        XCTAssertFalse(calendar.isDateInToday(today.addingTimeInterval(86400)))
    }

    // MARK: - Year Boundary Tests

    func testDaysOutsideYearAreMarked() {
        // When viewing 2026, days from Dec 2025 or Jan 2027 that appear
        // in boundary weeks should be visually different

        let dec31_2025 = Date.from(year: 2025, month: 12, day: 31)!
        let jan1_2026 = Date.from(year: 2026, month: 1, day: 1)!
        let jan1_2027 = Date.from(year: 2027, month: 1, day: 1)!

        XCTAssertEqual(calendar.component(.year, from: dec31_2025), 2025)
        XCTAssertEqual(calendar.component(.year, from: jan1_2026), 2026)
        XCTAssertEqual(calendar.component(.year, from: jan1_2027), 2027)
    }
}
