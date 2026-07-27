import XCTest
@testable import YearView

/// Covers the "Go to Today" signal that layouts use to scroll today into view.
final class GoToTodayTests: XCTestCase {

    var viewModel: CalendarViewModel!
    let calendar = Calendar.current

    override func setUp() {
        super.setUp()
        viewModel = CalendarViewModel()
    }

    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }

    func testGoToTodaySetsCurrentYear() {
        viewModel.displayedYear = 2019
        viewModel.goToToday()
        XCTAssertEqual(viewModel.displayedYear, calendar.component(.year, from: Date()))
    }

    func testGoToTodaySelectsToday() {
        viewModel.goToToday()
        let selected = try? XCTUnwrap(viewModel.selectedDate)
        XCTAssertNotNil(selected)
        XCTAssertTrue(calendar.isDateInToday(selected!))
    }

    func testGoToTodayRequestsAScroll() {
        let before = viewModel.scrollToTodayToken
        viewModel.goToToday()
        XCTAssertEqual(viewModel.scrollToTodayToken, before + 1)
    }

    /// The common case: already showing the current year. Changing the year alone is a
    /// no-op then, so the scroll request has to fire regardless or the button does nothing.
    func testGoToTodayRequestsAScrollEvenWhenAlreadyOnCurrentYear() {
        viewModel.displayedYear = calendar.component(.year, from: Date())
        let before = viewModel.scrollToTodayToken

        viewModel.goToToday()
        XCTAssertEqual(viewModel.scrollToTodayToken, before + 1)

        // And again - repeat presses must keep re-triggering, so this can't be a Bool.
        viewModel.goToToday()
        XCTAssertEqual(viewModel.scrollToTodayToken, before + 2)
    }
}

/// The month-rows layout offsets each month so weekdays line up across the year, so
/// today's scroll target is a column index rather than a day-of-month. This mirrors the
/// calculation in YearMonthRowLayout.
final class MonthRowTodayColumnTests: XCTestCase {

    private func columnIndex(for date: Date, calendar: Calendar) -> Int {
        var components = calendar.dateComponents([.year, .month], from: date)
        components.day = 1
        guard let firstOfMonth = calendar.date(from: components) else { return -1 }
        let firstDayWeekday = calendar.component(.weekday, from: firstOfMonth)
        let offset = (firstDayWeekday - calendar.firstWeekday + 7) % 7
        return offset + calendar.component(.day, from: date) - 1
    }

    /// 1 March 2026 is a Sunday. With weeks starting Monday it sits in column 6.
    func testFirstOfMonthUsesWeekdayOffset() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2 // Monday
        let march1 = calendar.date(from: DateComponents(year: 2026, month: 3, day: 1))!
        XCTAssertEqual(columnIndex(for: march1, calendar: calendar), 6)
    }

    /// Same date, weeks starting Sunday, is the first column.
    func testWeekStartChangesTheColumn() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 1 // Sunday
        let march1 = calendar.date(from: DateComponents(year: 2026, month: 3, day: 1))!
        XCTAssertEqual(columnIndex(for: march1, calendar: calendar), 0)
    }

    func testLaterDayAdvancesOneColumnPerDay() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2
        let march1 = calendar.date(from: DateComponents(year: 2026, month: 3, day: 1))!
        let march15 = calendar.date(from: DateComponents(year: 2026, month: 3, day: 15))!
        XCTAssertEqual(
            columnIndex(for: march15, calendar: calendar),
            columnIndex(for: march1, calendar: calendar) + 14
        )
    }
}
