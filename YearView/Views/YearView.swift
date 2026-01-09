import SwiftUI

struct YearView: View {
    @Environment(CalendarViewModel.self) private var calendarViewModel
    @Environment(AppSettings.self) private var appSettings
    @State private var yearViewModel = YearViewModel()
    @State private var selectedDate: Date?
    @State private var showingDayDetail = false
    @State private var showingSettings = false
    @GestureState private var magnifyBy = 1.0

    var body: some View {
        Group {
            switch yearViewModel.layoutStyle {
            case .bigYear:
                BigYearLayout(
                    year: calendarViewModel.displayedYear,
                    selectedDate: $selectedDate,
                    onDateTap: handleDateTap
                )
            case .monthRows:
                YearMonthRowLayout(
                    months: yearViewModel.months(for: calendarViewModel.displayedYear, using: appSettings),
                    selectedDate: $selectedDate,
                    onDateTap: handleDateTap
                )
            case .standardGrid:
                StandardGridLayout(
                    months: yearViewModel.months(for: calendarViewModel.displayedYear, using: appSettings),
                    selectedDate: $selectedDate,
                    onDateTap: handleDateTap
                )
            case .continuousRow:
                ContinuousRowLayout(
                    months: yearViewModel.months(for: calendarViewModel.displayedYear, using: appSettings),
                    selectedDate: $selectedDate,
                    onDateTap: handleDateTap
                )
            case .verticalList:
                VerticalListLayout(
                    months: yearViewModel.months(for: calendarViewModel.displayedYear, using: appSettings),
                    selectedDate: $selectedDate,
                    onDateTap: handleDateTap
                )
            }
        }
        .gesture(
            MagnificationGesture()
                .updating($magnifyBy) { currentState, gestureState, _ in
                    gestureState = currentState
                }
                .onEnded { value in
                    // Handle zoom gesture completion
                    if value < 0.8 {
                        // Zoom out - could switch to less detailed view
                    } else if value > 1.2 {
                        // Zoom in - could switch to more detailed view
                    }
                }
        )
        .simultaneousGesture(
            DragGesture(minimumDistance: 50)
                .onEnded { value in
                    let horizontalAmount = value.translation.width
                    if horizontalAmount < -50 {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            calendarViewModel.goToNextYear()
                        }
                    } else if horizontalAmount > 50 {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            calendarViewModel.goToPreviousYear()
                        }
                    }
                }
        )
        .overlay {
            if calendarViewModel.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.ultraThinMaterial)
            }
        }
        .sheet(isPresented: $showingDayDetail) {
            if let date = selectedDate {
                NavigationStack {
                    DayDetailView(
                        date: date,
                        events: calendarViewModel.events(for: date)
                    )
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") {
                                showingDayDetail = false
                            }
                        }
                    }
                }
                #if os(macOS)
                .frame(minWidth: 400, minHeight: 500)
                #endif
            }
        }
        .toolbar {
            #if os(iOS)
            ToolbarItem(placement: .bottomBar) {
                HStack(spacing: 2) {
                    ForEach(YearLayoutStyle.allCases) { style in
                        Button {
                            yearViewModel.layoutStyle = style
                        } label: {
                            Image(systemName: style.icon)
                                .frame(width: 32, height: 32)
                        }
                        .buttonStyle(.bordered)
                        .tint(yearViewModel.layoutStyle == style ? .accentColor : .gray)
                        .accessibilityLabel(style.description)
                    }
                    
                    Divider()
                        .frame(height: 24)
                        .padding(.horizontal, 4)
                    
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                            .frame(width: 32, height: 32)
                    }
                    .buttonStyle(.bordered)
                    .accessibilityLabel("Settings")
                }
            }
            #else
            ToolbarItem(placement: .automatic) {
                HStack(spacing: 2) {
                    ForEach(YearLayoutStyle.allCases) { style in
                        Button {
                            yearViewModel.layoutStyle = style
                        } label: {
                            Image(systemName: style.icon)
                                .frame(width: 24, height: 24)
                        }
                        .buttonStyle(.bordered)
                        .tint(yearViewModel.layoutStyle == style ? .accentColor : .gray)
                        .help(style.description)
                        .accessibilityLabel(style.description)
                    }
                }
            }
            #endif
        }
        .sheet(isPresented: $showingSettings) {
            NavigationStack {
                SettingsView()
                    .navigationTitle("Settings")
                    #if os(iOS)
                    .navigationBarTitleDisplayMode(.inline)
                    #endif
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") {
                                showingSettings = false
                            }
                        }
                    }
            }
            #if os(macOS)
            .frame(minWidth: 350, minHeight: 450)
            #endif
        }
        .accessibilityAction(.escape) {
            showingDayDetail = false
        }
    }

    private func handleDateTap(_ date: Date) {
        HapticFeedback.light()
        selectedDate = date
        showingDayDetail = true
    }
}

#Preview {
    NavigationStack {
        YearView()
    }
    .environment(CalendarViewModel())
    .environment(AppSettings())
}
