import SwiftUI
import SwiftData

@Model
final class CalendarSet {
    var id: UUID
    var name: String
    var calendarIDs: [String]
    var iconName: String
    var colorHex: String
    var isDefault: Bool

    init(
        id: UUID = UUID(),
        name: String,
        calendarIDs: [String] = [],
        iconName: String = "calendar",
        colorHex: String = "007AFF",
        isDefault: Bool = false
    ) {
        self.id = id
        self.name = name
        self.calendarIDs = calendarIDs
        self.iconName = iconName
        self.colorHex = colorHex
        self.isDefault = isDefault
    }

    var color: Color {
        Color(hex: colorHex) ?? .blue
    }
}

extension CalendarSet {
    static var all: CalendarSet {
        CalendarSet(
            name: "All Calendars",
            iconName: "calendar.badge.checkmark",
            colorHex: "007AFF",
            isDefault: true
        )
    }

    static var work: CalendarSet {
        CalendarSet(
            name: "Work",
            iconName: "briefcase",
            colorHex: "5856D6"
        )
    }

    static var personal: CalendarSet {
        CalendarSet(
            name: "Personal",
            iconName: "person",
            colorHex: "34C759"
        )
    }
}
