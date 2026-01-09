import SwiftUI

struct ContentView: View {
    @Environment(CalendarViewModel.self) private var calendarViewModel
    @State private var showingCalendarSelection = false
    @State private var showingYearPicker = false
    @State private var showingSearch = false

    var body: some View {
        @Bindable var calendarViewModel = calendarViewModel

        NavigationStack {
            YearView()
                .navigationTitle(String(calendarViewModel.displayedYear))
                #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
                #endif
                .toolbar {
                    #if os(iOS)
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            showingCalendarSelection = true
                        } label: {
                            Image(systemName: "calendar")
                        }
                        .accessibilityLabel("Select calendars")
                    }

                    ToolbarItem(placement: .principal) {
                        Button {
                            showingYearPicker = true
                        } label: {
                            HStack(spacing: 4) {
                                Text(String(calendarViewModel.displayedYear))
                                    .font(.headline)
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                            }
                        }
                        .accessibilityLabel("Select year")
                    }

                    ToolbarItem(placement: .topBarTrailing) {
                        HStack(spacing: 16) {
                            Button {
                                showingSearch = true
                            } label: {
                                Image(systemName: "magnifyingglass")
                            }
                            .accessibilityLabel("Search events")

                            Button {
                                calendarViewModel.goToToday()
                            } label: {
                                Text("Today")
                            }
                            .accessibilityLabel("Go to today")
                        }
                    }
                    #else
                    ToolbarItem(placement: .automatic) {
                        Button {
                            showingCalendarSelection = true
                        } label: {
                            Image(systemName: "calendar")
                        }
                        .accessibilityLabel("Select calendars")
                    }

                    ToolbarItem(placement: .automatic) {
                        Button {
                            showingYearPicker = true
                        } label: {
                            HStack(spacing: 4) {
                                Text(String(calendarViewModel.displayedYear))
                                    .font(.headline)
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                            }
                        }
                        .accessibilityLabel("Select year")
                    }

                    ToolbarItem(placement: .automatic) {
                        Button {
                            showingSearch = true
                        } label: {
                            Image(systemName: "magnifyingglass")
                        }
                        .accessibilityLabel("Search events")
                        .keyboardShortcut("f", modifiers: .command)
                    }

                    ToolbarItem(placement: .automatic) {
                        Button {
                            calendarViewModel.goToToday()
                        } label: {
                            Text("Today")
                        }
                        .accessibilityLabel("Go to today")
                        .keyboardShortcut("t", modifiers: .command)
                    }
                    #endif
                }
        }
        .sheet(isPresented: $showingCalendarSelection) {
            NavigationStack {
                CalendarSelectionView()
                    .navigationTitle("Calendars")
                    #if os(iOS)
                    .navigationBarTitleDisplayMode(.inline)
                    #endif
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") {
                                showingCalendarSelection = false
                            }
                        }
                    }
            }
            #if os(macOS)
            .frame(minWidth: 300, minHeight: 400)
            #endif
        }
        .sheet(isPresented: $showingYearPicker) {
            NavigationStack {
                YearPickerView(selectedYear: $calendarViewModel.displayedYear)
                    .navigationTitle("Select Year")
                    #if os(iOS)
                    .navigationBarTitleDisplayMode(.inline)
                    #endif
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") {
                                showingYearPicker = false
                            }
                        }
                    }
            }
            #if os(macOS)
            .frame(minWidth: 200, minHeight: 300)
            #endif
        }
        .sheet(isPresented: $showingSearch) {
            NavigationStack {
                SearchView()
                    .navigationTitle("Search")
                    #if os(iOS)
                    .navigationBarTitleDisplayMode(.inline)
                    #endif
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                showingSearch = false
                            }
                        }
                    }
            }
            #if os(macOS)
            .frame(minWidth: 400, minHeight: 500)
            #endif
        }
        .task {
            await calendarViewModel.requestAccess()
        }
    }
}

#Preview {
    ContentView()
        .environment(CalendarViewModel())
        .environment(AppSettings())
}
