import SwiftUI

#if canImport(EventKit)
@preconcurrency import EventKit

final class EventKitService {
    private final class EventStoreBox: @unchecked Sendable {
        let value = EKEventStore()
    }

    private let eventStoreBox = EventStoreBox()
    private var eventStore: EKEventStore { eventStoreBox.value }
    private let eventQueue = DispatchQueue(
        label: "com.yearview.eventkit.fetch",
        qos: .userInitiated
    )

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

    func fetchEvents(
        from startDate: Date,
        to endDate: Date
    ) async -> [EKEvent] {
        await withCheckedContinuation { continuation in
            eventQueue.async { [eventStoreBox] in
                let eventStore = eventStoreBox.value
                let predicate = eventStore.predicateForEvents(
                    withStart: startDate,
                    end: endDate,
                    calendars: nil
                )
                continuation.resume(returning: eventStore.events(matching: predicate))
            }
        }
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
#else
/// watchOS-safe stub to keep the shared code compiling even when EventKit isn't available.
final class EventKitService {
    func requestAccess() async throws -> Bool { false }
    func fetchCalendars() -> [Any] { [] }
    func fetchEvents(from startDate: Date, to endDate: Date) async -> [Any] { [] }
    func fetchEvent(withIdentifier identifier: String) -> Any? { nil }
    func startObservingChanges(handler: @escaping () -> Void) -> NSObjectProtocol {
        NotificationCenter.default.addObserver(forName: Notification.Name("EventKitUnavailable"), object: nil, queue: .main) { _ in }
    }
    func stopObservingChanges(observer: NSObjectProtocol) {
        NotificationCenter.default.removeObserver(observer)
    }
}
#endif
