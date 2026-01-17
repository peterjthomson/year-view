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

    static let defaultLightGray: Color = Color.gray.opacity(0.06)
    
    /// Background color for the page/view
    var pageBackgroundColor: Color = AppSettings.defaultLightGray
    
    /// Background color for weekday cells
    var weekdayBackgroundColor: Color = .white
    
    /// Background color for weekend cells
    var weekendBackgroundColor: Color = Color.gray.opacity(0.1)
    
    /// Background color for unused/placeholder cells (cells that maintain grid but have no day)
    var unusedCellColor: Color = AppSettings.defaultLightGray
    
    /// Color for date labels inside views
    var dateLabelColor: Color = .primary
    
    /// Color for column headings (weekday headers)
    var columnHeadingColor: Color = .secondary
    
    /// Color for row headings (month labels)
    var rowHeadingColor: Color = .primary
    
    /// Color for today highlight
    var todayColor: Color = Color.gray.opacity(0.25)
    
    /// Color for gridlines
    var gridlineColor: Color = Color.separator.opacity(0.5)
    
    // MARK: - Gridline Settings
    
    /// Show gridlines in Year view (Big Year)
    var showGridlinesBigYear: Bool = true
    
    /// Show gridlines in Month Rows view
    var showGridlinesMonthRows: Bool = true
    
    /// Show gridlines in Grid view
    var showGridlinesGrid: Bool = false
    
    /// Show gridlines in Row view
    var showGridlinesRow: Bool = false
    
    /// Show gridlines in List view
    var showGridlinesList: Bool = false
    
    // MARK: - Calendar Settings
    
    /// Which day the week starts on (1=Sunday, 2=Monday, 7=Saturday)
    var weekStartsOn: WeekStartDay = .monday
    
    // MARK: - YearMonth View Settings
    
    /// Format for month labels in YearMonth view
    var monthLabelFormat: MonthLabelFormat = .letter
    
    /// Font size for month labels in YearMonth view
    var monthLabelFontSize: MonthLabelFontSize = .medium
    
    // MARK: - Event Display Settings
    
    /// Whether to show all-day events
    var showAllDayEvents: Bool = true
    
    /// Whether to show time-based events
    var showTimeBasedEvents: Bool = false
    
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
}
