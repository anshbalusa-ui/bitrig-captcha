# Verified Apple API Notes

This project intentionally uses APIs that Apple currently documents for iPhone Duo and iOS 27.1 beta.

## Hinge tracking

SwiftUI exposes:

- `DeviceHinge`
- `DeviceHingeContext`
- `View.onHingeChange(isEnabled:_:)`

The callback provides the current `DeviceHingeContext`. Its `hinge` property is optional. When available, `hinge.angle` is a SwiftUI `Angle`, and `hinge.angle.degrees` gives the continuous hinge position in degrees.

Official docs:

- https://developer.apple.com/documentation/swiftui/devicehinge
- https://developer.apple.com/documentation/swiftui/devicehingecontext
- https://developer.apple.com/documentation/swiftui/view/onhingechange(isEnabled:_:)

The live implementation is in:

`FoldCaptcha/Services/HingeService.swift`

## Reserved hinge regions

SwiftUI's `GeometryProxy.reservedRegions(kind:)` can query division regions created by the physical fold. The challenge screen uses this to keep its content sizing aware of the active hinge layout.

Official material:

- https://developer.apple.com/documentation/updates/swiftui
- https://developer.apple.com/videos/play/tech-talks/111463/

## Liquid Glass

The interface uses SwiftUI's native `.glassEffect(_:in:)` and `.buttonStyle(.glassProminent)` instead of hand-rolled web-style blur cards.

Official docs:

- https://developer.apple.com/documentation/swiftui/view/glasseffect(_:in:)
- https://developer.apple.com/documentation/swiftui/primitivebuttonstyle/glassprominent

## Toolchain

Apple's iPhone Duo developer page currently points developers to Xcode 27.1 beta and the iPhone Duo simulator.

- https://developer.apple.com/iphone-duo/
- https://developer.apple.com/documentation/xcode-release-notes/xcode-27_1-release-notes

These are beta APIs and may change before final release. Verify names/signatures against the installed Xcode 27.1 SDK before demo day.
