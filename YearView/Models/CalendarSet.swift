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
        Color(hex: colorHex)
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

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
