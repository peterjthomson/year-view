import SwiftUI
import Observation

/// Day of week options for week start setting
enum WeekStartDay: Int, CaseIterable, Identifiable {
    case sunday = 1
    case monday = 2
    case saturday = 7
    
    var id: Int { rawValue }
    
    var name: String {
        switch self {
        case .sunday: return "Sunday"
        case .monday: return "Monday"
        case .saturday: return "Saturday"
        }
    }
}

/// Month label format options for YearMonth view
enum MonthLabelFormat: String, CaseIterable, Identifiable {
    case dual = "Dual"           // "January" + "JAN" (current behavior)
    case full = "Full"           // "January"
    case abbreviated = "Abbreviated" // "Jan"
    case letter = "Letter"       // "J"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .dual: return "Dual (January + JAN)"
        case .full: return "Full (January)"
        case .abbreviated: return "Short (Jan)"
        case .letter: return "Letter (J)"
        }
    }
    
    /// Suggested column width for this format
    var suggestedWidth: CGFloat {
        switch self {
        case .dual: return 80
        case .full: return 80
        case .abbreviated: return 40
        case .letter: return 24
        }
    }
}

/// Font size options for month labels
enum MonthLabelFontSize: String, CaseIterable, Identifiable {
    case small = "Small"
    case medium = "Medium"
    case large = "Large"
    
    var id: String { rawValue }
    
    var font: Font {
        switch self {
        case .small: return .caption
        case .medium: return .subheadline
        case .large: return .headline
        }
    }
    
    var secondaryFont: Font {
        switch self {
        case .small: return .caption2
        case .medium: return .caption2
        case .large: return .caption
        }
    }
}

/// App-wide settings for customizing appearance and event display
@Observable
final class AppSettings {
    // MARK: - Color Settings
    // All defaults use system-adaptive colors that work in both light and dark mode

    private let cache = CalendarCacheService.shared

    static let defaultLightGray: Color = Color.gray.opacity(0.06)

    /// Background color for the page/view
    var pageBackgroundColor: Color {
        didSet { cache.pageBackgroundColor = pageBackgroundColor }
    }

    /// Background color for weekday cells
    var weekdayBackgroundColor: Color {
        didSet { cache.weekdayBackgroundColor = weekdayBackgroundColor }
    }

    /// Background color for weekend cells
    var weekendBackgroundColor: Color {
        didSet { cache.weekendBackgroundColor = weekendBackgroundColor }
    }

    /// Background color for unused/placeholder cells (cells that maintain grid but have no day)
    var unusedCellColor: Color {
        didSet { cache.unusedCellColor = unusedCellColor }
    }

    /// Color for date labels inside views
    var dateLabelColor: Color {
        didSet { cache.dateLabelColor = dateLabelColor }
    }

    /// Color for column headings (weekday headers)
    var columnHeadingColor: Color {
        didSet { cache.columnHeadingColor = columnHeadingColor }
    }

    /// Color for row headings (month labels)
    var rowHeadingColor: Color {
        didSet { cache.rowHeadingColor = rowHeadingColor }
    }

    /// Color for today highlight
    var todayColor: Color {
        didSet { cache.todayColor = todayColor }
    }

    /// Color for gridlines
    var gridlineColor: Color {
        didSet { cache.gridlineColor = gridlineColor }
    }

    // MARK: - Gridline Settings

    /// Show gridlines in Year view (Big Year)
    var showGridlinesBigYear: Bool {
        didSet { cache.showGridlinesBigYear = showGridlinesBigYear }
    }

    /// Show gridlines in Month Rows view
    var showGridlinesMonthRows: Bool {
        didSet { cache.showGridlinesMonthRows = showGridlinesMonthRows }
    }

    /// Show gridlines in Grid view
    var showGridlinesGrid: Bool {
        didSet { cache.showGridlinesGrid = showGridlinesGrid }
    }

    /// Show gridlines in Row view
    var showGridlinesRow: Bool {
        didSet { cache.showGridlinesRow = showGridlinesRow }
    }

    /// Show gridlines in List view
    var showGridlinesList: Bool {
        didSet { cache.showGridlinesList = showGridlinesList }
    }

    // MARK: - Calendar Settings

    /// Which day the week starts on (1=Sunday, 2=Monday, 7=Saturday)
    var weekStartsOn: WeekStartDay {
        didSet { cache.weekStartsOn = weekStartsOn.rawValue }
    }

    // MARK: - YearMonth View Settings

    /// Format for month labels in YearMonth view
    var monthLabelFormat: MonthLabelFormat {
        didSet { cache.monthLabelFormat = monthLabelFormat.rawValue }
    }

