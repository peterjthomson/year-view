import SwiftUI
#if os(iOS)
import UIKit
#endif

struct HapticFeedback {
    static func light() {
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        #endif
    }

    static func medium() {
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        #endif
    }

    static func heavy() {
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        #endif
    }

    static func selection() {
        #if os(iOS)
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
        #endif
    }

    static func success() {
        #if os(iOS)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        #endif
    }

    static func warning() {
        #if os(iOS)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
        #endif
    }

    static func error() {
        #if os(iOS)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
        #endif
    }
}

struct HapticFeedbackModifier: ViewModifier {
    let feedbackType: FeedbackType

    enum FeedbackType {
        case light
        case medium
        case heavy
        case selection
        case success
        case warning
        case error
    }

    func body(content: Content) -> some View {
        content
            .onTapGesture {
                triggerFeedback()
            }
    }

    private func triggerFeedback() {
        switch feedbackType {
        case .light:
            HapticFeedback.light()
        case .medium:
            HapticFeedback.medium()
        case .heavy:
            HapticFeedback.heavy()
        case .selection:
            HapticFeedback.selection()
        case .success:
            HapticFeedback.success()
        case .warning:
            HapticFeedback.warning()
        case .error:
            HapticFeedback.error()
        }
    }
}

extension View {
    func hapticFeedback(_ type: HapticFeedbackModifier.FeedbackType) -> some View {
        modifier(HapticFeedbackModifier(feedbackType: type))
    }
}
