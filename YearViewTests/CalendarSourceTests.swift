import XCTest
@testable import YearView

final class CalendarSourceTests: XCTestCase {

    // MARK: - Initialization Tests

    func testSourceInitialization() {
        let source = CalendarSource(
            id: "cal-123",
            title: "Work Calendar",
            color: .blue,
            sourceType: .iCloud,
            isEnabled: true
        )

        XCTAssertEqual(source.id, "cal-123")
        XCTAssertEqual(source.title, "Work Calendar")
        XCTAssertEqual(source.sourceType, .iCloud)
        XCTAssertTrue(source.isEnabled)
    }

    func testSourceDefaultEnabled() {
        let source = CalendarSource(
            id: "cal-123",
            title: "Calendar",
            color: .blue,
            sourceType: .local
        )

        XCTAssertTrue(source.isEnabled) // Default is true
    }

    // MARK: - Source Type Tests

    func testSourceTypeDisplayNames() {
        XCTAssertEqual(CalendarSource.SourceType.local.displayName, "On My Device")
        XCTAssertEqual(CalendarSource.SourceType.iCloud.displayName, "iCloud")
        XCTAssertEqual(CalendarSource.SourceType.exchange.displayName, "Exchange")
        XCTAssertEqual(CalendarSource.SourceType.google.displayName, "Google")
        XCTAssertEqual(CalendarSource.SourceType.calDAV.displayName, "CalDAV")
        XCTAssertEqual(CalendarSource.SourceType.unknown.displayName, "Other")
    }

    func testSourceTypeIcons() {
        XCTAssertEqual(CalendarSource.SourceType.local.icon, "calendar")
        XCTAssertEqual(CalendarSource.SourceType.iCloud.icon, "icloud")
        XCTAssertEqual(CalendarSource.SourceType.exchange.icon, "building.2")
        XCTAssertEqual(CalendarSource.SourceType.google.icon, "g.circle")
        XCTAssertEqual(CalendarSource.SourceType.calDAV.icon, "server.rack")
        XCTAssertEqual(CalendarSource.SourceType.unknown.icon, "calendar")
    }

    // MARK: - Equatable & Hashable Tests

    func testSourceEquality() {
        let source1 = CalendarSource(
            id: "same-id",
            title: "Calendar 1",
            color: .blue,
            sourceType: .iCloud
        )

        let source2 = CalendarSource(
            id: "same-id",
            title: "Different Name",
            color: .red,
            sourceType: .google
        )

        XCTAssertEqual(source1, source2) // Same ID means equal
    }

    func testSourceHashable() {
        let source1 = CalendarSource(
            id: "hash-id",
            title: "Calendar",
            color: .blue,
            sourceType: .iCloud
        )

        let source2 = CalendarSource(
            id: "hash-id",
            title: "Different",
            color: .red,
            sourceType: .google
        )

        var set = Set<CalendarSource>()
        set.insert(source1)
        set.insert(source2)

        XCTAssertEqual(set.count, 1) // Same ID, should dedupe
    }

    // MARK: - Preview Data Tests

    func testPreviewSource() {
        let preview = CalendarSource.preview

        XCTAssertEqual(preview.title, "Work")
        XCTAssertEqual(preview.sourceType, .iCloud)
        XCTAssertTrue(preview.isEnabled)
    }

    func testPreviewListCount() {
        let list = CalendarSource.previewList

        XCTAssertEqual(list.count, 4)
        XCTAssertTrue(list.contains { $0.title == "Work" })
        XCTAssertTrue(list.contains { $0.title == "Personal" })
        XCTAssertTrue(list.contains { $0.title == "Family" })
        XCTAssertTrue(list.contains { $0.title == "Birthdays" })
    }
}
