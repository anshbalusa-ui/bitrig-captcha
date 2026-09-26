# Bitrig CAPTCHA

A physical CAPTCHA concept built specifically for iPhone Duo.

Instead of solving image puzzles, users verify human presence by completing a short randomized sequence of physical fold gestures such as:

**68° → 121° → hold at 47°**

The experience tracks the hinge continuously, uses forgiving angle tolerances, validates the full motion trajectory, confirms each step with native haptics, and returns a short-lived verification result to the requesting experience.

## Core interaction

1. An app or website requests verification.
2. A short randomized fold sequence is generated.
3. The challenge UI shows a ghosted target fold and a live representation of the current device fold.
4. The user physically folds the Duo to match each target.
5. A target is accepted inside a forgiving default tolerance of **±3°**.
6. Haptics confirm successful steps.
7. Hold steps require the device to remain inside the accepted range briefly.
8. The complete motion trajectory is validated in order.
9. A short-lived human-presence result is returned.

## UI direction

The UI should feel native, minimal, and Apple-like rather than like a traditional CAPTCHA.

- System typography and SF Symbols
- Restrained glassmorphic / frosted-material presentation
- Ghosted target fold + live current-fold visualization
- Numeric angles are secondary, not required to understand the interaction
- Subtle proximity feedback
- Crisp haptics when a target is reached
- Stronger success haptic after the full challenge
- Hold progress pauses rather than harshly failing if the user drifts outside the range
- Dynamic Type and VoiceOver support
- Layouts that respect safe areas and reserved hinge regions

## Proposed project structure

```text
FoldCaptcha/
├── App/
│   └── FoldCaptchaApp.swift
├── Models/
│   ├── FoldChallenge.swift
│   └── VerificationResult.swift
├── Services/
│   ├── HingeService.swift
│   ├── HapticService.swift
│   ├── ChallengeGenerator.swift
│   └── TrajectoryValidator.swift
├── ViewModels/
│   └── ChallengeViewModel.swift
└── Views/
    ├── ChallengeView.swift
    ├── FoldVisualizer.swift
    └── VerificationSuccessView.swift
```

## Build priorities

1. Real-time Duo hinge-angle input
2. Challenge state machine
3. ±3° tolerance + hold timing
4. Live fold visualizer
5. Haptics
6. Motion-trajectory validation
7. Success / verification result flow
8. Glassmorphic polish and accessibility

## Hackathon demo goal

The full idea should be understandable in seconds:

> “Traditional CAPTCHAs ask you to solve something on the screen. Ours makes the physical device itself the challenge.”

Ideal live demo:

**68° → 121° → hold at 47° → Human Verified**

See `docs/PRODUCT_SPEC.md` for the full product specification and `docs/BITRIG_PLAN_PROMPT.md` for a ready-to-paste Bitrig planning prompt.
