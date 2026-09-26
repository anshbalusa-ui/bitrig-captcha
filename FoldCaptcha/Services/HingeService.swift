import Foundation
import SwiftUI

/// One normalized iPhone Duo hinge reading.
///
/// The actual hardware value comes from SwiftUI's DeviceHinge API through
/// View.onHingeChange. Keeping a tiny model here makes the rest of the app
/// independent from the UI framework callback shape.
struct HingeReading: Equatable, Sendable {
    let angle: Double?
    let timestamp: Date

    var isAvailable: Bool {
        angle != nil
    }
}

/// Bridges Apple's iPhone Duo SwiftUI hinge API into the app.
///
/// Xcode 27.1 / iOS 27.1:
/// - View.onHingeChange delivers DeviceHingeContext updates.
/// - DeviceHinge.angle is a SwiftUI Angle.
/// - Angle.degrees gives the continuous hinge angle in degrees.
///
/// A nil hinge means this view hierarchy currently has no hinge available.
private struct DuoHingeReaderModifier: ViewModifier {
    let onReading: @MainActor (HingeReading) -> Void

    func body(content: Content) -> some View {
        content
            .onHingeChange { _, newContext in
                let degrees = newContext.hinge?.angle.degrees
                let reading = HingeReading(
                    angle: degrees,
                    timestamp: Date()
                )

                Task { @MainActor in
                    onReading(reading)
                }
            }
    }
}

extension View {
    /// Starts continuous iPhone Duo hinge tracking for this view hierarchy.
    func trackDuoHinge(
        onReading: @escaping @MainActor (HingeReading) -> Void
    ) -> some View {
        modifier(
            DuoHingeReaderModifier(
                onReading: onReading
            )
        )
    }
}
