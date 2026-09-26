import Foundation

struct HingeSample: Codable, Equatable, Sendable {
    let angle: Double
    let timestamp: Date
}

struct TargetCompletion: Codable, Equatable, Sendable {
    let targetIndex: Int
    let angle: Double
    let timestamp: Date
    let sampleIndex: Int
}

struct TrajectoryValidator {
    private(set) var samples: [HingeSample] = []
    private(set) var completions: [TargetCompletion] = []

    mutating func reset() {
        samples.removeAll(keepingCapacity: true)
        completions.removeAll(keepingCapacity: true)
    }

    mutating func record(
        angle: Double,
        at timestamp: Date = Date()
    ) {
        samples.append(
            HingeSample(
                angle: angle,
                timestamp: timestamp
            )
        )

        // Bound memory during a long debug session.
        if samples.count > 4_000 {
            let removed = samples.count - 4_000
            samples.removeFirst(removed)

            completions = completions.compactMap { completion in
                let shiftedIndex = completion.sampleIndex - removed
                guard shiftedIndex >= 0 else { return nil }

                return TargetCompletion(
                    targetIndex: completion.targetIndex,
                    angle: completion.angle,
                    timestamp: completion.timestamp,
                    sampleIndex: shiftedIndex
                )
            }
        }
    }

    func isInside(
        _ target: FoldTarget,
        angle: Double
    ) -> Bool {
        target.validRange.contains(angle)
    }

    mutating func markTargetCompleted(
        index: Int,
        angle: Double,
        at timestamp: Date = Date()
    ) {
        completions.append(
            TargetCompletion(
                targetIndex: index,
                angle: angle,
                timestamp: timestamp,
                sampleIndex: max(samples.count - 1, 0)
            )
        )
    }

    /// Validates that the final result came from one continuous, ordered
    /// sequence instead of three unrelated final angle values.
    ///
    /// This is intentionally a hackathon-grade local validator. See
    /// docs/SECURITY_NOTES.md before treating it as a production CAPTCHA.
    func validates(
        challenge: FoldChallenge
    ) -> Bool {
        guard
            completions.count == challenge.targets.count,
            samples.count >= challenge.targets.count * 2
        else {
            return false
        }

        for (index, completion) in completions.enumerated() {
            guard
                completion.targetIndex == index,
                challenge.targets[index].validRange.contains(completion.angle)
            else {
                return false
            }

            if index > 0 {
                let previous = completions[index - 1]

                guard
                    completion.sampleIndex > previous.sampleIndex,
                    completion.timestamp >= previous.timestamp
                else {
                    return false
                }

                // Make sure there was actual movement between sequential
                // challenge targets instead of duplicated snapshots.
                let segment = samples[
                    previous.sampleIndex...min(
                        completion.sampleIndex,
                        samples.count - 1
                    )
                ]

                guard
                    let minAngle = segment.map(\.angle).min(),
                    let maxAngle = segment.map(\.angle).max(),
                    (maxAngle - minAngle) >= 5
                else {
                    return false
                }
            }
        }

        return true
    }
}
