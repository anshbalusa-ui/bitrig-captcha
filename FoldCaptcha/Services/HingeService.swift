import Foundation

protocol HingeService: AnyObject {
    var onAngleChange: (@MainActor (Double) -> Void)? { get set }

    func start()
    func stop()
}

/// Development provider used until the real iPhone Duo hinge API is wired.
///
/// Keep the rest of the project dependent on HingeService rather than directly
/// on the hardware API. Bitrig can then add a production Duo implementation
/// without changing the challenge state machine or UI.
final class SimulatorHingeService: HingeService {
    var onAngleChange: (@MainActor (Double) -> Void)?

    private var timer: Timer?
    private var angle: Double = 120
    private var direction: Double = -1

    func start() {
        stop()

        timer = Timer.scheduledTimer(
            withTimeInterval: 0.05,
            repeats: true
        ) { [weak self] _ in
            guard let self else { return }

            angle += direction * 1.5

            if angle <= 40 {
                angle = 40
                direction = 1
            } else if angle >= 160 {
                angle = 160
                direction = -1
            }

            let updatedAngle = angle

            Task { @MainActor [weak self] in
                self?.onAngleChange?(updatedAngle)
            }
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    deinit {
        timer?.invalidate()
    }
}
