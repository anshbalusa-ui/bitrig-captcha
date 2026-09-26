import SwiftUI

struct LandingView: View {
    @ObservedObject var viewModel: ChallengeViewModel
    let onBegin: () -> Void

    @State private var initialAngle: Double?
    @State private var hasStartedFold = false

    private let automaticStartDelta: Double = 12

    var body: some View {
        ZStack {
            background

            VStack(spacing: 0) {
                topBrand
                    .padding(.top, 26)

                Spacer(minLength: 14)

                LandingHeroVisual(
                    angle: viewModel.currentAngle,
                    hingeAvailable: viewModel.hingeAvailable
                )
                .frame(maxWidth: 620)
                .padding(.horizontal, 8)

                Spacer(minLength: 12)

                bottomCopy

                Spacer(minLength: 18)

                controls
                    .padding(.bottom, 28)
            }
            .padding(.horizontal, 24)
            .frame(maxWidth: 680)
            .frame(maxWidth: .infinity)
        }
        .onChange(
            of: viewModel.currentAngle
        ) { _, newValue in
            guard
                viewModel.hingeAvailable,
                !hasStartedFold
            else {
                return
            }

            guard let initialAngle else {
                self.initialAngle = newValue
                return
            }

            let delta = abs(
                newValue - initialAngle
            )

            if delta >= automaticStartDelta {
                hasStartedFold = true
                onBegin()
            }
        }
    }

    private var topBrand: some View {
        VStack(spacing: 6) {
            Text("HUMAN")
                .font(
                    .system(
                        size: 30,
                        weight: .bold
                    )
                )
                .tracking(3.5)

            Text("PHYSICAL VERIFICATION")
                .font(
                    .caption2
                        .weight(.semibold)
                )
                .tracking(2)
                .foregroundStyle(.tertiary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "HUMAN physical verification"
        )
    }

    private var bottomCopy: some View {
        VStack(spacing: 8) {
            Text("Bend to begin")
                .font(
                    .system(
                        size: 28,
                        weight: .semibold,
                        design: .rounded
                    )
                )

            Text(
                viewModel.hingeAvailable
                    ? "Your phone is the challenge."
                    : "Move the Duo hinge or use the button below."
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)

            Text(
                "The angle above moves live with the device."
            )
            .font(.footnote)
            .foregroundStyle(.tertiary)
            .multilineTextAlignment(.center)
        }
    }

    private var controls: some View {
        VStack(spacing: 12) {
            Button {
                onBegin()
            } label: {
                HStack(spacing: 8) {
                    Text("Start verification")
                    Image(
                        systemName: "arrow.right"
                    )
                }
                .font(.headline)
                .frame(maxWidth: 360)
            }
            .buttonStyle(.glassProminent)
            .accessibilityHint(
                "Starts the fold verification challenge."
            )

            if !viewModel.hingeAvailable {
                Text(
                    "On iPhone Duo, a real fold of about 12° starts automatically."
                )
                .font(.caption)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
            }
        }
    }

    private var background: some View {
        ZStack {
            Color(.systemBackground)

            RadialGradient(
                colors: [
                    Color.accentColor.opacity(0.12),
                    Color.clear
                ],
                center: .center,
                startRadius: 10,
                endRadius: 430
            )

            LinearGradient(
                colors: [
                    Color.clear,
                    Color.secondary.opacity(0.045)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .ignoresSafeArea()
    }
}
