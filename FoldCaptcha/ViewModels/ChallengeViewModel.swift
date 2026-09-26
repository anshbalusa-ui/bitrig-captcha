import Foundation
import SwiftUI

@MainActor
final class ChallengeViewModel: ObservableObject {
    enum Phase: Equatable {
        case active
        case verified(VerificationResult)
    }

    @Published private(set) var challenge: FoldChallenge
    @Published private(set) var currentIndex: Int = 0
    @Published private(set) var currentAngle: Double = 120
    @Published private(set) var holdProgress: Double = 0
    @Published private(set) var phase: Phase = .active

    private var hingeService: HingeService
    private let challengeGenerator: ChallengeGenerator
    private var validator: TrajectoryValidator
    private let haptics: HapticService

    private var enteredTolerance = false
    private var holdStart: Date?

    init(
        hingeService: HingeService,
        challengeGenerator: ChallengeGenerator,
        validator: TrajectoryValidator,
        haptics: HapticService
    ) {
        self.hingeService = hingeService
        self.challengeGenerator = challengeGenerator
        self.validator = validator
        self.haptics = haptics
        self.challenge = challengeGenerator.makeChallenge()

        self.hingeService.onAngleChange = { [weak self] angle in
            self?.receive(angle: angle)
        }
    }

    var currentTarget: FoldTarget? {
        guard challenge.targets.indices.contains(currentIndex) else {
            return nil
        }

        return challenge.targets[currentIndex]
    }

    var progressText: String {
        "\(min(currentIndex + 1, challenge.targets.count)) of \(challenge.targets.count)"
    }

    var distanceFromTarget: Double {
        guard let target = currentTarget else {
            return 0
        }

        return abs(currentAngle - target.angle)
    }

    var isInsideTolerance: Bool {
        guard let target = currentTarget else {
            return false
        }

        return validator.isInside(
            target,
            angle: currentAngle
        )
    }

    func start() {
        haptics.prepare()
        hingeService.start()
    }

    func stop() {
        hingeService.stop()
    }

    func restart() {
        challenge = challengeGenerator.makeChallenge()
        currentIndex = 0
        holdProgress = 0
        phase = .active
        enteredTolerance = false
        holdStart = nil
        validator.reset()
    }

    private func receive(angle: Double) {
        guard
            case .active = phase,
            let target = currentTarget
        else {
            return
        }

        currentAngle = angle
        validator.record(angle: angle)

        let inside = validator.isInside(
            target,
            angle: angle
        )

        if inside && !enteredTolerance {
            enteredTolerance = true
            haptics.enteredTolerance()
        } else if !inside {
            enteredTolerance = false
        }

        if target.requiresHold {
            updateHold(
                for: target,
                inside: inside
            )
        } else if inside {
            completeCurrentStep()
        }
    }

    private func updateHold(
        for target: FoldTarget,
        inside: Bool
    ) {
        guard inside else {
            holdStart = nil
            holdProgress = 0
            return
        }

        if holdStart == nil {
            holdStart = Date()
        }

        guard let holdStart else {
            return
        }

        let elapsed = Date().timeIntervalSince(holdStart)
        holdProgress = min(
            elapsed / target.holdDuration,
            1
        )

        if holdProgress >= 1 {
            completeCurrentStep()
        }
    }

    private func completeCurrentStep() {
        haptics.completedStep()

        enteredTolerance = false
        holdStart = nil
        holdProgress = 0

        if currentIndex + 1 < challenge.targets.count {
            currentIndex += 1
            return
        }

        let result = VerificationResult.success(
            for: challenge
        )

        phase = .verified(result)
        haptics.success()
        hingeService.stop()
    }
}
