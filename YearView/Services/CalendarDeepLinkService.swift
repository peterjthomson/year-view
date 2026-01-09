import Foundation
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

final class CalendarDeepLinkService {

    func openCalendar(at date: Date) {
        let timestamp = date.timeIntervalSinceReferenceDate

        #if os(iOS)
        // Try Apple Calendar deep link
        if let url = URL(string: "calshow:\(timestamp)") {
            openURL(url)
        }
        #elseif os(macOS)
        // On macOS, open Calendar.app and try to navigate to date
        if let url = URL(string: "x-apple-calevent://") {
            openURL(url)
        }
        #endif
    }

    func openEvent(_ event: CalendarEvent) {
        #if os(iOS)
        // Try to open the specific event
        if let url = URL(string: "calshow:\(event.startDate.timeIntervalSinceReferenceDate)") {
            openURL(url)
        }
        #elseif os(macOS)
        // On macOS, open Calendar.app
        if let url = URL(string: "x-apple-calevent://") {
            openURL(url)
        }
        #endif
    }

    func createEvent(on date: Date) {
        #if os(iOS)
        // Open Calendar app to create new event
        if let url = URL(string: "calshow:\(date.timeIntervalSinceReferenceDate)") {
            openURL(url)
        }
        #elseif os(macOS)
        // On macOS, open Calendar.app
        // Calendar.app doesn't have a direct "create event" URL scheme
        // but we can open it to the day
        if let url = URL(string: "x-apple-calevent://") {
            openURL(url)
        }
        #endif
    }

    func openGoogleCalendar(at date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/M/d"
        let dateString = formatter.string(from: date)

        if let url = URL(string: "https://calendar.google.com/calendar/r/day/\(dateString)") {
            openURL(url)
        }
    }

    func openGoogleCalendarEvent(eventID: String, calendarID: String) {
        // Note: calendarID reserved for future use with calendar-specific event URLs
        _ = calendarID
        let encodedEventID = eventID.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? eventID

        if let url = URL(string: "https://calendar.google.com/calendar/event?eid=\(encodedEventID)") {
            openURL(url)
        }
    }

    func createGoogleCalendarEvent(on date: Date, title: String? = nil) {
        let formatter = ISO8601DateFormatter()
        let dateString = formatter.string(from: date)

        var urlString = "https://calendar.google.com/calendar/render?action=TEMPLATE"
        urlString += "&dates=\(dateString)/\(dateString)"

        if let title = title?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            urlString += "&text=\(title)"
        }

        if let url = URL(string: urlString) {
            openURL(url)
        }
    }

    func openURL(_ url: URL) {
        #if os(iOS)
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
        #elseif os(macOS)
        NSWorkspace.shared.open(url)
        #endif
    }
}
