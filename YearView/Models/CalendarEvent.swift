import SwiftUI
#if canImport(EventKit)
import EventKit
#endif

struct CalendarEvent: Identifiable, Hashable {
    let id: String
    let title: String
    let startDate: Date
    let endDate: Date
    let isAllDay: Bool
    let calendarID: String
    let calendarColor: Color
    let calendarTitle: String
    let location: String?
    let notes: String?
    let url: URL?
    let hasVideoCall: Bool
    let videoCallURL: URL?

    var isMultiDay: Bool {
        let calendar = Calendar.current
        
        // EventKit represents all-day events with an *exclusive* endDate (typically next day at 00:00).
        // Treat the "effective" end as the last moment of the event to avoid incorrectly marking
        // single-day all-day events as multi-day.
        let effectiveEndDate = isAllDay ? endDate.addingTimeInterval(-1) : endDate
        
        return !calendar.isDate(startDate, inSameDayAs: effectiveEndDate)
    }

    var duration: TimeInterval {
        endDate.timeIntervalSince(startDate)
    }

    init(
        id: String,
        title: String,
        startDate: Date,
        endDate: Date,
        isAllDay: Bool,
        calendarID: String,
        calendarColor: Color,
        calendarTitle: String,
        location: String? = nil,
        notes: String? = nil,
        url: URL? = nil,
        hasVideoCall: Bool = false,
        videoCallURL: URL? = nil
    ) {
        self.id = id
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.isAllDay = isAllDay
        self.calendarID = calendarID
        self.calendarColor = calendarColor
        self.calendarTitle = calendarTitle
        self.location = location
        self.notes = notes
        self.url = url
        self.hasVideoCall = hasVideoCall
        self.videoCallURL = videoCallURL
    }

    #if canImport(EventKit)
    init(from ekEvent: EKEvent) {
        self.id = ekEvent.eventIdentifier ?? UUID().uuidString
        self.title = ekEvent.title ?? "Untitled"
        self.startDate = ekEvent.startDate
        self.endDate = ekEvent.endDate
        self.isAllDay = ekEvent.isAllDay
        self.calendarID = ekEvent.calendar?.calendarIdentifier ?? ""
        self.calendarColor = Color(cgColor: ekEvent.calendar?.cgColor ?? CGColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1))
        self.calendarTitle = ekEvent.calendar?.title ?? "Calendar"
        self.location = ekEvent.location
        self.notes = ekEvent.notes
        self.url = ekEvent.url

        // Detect video call links
        let videoCallDetector = VideoCallDetector()
        let (hasCall, callURL) = videoCallDetector.detectVideoCall(
            in: ekEvent.notes,
            location: ekEvent.location,
            url: ekEvent.url
        )
        self.hasVideoCall = hasCall
        self.videoCallURL = callURL
    }
    #endif

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: CalendarEvent, rhs: CalendarEvent) -> Bool {
        lhs.id == rhs.id
    }
}

private struct VideoCallDetector {
    private let patterns: [(pattern: String, prefix: String)] = [
        ("https://[^\\s]*zoom\\.us/[^\\s]+", ""),
        ("https://meet\\.google\\.com/[^\\s]+", ""),
        ("https://teams\\.microsoft\\.com/[^\\s]+", ""),
        ("https://[^\\s]*webex\\.com/[^\\s]+", ""),
    ]

    func detectVideoCall(in notes: String?, location: String?, url: URL?) -> (hasCall: Bool, url: URL?) {
        // Check URL first
        if let url = url, isVideoCallURL(url) {
            return (true, url)
        }

        // Check location
        if let location = location, let foundURL = findVideoCallURL(in: location) {
            return (true, foundURL)
        }

        // Check notes
        if let notes = notes, let foundURL = findVideoCallURL(in: notes) {
            return (true, foundURL)
        }

        return (false, nil)
    }

    private func isVideoCallURL(_ url: URL) -> Bool {
        let host = url.host?.lowercased() ?? ""
        return host.contains("zoom.us") ||
               host.contains("meet.google.com") ||
               host.contains("teams.microsoft.com") ||
               host.contains("webex.com")
    }

    private func findVideoCallURL(in text: String) -> URL? {
        for (pattern, _) in patterns {
            if let range = text.range(of: pattern, options: .regularExpression) {
                let urlString = String(text[range])
                if let url = URL(string: urlString) {
                    return url
                }
            }
        }
        return nil
    }
}

extension CalendarEvent {
    static var preview: CalendarEvent {
        CalendarEvent(
            id: "preview-1",
            title: "Team Meeting",
            startDate: Date(),
            endDate: Date().addingTimeInterval(3600),
            isAllDay: false,
            calendarID: "work",
            calendarColor: .blue,
            calendarTitle: "Work",
            location: "Conference Room A",
            hasVideoCall: true,
            videoCallURL: URL(string: "https://meet.google.com/abc-defg-hij")
        )
    }

    static var previewAllDay: CalendarEvent {
        CalendarEvent(
            id: "preview-2",
            title: "Company Holiday",
            startDate: Calendar.current.startOfDay(for: Date()),
            endDate: Calendar.current.startOfDay(for: Date()).addingTimeInterval(86400),
            isAllDay: true,
            calendarID: "company",
            calendarColor: .green,
            calendarTitle: "Company"
        )
    }
}
