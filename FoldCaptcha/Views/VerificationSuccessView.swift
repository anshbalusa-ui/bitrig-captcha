import SwiftUI

struct VerificationSuccessView: View {
    let result: VerificationResult
    let restart: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(
                systemName: "checkmark.circle.fill"
            )
            .font(
                .system(
                    size: 64,
                    weight: .semibold
                )
            )
            .symbolRenderingMode(.hierarchical)
            .foregroundStyle(.green)

            Text("Human Verified")
                .font(.title2.bold())

            Text("Returning…")
                .foregroundStyle(.secondary)

            Button(
                "Run again",
                action: restart
            )
            .buttonStyle(.borderedProminent)
            .padding(.top, 8)
        }
        .padding(32)
        .background(
            .ultraThinMaterial,
            in: RoundedRectangle(
                cornerRadius: 28,
                style: .continuous
            )
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Human verified")
    }
}
