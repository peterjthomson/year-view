import SwiftUI
#if canImport(EventKit)
import EventKit
#endif

struct CalendarSource: Identifiable, Hashable {
    let id: String
    let title: String
    let color: Color
    let sourceType: SourceType
    var isEnabled: Bool

    enum SourceType: String, Codable {
        case local
        case iCloud
        case exchange
        case google
        case calDAV
        case unknown

        #if canImport(EventKit)
        init(from ekSourceType: EKSourceType) {
            switch ekSourceType {
            case .local:
                self = .local
            case .exchange:
                self = .exchange
            case .calDAV:
                self = .calDAV
            case .birthdays:
                self = .local
            case .subscribed:
                self = .calDAV
            case .mobileMe:
                self = .iCloud
            @unknown default:
                self = .unknown
            }
        }
        #endif

        var displayName: String {
            switch self {
            case .local:
                return "On My Device"
            case .iCloud:
                return "iCloud"
            case .exchange:
                return "Exchange"
            case .google:
                return "Google"
            case .calDAV:
                return "CalDAV"
            case .unknown:
                return "Other"
            }
        }

        var icon: String {
            switch self {
            case .local:
                return "calendar"
            case .iCloud:
                return "icloud"
            case .exchange:
                return "building.2"
            case .google:
                return "g.circle"
            case .calDAV:
                return "server.rack"
            case .unknown:
                return "calendar"
            }
        }
    }

    init(
        id: String,
        title: String,
        color: Color,
        sourceType: SourceType,
        isEnabled: Bool = true
    ) {
        self.id = id
        self.title = title
        self.color = color
        self.sourceType = sourceType
        self.isEnabled = isEnabled
    }

    #if canImport(EventKit)
    init(from ekCalendar: EKCalendar) {
        self.id = ekCalendar.calendarIdentifier
        self.title = ekCalendar.title
        self.color = Color(cgColor: ekCalendar.cgColor ?? CGColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1))

        // Detect source type
        if let source = ekCalendar.source {
            if source.title.lowercased().contains("icloud") {
                self.sourceType = .iCloud
            } else if source.title.lowercased().contains("google") {
                self.sourceType = .google
            } else {
                self.sourceType = SourceType(from: source.sourceType)
            }
        } else {
            self.sourceType = .unknown
        }

        self.isEnabled = true
    }
    #endif

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: CalendarSource, rhs: CalendarSource) -> Bool {
        lhs.id == rhs.id
    }
}

extension CalendarSource {
    static var preview: CalendarSource {
        CalendarSource(
            id: "preview-calendar",
            title: "Work",
            color: .blue,
            sourceType: .iCloud,
            isEnabled: true
        )
    }

    static var previewList: [CalendarSource] {
        [
            CalendarSource(id: "1", title: "Work", color: .blue, sourceType: .iCloud),
            CalendarSource(id: "2", title: "Personal", color: .green, sourceType: .iCloud),
            CalendarSource(id: "3", title: "Family", color: .orange, sourceType: .google),
            CalendarSource(id: "4", title: "Birthdays", color: .purple, sourceType: .local),
        ]
    }
}
