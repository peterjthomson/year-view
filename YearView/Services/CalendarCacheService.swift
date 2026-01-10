import Foundation

final class CalendarCacheService {
    private let userDefaults = UserDefaults.standard

    private let enabledCalendarsKey = "enabledCalendarIDs"
    private let selectedLayoutKey = "selectedLayout"
    private let showWeekendsKey = "showWeekends"
    private let showWeekNumbersKey = "showWeekNumbers"
    private let firstDayOfWeekKey = "firstDayOfWeek"
    private let lastViewedYearKey = "lastViewedYear"

    // MARK: - Calendar Preferences

    func saveEnabledCalendarIDs(_ ids: [String]) {
        userDefaults.set(ids, forKey: enabledCalendarsKey)
    }

    func loadEnabledCalendarIDs() -> [String] {
        userDefaults.stringArray(forKey: enabledCalendarsKey) ?? []
    }

    // MARK: - Layout Preferences

    func saveSelectedLayout(_ layout: String) {
        userDefaults.set(layout, forKey: selectedLayoutKey)
    }

    func loadSelectedLayout() -> String {
        userDefaults.string(forKey: selectedLayoutKey) ?? "Months"
    }

    // MARK: - Display Preferences

    func saveShowWeekends(_ show: Bool) {
        userDefaults.set(show, forKey: showWeekendsKey)
    }

    func loadShowWeekends() -> Bool {
        // Default to true if not set
        if userDefaults.object(forKey: showWeekendsKey) == nil {
            return true
        }
        return userDefaults.bool(forKey: showWeekendsKey)
    }

    func saveShowWeekNumbers(_ show: Bool) {
        userDefaults.set(show, forKey: showWeekNumbersKey)
    }

    func loadShowWeekNumbers() -> Bool {
        userDefaults.bool(forKey: showWeekNumbersKey)
    }

    func saveFirstDayOfWeek(_ day: Int) {
        userDefaults.set(day, forKey: firstDayOfWeekKey)
    }

    func loadFirstDayOfWeek() -> Int {
        let saved = userDefaults.integer(forKey: firstDayOfWeekKey)
        // Default to system setting if not set
        return saved > 0 ? saved : Calendar.current.firstWeekday
    }

    // MARK: - State Persistence

    func saveLastViewedYear(_ year: Int) {
        userDefaults.set(year, forKey: lastViewedYearKey)
    }

    func loadLastViewedYear() -> Int {
        let saved = userDefaults.integer(forKey: lastViewedYearKey)
        // Default to current year if not set
        return saved > 0 ? saved : Calendar.current.component(.year, from: Date())
    }

    // MARK: - Clear All

    func clearAllPreferences() {
        let keys = [
            enabledCalendarsKey,
            selectedLayoutKey,
            showWeekendsKey,
            showWeekNumbersKey,
            firstDayOfWeekKey,
            lastViewedYearKey
        ]

        for key in keys {
            userDefaults.removeObject(forKey: key)
        }
    }
}
