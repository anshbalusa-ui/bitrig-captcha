import SwiftUI

struct ChallengeView: View {
    @StateObject var viewModel: ChallengeViewModel

    var body: some View {
        ZStack {
            background

            Group {
                switch viewModel.phase {
                case .active:
                    challengeContent

                case .verified(let result):
                    VerificationSuccessView(
                        result: result
                    ) {
                        viewModel.restart()
                        viewModel.start()
                    }
                }
            }
            .padding(24)
        }
        .onAppear {
            viewModel.start()
        }
        .onDisappear {
            viewModel.stop()
        }
    }

    private var background: some View {
        LinearGradient(
            colors: [
                Color(.systemBackground),
                Color(.secondarySystemBackground)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    private var challengeContent: some View {
        VStack(spacing: 22) {
            header

            if let target = viewModel.currentTarget {
                challengeCard(target: target)
            }

            stepProgress

            Text(statusText)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .animation(
                    .easeInOut(duration: 0.15),
                    value: viewModel.distanceFromTarget
                )
        }
        .frame(maxWidth: 560)
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
    }

    private func challengeCard(
        target: FoldTarget
    ) -> some View {
        VStack(spacing: 20) {
            FoldVisualizer(
                currentAngle: viewModel.currentAngle,
                targetAngle: target.angle,
                isInsideTolerance: viewModel.isInsideTolerance
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
        .background(
            .ultraThinMaterial,
            in: RoundedRectangle(
                cornerRadius: 28,
                style: .continuous
            )
        )
        .overlay {
            RoundedRectangle(
                cornerRadius: 28,
                style: .continuous
            )
            .stroke(
                .white.opacity(0.14),
                lineWidth: 1
            )
        }
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
