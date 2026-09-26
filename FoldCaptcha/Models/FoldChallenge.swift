import Foundation

struct FoldTarget: Identifiable, Equatable, Codable, Sendable {
    let id: UUID
    let angle: Double
    let tolerance: Double
    let holdDuration: TimeInterval

    init(
        id: UUID = UUID(),
        angle: Double,
        tolerance: Double = 3,
        holdDuration: TimeInterval = 0
    ) {
        self.id = id
        self.angle = angle
        self.tolerance = tolerance
        self.holdDuration = holdDuration
    }

    var validRange: ClosedRange<Double> {
        (angle - tolerance)...(angle + tolerance)
    }

    var requiresHold: Bool {
        holdDuration > 0
    }
}

struct FoldChallenge: Identifiable, Equatable, Codable, Sendable {
    let id: UUID
    let targets: [FoldTarget]

    init(
        id: UUID = UUID(),
        targets: [FoldTarget]
    ) {
        self.id = id
        self.targets = targets
    }
}
