# Architecture

## Core flow

```text
Request verification
        ↓
ChallengeGenerator
        ↓
Random 3-step FoldChallenge
        ↓
View.onHingeChange
        ↓
DeviceHinge.angle.degrees
        ↓
ChallengeViewModel
        ↓
TrajectoryValidator + hold timer
        ↓
HapticService + SwiftUI UI
        ↓
VerificationResult
        ↓
Return to requesting experience
```

## iPhone Duo hinge input

The app uses Apple's real SwiftUI hinge API in:

`FoldCaptcha/Services/HingeService.swift`

The view attaches:

```swift
.trackDuoHinge { reading in
    viewModel.receiveHingeReading(reading)
}
```

The modifier is backed by:

```swift
.onHingeChange { _, newContext in
    let degrees = newContext.hinge?.angle.degrees
    // forward normalized reading
}
```

A nil hinge means the current hierarchy has no hinge available. In DEBUG builds, a fallback slider is shown only when a real hinge is unavailable.

## ChallengeGenerator

Generates three randomized targets.

Prototype defaults:

- target angle range: 45°–145°
- minimum separation: ~25°
- tolerance: ±3°
- final target hold: ~0.75 s

Example:

```text
68° → 121° → hold at 47°
```

## ChallengeViewModel

Owns the interaction state machine:

- current challenge
- current target index
- current hinge angle
- hinge availability
- tolerance entry
- hold timer/progress
- trajectory recording
- step completion
- retry/success state
- haptic timing

Hold progress is sampled every 50 ms while the device remains within tolerance so a steady hold still creates continuous evidence.

## TrajectoryValidator

Records timestamped hinge samples and target-completion points.

The local validator checks:

- all targets completed
- correct order
- completion angles were within tolerance
- each later target happened after the prior target
- there was real angular movement between target completions
- the final challenge came from one continuous recorded interaction

This is hackathon-grade local validation, not production anti-bot security.

## HapticService

Native UIKit feedback generators provide:

- light tolerance-entry feedback for hold targets
- medium step completion feedback
- final success notification feedback

No harsh failure haptic is used when a user drifts outside a hold range.

## FoldVisualizer

The visualization draws the real physical hinge geometry:

- 180° = flat
- 90° = right half upright
- 0° = folded back toward the left

The live hinge is drawn over a dashed/ghosted target so users can match shapes instead of interpreting numbers.

## Duo-aware UI

`ChallengeView` queries:

```swift
proxy.reservedRegions(kind: .division)
```

to stay aware of active fold division regions.

The main challenge card uses native SwiftUI Liquid Glass:

```swift
.glassEffect(
    .regular,
    in: RoundedRectangle(
        cornerRadius: 30,
        style: .continuous
    )
)
```

## Verification result

A successful local prototype issues a short-lived `VerificationResult` containing:

- verification ID
- challenge ID
- random token
- verified timestamp
- expiration timestamp

Default lifetime: 30 seconds.

## Optional server-backed flow

The repository also contains:

```text
backend/server.mjs
```

The demo server can:

1. generate randomized challenges
2. keep them server-side for 60 seconds
3. accept timestamped hinge samples
4. validate the ordered trajectory
5. enforce the hold target
6. consume challenges once to reduce replay
7. issue a signed short-lived verification token

The matching Swift networking code is:

`FoldCaptcha/Services/RemoteVerificationClient.swift`

The default hackathon UI remains local so the core Duo interaction works even without a server.

## Separation of concerns

```text
Apple hinge API
      ↓
HingeReading
      ↓
ChallengeViewModel
   ↙          ↘
validator    haptics
      ↓
SwiftUI / Liquid Glass
      ↓
verification result
```

See `docs/SECURITY_NOTES.md` for the line between the hackathon prototype and a production security system.
