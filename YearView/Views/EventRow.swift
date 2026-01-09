import SwiftUI

struct EventRow: View {
    let event: CalendarEvent
    let viewModel: DayViewModel

    @Environment(\.openURL) private var openURL

    var body: some View {
        Button {
            viewModel.openInCalendar(event: event)
        } label: {
            HStack(alignment: .top, spacing: 12) {
                // Calendar color indicator
                RoundedRectangle(cornerRadius: 2)
                    .fill(event.calendarColor)
                    .frame(width: 4)
                    .padding(.vertical, 4)

                VStack(alignment: .leading, spacing: 4) {
                    // Title
                    Text(event.title)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                        .lineLimit(2)

                    // Time
                    Text(viewModel.formattedTime(for: event))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    // Location
                    if let location = event.location, !location.isEmpty {
                        Label(location, systemImage: "location")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }

                    // Calendar name
                    Text(event.calendarTitle)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }

                Spacer()

                // Video call button
                if event.hasVideoCall {
                    Button {
                        viewModel.joinVideoCall(event: event)
                    } label: {
                        Image(systemName: "video.fill")
                            .font(.body)
                            .foregroundStyle(.white)
                            .padding(8)
                            .background(Color.green, in: Circle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Join video call")
                }
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint("Double tap to open in Calendar app")
        .contextMenu {
            if event.hasVideoCall, let url = event.videoCallURL {
                Button {
                    viewModel.joinVideoCall(event: event)
                } label: {
                    Label("Join Video Call", systemImage: "video")
                }
            }

            Button {
                viewModel.openInCalendar(event: event)
            } label: {
                Label("Open in Calendar", systemImage: "calendar")
            }

            if let location = event.location, !location.isEmpty {
                Button {
                    #if os(iOS)
                    if let url = URL(string: "maps://?q=\(location.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") {
                        openURL(url)
                    }
                    #else
                    if let url = URL(string: "https://maps.apple.com/?q=\(location.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") {
                        openURL(url)
                    }
                    #endif
                } label: {
                    Label("Open in Maps", systemImage: "map")
                }
            }
        }
    }

    private var accessibilityLabel: String {
        var label = event.title

        if event.isAllDay {
            label += ", all day event"
        } else {
            label += ", \(viewModel.formattedTime(for: event))"
        }

        if let location = event.location {
            label += ", at \(location)"
        }

        label += ", \(event.calendarTitle) calendar"

        if event.hasVideoCall {
            label += ", has video call"
        }

        return label
    }
}

struct EventRowCompact: View {
    let event: CalendarEvent

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(event.calendarColor)
                .frame(width: 8, height: 8)

            Text(event.title)
                .font(.caption)
                .lineLimit(1)

            Spacer()

            if !event.isAllDay {
                Text(formattedStartTime)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var formattedStartTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: event.startDate)
    }
}

#Preview("Event Row") {
    List {
        EventRow(
            event: .preview,
            viewModel: DayViewModel()
        )

        EventRow(
            event: .previewAllDay,
            viewModel: DayViewModel()
        )
    }
}

#Preview("Compact Event Row") {
    VStack(spacing: 8) {
        EventRowCompact(event: .preview)
        EventRowCompact(event: .previewAllDay)
    }
    .padding()
}
