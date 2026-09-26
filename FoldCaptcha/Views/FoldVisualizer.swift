import SwiftUI

struct FoldVisualizer: View {
    let currentAngle: Double
    let targetAngle: Double
    let isInsideTolerance: Bool

    var body: some View {
        GeometryReader { proxy in
            let width = min(
                proxy.size.width,
                proxy.size.height * 1.7
            )

            ZStack {
                foldShape(
                    angle: targetAngle,
                    width: width
                )
                .stroke(
                    .secondary.opacity(0.30),
                    style: StrokeStyle(
                        lineWidth: 8,
                        lineCap: .round,
                        lineJoin: .round
                    )
                )

                foldShape(
                    angle: currentAngle,
                    width: width
                )
                .stroke(
                    isInsideTolerance
                        ? Color.accentColor
                        : Color.primary,
                    style: StrokeStyle(
                        lineWidth: 7,
                        lineCap: .round,
                        lineJoin: .round
                    )
                )
                .animation(
                    .interactiveSpring(
                        response: 0.20,
                        dampingFraction: 0.90
                    ),
                    value: currentAngle
                )
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity
            )
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Fold position")
            .accessibilityValue(
                "Current angle \(Int(currentAngle.rounded())) degrees. Target \(Int(targetAngle.rounded())) degrees."
            )
        }
        .aspectRatio(
            1.7,
            contentMode: .fit
        )
    }

    private func foldShape(
        angle: Double,
        width: CGFloat
    ) -> Path {
        let clamped = min(
            max(angle, 35),
            170
        )

        let normalized = CGFloat(
            (clamped - 35) / 135
        )

        let bend = (1 - normalized) * width * 0.23

        return Path { path in
            let y = width * 0.34
            let centerX = width * 0.5
            let half = width * 0.34

            path.move(
                to: CGPoint(
                    x: centerX - half,
                    y: y
                )
            )

            path.addLine(
                to: CGPoint(
                    x: centerX,
                    y: y
                )
            )

            path.addLine(
                to: CGPoint(
                    x: centerX + half,
                    y: y - bend
                )
            )
        }
    }
}
