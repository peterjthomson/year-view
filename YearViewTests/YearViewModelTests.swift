import XCTest
@testable import YearView

final class YearViewModelTests: XCTestCase {

    var viewModel: YearViewModel!
    let calendar = Calendar.current

    override func setUp() {
        super.setUp()
        viewModel = YearViewModel()
    }

    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }

    // MARK: - Default State Tests

    func testDefaultLayoutStyle() {
        XCTAssertEqual(viewModel.layoutStyle, .monthRows)
    }

    func testDefaultShowWeekends() {
        XCTAssertTrue(viewModel.showWeekends)
    }

    func testDefaultShowWeekNumbers() {
        XCTAssertFalse(viewModel.showWeekNumbers)
    }

    func testDefaultZoomLevel() {
        XCTAssertEqual(viewModel.zoomLevel, 1.0)
    }

    // MARK: - Layout Style Tests

    func testAllLayoutStylesExist() {
        // Verify all layout styles are available
        XCTAssertEqual(YearLayoutStyle.allCases.count, 6)
        XCTAssertTrue(YearLayoutStyle.allCases.contains(.monthRows))
        XCTAssertTrue(YearLayoutStyle.allCases.contains(.bigYear))
        XCTAssertTrue(YearLayoutStyle.allCases.contains(.standardGrid))
        XCTAssertTrue(YearLayoutStyle.allCases.contains(.continuousRow))
        XCTAssertTrue(YearLayoutStyle.allCases.contains(.verticalList))
        XCTAssertTrue(YearLayoutStyle.allCases.contains(.powerLaw))
    }

    func testLayoutStylesHaveUniqueIdentifiers() {
        let ids = YearLayoutStyle.allCases.map { $0.id }
        XCTAssertEqual(Set(ids).count, YearLayoutStyle.allCases.count, "All layout styles should have unique IDs")
    }

    func testLayoutStylesHaveIcons() {
        for style in YearLayoutStyle.allCases {
            XCTAssertFalse(style.icon.isEmpty, "\(style) should have an icon")
        }
    }

    func testLayoutStylesHaveDescriptions() {
        for style in YearLayoutStyle.allCases {
            XCTAssertFalse(style.description.isEmpty, "\(style) should have a description")
        }
    }

    // MARK: - Month Generation Tests

    func testMonthsForYear() {
        let months = viewModel.months(for: 2026)

        XCTAssertEqual(months.count, 12)
        XCTAssertEqual(calendar.component(.month, from: months[0].date), 1)
        XCTAssertEqual(calendar.component(.month, from: months[11].date), 12)
    }

    func testMonthDataName() {
        let months = viewModel.months(for: 2026)
        for month in months {
            XCTAssertFalse(month.name.isEmpty)
        }
    }

    func testMonthDataShortName() {
        let months = viewModel.months(for: 2026)
        for month in months {
            XCTAssertFalse(month.shortName.isEmpty)
        }
    }

    func testMonthDataDaysCount() {
        let months = viewModel.months(for: 2026)

        XCTAssertEqual(months[0].days.count, 31) // January
        XCTAssertEqual(months[1].days.count, 28) // February 2026 (not leap)
        XCTAssertEqual(months[3].days.count, 30) // April
    }

    func testMonthDataWeekdayHeaders() {
        let months = viewModel.months(for: 2026)

        XCTAssertEqual(months[0].weekdayHeaders.count, 7)
        XCTAssertTrue(months[0].weekdayHeaders.allSatisfy { !$0.isEmpty })
    }

    func testMonthDataWeeks() {
        let months = viewModel.months(for: 2026)

        // January 2026 starts on Thursday, so needs 5 weeks
        XCTAssertGreaterThanOrEqual(months[0].weeks.count, 4)
        XCTAssertLessThanOrEqual(months[0].weeks.count, 6)

        // Each week should have 7 slots (some may be nil for padding)
        for week in months[0].weeks {
            XCTAssertEqual(week.count, 7)
        }
    }

    // MARK: - DayData Tests

    func testDayDataProperties() {
        let months = viewModel.months(for: 2026)
        let january = months[0]

        guard let firstDay = january.days.first else {
            XCTFail("No days in month")
            return
        }

        XCTAssertEqual(firstDay.dayNumber, 1)
        XCTAssertNotNil(firstDay.date)
        XCTAssertNotNil(firstDay.weekday)
    }

    func testDayDataIsWeekend() {
        let months = viewModel.months(for: 2026)
        let january = months[0]

        // Jan 3, 2026 is Saturday, Jan 4 is Sunday
        let saturday = january.days.first { $0.dayNumber == 3 }
        let sunday = january.days.first { $0.dayNumber == 4 }
        let monday = january.days.first { $0.dayNumber == 5 }

        XCTAssertTrue(saturday?.isWeekend ?? false)
        XCTAssertTrue(sunday?.isWeekend ?? false)
        XCTAssertFalse(monday?.isWeekend ?? true)
    }

    // MARK: - Leap Year Tests

    func testLeapYearFebruary() {
        let months2024 = viewModel.months(for: 2024) // Leap year
        let months2026 = viewModel.months(for: 2026) // Not leap year

        XCTAssertEqual(months2024[1].days.count, 29) // Feb 2024
        XCTAssertEqual(months2026[1].days.count, 28) // Feb 2026
    }
}
