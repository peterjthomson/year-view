import SwiftUI

struct WatchDayDetailView: View {
    let date: Date
    @Environment(WatchCalendarViewModel.self) private var viewModel

    var body: some View {
        List {
            Section {
                Text(formattedDate)
                    .font(.headline)
            }

            if events.isEmpty {
                Section {
                    Text("No events")
                        .foregroundStyle(.secondary)
                }
            } else {
                Section("Events") {
                    ForEach(sortedEvents) { event in
                        WatchEventRow(event: event)
                    }
                }
            }

            Section {
                Button {
                    openOnPhone()
                } label: {
                    Label("Open on iPhone", systemImage: "iphone")
                }
            }
        }
        .navigationTitle(shortDate)
    }

    private var events: [CalendarEvent] {
        viewModel.events(for: date)
    }

    private var sortedEvents: [CalendarEvent] {
        events.sorted { event1, event2 in
            if event1.isAllDay && !event2.isAllDay { return true }
            if !event1.isAllDay && event2.isAllDay { return false }
            return event1.startDate < event2.startDate
        }
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: date)
    }

    private var shortDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }

    private func openOnPhone() {
        // This would use WCSession to communicate with the phone app
        // For now, this is a placeholder
    }
}

struct WatchEventRow: View {
    let event: CalendarEvent

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Circle()
                    .fill(event.calendarColor)
                    .frame(width: 8, height: 8)

                Text(event.title)
                    .font(.headline)
                    .lineLimit(2)
            }

            Text(timeString)
                .font(.caption)
                .foregroundStyle(.secondary)

            if let location = event.location, !location.isEmpty {
                Label(location, systemImage: "location")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            if event.hasVideoCall {
                Label("Video call", systemImage: "video")
                    .font(.caption2)
                    .foregroundStyle(.green)
            }
        }
        .padding(.vertical, 4)
    }

    private var timeString: String {
        if event.isAllDay {
            return "All day"
        }

        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return "\(formatter.string(from: event.startDate)) - \(formatter.string(from: event.endDate))"
    }
}

#Preview {
    NavigationStack {
        WatchDayDetailView(date: Date())
    }
    .environment(WatchCalendarViewModel())
}
