import SwiftUI

struct DayCell: View {
    let day: DayData
    let isSelected: Bool
    let eventColors: [Color]
    let appSettings: AppSettings
    let onTap: () -> Void

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    private var isWeekend: Bool { appSettings.isWeekend(weekday: day.weekday) }
    
    // Much smaller sizes for compact (narrow iPhone) displays to prevent collisions
    private var circleSize: CGFloat {
        #if os(iOS)
        return horizontalSizeClass == .compact ? 14 : 28
        #else
        return 28
        #endif
    }
    
    private var fontSize: Font {
        #if os(iOS)
        return horizontalSizeClass == .compact ? .system(size: 8, design: .rounded) : .system(size: 9, design: .rounded)
        #else
        return .system(size: 9, design: .rounded)
        #endif
    }

    var body: some View {
        WobbleTapButton(hasEvents: !eventColors.isEmpty, wobbleScale: 1.1, wobbleRotation: 2.5, action: onTap) {
            VStack(spacing: 2) {
                ZStack {
                    // Weekend/weekday background
                    if !day.isToday && !isSelected {
                        Circle()
                            .fill(appSettings.backgroundColor(isWeekend: isWeekend))
                            .frame(width: circleSize, height: circleSize)
                    }
                    
                    // Today highlight
                    if day.isToday {
                        Circle()
                            .fill(appSettings.todayColor)
                            .frame(width: circleSize, height: circleSize)
                    }

                    // Selection ring
                    if isSelected && !day.isToday {
                        Circle()
                            .stroke(appSettings.todayColor, lineWidth: 2)
                            .frame(width: circleSize, height: circleSize)
                    }

                    Text("\(day.dayNumber)")
                        .font(fontSize)
                        .fontWeight(day.isToday ? .bold : .regular)
                        .foregroundStyle(dayTextColor)
                }
                .frame(width: circleSize + 2, height: circleSize + 2)

                // Event dots - smaller on compact displays
                HStack(spacing: horizontalSizeClass == .compact ? 1 : 2) {
                    ForEach(eventColors.prefix(3), id: \.self) { color in
                        Circle()
                            .fill(color)
                            .frame(width: horizontalSizeClass == .compact ? 2 : 4, height: horizontalSizeClass == .compact ? 2 : 4)
                    }
                }
                .frame(height: horizontalSizeClass == .compact ? 3 : 6)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint("Double tap to view events")
        .accessibilityAddTraits(day.isToday ? [.isSelected] : [])
    }

    private var dayTextColor: Color {
        if day.isToday {
            return appSettings.dateLabelColor
        } else {
            return appSettings.dateLabelColor
        }
    }

    private var accessibilityLabel: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        var label = formatter.string(from: day.date)

        if day.isToday {
            label = "Today, " + label
        }

        let eventCount = eventColors.count
        if eventCount > 0 {
            label += ", \(eventCount) event\(eventCount == 1 ? "" : "s")"
        }

        return label
    }
}

struct CompactDayCell: View {
    let day: DayData
    let hasEvents: Bool
    let eventColor: Color?
    let onTap: () -> Void

    var body: some View {
        WobbleTapButton(hasEvents: hasEvents, action: onTap) {
            ZStack {
                // Background for today
                if day.isToday {
                    Circle()
                        .fill(Color.gray.opacity(0.25))
                        .frame(width: 16, height: 16)
                }

                // Event indicator
                if hasEvents && !day.isToday {
                    Circle()
                        .fill(eventColor ?? .gray)
                        .frame(width: 16, height: 16)
                        .opacity(0.3)
                }

                Text("\(day.dayNumber)")
                    .font(.system(size: 9, weight: day.isToday ? .bold : .regular, design: .rounded))
                    .foregroundStyle(day.isToday ? .primary : (day.isWeekend ? .secondary : .primary))
            }
            .frame(width: 16, height: 16)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
    }

    private var accessibilityLabel: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        var label = formatter.string(from: day.date)

        if day.isToday {
            label = "Today, " + label
        }

        if hasEvents {
            label += ", has events"
        }

        return label
    }
}

struct WobbleTapButton<Label: View>: View {
    let hasEvents: Bool
    let wobbleScale: CGFloat
    let wobbleRotation: Double
    let wobbleDuration: TimeInterval
    let action: () -> Void
    let label: () -> Label

    @State private var isWobbling = false

    init(
        hasEvents: Bool,
        wobbleScale: CGFloat = 1.03,
        wobbleRotation: Double = 1.2,
        wobbleDuration: TimeInterval = 0.12,
        action: @escaping () -> Void,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.hasEvents = hasEvents
        self.wobbleScale = wobbleScale
        self.wobbleRotation = wobbleRotation
        self.wobbleDuration = wobbleDuration
        self.action = action
        self.label = label
    }

    var body: some View {
        Button(action: handleTap) {
            label()
                .scaleEffect(isWobbling ? wobbleScale : 1)
                .rotationEffect(.degrees(isWobbling ? wobbleRotation : 0))
        }
    }

    private func handleTap() {
        if hasEvents {
            action()
        } else {
            triggerWobble()
        }
    }

    private func triggerWobble() {
        HapticFeedback.light()

        let animation = Animation.spring(response: 0.18, dampingFraction: 0.45)
        withAnimation(animation) {
            isWobbling = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + wobbleDuration) {
            withAnimation(animation) {
                isWobbling = false
            }
        }
    }
}

#Preview("Day Cell") {
    let settings = AppSettings()
    return HStack(spacing: 20) {
        DayCell(
            day: DayData(date: Date(), calendar: Calendar.current),
            isSelected: false,
            eventColors: [.blue, .green],
            appSettings: settings,
            onTap: {}
        )

        DayCell(
            day: DayData(date: Date(), calendar: Calendar.current),
            isSelected: true,
            eventColors: [.blue],
            appSettings: settings,
            onTap: {}
        )

        DayCell(
            day: DayData(date: Date().addingTimeInterval(86400), calendar: Calendar.current),
            isSelected: false,
            eventColors: [],
            appSettings: settings,
            onTap: {}
        )
    }
    .padding()
}

#Preview("Compact Day Cell") {
    HStack(spacing: 8) {
        CompactDayCell(
            day: DayData(date: Date(), calendar: Calendar.current),
            hasEvents: true,
            eventColor: .blue,
            onTap: {}
        )

        CompactDayCell(
            day: DayData(date: Date().addingTimeInterval(86400), calendar: Calendar.current),
            hasEvents: false,
            eventColor: nil,
            onTap: {}
        )
    }
    .padding()
}
