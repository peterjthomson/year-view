import XCTest
@testable import YearView

final class CalendarEventTests: XCTestCase {

    // MARK: - Initialization Tests

    func testEventInitialization() {
        let startDate = Date()
        let endDate = startDate.addingTimeInterval(3600) // 1 hour later

        let event = CalendarEvent(
            id: "test-123",
            title: "Test Meeting",
            startDate: startDate,
            endDate: endDate,
            isAllDay: false,
            calendarID: "cal-1",
            calendarColor: .blue,
            calendarTitle: "Work",
            location: "Conference Room A",
            notes: "Discuss Q1 goals",
            url: URL(string: "https://example.com"),
            hasVideoCall: true,
            videoCallURL: URL(string: "https://meet.google.com/abc-defg-hij")
        )

        XCTAssertEqual(event.id, "test-123")
        XCTAssertEqual(event.title, "Test Meeting")
        XCTAssertEqual(event.startDate, startDate)
        XCTAssertEqual(event.endDate, endDate)
        XCTAssertFalse(event.isAllDay)
        XCTAssertEqual(event.calendarID, "cal-1")
        XCTAssertEqual(event.calendarTitle, "Work")
        XCTAssertEqual(event.location, "Conference Room A")
        XCTAssertEqual(event.notes, "Discuss Q1 goals")
        XCTAssertTrue(event.hasVideoCall)
        XCTAssertNotNil(event.videoCallURL)
    }

    func testAllDayEvent() {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = startOfDay.addingTimeInterval(86400)

        let event = CalendarEvent(
            id: "allday-1",
            title: "Company Holiday",
            startDate: startOfDay,
            endDate: endOfDay,
            isAllDay: true,
            calendarID: "cal-1",
            calendarColor: .green,
            calendarTitle: "Company"
        )

        XCTAssertTrue(event.isAllDay)
        XCTAssertEqual(event.duration, 86400, accuracy: 1)
    }

    // MARK: - Multi-day Event Tests

    func testIsMultiDayEvent() {
        let startDate = Date()
        let endDate = startDate.addingTimeInterval(86400 * 3) // 3 days later

        let event = CalendarEvent(
            id: "multiday-1",
            title: "Conference",
            startDate: startDate,
            endDate: endDate,
            isAllDay: false,
            calendarID: "cal-1",
            calendarColor: .purple,
            calendarTitle: "Events"
        )

        XCTAssertTrue(event.isMultiDay)
    }

    func testSingleDayEventIsNotMultiDay() {
        let startDate = Date()
        let endDate = startDate.addingTimeInterval(3600) // 1 hour later

        let event = CalendarEvent(
            id: "single-1",
            title: "Quick Meeting",
            startDate: startDate,
            endDate: endDate,
            isAllDay: false,
            calendarID: "cal-1",
            calendarColor: .blue,
            calendarTitle: "Work"
        )

        XCTAssertFalse(event.isMultiDay)
    }

    // MARK: - Duration Tests

    func testEventDuration() {
        let startDate = Date()
        let endDate = startDate.addingTimeInterval(5400) // 1.5 hours

        let event = CalendarEvent(
            id: "dur-1",
            title: "Long Meeting",
            startDate: startDate,
            endDate: endDate,
            isAllDay: false,
            calendarID: "cal-1",
            calendarColor: .blue,
            calendarTitle: "Work"
        )

        XCTAssertEqual(event.duration, 5400, accuracy: 0.001)
    }

    // MARK: - Equatable & Hashable Tests

    func testEventEquality() {
        let event1 = CalendarEvent(
            id: "same-id",
            title: "Meeting 1",
            startDate: Date(),
            endDate: Date(),
            isAllDay: false,
            calendarID: "cal-1",
            calendarColor: .blue,
            calendarTitle: "Work"
        )

        let event2 = CalendarEvent(
            id: "same-id",
            title: "Different Title",
            startDate: Date().addingTimeInterval(3600),
            endDate: Date().addingTimeInterval(7200),
            isAllDay: true,
            calendarID: "cal-2",
            calendarColor: .red,
            calendarTitle: "Personal"
        )

        XCTAssertEqual(event1, event2) // Same ID means equal
    }

    func testEventInequality() {
        let event1 = CalendarEvent(
            id: "id-1",
            title: "Meeting",
            startDate: Date(),
            endDate: Date(),
            isAllDay: false,
            calendarID: "cal-1",
            calendarColor: .blue,
            calendarTitle: "Work"
        )

        let event2 = CalendarEvent(
            id: "id-2",
            title: "Meeting",
            startDate: Date(),
            endDate: Date(),
            isAllDay: false,
            calendarID: "cal-1",
            calendarColor: .blue,
            calendarTitle: "Work"
        )

        XCTAssertNotEqual(event1, event2) // Different IDs
    }

    func testEventHashable() {
        let event1 = CalendarEvent(
            id: "hash-test",
            title: "Meeting",
            startDate: Date(),
            endDate: Date(),
            isAllDay: false,
            calendarID: "cal-1",
            calendarColor: .blue,
            calendarTitle: "Work"
        )

        let event2 = CalendarEvent(
            id: "hash-test",
            title: "Different",
            startDate: Date(),
            endDate: Date(),
            isAllDay: false,
            calendarID: "cal-1",
            calendarColor: .blue,
            calendarTitle: "Work"
        )

        var set = Set<CalendarEvent>()
        set.insert(event1)
        set.insert(event2)

        XCTAssertEqual(set.count, 1) // Same ID, should dedupe
    }

    // MARK: - Preview Data Tests

    func testPreviewEvent() {
        let preview = CalendarEvent.preview

        XCTAssertEqual(preview.title, "Team Meeting")
        XCTAssertFalse(preview.isAllDay)
        XCTAssertTrue(preview.hasVideoCall)
        XCTAssertNotNil(preview.videoCallURL)
    }

    func testPreviewAllDayEvent() {
        let preview = CalendarEvent.previewAllDay

        XCTAssertEqual(preview.title, "Company Holiday")
        XCTAssertTrue(preview.isAllDay)
    }
}
