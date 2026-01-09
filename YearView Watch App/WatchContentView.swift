import SwiftUI

struct WatchContentView: View {
    @Environment(WatchCalendarViewModel.self) private var viewModel

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading...")
                } else if !viewModel.hasCalendarAccess {
                    ContentUnavailableView {
                        Label("Calendar Access", systemImage: "calendar.badge.exclamationmark")
                    } description: {
                        Text("Year View needs calendar access to show your events.")
                    }
                } else {
                    WatchMonthView()
                }
            }
            .navigationTitle("Year View")
            .navigationBarTitleDisplayMode(.inline)
        }
        .task {
            await viewModel.requestAccess()
        }
    }
}

#Preview {
    WatchContentView()
        .environment(WatchCalendarViewModel())
}
