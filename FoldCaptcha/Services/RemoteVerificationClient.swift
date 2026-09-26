import Foundation

struct ServerVerificationResponse: Decodable, Sendable {
    let verified: Bool
    let token: String
    let expiresAt: Int64
}

actor RemoteVerificationClient {
    private struct ServerTarget: Decodable {
        let angle: Double
        let tolerance: Double
        let holdDurationMs: Int
    }

    private struct ServerChallenge: Decodable {
        let id: UUID
        let targets: [ServerTarget]
    }

    private struct VerifyRequest: Encodable {
        struct Sample: Encodable {
            let angle: Double
            let timestampMs: Int64
        }

        let challengeId: UUID
        let samples: [Sample]
    }

    private let baseURL: URL
    private let session: URLSession

    init(
        baseURL: URL,
        session: URLSession = .shared
    ) {
        self.baseURL = baseURL
        self.session = session
    }

    func requestChallenge() async throws -> FoldChallenge {
        var request = URLRequest(
            url: baseURL.appending(
                path: "api/challenge"
            )
        )

        request.httpMethod = "POST"
        request.setValue(
            "application/json",
            forHTTPHeaderField: "content-type"
        )

        let (data, response) = try await session.data(
            for: request
        )

        try validateHTTP(response)

        let serverChallenge = try JSONDecoder()
            .decode(
                ServerChallenge.self,
                from: data
            )

        return FoldChallenge(
            id: serverChallenge.id,
            targets: serverChallenge.targets.map {
                FoldTarget(
                    angle: $0.angle,
                    tolerance: $0.tolerance,
                    holdDuration:
                        Double($0.holdDurationMs) /
                        1_000
                )
            }
        )
    }

    func verify(
        challengeID: UUID,
        samples: [HingeSample]
    ) async throws -> ServerVerificationResponse {
        let payload = VerifyRequest(
            challengeId: challengeID,
            samples: samples.map {
                VerifyRequest.Sample(
                    angle: $0.angle,
                    timestampMs: Int64(
                        $0.timestamp
                            .timeIntervalSince1970 *
                        1_000
                    )
                )
            }
        )

        var request = URLRequest(
            url: baseURL.appending(
                path: "api/verify"
            )
        )

        request.httpMethod = "POST"
        request.setValue(
            "application/json",
            forHTTPHeaderField: "content-type"
        )
        request.httpBody = try JSONEncoder()
            .encode(payload)

        let (data, response) = try await session.data(
            for: request
        )

        try validateHTTP(response)

        return try JSONDecoder().decode(
            ServerVerificationResponse.self,
            from: data
        )
    }

    private func validateHTTP(
        _ response: URLResponse
    ) throws {
        guard
            let http = response as? HTTPURLResponse,
            (200..<300).contains(
                http.statusCode
            )
        else {
            throw URLError(
                .badServerResponse
            )
        }
    }
}
