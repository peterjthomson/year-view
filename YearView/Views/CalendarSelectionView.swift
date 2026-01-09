import SwiftUI

struct CalendarSelectionView: View {
    @Environment(CalendarViewModel.self) private var calendarViewModel

    var body: some View {
        List {
            // Quick actions
            Section {
                Button {
                    calendarViewModel.enableAllCalendars()
                } label: {
                    Label("Show All", systemImage: "checkmark.circle.fill")
                }

                Button {
                    calendarViewModel.disableAllCalendars()
                } label: {
                    Label("Hide All", systemImage: "circle")
                }
            }

            // Group calendars by source type
            ForEach(groupedCalendars, id: \.key) { sourceType, calendars in
                Section(sourceType.displayName) {
                    ForEach(calendars) { calendar in
                        CalendarRow(
                            calendar: calendar,
                            isEnabled: calendar.isEnabled,
                            onToggle: {
                                calendarViewModel.toggleCalendar(calendar)
                            }
                        )
                    }
                }
            }
        }
        #if os(iOS)
        .listStyle(.insetGrouped)
        #else
        .listStyle(.inset)
        #endif
    }

    private var groupedCalendars: [(key: CalendarSource.SourceType, value: [CalendarSource])] {
        let grouped = Dictionary(grouping: calendarViewModel.calendars) { $0.sourceType }
        return grouped
            .sorted { $0.key.rawValue < $1.key.rawValue }
            .map { (key: $0.key, value: $0.value.sorted { $0.title < $1.title }) }
    }
}

struct CalendarRow: View {
    let calendar: CalendarSource
    let isEnabled: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                // Calendar color
                Circle()
                    .fill(calendar.color)
                    .frame(width: 12, height: 12)

                // Calendar title
                Text(calendar.title)
                    .foregroundStyle(.primary)

                Spacer()

                // Checkmark
                if isEnabled {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.accentColor)
                        .fontWeight(.semibold)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(calendar.title) calendar")
        .accessibilityValue(isEnabled ? "enabled" : "disabled")
        .accessibilityHint("Double tap to toggle visibility")
    }
}

#Preview {
    NavigationStack {
        CalendarSelectionView()
            .navigationTitle("Calendars")
    }
    .environment(CalendarViewModel())
}
