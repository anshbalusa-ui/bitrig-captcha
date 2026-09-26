import SwiftUI

/// The main visual on the HUMAN landing page.
///
/// This is intentionally more cinematic than the challenge protractor. It uses
/// the same 0°...180° language, but treats the hinge as a large visual object:
/// a quiet semicircle, one live needle, one live point on the arc, and the
/// current angle floating in the center.
struct LandingHeroVisual: View {
    let angle: Double
    let hingeAvailable: Bool

    var body: some View {
        GeometryReader { proxy in
            let size = min(
                proxy.size.width,
                proxy.size.height * 1.45
            )

            let center = CGPoint(
                x: proxy.size.width / 2,
                y: proxy.size.height * 0.82
            )

            let radius = min(
                size * 0.42,
                proxy.size.height * 0.60
            )

            ZStack {
                ambientGlow(
                    center: center,
                    radius: radius
                )

                Canvas { context, _ in
                    drawArcLayers(
                        context: &context,
                        center: center,
                        radius: radius
                    )

                    drawTicks(
                        context: &context,
                        center: center,
                        radius: radius
                    )

                    drawLiveNeedle(
                        context: &context,
                        center: center,
                        radius: radius
                    )

                    drawLivePoint(
                        context: &context,
                        center: center,
                        radius: radius
                    )
                }

                VStack(spacing: 4) {
                    Text(
                        "\(Int(clamped(angle).rounded()))°"
                    )
                    .font(
                        .system(
                            size: 58,
                            weight: .semibold,
                            design: .rounded
                        )
                        .monospacedDigit()
                    )
                    .contentTransition(.numericText())
                    .animation(
                        .easeOut(duration: 0.10),
                        value: angle
                    )

                    Text(
                        hingeAvailable
                            ? "LIVE HINGE"
                            : "HINGE PREVIEW"
                    )
                    .font(
                        .caption2
                            .weight(.semibold)
                    )
                    .tracking(1.8)
                    .foregroundStyle(.secondary)
                }
                .position(
                    x: center.x,
                    y: center.y - radius * 0.29
                )

                endpointLabel(
                    "0°",
                    angle: 0,
                    center: center,
                    radius: radius + 28
                )

                endpointLabel(
                    "90°",
                    angle: 90,
                    center: center,
                    radius: radius + 28
                )

                endpointLabel(
                    "180°",
                    angle: 180,
                    center: center,
                    radius: radius + 28
                )
            }
        }
        .aspectRatio(
            1.32,
            contentMode: .fit
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Live hinge visual")
        .accessibilityValue(
            "\(Int(angle.rounded())) degrees"
        )
    }

    private func ambientGlow(
        center: CGPoint,
        radius: CGFloat
    ) -> some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        Color.accentColor.opacity(0.20),
                        Color.accentColor.opacity(0.07),
                        Color.clear
                    ],
                    center: .center,
                    startRadius: 4,
                    endRadius: radius * 0.82
                )
            )
            .frame(
                width: radius * 1.65,
                height: radius * 1.65
            )
            .position(
                x: center.x,
                y: center.y - radius * 0.38
            )
            .blur(radius: 10)
            .allowsHitTesting(false)
    }

    private func drawArcLayers(
        context: inout GraphicsContext,
        center: CGPoint,
        radius: CGFloat
    ) {
        let mainArc = arcPath(
            from: 0,
            through: 180,
            center: center,
            radius: radius
        )

        context.stroke(
            mainArc,
            with: .color(
                .secondary.opacity(0.17)
            ),
            style: StrokeStyle(
                lineWidth: 18,
                lineCap: .round
            )
        )

        let innerArc = arcPath(
            from: 0,
            through: 180,
            center: center,
            radius: radius - 20
        )

        context.stroke(
            innerArc,
            with: .color(
                .secondary.opacity(0.08)
            ),
            style: StrokeStyle(
                lineWidth: 1.5,
                lineCap: .round
            )
        )

        let travelledArc = arcPath(
            from: 0,
            through: clamped(angle),
            center: center,
            radius: radius
        )

        context.stroke(
            travelledArc,
            with: .color(
                Color.accentColor.opacity(0.40)
            ),
            style: StrokeStyle(
                lineWidth: 8,
                lineCap: .round
            )
        )
    }

    private func drawTicks(
        context: inout GraphicsContext,
        center: CGPoint,
        radius: CGFloat
    ) {
        for value in stride(
            from: 0.0,
            through: 180.0,
            by: 10.0
        ) {
            let isMajor = Int(value) % 30 == 0

            let outer = point(
                angle: value,
                center: center,
                radius: radius + 2
            )

            let inner = point(
                angle: value,
                center: center,
                radius: radius -
                    (isMajor ? 18 : 10)
            )

            var path = Path()
            path.move(to: inner)
            path.addLine(to: outer)

            context.stroke(
                path,
                with: .color(
                    .secondary.opacity(
                        isMajor ? 0.38 : 0.18
                    )
                ),
                style: StrokeStyle(
                    lineWidth: isMajor ? 2 : 1,
                    lineCap: .round
                )
            )
        }
    }

    private func drawLiveNeedle(
        context: inout GraphicsContext,
        center: CGPoint,
        radius: CGFloat
    ) {
        let end = point(
            angle: angle,
            center: center,
            radius: radius * 0.76
        )

        var path = Path()
        path.move(to: center)
        path.addLine(to: end)

        context.stroke(
            path,
            with: .color(.primary),
            style: StrokeStyle(
                lineWidth: 5,
                lineCap: .round
            )
        )

        context.fill(
            Path(
                ellipseIn: CGRect(
                    x: center.x - 7,
                    y: center.y - 7,
                    width: 14,
                    height: 14
                )
            ),
            with: .color(.primary)
        )
    }

    private func drawLivePoint(
        context: inout GraphicsContext,
        center: CGPoint,
        radius: CGFloat
    ) {
        let position = point(
            angle: angle,
            center: center,
            radius: radius
        )

        context.fill(
            Path(
                ellipseIn: CGRect(
                    x: position.x - 8,
                    y: position.y - 8,
                    width: 16,
                    height: 16
                )
            ),
            with: .color(Color.accentColor)
        )
    }

    @ViewBuilder
    private func endpointLabel(
        _ text: String,
        angle: Double,
        center: CGPoint,
        radius: CGFloat
    ) -> some View {
        let position = point(
            angle: angle,
            center: center,
            radius: radius
        )

        Text(text)
            .font(
                .caption2
                    .monospacedDigit()
            )
            .foregroundStyle(.tertiary)
            .position(position)
            .accessibilityHidden(true)
    }

    private func arcPath(
        from start: Double,
        through end: Double,
        center: CGPoint,
        radius: CGFloat
    ) -> Path {
        var path = Path()
        let lower = min(start, end)
        let upper = max(start, end)
        var first = true

        for value in stride(
            from: lower,
            through: upper,
            by: 1.0
        ) {
            let p = point(
                angle: value,
                center: center,
                radius: radius
            )

            if first {
                path.move(to: p)
                first = false
            } else {
                path.addLine(to: p)
            }
        }

        return path
    }

    private func point(
        angle: Double,
        center: CGPoint,
        radius: CGFloat
    ) -> CGPoint {
        let radians = CGFloat(
            clamped(angle) * .pi / 180
        )

        return CGPoint(
            x: center.x +
                cos(radians) * radius,
            y: center.y -
                sin(radians) * radius
        )
    }

    private func clamped(
        _ value: Double
    ) -> Double {
        min(
            max(value, 0),
            180
        )
    }
}
