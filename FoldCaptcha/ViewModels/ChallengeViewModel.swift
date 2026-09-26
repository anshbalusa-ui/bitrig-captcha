import Foundation
import SwiftUI

@MainActor
final class ChallengeViewModel: ObservableObject {
    enum Phase: Equatable {
        case active
        case verified(VerificationResult)
        case retryNeeded
    }

    @Published private(set) var challenge: FoldChallenge
    @Published private(set) var currentIndex: Int = 0
    @Published private(set) var currentAngle: Double = 120
    @Published private(set) var hingeAvailable = false
    @Published private(set) var holdProgress: Double = 0
    @Published private(set) var phase: Phase = .active

    private let challengeGenerator: ChallengeGenerator
    private var validator: TrajectoryValidator
    private let haptics: HapticService

    private var enteredTolerance = false
    private var holdTask: Task<Void, Never>?

    init(
        challengeGenerator: ChallengeGenerator,
        validator: TrajectoryValidator,
        haptics: HapticService
    ) {
        self.challengeGenerator = challengeGenerator
        self.validator = validator
        self.haptics = haptics
        self.challenge = challengeGenerator.makeChallenge()
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

    var recordedSamples: [HingeSample] {
        validator.samples
    }

    func prepare() {
        haptics.prepare()
    }

    func receiveHingeReading(
        _ reading: HingeReading
    ) {
        hingeAvailable = reading.isAvailable

        guard let angle = reading.angle else {
            cancelHold(resetProgress: true)
            return
        }

        processAngle(
            angle,
            timestamp: reading.timestamp
        )
    }

    /// Used only for previews and fallback debugging on a non-Duo simulator.
    func receiveDebugAngle(
        _ angle: Double
    ) {
        processAngle(
            angle,
            timestamp: Date()
        )
    }

    func restart() {
        holdTask?.cancel()
        holdTask = nil

        challenge = challengeGenerator.makeChallenge()
        currentIndex = 0
        holdProgress = 0
        phase = .active
        enteredTolerance = false
        validator.reset()

        haptics.prepare()
    }

    private func processAngle(
        _ rawAngle: Double,
        timestamp: Date
    ) {
        guard case .active = phase else {
            return
        }

        let angle = min(
            max(rawAngle, 0),
            180
        )

        currentAngle = angle
        validator.record(
            angle: angle,
            at: timestamp
        )

        guard let target = currentTarget else {
            return
        }

        let inside = validator.isInside(
            target,
            angle: angle
        )

        if inside && !enteredTolerance {
            enteredTolerance = true

            if target.requiresHold {
                haptics.enteredTolerance()
                beginHold(for: target)
            }
        }

        if !inside {
            enteredTolerance = false

            if target.requiresHold {
                cancelHold(resetProgress: true)
            }
        }

        if inside && !target.requiresHold {
            completeCurrentStep()
        }
    }

    private func beginHold(
        for target: FoldTarget
    ) {
        guard holdTask == nil else {
            return
        }

        let targetID = target.id
        let startedAt = Date()

        holdTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(
                    for: .milliseconds(50)
                )

                guard let self else {
                    return
                }

                guard
                    case .active = self.phase,
                    self.currentTarget?.id == targetID,
                    self.isInsideTolerance
                else {
                    self.cancelHold(
                        resetProgress: true
                    )
                    return
                }

                // Sample during a steady hold too, not only while the hinge is
                // physically moving. This lets local/server validation prove
                // the requested hold duration happened continuously.
                self.validator.record(
                    angle: self.currentAngle,
                    at: Date()
                )

                let elapsed = Date().timeIntervalSince(
                    startedAt
                )

                self.holdProgress = min(
                    elapsed / target.holdDuration,
                    1
                )

                if self.holdProgress >= 1 {
                    self.holdTask = nil
                    self.completeCurrentStep()
                    return
                }
            }
        }
    }

    private func cancelHold(
        resetProgress: Bool
    ) {
        holdTask?.cancel()
        holdTask = nil

        if resetProgress {
            holdProgress = 0
        }
    }

    private func completeCurrentStep() {
        guard
            case .active = phase,
            let target = currentTarget,
            validator.isInside(
                target,
                angle: currentAngle
            )
        else {
            return
        }

        validator.markTargetCompleted(
            index: currentIndex,
            angle: currentAngle
        )

        cancelHold(resetProgress: true)
        enteredTolerance = false

        let isFinalStep =
            currentIndex + 1 >= challenge.targets.count

        if !isFinalStep {
            haptics.completedStep()
            currentIndex += 1
            return
        }

        if validator.validates(challenge: challenge) {
            let result = VerificationResult.success(
                for: challenge
            )

            phase = .verified(result)
            haptics.success()
        } else {
            phase = .retryNeeded
        }
    }
}
