import SwiftUI

/// Protractor-style visualization for the Duo hinge.
///
/// The semicircle maps the complete 0°...180° hinge range:
/// - 0°   = fully closed
/// - 90°  = right angle
/// - 180° = fully flat
///
/// A ghosted target needle and tolerance band show where the user should move.
/// The live needle and large numeric readout update continuously with the
/// physical hinge.
struct FoldVisualizer: View {
    let currentAngle: Double
    let targetAngle: Double
    let isInsideTolerance: Bool
    var targetTolerance: Double = 3

    var body: some View {
        GeometryReader { proxy in
            let center = CGPoint(
                x: proxy.size.width / 2,
                y: proxy.size.height * 0.86
            )

            let radius = min(
                proxy.size.width * 0.42,
                proxy.size.height * 0.72
            )

            ZStack {
                Canvas { context, _ in
                    drawBaseArc(
                        context: &context,
                        center: center,
                        radius: radius
                    )

                    drawTicks(
                        context: &context,
                        center: center,
                        radius: radius
                    )

                    drawTargetBand(
                        context: &context,
                        center: center,
                        radius: radius
                    )

                    drawNeedles(
                        context: &context,
                        center: center,
                        radius: radius
                    )

                    drawLabels(
                        context: &context,
                        center: center,
                        radius: radius
                    )
                }

                VStack(spacing: 3) {
                    Text(
                        "\(Int(clamped(currentAngle).rounded()))°"
                    )
                    .font(
                        .system(
                            size: 34,
                            weight: .bold,
                            design: .rounded
                        )
                        .monospacedDigit()
                    )
                    .contentTransition(.numericText())
                    .animation(
                        .easeOut(duration: 0.10),
                        value: currentAngle
                    )

                    Text(
                        "TARGET \(Int(clamped(targetAngle).rounded()))°"
                    )
                    .font(
                        .caption
                            .weight(.semibold)
                            .monospacedDigit()
                    )
                    .foregroundStyle(.secondary)
                }
                .position(
                    x: center.x,
                    y: center.y - radius * 0.24
                )
            }
        }
        .aspectRatio(
            1.65,
            contentMode: .fit
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Hinge angle")
        .accessibilityValue(
            "Current angle \(Int(currentAngle.rounded())) degrees. Target \(Int(targetAngle.rounded())) degrees."
        )
    }

    private func drawBaseArc(
        context: inout GraphicsContext,
        center: CGPoint,
        radius: CGFloat
    ) {
        let path = arcPath(
            from: 0,
            through: 180,
            center: center,
            radius: radius
        )

        context.stroke(
            path,
            with: .color(
                .secondary.opacity(0.22)
            ),
            style: StrokeStyle(
                lineWidth: 12,
                lineCap: .round
            )
        )
    }

    private func drawTicks(
        context: inout GraphicsContext,
        center: CGPoint,
        radius: CGFloat
    ) {
        for angle in stride(
            from: 0.0,
            through: 180.0,
            by: 15.0
        ) {
            let isMajor =
                Int(angle) % 30 == 0

            let outer = point(
                angle: angle,
                center: center,
                radius: radius + 1
            )

            let inner = point(
                angle: angle,
                center: center,
                radius: radius -
                    (isMajor ? 18 : 10)
            )

            var tick = Path()
            tick.move(to: inner)
            tick.addLine(to: outer)

            context.stroke(
                tick,
                with: .color(
                    .secondary.opacity(
                        isMajor ? 0.55 : 0.30
                    )
                ),
                style: StrokeStyle(
                    lineWidth: isMajor ? 2 : 1,
                    lineCap: .round
                )
            )
        }
    }

    private func drawTargetBand(
        context: inout GraphicsContext,
        center: CGPoint,
        radius: CGFloat
    ) {
        let lower = clamped(
            targetAngle - targetTolerance
        )

        let upper = clamped(
            targetAngle + targetTolerance
        )

        let band = arcPath(
            from: lower,
            through: upper,
            center: center,
            radius: radius
        )

        context.stroke(
            band,
            with: .color(
                Color.accentColor.opacity(0.32)
            ),
            style: StrokeStyle(
                lineWidth: 20,
                lineCap: .round
            )
        )
    }

    private func drawNeedles(
        context: inout GraphicsContext,
        center: CGPoint,
        radius: CGFloat
    ) {
        let targetPoint = point(
            angle: targetAngle,
            center: center,
            radius: radius * 0.89
        )

        var targetNeedle = Path()
        targetNeedle.move(to: center)
        targetNeedle.addLine(to: targetPoint)

        context.stroke(
            targetNeedle,
            with: .color(
                .secondary.opacity(0.38)
            ),
            style: StrokeStyle(
                lineWidth: 4,
                lineCap: .round,
                dash: [8, 7]
            )
        )

        let currentPoint = point(
            angle: currentAngle,
            center: center,
            radius: radius * 0.82
        )

        var currentNeedle = Path()
        currentNeedle.move(to: center)
        currentNeedle.addLine(to: currentPoint)

        context.stroke(
            currentNeedle,
            with: .color(
                isInsideTolerance
                    ? Color.accentColor
                    : Color.primary
            ),
            style: StrokeStyle(
                lineWidth: 6,
                lineCap: .round
            )
        )

        let hub = Path(
            ellipseIn: CGRect(
                x: center.x - 7,
                y: center.y - 7,
                width: 14,
                height: 14
            )
        )

        context.fill(
            hub,
            with: .color(
                isInsideTolerance
                    ? Color.accentColor
                    : Color.primary
            )
        )
    }

    private func drawLabels(
        context: inout GraphicsContext,
        center: CGPoint,
        radius: CGFloat
    ) {
        let labelRadius = radius + 28

        let labels: [(Double, String)] = [
            (0, "0°"),
            (90, "90°"),
            (180, "180°")
        ]

        for (angle, label) in labels {
            let position = point(
                angle: angle,
                center: center,
                radius: labelRadius
            )

            context.draw(
                Text(label)
                    .font(.caption2)
                    .foregroundStyle(.secondary),
                at: position
            )
        }
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

        var isFirstPoint = true

        for angle in stride(
            from: lower,
            through: upper,
            by: 1.0
        ) {
            let value = point(
                angle: angle,
                center: center,
                radius: radius
            )

            if isFirstPoint {
                path.move(to: value)
                isFirstPoint = false
            } else {
                path.addLine(to: value)
            }
        }

        if lower == upper {
            let value = point(
                angle: lower,
                center: center,
                radius: radius
            )
            path.move(to: value)
            path.addLine(to: value)
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
        _ angle: Double
    ) -> Double {
        min(
            max(angle, 0),
            180
        )
    }
}
