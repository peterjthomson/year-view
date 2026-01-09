import XCTest
@testable import YearView

final class CalendarCacheServiceTests: XCTestCase {

    var cacheService: CalendarCacheService!

    override func setUp() {
        super.setUp()
        cacheService = CalendarCacheService()
        // Clear any existing preferences
        cacheService.clearAllPreferences()
    }

    override func tearDown() {
        cacheService.clearAllPreferences()
        cacheService = nil
        super.tearDown()
    }

    // MARK: - Calendar Preferences Tests

    func testSaveAndLoadEnabledCalendarIDs() {
        let ids = ["cal-1", "cal-2", "cal-3"]

        cacheService.saveEnabledCalendarIDs(ids)
        let loaded = cacheService.loadEnabledCalendarIDs()

        XCTAssertEqual(loaded, ids)
    }

    func testLoadEmptyCalendarIDs() {
        let loaded = cacheService.loadEnabledCalendarIDs()

        XCTAssertTrue(loaded.isEmpty)
    }

    func testOverwriteCalendarIDs() {
        cacheService.saveEnabledCalendarIDs(["cal-1", "cal-2"])
        cacheService.saveEnabledCalendarIDs(["cal-3"])

        let loaded = cacheService.loadEnabledCalendarIDs()

        XCTAssertEqual(loaded, ["cal-3"])
    }

    // MARK: - Layout Preferences Tests

    func testSaveAndLoadSelectedLayout() {
        cacheService.saveSelectedLayout("continuousRow")
        let loaded = cacheService.loadSelectedLayout()

        XCTAssertEqual(loaded, "continuousRow")
    }

    func testDefaultLayout() {
        let loaded = cacheService.loadSelectedLayout()

        XCTAssertEqual(loaded, "standardGrid")
    }

    // MARK: - Display Preferences Tests

    func testSaveAndLoadShowWeekends() {
        cacheService.saveShowWeekends(false)
        let loaded = cacheService.loadShowWeekends()

        XCTAssertFalse(loaded)
    }

    func testDefaultShowWeekends() {
        let loaded = cacheService.loadShowWeekends()

        XCTAssertTrue(loaded) // Default is true
    }

    func testSaveAndLoadShowWeekNumbers() {
        cacheService.saveShowWeekNumbers(true)
        let loaded = cacheService.loadShowWeekNumbers()

        XCTAssertTrue(loaded)
    }

    func testDefaultShowWeekNumbers() {
        let loaded = cacheService.loadShowWeekNumbers()

        XCTAssertFalse(loaded) // Default is false
    }

    func testSaveAndLoadFirstDayOfWeek() {
        cacheService.saveFirstDayOfWeek(2) // Monday

        let loaded = cacheService.loadFirstDayOfWeek()

        XCTAssertEqual(loaded, 2)
    }

    func testDefaultFirstDayOfWeek() {
        let loaded = cacheService.loadFirstDayOfWeek()

        // Should return system default (varies by locale)
        XCTAssertGreaterThanOrEqual(loaded, 1)
        XCTAssertLessThanOrEqual(loaded, 7)
    }

    // MARK: - State Persistence Tests

    func testSaveAndLoadLastViewedYear() {
        cacheService.saveLastViewedYear(2025)
        let loaded = cacheService.loadLastViewedYear()

        XCTAssertEqual(loaded, 2025)
    }

    func testDefaultLastViewedYear() {
        let loaded = cacheService.loadLastViewedYear()
        let currentYear = Calendar.current.component(.year, from: Date())

        XCTAssertEqual(loaded, currentYear)
    }

    // MARK: - Clear All Tests

    func testClearAllPreferences() {
        // Set some values
        cacheService.saveEnabledCalendarIDs(["cal-1"])
        cacheService.saveSelectedLayout("verticalList")
        cacheService.saveShowWeekends(false)
        cacheService.saveLastViewedYear(2020)

        // Clear all
        cacheService.clearAllPreferences()

        // Verify defaults are restored
        XCTAssertTrue(cacheService.loadEnabledCalendarIDs().isEmpty)
        XCTAssertEqual(cacheService.loadSelectedLayout(), "standardGrid")
        XCTAssertTrue(cacheService.loadShowWeekends())

        let currentYear = Calendar.current.component(.year, from: Date())
        XCTAssertEqual(cacheService.loadLastViewedYear(), currentYear)
    }

    // MARK: - Persistence Across Instances Tests

    func testPersistenceAcrossInstances() {
        cacheService.saveEnabledCalendarIDs(["persist-test"])

        // Create new instance
        let newService = CalendarCacheService()
        let loaded = newService.loadEnabledCalendarIDs()

        XCTAssertEqual(loaded, ["persist-test"])

        // Clean up
        newService.clearAllPreferences()
    }
}
