import Foundation

struct HingeSample: Sendable {
    let angle: Double
    let timestamp: Date
}

struct TrajectoryValidator {
    private(set) var samples: [HingeSample] = []

    mutating func reset() {
        samples.removeAll(keepingCapacity: true)
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

        if samples.count > 2_000 {
            samples.removeFirst(samples.count - 2_000)
        }
    }

    func isInside(
        _ target: FoldTarget,
        angle: Double
    ) -> Bool {
        target.validRange.contains(angle)
    }

    /// Lightweight prototype check proving that recent data contains an actual
    /// trajectory rather than a single submitted final value.
    ///
    /// Production security should add stronger server-backed validation.
    func hasMeaningfulRecentMotion(
        window: TimeInterval = 2
    ) -> Bool {
        guard let last = samples.last else {
            return false
        }

        let cutoff = last.timestamp.addingTimeInterval(-window)
        let recent = samples.filter { $0.timestamp >= cutoff }

        guard
            let minAngle = recent.map(\.angle).min(),
            let maxAngle = recent.map(\.angle).max()
        else {
            return false
        }

        return (maxAngle - minAngle) >= 4
    }
}
