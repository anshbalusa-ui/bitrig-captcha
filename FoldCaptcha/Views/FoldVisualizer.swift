import SwiftUI

/// Draws a side profile of the folding device.
///
/// The left half stays horizontal. The right half rotates using the actual
/// hinge angle so 180° appears flat and 90° appears upright. The target is
/// rendered as a ghost behind the live position.
struct FoldVisualizer: View {
    let currentAngle: Double
    let targetAngle: Double
    let isInsideTolerance: Bool

    var body: some View {
        GeometryReader { proxy in
            let size = min(
                proxy.size.width,
                proxy.size.height * 1.75
            )

            ZStack {
                hingeShape(
                    angle: targetAngle,
                    size: size
                )
                .stroke(
                    .secondary.opacity(0.28),
                    style: StrokeStyle(
                        lineWidth: 10,
                        lineCap: .round,
                        lineJoin: .round,
                        dash: [12, 10]
                    )
                )

                hingeShape(
                    angle: currentAngle,
                    size: size
                )
                .stroke(
                    isInsideTolerance
                        ? Color.accentColor
                        : Color.primary,
                    style: StrokeStyle(
                        lineWidth: 8,
                        lineCap: .round,
                        lineJoin: .round
                    )
                )
                .animation(
                    .interactiveSpring(
                        response: 0.18,
                        dampingFraction: 0.92
                    ),
                    value: currentAngle
                )

                hingeDot(size: size)
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity
            )
        }
        .aspectRatio(
            1.75,
            contentMode: .fit
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Fold position")
        .accessibilityValue(
            "Current angle \(Int(currentAngle.rounded())) degrees. Target \(Int(targetAngle.rounded())) degrees."
        )
    }

    private func hingeShape(
        angle: Double,
        size: CGFloat
    ) -> Path {
        let clamped = min(
            max(angle, 0),
            180
        )

        let center = CGPoint(
            x: size * 0.50,
            y: size * 0.44
        )

        let halfLength = size * 0.34

        // 180° => flat to the right.
        // 90°  => vertical upward.
        // 0°   => folded back toward the left.
        let theta = CGFloat(
            (180 - clamped) * .pi / 180
        )

        let rightEnd = CGPoint(
            x: center.x + cos(theta) * halfLength,
            y: center.y - sin(theta) * halfLength
        )

        return Path { path in
            path.move(
                to: CGPoint(
                    x: center.x - halfLength,
                    y: center.y
                )
            )

            path.addLine(to: center)
            path.addLine(to: rightEnd)
        }
    }

    @ViewBuilder
    private func hingeDot(
        size: CGFloat
    ) -> some View {
        Circle()
            .fill(.primary)
            .frame(
                width: 10,
                height: 10
            )
            .position(
                x: size * 0.50,
                y: size * 0.44
            )
            .accessibilityHidden(true)
    }
}
