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

        XCTAssertEqual(loaded, "Months")
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
        XCTAssertEqual(cacheService.loadSelectedLayout(), "Months")
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

    // MARK: - Disabled Calendar Tests

    func testSaveAndLoadDisabledCalendarIDs() {
        let ids = ["disabled-1", "disabled-2"]

        cacheService.saveDisabledCalendarIDs(ids)
        let loaded = cacheService.loadDisabledCalendarIDs()

        XCTAssertEqual(loaded, ids)
    }

    func testLoadDisabledCalendarIDsReturnsNilWhenNotSet() {
        let loaded = cacheService.loadDisabledCalendarIDs()

        XCTAssertNil(loaded)
    }

    func testLoadDisabledCalendarIDsReturnsEmptyArrayWhenSetToEmpty() {
        cacheService.saveDisabledCalendarIDs([])
        let loaded = cacheService.loadDisabledCalendarIDs()

        XCTAssertNotNil(loaded)
        XCTAssertEqual(loaded, [])
    }

    // MARK: - Legacy Migration Helper Tests

    func testHasLegacyEnabledCalendarsReturnsFalseWhenNotSet() {
        let hasLegacy = cacheService.hasLegacyEnabledCalendars()

        XCTAssertFalse(hasLegacy)
    }

    func testHasLegacyEnabledCalendarsReturnsTrueWhenSet() {
        cacheService.saveEnabledCalendarIDs(["cal-1"])

        let hasLegacy = cacheService.hasLegacyEnabledCalendars()

        XCTAssertTrue(hasLegacy)
    }

    func testHasLegacyEnabledCalendarsReturnsTrueEvenWhenEmpty() {
        // An empty array is still "set" - distinguishes from "never configured"
        cacheService.saveEnabledCalendarIDs([])

        let hasLegacy = cacheService.hasLegacyEnabledCalendars()

        XCTAssertTrue(hasLegacy)
    }

    func testRemoveEnabledCalendarIDs() {
        cacheService.saveEnabledCalendarIDs(["cal-1", "cal-2"])
        XCTAssertTrue(cacheService.hasLegacyEnabledCalendars())

        cacheService.removeEnabledCalendarIDs()

        XCTAssertFalse(cacheService.hasLegacyEnabledCalendars())
        XCTAssertTrue(cacheService.loadEnabledCalendarIDs().isEmpty)
    }

    // MARK: - Clear All Includes Disabled Calendars

    func testClearAllPreferencesIncludesDisabledCalendars() {
        cacheService.saveDisabledCalendarIDs(["disabled-1"])

        cacheService.clearAllPreferences()

        XCTAssertNil(cacheService.loadDisabledCalendarIDs())
    }
}
