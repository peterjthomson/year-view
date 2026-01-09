import SwiftUI

extension Color {
    var luminance: Double {
        #if os(macOS)
        let cgColor = NSColor(self).cgColor
        #else
        let cgColor = UIColor(self).cgColor
        #endif

        guard let components = cgColor.components, components.count >= 3 else {
            return 0.5
        }

        let red = components[0]
        let green = components[1]
        let blue = components[2]

        // Calculate relative luminance
        return 0.2126 * Double(red) + 0.7152 * Double(green) + 0.0722 * Double(blue)
    }

    var isDark: Bool {
        luminance < 0.5
    }

    var contrastingTextColor: Color {
        isDark ? .white : .black
    }

    func adjustedBrightness(_ amount: Double) -> Color {
        #if os(macOS)
        guard let nsColor = NSColor(self).usingColorSpace(.deviceRGB) else {
            return self
        }

        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0

        nsColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)

        let newBrightness = max(0, min(1, brightness + CGFloat(amount)))
        return Color(NSColor(hue: hue, saturation: saturation, brightness: newBrightness, alpha: alpha))
        #else
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0

        UIColor(self).getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)

        let newBrightness = max(0, min(1, brightness + CGFloat(amount)))
        return Color(UIColor(hue: hue, saturation: saturation, brightness: newBrightness, alpha: alpha))
        #endif
    }

    func withOpacity(_ opacity: Double) -> Color {
        self.opacity(opacity)
    }

    static var systemGroupedBackground: Color {
        #if os(macOS)
        Color(NSColor.windowBackgroundColor)
        #else
        Color(UIColor.systemGroupedBackground)
        #endif
    }

    static var secondarySystemGroupedBackground: Color {
        #if os(macOS)
        Color(NSColor.controlBackgroundColor)
        #else
        Color(UIColor.secondarySystemGroupedBackground)
        #endif
    }
}

extension Color {
    init(cgColor: CGColor) {
        #if os(macOS)
        if let nsColor = NSColor(cgColor: cgColor) {
            self.init(nsColor)
        } else {
            self.init(.gray)
        }
        #else
        self.init(UIColor(cgColor: cgColor))
        #endif
    }
}

struct CalendarColors {
    static let defaultColors: [Color] = [
        .blue,
        .green,
        .orange,
        .purple,
        .pink,
        .red,
        .yellow,
        .cyan,
        .indigo,
        .mint,
        .teal,
        .brown
    ]

    static func color(for index: Int) -> Color {
        defaultColors[index % defaultColors.count]
    }

    static func randomColor() -> Color {
        defaultColors.randomElement() ?? .blue
    }
}