    /// Font size for month labels in YearMonth view
    var monthLabelFontSize: MonthLabelFontSize {
        didSet { cache.monthLabelFontSize = monthLabelFontSize.rawValue }
    }

    // MARK: - Event Display Settings

    /// Whether to show all-day events
    var showAllDayEvents: Bool {
        didSet { cache.showAllDayEvents = showAllDayEvents }
    }

    /// Whether to show time-based events
    var showTimeBasedEvents: Bool {
        didSet { cache.showTimeBasedEvents = showTimeBasedEvents }
    }

    // MARK: - Initialization

    init() {
        // Load all settings from cache
        self.pageBackgroundColor = cache.pageBackgroundColor
        self.weekdayBackgroundColor = cache.weekdayBackgroundColor
        self.weekendBackgroundColor = cache.weekendBackgroundColor
        self.unusedCellColor = cache.unusedCellColor
        self.dateLabelColor = cache.dateLabelColor
        self.columnHeadingColor = cache.columnHeadingColor
        self.rowHeadingColor = cache.rowHeadingColor
        self.todayColor = cache.todayColor
        self.gridlineColor = cache.gridlineColor
        self.showGridlinesBigYear = cache.showGridlinesBigYear
        self.showGridlinesMonthRows = cache.showGridlinesMonthRows
        self.showGridlinesGrid = cache.showGridlinesGrid
        self.showGridlinesRow = cache.showGridlinesRow
        self.showGridlinesList = cache.showGridlinesList
        self.weekStartsOn = WeekStartDay(rawValue: cache.weekStartsOn) ?? .monday
        self.monthLabelFormat = MonthLabelFormat(rawValue: cache.monthLabelFormat) ?? .letter
        self.monthLabelFontSize = MonthLabelFontSize(rawValue: cache.monthLabelFontSize) ?? .medium
        self.showAllDayEvents = cache.showAllDayEvents
        self.showTimeBasedEvents = cache.showTimeBasedEvents
    }
    
    // MARK: - Computed Properties
    
    /// Returns a Calendar configured with the user's week start preference
    var calendar: Calendar {
        var cal = Calendar.current
        cal.firstWeekday = weekStartsOn.rawValue
        return cal
    }
    
    /// Weekend days based on week start (always Saturday=7 and Sunday=1 in standard weekday numbering)
    var weekendWeekdays: Set<Int> {
        return [1, 7] // Sunday and Saturday are always weekends
    }
    
    // MARK: - Convenience Methods
    
    /// Returns whether a given weekday (1-7, where 1=Sunday) is a weekend
    func isWeekend(weekday: Int) -> Bool {
        weekendWeekdays.contains(weekday)
    }
    
    /// Returns whether a date is a weekend
    func isWeekend(date: Date) -> Bool {
        let weekday = Calendar.current.component(.weekday, from: date)
        return isWeekend(weekday: weekday)
    }
    
    /// Returns the appropriate background color for a given day
    func backgroundColor(isWeekend: Bool) -> Color {
        isWeekend ? weekendBackgroundColor : weekdayBackgroundColor
    }
    
    /// Returns the appropriate background color for a weekday number (1-7)
    func backgroundColor(forWeekday weekday: Int) -> Color {
        backgroundColor(isWeekend: isWeekend(weekday: weekday))
    }
    
    /// Returns background color for unused cells, with weekend shading taking priority
    func unusedCellBackgroundColor(forWeekday weekday: Int) -> Color {
        // Weekend shading takes priority over unused cell shading
        if isWeekend(weekday: weekday) {
            return weekendBackgroundColor
        }
        return unusedCellColor
    }
    
    /// Filters events based on current settings
    func filterEvents(_ events: [CalendarEvent]) -> [CalendarEvent] {
        events.filter { event in
            if event.isAllDay {
                return showAllDayEvents
            } else {
                return showTimeBasedEvents
            }
        }
    }

    /// Resets all settings to their default values
    func resetToDefaults() {
        pageBackgroundColor = AppSettings.defaultLightGray
        weekdayBackgroundColor = .white
        weekendBackgroundColor = Color.gray.opacity(0.1)
        unusedCellColor = AppSettings.defaultLightGray
        dateLabelColor = .primary
        columnHeadingColor = .secondary
        rowHeadingColor = .primary
        todayColor = Color.gray.opacity(0.25)
        gridlineColor = Color.gray.opacity(0.3)
        showGridlinesBigYear = true
        showGridlinesMonthRows = true
        showGridlinesGrid = false
        showGridlinesRow = false
        showGridlinesList = false
        weekStartsOn = .monday
        monthLabelFormat = .letter
        monthLabelFontSize = .medium
        showAllDayEvents = true
        showTimeBasedEvents = false
    }
}
