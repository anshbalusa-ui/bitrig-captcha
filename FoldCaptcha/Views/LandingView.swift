import SwiftUI

struct LandingView: View {
    @ObservedObject var viewModel: ChallengeViewModel
    let onBegin: () -> Void

    @State private var initialAngle: Double?
    @State private var hasStartedFold = false

    private let automaticStartDelta: Double = 12

    var body: some View {
        ZStack {
            landingBackground

            VStack(spacing: 28) {
                Spacer(minLength: 24)

                HumanLogo(
                    angle: viewModel.currentAngle
                )

                landingGlass

                VStack(spacing: 10) {
                    Text("Bend to begin")
                        .font(.headline)

                    Text(
                        "Current angle: \(Int(viewModel.currentAngle.rounded()))°"
                    )
                    .font(
                        .title3
                            .monospacedDigit()
                            .bold()
                    )
                    .contentTransition(.numericText())
                    .accessibilityLabel(
                        "Current hinge angle"
                    )
                    .accessibilityValue(
                        "\(Int(viewModel.currentAngle.rounded())) degrees"
                    )

                    Text(
                        "The angle updates live as you fold the Duo."
                    )
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                }

                Button("Start verification") {
                    onBegin()
                }
                .buttonStyle(.glassProminent)
                .accessibilityHint(
                    "Starts the fold verification challenge."
                )

                if !viewModel.hingeAvailable {
                    Text(
                        "On iPhone Duo, folding the device starts automatically. Use the button above on other simulators."
                    )
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                }

                Spacer(minLength: 20)
            }
            .padding(28)
            .frame(maxWidth: 560)
            .frame(maxWidth: .infinity)
        }
        .onAppear {
            initialAngle = viewModel.currentAngle
        }
        .onChange(
            of: viewModel.currentAngle
        ) { oldValue, newValue in
            guard
                viewModel.hingeAvailable,
                !hasStartedFold
            else {
                return
            }

            if initialAngle == nil {
                initialAngle = oldValue
            }

            guard let initialAngle else {
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

    private var landingGlass: some View {
        VStack(spacing: 18) {
            FoldVisualizer(
                currentAngle: viewModel.currentAngle,
                targetAngle: 110,
                isInsideTolerance: false
            )
            .opacity(0.95)

            HStack {
                Label(
                    "Live hinge",
                    systemImage: "angle"
                )
                .font(.subheadline.bold())

                Spacer()

                Text(
                    "\(Int(viewModel.currentAngle.rounded()))°"
                )
                .font(
                    .title2
                        .monospacedDigit()
                        .bold()
                )
                .contentTransition(.numericText())
            }
        }
        .padding(24)
        .glassEffect(
            .regular,
            in: RoundedRectangle(
                cornerRadius: 30,
                style: .continuous
            )
        )
    }

    private var landingBackground: some View {
        ZStack {
            Color(.systemBackground)

            RadialGradient(
                colors: [
                    Color.accentColor.opacity(0.16),
                    Color.clear
                ],
                center: .center,
                startRadius: 20,
                endRadius: 360
            )

            LinearGradient(
                colors: [
                    Color.clear,
                    Color.secondary.opacity(0.07)
                ],
                startPoint: .top,
                endPoint: .bottomTrailing
            )
        }
        .ignoresSafeArea()
    }
}
