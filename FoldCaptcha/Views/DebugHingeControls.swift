import SwiftUI

#if DEBUG
struct DebugHingeControls: View {
    @Binding var angle: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(
                "Debug hinge",
                systemImage: "slider.horizontal.3"
            )
            .font(.caption.bold())

            Slider(
                value: $angle,
                in: 0...180,
                step: 1
            )

            Text("\(Int(angle.rounded()))°")
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .glassEffect(
            .regular,
            in: RoundedRectangle(
                cornerRadius: 18,
                style: .continuous
            )
        )
        .accessibilityElement(children: .contain)
    }
}
#endif
