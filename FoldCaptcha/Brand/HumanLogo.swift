import SwiftUI

/// Primary app brand.
///
/// The center mark mirrors the Duo hinge so the logo itself teaches the core
/// interaction before the CAPTCHA begins.
struct HumanLogo: View {
    let angle: Double

    var body: some View {
        VStack(spacing: 14) {
            HStack(spacing: 10) {
                Text("HU")
                HumanHingeMark(angle: angle)
                Text("MAN")
            }
            .font(
                .system(
                    size: 34,
                    weight: .bold,
                    design: .rounded
                )
            )
            .tracking(1.4)

            Text("Your phone is the challenge.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("HUMAN. Your phone is the challenge.")
    }
}

private struct HumanHingeMark: View {
    let angle: Double

    var body: some View {
        Canvas { context, size in
            let clamped = min(
                max(angle, 0),
                180
            )

            let center = CGPoint(
                x: size.width / 2,
                y: size.height * 0.58
            )

            let arm = min(
                size.width,
                size.height
            ) * 0.34

            let theta = CGFloat(
                (180 - clamped) *
                .pi / 180
            )

            var path = Path()
            path.move(
                to: CGPoint(
                    x: center.x - arm,
                    y: center.y
                )
            )
            path.addLine(to: center)
            path.addLine(
                to: CGPoint(
                    x: center.x +
                        cos(theta) * arm,
                    y: center.y -
                        sin(theta) * arm
                )
            )

            context.stroke(
                path,
                with: .foreground,
                style: StrokeStyle(
                    lineWidth: 4,
                    lineCap: .round,
                    lineJoin: .round
                )
            )
        }
        .frame(
            width: 38,
            height: 38
        )
        .animation(
            .interactiveSpring(
                response: 0.18,
                dampingFraction: 0.92
            ),
            value: angle
        )
        .accessibilityHidden(true)
    }
}
