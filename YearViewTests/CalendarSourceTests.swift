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

    func testAllSourceTypesHaveDisplayNames() {
        // All source types should have non-empty display names for UI
        let allTypes: [CalendarSource.SourceType] = [.local, .iCloud, .exchange, .google, .calDAV, .unknown]
        for type in allTypes {
            XCTAssertFalse(type.displayName.isEmpty, "\(type) should have a display name")
        }
    }

    func testAllSourceTypesHaveIcons() {
        // All source types should have icons for UI
        let allTypes: [CalendarSource.SourceType] = [.local, .iCloud, .exchange, .google, .calDAV, .unknown]
        for type in allTypes {
            XCTAssertFalse(type.icon.isEmpty, "\(type) should have an icon")
        }
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

    func testPreviewSourceIsValid() {
        let preview = CalendarSource.preview

        // Verify preview has required data for SwiftUI previews
        XCTAssertFalse(preview.id.isEmpty)
        XCTAssertFalse(preview.title.isEmpty)
    }

    func testPreviewListHasMultipleSources() {
        let list = CalendarSource.previewList

        // Verify preview list has enough variety for testing
        XCTAssertGreaterThanOrEqual(list.count, 2, "Preview list should have multiple calendars")
        
        // Verify each item is valid
        for source in list {
            XCTAssertFalse(source.id.isEmpty)
            XCTAssertFalse(source.title.isEmpty)
        }
        
        // Verify unique IDs
        let ids = list.map { $0.id }
        XCTAssertEqual(Set(ids).count, list.count, "All preview sources should have unique IDs")
    }
}
