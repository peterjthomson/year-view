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
            if let helpURL = URL(string: "https://yearview.app/help") {
                Link("Year View Help", destination: helpURL)
            }

            Divider()

            if let feedbackURL = URL(string: "mailto:support@yearview.app") {
                Link("Send Feedback", destination: feedbackURL)
            }

            if let privacyURL = URL(string: "https://yearview.app/privacy") {
                Link("Privacy Policy", destination: privacyURL)
            }
        }
    }
}
#endif
