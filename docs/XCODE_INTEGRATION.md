# Xcode Integration Guide

This document is the handoff for moving the HUMAN / Fold CAPTCHA feature into an existing main Xcode project.

## What to copy

Copy these folders from this repository into the main app target:

```text
FoldCaptcha/
├── Brand/
│   └── HumanLogo.swift
├── Models/
│   ├── FoldChallenge.swift
│   └── VerificationResult.swift
├── Services/
│   ├── ChallengeGenerator.swift
│   ├── HapticService.swift
│   ├── HingeService.swift
│   ├── RemoteVerificationClient.swift
│   └── TrajectoryValidator.swift
├── ViewModels/
│   └── ChallengeViewModel.swift
└── Views/
    ├── ChallengeView.swift
    ├── DebugHingeControls.swift
    ├── FoldVisualizer.swift
    ├── LandingHeroVisual.swift
    ├── LandingView.swift
    ├── RootView.swift
    └── VerificationSuccessView.swift
```

`FoldCaptchaApp.swift` is only needed when running this repository as its own standalone app.

If the main project already has its own `@main App`, do **not** replace it.

## Minimum integration

Add the files above to the main app target, then present this view wherever the CAPTCHA experience should begin:

```swift
RootView(
    viewModel: ChallengeViewModel(
        challengeGenerator: ChallengeGenerator(),
        validator: TrajectoryValidator(),
        haptics: HapticService()
    )
)
```

Example inside an existing app:

```swift
import SwiftUI

struct ContentView: View {
    var body: some View {
        RootView(
            viewModel: ChallengeViewModel(
                challengeGenerator: ChallengeGenerator(),
                validator: TrajectoryValidator(),
                haptics: HapticService()
            )
        )
    }
}
```

Or present `RootView` from a sheet, navigation destination, verification flow, or whatever routing system the main project already uses.

## How hinge data flows

`RootView.swift` owns the real Duo hinge listener:

```swift
.trackDuoHinge { reading in
    viewModel.receiveHingeReading(reading)
}
```

That modifier comes from:

```text
FoldCaptcha/Services/HingeService.swift
```

The implementation uses the Duo SwiftUI hinge callback and reads:

```swift
newContext.hinge?.angle.degrees
```

That value is then forwarded into `ChallengeViewModel`.

The view model publishes `currentAngle`, so both the landing page and CAPTCHA screen update continuously while the phone is being bent.

## Landing page flow

The landing page is made from:

```text
HumanLogo.swift
LandingView.swift
LandingHeroVisual.swift
RootView.swift
```

The current landing visual contains:

- HUMAN wordmark
- large semicircle / protractor hero
- live current-angle needle
- live point moving around the arc
- large live numeric hinge angle
- 0°, 90°, and 180° reference labels
- soft accent glow
- “Bend to begin”
- automatic start after about 12° of intentional real hinge movement
- fallback Start verification button

The live angle is not decorative. It is driven from the actual hinge state through the same `ChallengeViewModel.currentAngle` used by the CAPTCHA.

## Challenge screen flow

The challenge UI uses:

```text
ChallengeView.swift
FoldVisualizer.swift
VerificationSuccessView.swift
```

`FoldVisualizer` is a semicircle protractor:

- full 0°–180° arc
- solid live-angle needle
- ghosted target needle
- highlighted ±3° target band
- live numeric angle
- target numeric angle
- tick marks and 0° / 90° / 180° labels

## Logic files

### ChallengeGenerator.swift

Creates a randomized three-step challenge.

Default behavior:

- angles between roughly 45° and 145°
- about 25° minimum difference between consecutive targets
- ±3° tolerance
- final step includes a ~0.75 second hold

### ChallengeViewModel.swift

Controls:

- current hinge angle
- current target
- step progression
- tolerance entry
- hold timer
- hold progress
- haptics
- retry state
- success state
- trajectory recording

### TrajectoryValidator.swift

Records continuous timestamped angle samples and checks:

- correct target order
- completion inside tolerance
- meaningful movement between targets
- continuous physical sequence rather than isolated final values

### HapticService.swift

Provides:

- light target/tolerance feedback
- medium step-completion feedback
- final success haptic

### VerificationResult.swift

Creates the short-lived local verification result and temporary token.

## Xcode target settings

Recommended prototype setup:

```text
Swift: 6
Deployment target: iOS 27.1
Xcode: 27.1 beta or newer
Device/runtime: iPhone Duo
```

The Duo APIs are beta SDK APIs, so if the exact SDK installed on the hackathon machine has a signature difference, fix only the API call in `HingeService.swift` rather than rewriting the rest of the feature.

## Add files correctly in Xcode

When dragging the folders into the main project:

1. Select the main app target under **Add to targets**.
2. Prefer **Create groups** unless the project already uses synchronized folders.
3. Confirm every Swift file has the main target checked under **Target Membership**.
4. Build once before changing logic.
5. Fix any SDK-only compile differences first.
6. Run on the Duo simulator and verify that the live landing angle changes while the hinge moves.

## Existing app lifecycle

If the main project already has:

```swift
@main
struct MyApp: App {
    ...
}
```

keep it.

You only need to insert `RootView` into the existing navigation/UI hierarchy.

Do not add the standalone `FoldCaptchaApp.swift` unless you want the CAPTCHA project to be the whole application.

## Optional backend

These files are separate from Xcode:

```text
backend/
├── package.json
└── server.mjs
```

The iOS client for that server is:

```text
FoldCaptcha/Services/RemoteVerificationClient.swift
```

The main physical CAPTCHA prototype can run locally without the backend.

## No image assets required

The HUMAN logo, landing hero, protractor, needles, ticks, glow, and challenge visualization are all drawn in SwiftUI/Canvas.

The SVG in:

```text
BrandAssets/human-logo.svg
```

is only a reference/vector export. The app does not need it to render the logo.

## Core file dependency map

```text
RootView
├── LandingView
│   ├── LandingHeroVisual
│   └── ChallengeViewModel
├── ChallengeView
│   ├── FoldVisualizer
│   ├── VerificationSuccessView
│   └── ChallengeViewModel
└── trackDuoHinge
    └── HingeService

ChallengeViewModel
├── ChallengeGenerator
├── TrajectoryValidator
├── HapticService
├── FoldChallenge
└── VerificationResult
```

## Fastest main-project handoff

If time is tight, copy everything under:

```text
FoldCaptcha/Brand
FoldCaptcha/Models
FoldCaptcha/Services
FoldCaptcha/ViewModels
FoldCaptcha/Views
```

into the main app target.

Then present:

```swift
RootView(
    viewModel: ChallengeViewModel(
        challengeGenerator: ChallengeGenerator(),
        validator: TrajectoryValidator(),
        haptics: HapticService()
    )
)
```

That gives the main project the entire landing page, live hinge visualization, CAPTCHA challenge, haptics, validation, and success flow.
