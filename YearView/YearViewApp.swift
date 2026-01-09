import SwiftUI

@main
struct YearViewApp: App {
    @State private var calendarViewModel = CalendarViewModel()

    var body: some Scene {
        #if os(macOS)
        WindowGroup {
            ContentView()
                .environment(calendarViewModel)
        }
        .commands {
            MacCommands(calendarViewModel: calendarViewModel)
        }

        MenuBarExtra("Year View", systemImage: "calendar") {
            MenuBarView()
                .environment(calendarViewModel)
        }
        .menuBarExtraStyle(.window)

        Settings {
            CalendarSelectionView()
                .environment(calendarViewModel)
        }
        #else
        WindowGroup {
            ContentView()
                .environment(calendarViewModel)
        }
        #endif
    }
}
