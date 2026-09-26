import UIKit

@MainActor
final class HapticService {
    private let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private let notification = UINotificationFeedbackGenerator()

    func prepare() {
        lightImpact.prepare()
        mediumImpact.prepare()
        notification.prepare()
    }

    func enteredTolerance() {
        lightImpact.impactOccurred(intensity: 0.7)
        lightImpact.prepare()
    }

    func completedStep() {
        mediumImpact.impactOccurred(intensity: 0.85)
        mediumImpact.prepare()
    }

    func success() {
        notification.notificationOccurred(.success)
        notification.prepare()
    }
}
