import SwiftUI

struct DayDetailView: View {
    let date: Date
    let events: [CalendarEvent]

    @State private var dayViewModel: DayViewModel

    init(date: Date, events: [CalendarEvent]) {
        self.date = date
        self.events = events
        self._dayViewModel = State(initialValue: DayViewModel(date: date, events: events))
    }

    var body: some View {
        List {
            // Date header
            Section {
                VStack(alignment: .leading, spacing: 4) {
                    Text(dayViewModel.formattedDate)
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("\(events.count) event\(events.count == 1 ? "" : "s")")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
                .padding(.vertical, 8)
            }

            // All-day events
            if !dayViewModel.allDayEvents.isEmpty {
                Section("All Day") {
                    ForEach(dayViewModel.allDayEvents) { event in
                        EventRow(event: event, viewModel: dayViewModel)
                    }
                }
            }

            // Timed events
            if !dayViewModel.timedEvents.isEmpty {
                Section("Events") {
                    ForEach(dayViewModel.timedEvents) { event in
                        EventRow(event: event, viewModel: dayViewModel)
                    }
                }
            }

            // Empty state
            if events.isEmpty {
                Section {
                    ContentUnavailableView {
                        Label("No Events", systemImage: "calendar")
                    } description: {
                        Text("There are no events scheduled for this day.")
                    } actions: {
                        Button("Add Event") {
                            dayViewModel.addEvent()
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .listRowBackground(Color.clear)
            }
        }
        #if os(iOS)
        .listStyle(.insetGrouped)
        #else
        .listStyle(.inset)
        #endif
        .navigationTitle(dayViewModel.shortFormattedDate)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    dayViewModel.addEvent()
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Add event")
            }

            ToolbarItem(placement: .secondaryAction) {
                Button {
                    dayViewModel.openInCalendar()
                } label: {
                    Label("Open in Calendar", systemImage: "calendar")
                }
            }
        }
    }
}

#Preview("With Events") {
    NavigationStack {
        DayDetailView(
            date: Date(),
            events: [
                .preview,
                .previewAllDay
            ]
        )
    }
}

#Preview("Empty") {
    NavigationStack {
        DayDetailView(
            date: Date(),
            events: []
        )
    }
}
