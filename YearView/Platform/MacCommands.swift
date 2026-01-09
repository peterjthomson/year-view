import SwiftUI

#if os(macOS)
struct MacCommands: Commands {
    let calendarViewModel: CalendarViewModel

    var body: some Commands {
        // Navigation commands
        CommandGroup(after: .toolbar) {
            Button("Go to Today") {
                calendarViewModel.goToToday()
            }
            .keyboardShortcut("t", modifiers: .command)

            Button("Previous Year") {
                calendarViewModel.goToPreviousYear()
            }
            .keyboardShortcut(.leftArrow, modifiers: [.command, .option])

            Button("Next Year") {
                calendarViewModel.goToNextYear()
            }
            .keyboardShortcut(.rightArrow, modifiers: [.command, .option])

            Divider()
        }

        // View commands
        CommandGroup(after: .sidebar) {
            Button("Refresh Calendars") {
                Task {
                    await calendarViewModel.loadCalendars()
                    await calendarViewModel.loadEvents()
                }
            }
            .keyboardShortcut("r", modifiers: .command)

            Divider()
        }

        // Help menu additions
        CommandGroup(replacing: .help) {
            Link("Year View Help", destination: URL(string: "https://yearview.app/help")!)

            Divider()

            Link("Send Feedback", destination: URL(string: "mailto:support@yearview.app")!)

            Link("Privacy Policy", destination: URL(string: "https://yearview.app/privacy")!)
        }
    }
}
#endif
