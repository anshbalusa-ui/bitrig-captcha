import SwiftUI

struct ChallengeView: View {
    @StateObject var viewModel: ChallengeViewModel

    var body: some View {
        GeometryReader { proxy in
            let divisionRegions = proxy.reservedRegions(
                kind: .division
            )

            ZStack {
                background

                Group {
                    switch viewModel.phase {
                    case .active:
                        challengeContent(
                            hasActiveDivision:
                                !divisionRegions.isEmpty
                        )

                    case .verified(let result):
                        VerificationSuccessView(
                            result: result
                        ) {
                            viewModel.restart()
                        }

                    case .retryNeeded:
                        retryContent
                    }
                }
                .padding(24)
            }
        }
        .trackDuoHinge { reading in
            viewModel.receiveHingeReading(reading)
        }
        .task {
            viewModel.prepare()
        }
    }

    private var background: some View {
        ZStack {
            Color(.systemBackground)

            LinearGradient(
                colors: [
                    Color.accentColor.opacity(0.10),
                    Color.clear,
                    Color.secondary.opacity(0.08)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        .ignoresSafeArea()
    }

    private func challengeContent(
        hasActiveDivision: Bool
    ) -> some View {
        VStack(spacing: 22) {
            header

            if let target = viewModel.currentTarget {
                challengeCard(
                    target: target
                )
            }

            stepProgress

            Text(statusText)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .contentTransition(.numericText())
                .animation(
                    .easeInOut(duration: 0.15),
                    value: viewModel.distanceFromTarget
                )

            if !viewModel.hingeAvailable {
                hingeUnavailableHint
            }

            #if DEBUG
            DebugHingeControls(
                angle: Binding(
                    get: {
                        viewModel.currentAngle
                    },
                    set: {
                        viewModel.receiveDebugAngle($0)
                    }
                )
            )
            #endif
        }
        .frame(
            maxWidth: hasActiveDivision
                ? 500
                : 560
        )
        .frame(maxWidth: .infinity)
    }

    private var header: some View {
        VStack(spacing: 6) {
            Text("Verify you're here")
                .font(.title2.bold())

            Text(
                viewModel.currentTarget?.requiresHold == true
                    ? "Hold here"
                    : "Match the fold"
            )
            .font(.headline)
            .foregroundStyle(.secondary)
        }
        .multilineTextAlignment(.center)
    }

    private func challengeCard(
        target: FoldTarget
    ) -> some View {
        VStack(spacing: 20) {
            FoldVisualizer(
                currentAngle: viewModel.currentAngle,
                targetAngle: target.angle,
                isInsideTolerance:
                    viewModel.isInsideTolerance
            )

            HStack(alignment: .firstTextBaseline) {
                VStack(
                    alignment: .leading,
                    spacing: 2
                ) {
                    Text("Current")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(
                        "\(Int(viewModel.currentAngle.rounded()))°"
                    )
                    .font(
                        .title3
                            .monospacedDigit()
                            .bold()
                    )
                }

                Spacer()

                VStack(
                    alignment: .trailing,
                    spacing: 2
                ) {
                    Text("Target")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(
                        "\(Int(target.angle.rounded()))° ± \(Int(target.tolerance))°"
                    )
                    .font(
                        .title3
                            .monospacedDigit()
                            .bold()
                    )
                }
            }

            if target.requiresHold {
                ProgressView(
                    value: viewModel.holdProgress
                )
                .accessibilityLabel("Hold progress")
                .accessibilityValue(
                    "\(Int(viewModel.holdProgress * 100)) percent"
                )
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

    private var stepProgress: some View {
        HStack(spacing: 8) {
            ForEach(
                Array(viewModel.challenge.targets.indices),
                id: \.self
            ) { index in
                Circle()
                    .fill(
                        colorForStep(index)
                    )
                    .frame(
                        width: 8,
                        height: 8
                    )
            }
        }
        .accessibilityLabel("Challenge progress")
        .accessibilityValue(viewModel.progressText)
    }

    private var hingeUnavailableHint: some View {
        Label(
            "Move this window to the iPhone Duo simulator or device to enable hinge tracking.",
            systemImage: "rectangle.split.2x1"
        )
        .font(.footnote)
        .foregroundStyle(.secondary)
        .multilineTextAlignment(.center)
        .padding(.horizontal)
    }

    private var retryContent: some View {
        VStack(spacing: 16) {
            Image(
                systemName: "arrow.clockwise.circle"
            )
            .font(.system(size: 52))
            .foregroundStyle(.secondary)

            Text("Let's try that once more")
                .font(.title3.bold())

            Text(
                "The fold sequence wasn't continuous enough to verify."
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)

            Button("New challenge") {
                viewModel.restart()
            }
            .buttonStyle(.glassProminent)
        }
        .padding(30)
        .frame(maxWidth: 420)
        .glassEffect(
            .regular,
            in: RoundedRectangle(
                cornerRadius: 30,
                style: .continuous
            )
        )
    }

    private func colorForStep(
        _ index: Int
    ) -> Color {
        if index < viewModel.currentIndex {
            return .accentColor
        }

        if index == viewModel.currentIndex {
            return .primary
        }

        return .secondary.opacity(0.25)
    }

    private var statusText: String {
        if viewModel.isInsideTolerance {
            return viewModel.currentTarget?.requiresHold == true
                ? "Hold steady"
                : "Matched"
        }

        switch viewModel.distanceFromTarget {
        case 0..<7:
            return "Almost there"
        case 7..<18:
            return "Getting close"
        default:
            return "Fold toward the ghosted target"
        }
    }
}
