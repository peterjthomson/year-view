import Foundation
import SwiftUI

final class CalendarCacheService {
    static let shared = CalendarCacheService()

    private let userDefaults = UserDefaults.standard

    private let enabledCalendarsKey = "enabledCalendarIDs"
    private let disabledCalendarsKey = "disabledCalendarIDs"
    private let selectedLayoutKey = "selectedLayout"
    private let showWeekendsKey = "showWeekends"
    private let showWeekNumbersKey = "showWeekNumbers"
    private let firstDayOfWeekKey = "firstDayOfWeek"
    private let lastViewedYearKey = "lastViewedYear"

    // AppSettings keys
    private let pageBackgroundColorKey = "pageBackgroundColor"
    private let weekdayBackgroundColorKey = "weekdayBackgroundColor"
    private let weekendBackgroundColorKey = "weekendBackgroundColor"
    private let unusedCellColorKey = "unusedCellColor"
    private let dateLabelColorKey = "dateLabelColor"
    private let columnHeadingColorKey = "columnHeadingColor"
    private let rowHeadingColorKey = "rowHeadingColor"
    private let todayColorKey = "todayColor"
    private let gridlineColorKey = "gridlineColor"
    private let showGridlinesBigYearKey = "showGridlinesBigYear"
    private let showGridlinesMonthRowsKey = "showGridlinesMonthRows"
    private let showGridlinesGridKey = "showGridlinesGrid"
    private let showGridlinesRowKey = "showGridlinesRow"
    private let showGridlinesListKey = "showGridlinesList"
    private let weekStartsOnKey = "weekStartsOn"
    private let monthLabelFormatKey = "monthLabelFormat"
    private let monthLabelFontSizeKey = "monthLabelFontSize"
    private let showAllDayEventsKey = "showAllDayEvents"
    private let showTimeBasedEventsKey = "showTimeBasedEvents"

    // MARK: - Calendar Preferences

    func saveEnabledCalendarIDs(_ ids: [String]) {
        userDefaults.set(ids, forKey: enabledCalendarsKey)
    }

    func loadEnabledCalendarIDs() -> [String] {
        userDefaults.stringArray(forKey: enabledCalendarsKey) ?? []
    }
    
    func hasLegacyEnabledCalendars() -> Bool {
        userDefaults.object(forKey: enabledCalendarsKey) != nil
    }
    
    func removeEnabledCalendarIDs() {
        userDefaults.removeObject(forKey: enabledCalendarsKey)
    }
    
    func saveDisabledCalendarIDs(_ ids: [String]) {
        userDefaults.set(ids, forKey: disabledCalendarsKey)
    }
    
