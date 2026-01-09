import SwiftUI

struct SearchView: View {
    @Environment(CalendarViewModel.self) private var calendarViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var selectedEvent: CalendarEvent?

    var body: some View {
        VStack(spacing: 0) {
            // Search field
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)

                TextField("Search events", text: $searchText)
                    .textFieldStyle(.plain)
                    #if os(iOS)
                    .autocapitalization(.none)
                    #endif
                    .disableAutocorrection(true)

                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(12)
            .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 10))
            .padding()

            Divider()

            // Results
            if searchText.isEmpty {
                ContentUnavailableView {
                    Label("Search Events", systemImage: "magnifyingglass")
                } description: {
                    Text("Enter a search term to find events by title, location, or notes.")
                }
            } else if searchResults.isEmpty {
                ContentUnavailableView {
                    Label("No Results", systemImage: "magnifyingglass")
                } description: {
                    Text("No events match \"\(searchText)\"")
                }
            } else {
                List(searchResults) { event in
                    SearchResultRow(event: event)
                        .onTapGesture {
                            selectedEvent = event
                            // Navigate to the date
                            calendarViewModel.displayedYear = Calendar.current.component(.year, from: event.startDate)
                            calendarViewModel.selectedDate = event.startDate
                            dismiss()
                        }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Search")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }

    private var searchResults: [CalendarEvent] {
        calendarViewModel.search(query: searchText)
    }
}

struct SearchResultRow: View {
    let event: CalendarEvent

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Calendar color
            RoundedRectangle(cornerRadius: 2)
                .fill(event.calendarColor)
                .frame(width: 4, height: 44)

            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.body)
                    .fontWeight(.medium)
                    .lineLimit(1)

                HStack(spacing: 8) {
                    Text(formattedDate)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    if !event.isAllDay {
                        Text(formattedTime)
                            .font(.subheadline)
                            .foregroundStyle(.tertiary)
                    }
                }

                if let location = event.location, !location.isEmpty {
                    Text(location)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .lineLimit(1)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(event.title), \(formattedDate)")
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d"
        return formatter.string(from: event.startDate)
    }

    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: event.startDate)
    }
}

#Preview {
    NavigationStack {
        SearchView()
    }
    .environment(CalendarViewModel())
}
