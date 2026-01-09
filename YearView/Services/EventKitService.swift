import EventKit
import SwiftUI

final class EventKitService {
    private let eventStore = EKEventStore()

    var authorizationStatus: EKAuthorizationStatus {
        EKEventStore.authorizationStatus(for: .event)
    }

    func requestAccess() async throws -> Bool {
        let status = authorizationStatus

        switch status {
        case .authorized, .fullAccess:
            return true
        case .writeOnly:
            // We need read access
            return try await requestFullAccess()
        case .notDetermined:
            return try await requestFullAccess()
        case .restricted, .denied:
            return false
        @unknown default:
            return false
        }
    }

    private func requestFullAccess() async throws -> Bool {
        if #available(iOS 17.0, macOS 14.0, *) {
            return try await eventStore.requestFullAccessToEvents()
        } else {
            return try await withCheckedThrowingContinuation { continuation in
                eventStore.requestAccess(to: .event) { granted, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: granted)
                    }
                }
            }
        }
    }

    func fetchCalendars() -> [EKCalendar] {
        eventStore.calendars(for: .event)
    }

    func fetchEvents(from startDate: Date, to endDate: Date, calendars: [EKCalendar]? = nil) -> [EKEvent] {
        let predicate = eventStore.predicateForEvents(
            withStart: startDate,
            end: endDate,
            calendars: calendars
        )
        return eventStore.events(matching: predicate)
    }

    func fetchEvent(withIdentifier identifier: String) -> EKEvent? {
        eventStore.event(withIdentifier: identifier)
    }

    func startObservingChanges(handler: @escaping () -> Void) -> NSObjectProtocol {
        NotificationCenter.default.addObserver(
            forName: .EKEventStoreChanged,
            object: eventStore,
            queue: .main
        ) { _ in
            handler()
        }
    }

    func stopObservingChanges(observer: NSObjectProtocol) {
        NotificationCenter.default.removeObserver(observer)
    }
}
