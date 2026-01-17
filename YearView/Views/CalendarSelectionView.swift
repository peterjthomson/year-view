import SwiftUI

struct CalendarSelectionView: View {
    @Environment(CalendarViewModel.self) private var calendarViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var enabledCalendarIDs: Set<String> = []

    var body: some View {
        List {
            // Quick actions
            Section {
                Button {
                    enabledCalendarIDs = Set(calendarViewModel.calendars.map(\.id))
                } label: {
                    Label("Show All", systemImage: isShowAllSelected ? "checkmark.circle.fill" : "circle")
                }

                Button {
                    enabledCalendarIDs = []
                } label: {
                    Label("Hide All", systemImage: isHideAllSelected ? "checkmark.circle.fill" : "circle")
                }
            }

            // Group calendars by source type
            ForEach(groupedCalendars, id: \.key) { sourceType, calendars in
                Section(sourceType.displayName) {
                    ForEach(calendars) { calendar in
                        CalendarRow(
                            calendar: calendar,
                            isEnabled: enabledCalendarIDs.contains(calendar.id),
                            onToggle: {
                                toggle(calendarID: calendar.id)
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
        .onAppear {
            enabledCalendarIDs = Set(calendarViewModel.calendars.filter(\.isEnabled).map(\.id))
        }
        .onChange(of: calendarViewModel.calendars) { _, newValue in
            // Keep local state in sync if calendars load/change while sheet is open.
            enabledCalendarIDs = Set(newValue.filter(\.isEnabled).map(\.id))
        }
        .onDisappear {
            // Apply once when closing to avoid laggy per-toggle redraws.
            calendarViewModel.setEnabledCalendarIDs(enabledCalendarIDs)
        }
        .navigationTitle("Manage Calendars")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }

    private var isShowAllSelected: Bool {
        guard !calendarViewModel.calendars.isEmpty else { return false }
        let allCalendarIDs = Set(calendarViewModel.calendars.map(\.id))
        return enabledCalendarIDs == allCalendarIDs
    }

    private var isHideAllSelected: Bool {
        enabledCalendarIDs.isEmpty
    }

    private var groupedCalendars: [(key: CalendarSource.SourceType, value: [CalendarSource])] {
        let grouped = Dictionary(grouping: calendarViewModel.calendars) { $0.sourceType }
        return grouped
            .sorted { $0.key.rawValue < $1.key.rawValue }
            .map { (key: $0.key, value: $0.value.sorted { $0.title < $1.title }) }
    }

    private func toggle(calendarID: String) {
        if enabledCalendarIDs.contains(calendarID) {
            enabledCalendarIDs.remove(calendarID)
        } else {
            enabledCalendarIDs.insert(calendarID)
        }
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
                        .foregroundStyle(Color.accentColor)
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
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
