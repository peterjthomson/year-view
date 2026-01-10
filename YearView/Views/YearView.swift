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
        contentView
            .gesture(magnificationGesture)
            .overlay { loadingOverlay }
            .sheet(isPresented: $showingDayDetail) { dayDetailSheet }
            .toolbar { toolbarContent }
            .sheet(isPresented: $showingSettings) { settingsSheet }
            .accessibilityAction(.escape) {
                showingDayDetail = false
            }
    }
    
    // MARK: - Content View
    
    @ViewBuilder
    private var contentView: some View {
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
        case .powerLaw:
            PowerLawLayout(
                selectedDate: $selectedDate,
                onDateTap: handleDateTap
            )
        }
    }
    
    // MARK: - Gestures
    
    private var magnificationGesture: some Gesture {
        MagnificationGesture()
            .updating($magnifyBy) { currentState, gestureState, _ in
                gestureState = currentState
            }
            .onEnded { value in
                if value < 0.8 {
                    // Zoom out - could switch to less detailed view
                } else if value > 1.2 {
                    // Zoom in - could switch to more detailed view
                }
            }
    }
    
    // MARK: - Overlays
    
    @ViewBuilder
    private var loadingOverlay: some View {
        if calendarViewModel.isLoading {
            ProgressView()
                .scaleEffect(1.5)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.ultraThinMaterial)
        }
    }
    
    // MARK: - Sheets
    
    @ViewBuilder
    private var dayDetailSheet: some View {
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
    
    @ViewBuilder
    private var settingsSheet: some View {
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
    
    // MARK: - Toolbar
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        #if os(iOS)
        ToolbarItem(placement: .bottomBar) {
            iOSToolbarButtons
        }
        #else
        ToolbarItem(placement: .automatic) {
            macOSToolbarButtons
        }
        #endif
    }
    
    #if os(iOS)
    private var iOSToolbarButtons: some View {
        HStack(spacing: 2) {
            ForEach(YearLayoutStyle.allCases) { style in
                LayoutStyleButton(
                    style: style,
                    isSelected: yearViewModel.layoutStyle == style,
                    action: { yearViewModel.layoutStyle = style }
                )
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
    #endif
    
    #if os(macOS)
    private var macOSToolbarButtons: some View {
        HStack(spacing: 2) {
            ForEach(YearLayoutStyle.allCases) { style in
                LayoutStyleButton(
                    style: style,
                    isSelected: yearViewModel.layoutStyle == style,
                    action: { yearViewModel.layoutStyle = style }
                )
            }
        }
    }
    #endif

    private func handleDateTap(_ date: Date) {
        HapticFeedback.light()
        selectedDate = date
        showingDayDetail = true
    }
}

// MARK: - Layout Style Button

private struct LayoutStyleButton: View {
    let style: YearLayoutStyle
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: style.icon)
                #if os(iOS)
                .frame(width: 32, height: 32)
                #else
                .font(.system(size: 14))
                .frame(width: 28, height: 28)
                #endif
        }
        #if os(iOS)
        .buttonStyle(.bordered)
        .tint(isSelected ? Color.secondary : Color.gray)
        #else
        .buttonStyle(.plain)
        .foregroundStyle(isSelected ? Color.primary : Color.secondary)
        #endif
        .background(isSelected ? Color.secondary.opacity(0.14) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 6))
        #if os(macOS)
        .help(style.description)
        #endif
        .accessibilityLabel(style.description)
    }
}

#Preview {
    NavigationStack {
        YearView()
    }
    .environment(CalendarViewModel())
    .environment(AppSettings())
}
