import XCTest
@testable import YearView

final class DayViewModelTests: XCTestCase {

    var viewModel: DayViewModel!
    var testDate: Date!
    var testEvents: [CalendarEvent]!

    override func setUp() {
        super.setUp()
        testDate = Date.from(year: 2026, month: 6, day: 15)!

        testEvents = [
            CalendarEvent(
                id: "1",
                title: "Morning Standup",
                startDate: testDate.addingTimeInterval(9 * 3600), // 9 AM
                endDate: testDate.addingTimeInterval(9.5 * 3600), // 9:30 AM
                isAllDay: false,
                calendarID: "work",
                calendarColor: .blue,
                calendarTitle: "Work"
            ),
            CalendarEvent(
                id: "2",
                title: "Company Holiday",
                startDate: testDate,
                endDate: testDate.addingTimeInterval(86400),
                isAllDay: true,
                calendarID: "company",
                calendarColor: .green,
                calendarTitle: "Company"
            ),
            CalendarEvent(
                id: "3",
                title: "Lunch Meeting",
                startDate: testDate.addingTimeInterval(12 * 3600), // 12 PM
                endDate: testDate.addingTimeInterval(13 * 3600), // 1 PM
                isAllDay: false,
                calendarID: "work",
                calendarColor: .blue,
                calendarTitle: "Work"
            ),
        ]

        viewModel = DayViewModel(date: testDate, events: testEvents)
    }

    override func tearDown() {
        viewModel = nil
        testDate = nil
        testEvents = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testInitialization() {
        XCTAssertEqual(viewModel.selectedDate, testDate)
        XCTAssertEqual(viewModel.events.count, 3)
        XCTAssertFalse(viewModel.isLoading)
    }

    func testDefaultInitialization() {
        let defaultViewModel = DayViewModel()

        XCTAssertTrue(defaultViewModel.events.isEmpty)
        XCTAssertFalse(defaultViewModel.isLoading)
    }

    // MARK: - Date Formatting Tests

    func testFormattedDate() {
        // Should return full date format like "Monday, June 15, 2026"
        let formatted = viewModel.formattedDate

        XCTAssertTrue(formatted.contains("2026"))
        XCTAssertTrue(formatted.contains("June") || formatted.contains("15"))
    }

    func testShortFormattedDate() {
        // Should return format like "Monday, Jun 15"
        let formatted = viewModel.shortFormattedDate

        XCTAssertTrue(formatted.contains("Jun") || formatted.contains("15"))
    }

    // MARK: - Event Sorting Tests

    func testSortedEventsAllDayFirst() {
        let sorted = viewModel.sortedEvents

        // All-day events should come first
        XCTAssertTrue(sorted[0].isAllDay)
    }

    func testSortedEventsTimedByStartTime() {
        let sorted = viewModel.sortedEvents

        // Filter to timed events only
        let timedEvents = sorted.filter { !$0.isAllDay }

        // Should be sorted by start time
        for i in 0..<(timedEvents.count - 1) {
            XCTAssertLessThanOrEqual(timedEvents[i].startDate, timedEvents[i + 1].startDate)
        }
    }

    // MARK: - Event Filtering Tests

    func testAllDayEvents() {
        let allDay = viewModel.allDayEvents

        XCTAssertEqual(allDay.count, 1)
        XCTAssertTrue(allDay.allSatisfy { $0.isAllDay })
    }

    func testTimedEvents() {
        let timed = viewModel.timedEvents

        XCTAssertEqual(timed.count, 2)
        XCTAssertTrue(timed.allSatisfy { !$0.isAllDay })
    }

    func testTimedEventsSortedByTime() {
        let timed = viewModel.timedEvents

        XCTAssertEqual(timed[0].title, "Morning Standup")
        XCTAssertEqual(timed[1].title, "Lunch Meeting")
    }

    // MARK: - Time Formatting Tests

    func testFormattedTimeAllDay() {
        let allDayEvent = testEvents.first { $0.isAllDay }!
        let formatted = viewModel.formattedTime(for: allDayEvent)

        XCTAssertEqual(formatted, "All day")
    }

    func testFormattedTimeRegularEvent() {
        let timedEvent = testEvents.first { !$0.isAllDay }!
        let formatted = viewModel.formattedTime(for: timedEvent)

        // Should contain time range like "9:00 AM - 9:30 AM"
        XCTAssertTrue(formatted.contains("-"))
    }

    // MARK: - Duration Formatting Tests

    func testFormattedDurationHoursAndMinutes() {
        let event = CalendarEvent(
            id: "dur-1",
            title: "Meeting",
            startDate: testDate,
            endDate: testDate.addingTimeInterval(5400), // 1.5 hours
            isAllDay: false,
            calendarID: "work",
            calendarColor: .blue,
            calendarTitle: "Work"
        )

        let formatted = viewModel.formattedDuration(for: event)
        XCTAssertEqual(formatted, "1h 30m")
    }

    func testFormattedDurationHoursOnly() {
        let event = CalendarEvent(
            id: "dur-2",
            title: "Meeting",
            startDate: testDate,
            endDate: testDate.addingTimeInterval(7200), // 2 hours
            isAllDay: false,
            calendarID: "work",
            calendarColor: .blue,
            calendarTitle: "Work"
        )

        let formatted = viewModel.formattedDuration(for: event)
        XCTAssertEqual(formatted, "2h")
    }

    func testFormattedDurationMinutesOnly() {
        let event = CalendarEvent(
            id: "dur-3",
            title: "Quick Sync",
            startDate: testDate,
            endDate: testDate.addingTimeInterval(900), // 15 minutes
            isAllDay: false,
            calendarID: "work",
            calendarColor: .blue,
            calendarTitle: "Work"
        )

        let formatted = viewModel.formattedDuration(for: event)
        XCTAssertEqual(formatted, "15m")
    }

    // MARK: - Empty State Tests

    func testEmptyEvents() {
        let emptyViewModel = DayViewModel(date: testDate, events: [])

        XCTAssertTrue(emptyViewModel.allDayEvents.isEmpty)
        XCTAssertTrue(emptyViewModel.timedEvents.isEmpty)
        XCTAssertTrue(emptyViewModel.sortedEvents.isEmpty)
    }
}
