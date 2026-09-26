import Foundation

struct VerificationResult: Identifiable, Equatable, Sendable {
    let id: UUID
    let challengeID: UUID
    let verifiedAt: Date
    let expiresAt: Date

    var isValid: Bool {
        Date() < expiresAt
    }

    static func success(
        for challenge: FoldChallenge,
        lifetime: TimeInterval = 30
    ) -> VerificationResult {
        let now = Date()

        return VerificationResult(
            id: UUID(),
            challengeID: challenge.id,
            verifiedAt: now,
            expiresAt: now.addingTimeInterval(lifetime)
        )
    }
}
