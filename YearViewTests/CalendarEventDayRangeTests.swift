import XCTest
@testable import YearView

final class CalendarEventDayRangeTests: XCTestCase {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Pacific/Auckland")!
        return calendar
    }

    func testSingleDayAllDayEventAcrossDSTSpansOneDay() throws {
        let start = try XCTUnwrap(
            calendar.date(from: DateComponents(year: 2026, month: 4, day: 5))
        )
        let end = try XCTUnwrap(
            calendar.date(byAdding: .day, value: 1, to: start)
        )
        let event = makeEvent(start: start, end: end, isAllDay: true)

        let interval = event.displayedDayInterval(calendar: calendar)
        let placement = try XCTUnwrap(
            event.displayedDayOffsets(in: interval, calendar: calendar)
        )

        XCTAssertEqual(placement.start, 0)
        XCTAssertEqual(placement.span, 1)
        XCTAssertEqual(end.timeIntervalSince(start), 25 * 60 * 60)
    }

    func testEventCrossingIntoMonthIsClippedToVisibleDays() throws {
        let eventStart = try XCTUnwrap(
            calendar.date(from: DateComponents(year: 2026, month: 3, day: 30))
        )
        let eventEnd = try XCTUnwrap(
            calendar.date(from: DateComponents(year: 2026, month: 4, day: 3))
        )
        let aprilStart = try XCTUnwrap(
            calendar.date(from: DateComponents(year: 2026, month: 4, day: 1))
        )
        let mayStart = try XCTUnwrap(
            calendar.date(from: DateComponents(year: 2026, month: 5, day: 1))
        )
        let event = makeEvent(start: eventStart, end: eventEnd, isAllDay: true)

        let placement = try XCTUnwrap(
            event.displayedDayOffsets(
                in: DateInterval(start: aprilStart, end: mayStart),
                calendar: calendar
            )
        )

        XCTAssertEqual(placement.start, 0)
        XCTAssertEqual(placement.span, 2)
    }

    func testTimedEventEndingAtMidnightDoesNotOccupyNextDay() throws {
        let dayStart = try XCTUnwrap(
            calendar.date(from: DateComponents(year: 2026, month: 6, day: 15))
        )
        let start = try XCTUnwrap(
            calendar.date(byAdding: .hour, value: 20, to: dayStart)
        )
        let end = try XCTUnwrap(
            calendar.date(byAdding: .day, value: 1, to: dayStart)
        )
        let event = makeEvent(start: start, end: end, isAllDay: false)
        let interval = event.displayedDayInterval(calendar: calendar)

        XCTAssertEqual(
            calendar.dateComponents([.day], from: interval.start, to: interval.end).day,
            1
        )
    }

    func testCalendarViewModelIndexesSingleDayAllDayEvent() throws {
        let start = try XCTUnwrap(
            calendar.date(from: DateComponents(year: 2026, month: 7, day: 12))
        )
        let end = try XCTUnwrap(
            calendar.date(byAdding: .day, value: 1, to: start)
        )
        let event = makeEvent(start: start, end: end, isAllDay: true)
        let viewModel = CalendarViewModel()
        viewModel.calendars = [
            CalendarSource(
                id: "calendar",
                title: "Birthdays",
                color: .red,
                sourceType: .local
            )
        ]
        viewModel.events = [event]

        XCTAssertEqual(viewModel.events(for: start), [event])
        XCTAssertTrue(
            viewModel.events(
                for: calendar.date(byAdding: .day, value: 1, to: start)!
            ).isEmpty
        )
    }

    private func makeEvent(
        start: Date,
        end: Date,
        isAllDay: Bool
    ) -> CalendarEvent {
        CalendarEvent(
            id: "event",
            title: "Birthday",
            startDate: start,
            endDate: end,
            isAllDay: isAllDay,
            calendarID: "calendar",
            calendarColor: .red,
            calendarTitle: "Birthdays"
        )
    }
}