    func loadDisabledCalendarIDs() -> [String]? {
        userDefaults.stringArray(forKey: disabledCalendarsKey)
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

    // MARK: - AppSettings Color Preferences

    func saveColor(_ color: Color, forKey key: String) {
        if let hexString = color.toHexString() {
            userDefaults.set(hexString, forKey: key)
        }
    }

    func loadColor(forKey key: String, default defaultColor: Color) -> Color {
        guard let hexString = userDefaults.string(forKey: key) else {
            return defaultColor
        }
        return Color(hex: hexString) ?? defaultColor
    }

    // Color property accessors
    var pageBackgroundColor: Color {
        get { loadColor(forKey: pageBackgroundColorKey, default: Color.gray.opacity(0.06)) }
        set { saveColor(newValue, forKey: pageBackgroundColorKey) }
    }

    var weekdayBackgroundColor: Color {
        get { loadColor(forKey: weekdayBackgroundColorKey, default: .white) }
        set { saveColor(newValue, forKey: weekdayBackgroundColorKey) }
    }

    var weekendBackgroundColor: Color {
        get { loadColor(forKey: weekendBackgroundColorKey, default: Color.gray.opacity(0.1)) }
        set { saveColor(newValue, forKey: weekendBackgroundColorKey) }
    }

    var unusedCellColor: Color {
        get { loadColor(forKey: unusedCellColorKey, default: Color.gray.opacity(0.06)) }
        set { saveColor(newValue, forKey: unusedCellColorKey) }
    }

    var dateLabelColor: Color {
        get { loadColor(forKey: dateLabelColorKey, default: .primary) }
        set { saveColor(newValue, forKey: dateLabelColorKey) }
    }

    var columnHeadingColor: Color {
        get { loadColor(forKey: columnHeadingColorKey, default: .secondary) }
        set { saveColor(newValue, forKey: columnHeadingColorKey) }
    }

    var rowHeadingColor: Color {
        get { loadColor(forKey: rowHeadingColorKey, default: .primary) }
        set { saveColor(newValue, forKey: rowHeadingColorKey) }
    }

    var todayColor: Color {
        get { loadColor(forKey: todayColorKey, default: Color.gray.opacity(0.25)) }
        set { saveColor(newValue, forKey: todayColorKey) }
    }

    var gridlineColor: Color {
        get { loadColor(forKey: gridlineColorKey, default: Color.gray.opacity(0.3)) }
        set { saveColor(newValue, forKey: gridlineColorKey) }
    }

    // MARK: - AppSettings Gridline Preferences

    var showGridlinesBigYear: Bool {
        get {
            if userDefaults.object(forKey: showGridlinesBigYearKey) == nil { return true }
            return userDefaults.bool(forKey: showGridlinesBigYearKey)
        }
        set { userDefaults.set(newValue, forKey: showGridlinesBigYearKey) }
    }

    var showGridlinesMonthRows: Bool {
        get {
            if userDefaults.object(forKey: showGridlinesMonthRowsKey) == nil { return true }
            return userDefaults.bool(forKey: showGridlinesMonthRowsKey)
        }
        set { userDefaults.set(newValue, forKey: showGridlinesMonthRowsKey) }
    }

    var showGridlinesGrid: Bool {
        get { userDefaults.bool(forKey: showGridlinesGridKey) }
        set { userDefaults.set(newValue, forKey: showGridlinesGridKey) }
    }

    var showGridlinesRow: Bool {
        get { userDefaults.bool(forKey: showGridlinesRowKey) }
        set { userDefaults.set(newValue, forKey: showGridlinesRowKey) }
    }

    var showGridlinesList: Bool {
        get { userDefaults.bool(forKey: showGridlinesListKey) }
        set { userDefaults.set(newValue, forKey: showGridlinesListKey) }
    }

    // MARK: - AppSettings Other Preferences

    var weekStartsOn: Int {
        get {
            let saved = userDefaults.integer(forKey: weekStartsOnKey)
            return saved > 0 ? saved : 2 // Default to Monday
        }
        set { userDefaults.set(newValue, forKey: weekStartsOnKey) }
    }

    var monthLabelFormat: String {
        get { userDefaults.string(forKey: monthLabelFormatKey) ?? "Letter" }
        set { userDefaults.set(newValue, forKey: monthLabelFormatKey) }
    }

    var monthLabelFontSize: String {
        get { userDefaults.string(forKey: monthLabelFontSizeKey) ?? "Medium" }
        set { userDefaults.set(newValue, forKey: monthLabelFontSizeKey) }
    }

    var showAllDayEvents: Bool {
        get {
            if userDefaults.object(forKey: showAllDayEventsKey) == nil { return true }
            return userDefaults.bool(forKey: showAllDayEventsKey)
        }
        set { userDefaults.set(newValue, forKey: showAllDayEventsKey) }
    }

    var showTimeBasedEvents: Bool {
        get { userDefaults.bool(forKey: showTimeBasedEventsKey) }
        set { userDefaults.set(newValue, forKey: showTimeBasedEventsKey) }
    }

    // MARK: - Clear All

    func clearAllPreferences() {
        let keys = [
            enabledCalendarsKey,
            disabledCalendarsKey,
            selectedLayoutKey,
            showWeekendsKey,
            showWeekNumbersKey,
            firstDayOfWeekKey,
            lastViewedYearKey,
            // AppSettings keys
            pageBackgroundColorKey,
            weekdayBackgroundColorKey,
            weekendBackgroundColorKey,
            unusedCellColorKey,
            dateLabelColorKey,
            columnHeadingColorKey,
            rowHeadingColorKey,
            todayColorKey,
            gridlineColorKey,
            showGridlinesBigYearKey,
            showGridlinesMonthRowsKey,
            showGridlinesGridKey,
            showGridlinesRowKey,
            showGridlinesListKey,
            weekStartsOnKey,
            monthLabelFormatKey,
            monthLabelFontSizeKey,
            showAllDayEventsKey,
            showTimeBasedEventsKey
        ]

        for key in keys {
            userDefaults.removeObject(forKey: key)
        }
    }
}

// MARK: - Color Hex Conversion

extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        let length = hexSanitized.count
        if length == 6 {
            let r = Double((rgb & 0xFF0000) >> 16) / 255.0
            let g = Double((rgb & 0x00FF00) >> 8) / 255.0
            let b = Double(rgb & 0x0000FF) / 255.0
            self.init(red: r, green: g, blue: b)
        } else if length == 8 {
            let r = Double((rgb & 0xFF000000) >> 24) / 255.0
            let g = Double((rgb & 0x00FF0000) >> 16) / 255.0
            let b = Double((rgb & 0x0000FF00) >> 8) / 255.0
            let a = Double(rgb & 0x000000FF) / 255.0
            self.init(red: r, green: g, blue: b, opacity: a)
        } else {
            return nil
        }
    }

    func toHexString() -> String? {
        #if os(macOS)
        guard let cgColor = NSColor(self).cgColor,
              let components = cgColor.components,
              components.count >= 3 else {
            return nil
        }
        #else
        guard let cgColor = UIColor(self).cgColor,
              let components = cgColor.components,
              components.count >= 3 else {
            return nil
        }
        #endif

        let r = Int(components[0] * 255)
        let g = Int(components[1] * 255)
        let b = Int(components[2] * 255)
        let a = components.count >= 4 ? Int(components[3] * 255) : 255

        if a == 255 {
            return String(format: "#%02X%02X%02X", r, g, b)
        } else {
            return String(format: "#%02X%02X%02X%02X", r, g, b, a)
        }
    }
}
