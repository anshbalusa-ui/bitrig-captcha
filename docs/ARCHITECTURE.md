# Architecture

## Core flow

```text
Request verification
        ↓
ChallengeGenerator
        ↓
Random FoldChallenge
        ↓
HingeService streams live angle samples
        ↓
ChallengeViewModel updates UI + state machine
        ↓
TrajectoryValidator checks ordered motion + tolerance + holds
        ↓
HapticService confirms milestones
        ↓
VerificationResult issued
        ↓
Return to requesting experience
```

## Components

### HingeService

Owns the live hinge-angle stream.

The initial project includes a simulator/mock implementation so UI and state-machine work can proceed before the real iPhone Duo hinge API is wired. The production Duo implementation should conform to the same interface.

### ChallengeGenerator

Generates a short randomized sequence of fold targets.

Recommended prototype behavior:

- 3 targets
- target range roughly 45°–145°
- about 25° minimum separation between consecutive targets
- default tolerance **±3°**
- final step may require a short hold

Example:

```text
68° → 121° → hold at 47°
```

### TrajectoryValidator

Records continuous hinge samples and validates:

- correct target order
- entry into each target tolerance
- required hold duration
- continuous movement samples rather than only final submitted values
- complete challenge completion

For the hackathon, validation can be local. A production security system should not trust client-side validation by itself.

### HapticService

Centralizes:

- tolerance-entry feedback
- step-completion feedback
- final success feedback

### ChallengeViewModel

Coordinates:

- current challenge
- active target index
- current hinge angle
- tolerance state
- hold timing/progress
- trajectory recording
- haptics
- verification success

### VerificationResult

A successful prototype can emit a short-lived local result containing:

- verification ID
- challenge ID
- verified timestamp
- expiration timestamp
- success state

A later server-backed version could exchange the successful challenge for a signed, short-lived token tied to the requesting session or action.

## Separation of concerns

Keep these layers separate:

```text
hardware input
    ↓
hinge service
    ↓
state machine / validator
    ↓
view model
    ↓
SwiftUI presentation
```

This makes it easy to use simulated hinge data during development and swap in the real Duo hinge source later.
