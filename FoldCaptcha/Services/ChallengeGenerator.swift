import Foundation

struct ChallengeGenerator {
    let tolerance: Double
    let holdDuration: TimeInterval

    init(
        tolerance: Double = 3,
        holdDuration: TimeInterval = 0.75
    ) {
        self.tolerance = tolerance
        self.holdDuration = holdDuration
    }

    func makeChallenge() -> FoldChallenge {
        let first = randomAngle(excluding: [])
        let second = randomAngle(excluding: [first])
        let third = randomAngle(excluding: [first, second])

        return FoldChallenge(
            targets: [
                FoldTarget(
                    angle: first,
                    tolerance: tolerance
                ),
                FoldTarget(
                    angle: second,
                    tolerance: tolerance
                ),
                FoldTarget(
                    angle: third,
                    tolerance: tolerance,
                    holdDuration: holdDuration
                )
            ]
        )
    }

    private func randomAngle(excluding existing: [Double]) -> Double {
        let candidates = stride(
            from: 45.0,
            through: 145.0,
            by: 1.0
        )
        .filter { candidate in
            existing.allSatisfy { abs(candidate - $0) >= 25 }
        }

        return candidates.randomElement() ?? 90
    }
}
