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

            Text("Verification expires in 30 seconds")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(
                String(result.token.prefix(8)).uppercased()
            )
            .font(
                .caption
                    .monospaced()
            )
            .foregroundStyle(.tertiary)
            .accessibilityLabel("Temporary verification token issued")

            Button(
                "Run again",
                action: restart
            )
            .buttonStyle(.glassProminent)
            .padding(.top, 8)
        }
        .padding(32)
        .frame(maxWidth: 420)
        .glassEffect(
            .regular,
            in: RoundedRectangle(
                cornerRadius: 30,
                style: .continuous
            )
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Human verified")
    }
}
