import XCTest
import SwiftUI
@testable import YearView

final class MonthRowEventDisplayTests: XCTestCase {
    private let calendar = Calendar.current
    private var defaults: UserDefaults!
    private var suiteName: String!

    override func setUp() {
        super.setUp()
        suiteName = "MonthRowEventDisplayTests.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)!
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        defaults = nil
        super.tearDown()
    }

    private func settings() -> AppSettings {
        AppSettings(cache: CalendarCacheService(userDefaults: defaults))
    }

    private func date(_ day: Int, month: Int = 7) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: month, day: day))!
    }

    private func event(_ id: String, start: Date, end: Date, color: Color = .red) -> CalendarEvent {
        CalendarEvent(id: id, title: id, startDate: start, endDate: end,
                      isAllDay: true, calendarID: "test", calendarColor: color, calendarTitle: "Test")
    }

    private func row(_ events: [CalendarEvent], height: CGFloat = 80, showTitles: Bool = true) -> MonthRow {
        let settings = settings()
        settings.showAllDayEvents = true
        settings.showMonthRowEvents = showTitles
        let model = CalendarViewModel()
        model.calendars = [CalendarSource(id: "test", title: "Test", color: .red, sourceType: .local)]
        model.events = events
        return MonthRow(month: MonthData(date: date(1), calendar: settings.calendar, appSettings: settings),
                        cellSize: CGSize(width: 40, height: height), monthLabelWidth: 24,
                        totalColumns: 37, selectedDate: nil, calendarViewModel: model,
                        appSettings: settings, verticalPadding: 4, onDateTap: { _ in })
    }

    func testIssue9MultipleEventsOnSameDayAreDisplayed() {
        let events = [event("First", start: date(6), end: date(7)),
                      event("Second", start: date(6), end: date(7), color: .blue),
                      event("Third", start: date(6), end: date(7), color: .green)]
        XCTAssertEqual(Set(row(events).featuredEventSegments.map(\.event.id)), Set(events.map(\.id)))
    }

    func testIssue11OverlappingEventDoesNotLoseItsFinalDay() throws {
        let trip = event("Buenos Aires", start: date(6), end: date(11))
        let overlap = event("Longer event", start: date(10), end: date(20))
        let segment = try XCTUnwrap(row([trip, overlap]).featuredEventSegments.first { $0.event.id == trip.id })
        XCTAssertEqual(segment.span, 5, "The trip must remain visible on July 6–10, including the overlapping final day")
    }

    func testIssue11ScreenshotDateRangesIncludeLastDay() throws {
        let events = [event("Kuelap", start: date(29, month: 6), end: date(4)),
                      event("Lima", start: date(4), end: date(6)),
                      event("Buenos Aires", start: date(6), end: date(11))]
        let segments = row(events).featuredEventSegments
        for (id, expectedSpan) in [("Kuelap", 3), ("Lima", 2), ("Buenos Aires", 5)] {
            XCTAssertEqual(try XCTUnwrap(segments.first { $0.event.id == id }).span, expectedSpan)
        }
    }

    private func weekOverlay(_ events: [CalendarEvent], fontSize: Double = 10) -> BigYearEventBarsOverlay {
        BigYearEventBarsOverlay(daysInWeek: (6...12).map { date($0) },
                               events: events, dayColumnWidth: 140, rowHeight: 80, fontSize: fontSize)
    }

    func testIssue11ExclusiveEndDoesNotLeakIntoFollowingWeek() {
        let trip = event("Weekend", start: date(4), end: date(6))
        XCTAssertTrue(weekOverlay([trip]).layoutEvents.isEmpty)
    }

    func testIssue11TimedMidnightEndDoesNotExtendBar() throws {
        let meeting = CalendarEvent(id: "Meeting", title: "Meeting", startDate: date(6).addingTimeInterval(20 * 3600),
                                    endDate: date(7), isAllDay: false, calendarID: "test",
                                    calendarColor: .red, calendarTitle: "Test")
        XCTAssertEqual(try XCTUnwrap(weekOverlay([meeting]).layoutEvents.first).width, 136)
    }

    func testIssue10ThinLinesKeepDenseEventsOnDistinctRows() {
        let events = (0..<14).map { event("Event \($0)", start: date(6), end: date(7)) }
        XCTAssertEqual(Set(weekOverlay(events, fontSize: 1).layoutEvents.map(\.row)).count, 14)
    }

    func testEventFontSizePersistsAndResets() {
        let settings = settings()
        XCTAssertEqual(settings.eventFontSize, 10)
        for size in [1.0, 6.0, 24.0] {
            settings.eventFontSize = size
            XCTAssertEqual(self.settings().eventFontSize, size)
        }
        settings.resetToDefaults()
        XCTAssertEqual(self.settings().eventFontSize, 10)
    }

    func testInvalidSavedFontSizesAreBounded() {
        for (saved, expected) in [(-4.0, 1.0), (100.0, 24.0), (.infinity, 10.0)] {
            defaults.set(saved, forKey: "eventFontSize")
            XCTAssertEqual(settings().eventFontSize, expected)
        }
    }

    func testDisjointEventsReuseLanesAndOverlapsKeepSeparateLanes() throws {
        let a = event("A", start: date(6), end: date(8))
        let b = event("B", start: date(8), end: date(10))
        let c = event("C", start: date(7), end: date(9))
        let segments = row([a, b, c]).featuredEventSegments
        let first = try XCTUnwrap(segments.first { $0.event.id == "A" })
        let next = try XCTUnwrap(segments.first { $0.event.id == "B" })
        let overlap = try XCTUnwrap(segments.first { $0.event.id == "C" })
        XCTAssertEqual(first.row, next.row)
        XCTAssertNotEqual(first.row, overlap.row)
        XCTAssertEqual(overlap.span, 2)
    }

    func testBarCapacityRespectsAvailableHeight() {
        XCTAssertEqual(EventBarMetrics(fontSize: 10, cellHeight: 80).capacity, 3)
        XCTAssertEqual(EventBarMetrics(fontSize: 10, cellHeight: 0).capacity, 0)
        XCTAssertGreaterThan(EventBarMetrics(fontSize: 1, cellHeight: 80).capacity, 14)
    }

    #if os(macOS)
    @MainActor
    private func renderedRow(_ events: [CalendarEvent], height: CGFloat = 80, showTitles: Bool = true) throws -> NSBitmapImageRep {
        let renderer = ImageRenderer(content: row(events, height: height, showTitles: showTitles)
            .frame(width: 1504, height: height + 8)
            .environment(\.colorScheme, .light))
        renderer.scale = 1
        let cgImage = try XCTUnwrap(renderer.cgImage)
        let attachment = XCTAttachment(image: NSImage(cgImage: cgImage, size: NSSize(width: 1504, height: height + 8)))
        attachment.name = "Month row: \(events.count) events, \(Int(settings().eventFontSize)) pt"
        attachment.lifetime = .keepAlways
        add(attachment)
        return NSBitmapImageRep(cgImage: cgImage)
    }

    private func redRows(_ bitmap: NSBitmapImageRep, on day: Int) -> [Int] {
        let offset = (calendar.component(.weekday, from: date(1)) - settings().calendar.firstWeekday + 7) % 7
        let x = 24 + (offset + day - 1) * 40 + 20
        return (0..<bitmap.pixelsHigh).filter { y in
            guard let c = bitmap.colorAt(x: x, y: y)?.usingColorSpace(.sRGB) else { return false }
            // Allow color-profile conversion of the saturated red fixture.
            return c.redComponent > 0.8 && c.greenComponent < 0.3 && c.blueComponent < 0.3
        }
    }

    private func redPixels(_ bitmap: NSBitmapImageRep, on day: Int) -> Int {
        redRows(bitmap, on: day).count
    }

    @MainActor
    func testIssue9AllThreeEventBarsActuallyRender() throws {
        let events = ["A", "B", "C"].map {
            event($0, start: date(6), end: date(11), color: Color(red: 1, green: 0, blue: 0))
        }
        let rows = redRows(try renderedRow(events), on: 9)
        let bands = rows.enumerated().filter { index, row in
            index == 0 || row > rows[index - 1] + 1
        }.count
        XCTAssertEqual(bands, 3, "Each event should render as a separate bar")
    }

    @MainActor
    func testIssue11FinalDayActuallyRendersDuringOverlap() throws {
        let trip = event("Trip", start: date(6), end: date(11), color: Color(red: 1, green: 0, blue: 0))
        let overlap = event("Longer", start: date(10), end: date(20), color: .blue)
        let image = try renderedRow([trip, overlap])
        XCTAssertGreaterThan(redPixels(image, on: 10), 5)
        XCTAssertEqual(redPixels(image, on: 11), 0)
    }

    @MainActor
    func testSmallCellsIndicateEventsEvenWhenNoBarFits() throws {
        defaults.set(24, forKey: "eventFontSize")
        let trip = event("Trip", start: date(6), end: date(11))
        for showTitles in [true, false] {
            for height: CGFloat in [24, 32] {
                let empty = try renderedRow([], height: height, showTitles: showTitles)
                let occupied = try renderedRow([trip], height: height, showTitles: showTitles)
                XCTAssertNotEqual(empty.tiffRepresentation, occupied.tiffRepresentation,
                                  "Events need a visible bar or indicator at height \(height)")
            }
        }
    }

    @MainActor
    func testYearViewIndicatesEventsThatDoNotFit() throws {
        let first = event("A", start: date(6), end: date(11))
        let second = event("B", start: date(6), end: date(11))
        func image(_ events: [CalendarEvent]) throws -> Data? {
            let renderer = ImageRenderer(content: weekOverlay(events, fontSize: 24)
                .frame(width: 980, height: 80, alignment: .topLeading)
                .environment(\.colorScheme, .light))
            let cgImage = try XCTUnwrap(renderer.cgImage)
            let attachment = XCTAttachment(image: NSImage(cgImage: cgImage, size: NSSize(width: 980, height: 80)))
            attachment.name = "Year row: \(events.count) events"
            attachment.lifetime = .keepAlways
            add(attachment)
            return NSBitmapImageRep(cgImage: cgImage).tiffRepresentation
        }
        XCTAssertNotEqual(try image([first]), try image([first, second]),
                          "An additional hidden event must not look like a single-event day")
    }

    @MainActor
    func testIssue10OnePointPreferenceRendersThinEventLine() throws {
        let trip = event("Trip", start: date(6), end: date(11), color: Color(red: 1, green: 0, blue: 0))

        func redRows(fontSize: Double) throws -> Int {
            defaults.set(fontSize, forKey: "eventFontSize")
            return redPixels(try renderedRow([trip]), on: 9)
        }

        let normal = try redRows(fontSize: 11)
        let tiny = try redRows(fontSize: 1)
        XCTAssertGreaterThan(normal, 5)
        XCTAssertGreaterThan(tiny, 0)
        XCTAssertLessThanOrEqual(tiny, 2, "The 1 pt setting should render a thin line")
        XCTAssertLessThan(tiny, normal, "The saved font-size preference must affect the actual rendered event")
    }
    #endif
}
