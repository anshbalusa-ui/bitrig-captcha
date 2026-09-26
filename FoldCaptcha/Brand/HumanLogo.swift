import SwiftUI

/// Primary product mark for HUMAN.
///
/// The wordmark stays clean and static. Above it, a minimal semicircle/needle
/// symbol mirrors the Duo hinge angle in real time, matching the visual
/// language used by the CAPTCHA itself.
struct HumanLogo: View {
    let angle: Double

    var body: some View {
        VStack(spacing: 12) {
            HumanAngleMark(
                angle: angle
            )
            .frame(
                width: 82,
                height: 48
            )

            Text("HUMAN")
                .font(
                    .system(
                        size: 34,
                        weight: .bold,
                        design: .default
                    )
                )
                .tracking(3.2)

            Text("Your phone is the challenge.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "HUMAN. Your phone is the challenge."
        )
    }
}

private struct HumanAngleMark: View {
    let angle: Double

    var body: some View {
        Canvas { context, size in
            let clamped = min(
                max(angle, 0),
                180
            )

            let center = CGPoint(
                x: size.width / 2,
                y: size.height * 0.88
            )

            let radius = min(
                size.width * 0.42,
                size.height * 0.78
            )

            // Quiet semicircle base.
            var arc = Path()
            var first = true

            for degree in stride(
                from: 0.0,
                through: 180.0,
                by: 2.0
            ) {
                let point = point(
                    angle: degree,
                    center: center,
                    radius: radius
                )

                if first {
                    arc.move(to: point)
                    first = false
                } else {
                    arc.addLine(to: point)
                }
            }

            context.stroke(
                arc,
                with: .color(
                    .secondary.opacity(0.34)
                ),
                style: StrokeStyle(
                    lineWidth: 3,
                    lineCap: .round
                )
            )

            // Live hinge needle.
            let needleEnd = point(
                angle: clamped,
                center: center,
                radius: radius * 0.82
            )

            var needle = Path()
            needle.move(to: center)
            needle.addLine(to: needleEnd)

            context.stroke(
                needle,
                with: .color(.primary),
                style: StrokeStyle(
                    lineWidth: 4,
                    lineCap: .round
                )
            )

            let hubRect = CGRect(
                x: center.x - 4,
                y: center.y - 4,
                width: 8,
                height: 8
            )

            context.fill(
                Path(
                    ellipseIn: hubRect
                ),
                with: .color(.primary)
            )
        }
        .animation(
            .interactiveSpring(
                response: 0.18,
                dampingFraction: 0.92
            ),
            value: angle
        )
        .accessibilityHidden(true)
    }

    private func point(
        angle: Double,
        center: CGPoint,
        radius: CGFloat
    ) -> CGPoint {
        let radians = CGFloat(
            angle * .pi / 180
        )

        return CGPoint(
            x: center.x +
                cos(radians) * radius,
            y: center.y -
                sin(radians) * radius
        )
    }
}
