# Bitrig CAPTCHA

A native physical CAPTCHA built specifically for **iPhone Duo**.

Traditional CAPTCHAs ask the user to recognize images or type text. This project turns the **physical fold of the device itself into the challenge**.

A randomized verification can look like:

**68° → 121° → hold at 47°**

The app reads the Duo's real hinge angle continuously, gives native haptic feedback, validates the ordered motion trajectory with a forgiving **±3° tolerance**, and produces a short-lived human-presence result.

## What is already implemented

- Apple's real SwiftUI `DeviceHinge` / `onHingeChange` API
- continuous hinge-angle readings in degrees
- 3-step randomized challenges
- default ±3° tolerance
- optional hold step
- 50 ms hold sampling
- trajectory recording and ordered validation
- native haptics
- live fold visualization that mirrors the device angle
- ghosted target fold
- iPhone Duo reserved-region awareness
- native SwiftUI Liquid Glass
- step progress + retry + success states
- short-lived verification token model
- DEBUG hinge slider for a non-Duo simulator
- optional demo backend that generates challenges and verifies trajectories server-side
- optional Swift client for that backend

## Verified Apple APIs

The Duo integration uses APIs Apple currently documents for iOS 27.1 / Xcode 27.1 beta:

- `DeviceHinge`
- `DeviceHingeContext`
- `View.onHingeChange(isEnabled:_:)`
- `GeometryProxy.reservedRegions(kind:)`
- `View.glassEffect(_:in:)`

See `docs/APPLE_API_NOTES.md`.

## Project structure

```text
bitrig-captcha/
├── FoldCaptcha.xcodeproj/
│   └── project.pbxproj
├── FoldCaptcha/
│   ├── App/
│   │   └── FoldCaptchaApp.swift
│   ├── Models/
│   │   ├── FoldChallenge.swift
│   │   └── VerificationResult.swift
│   ├── Services/
│   │   ├── ChallengeGenerator.swift
│   │   ├── HapticService.swift
│   │   ├── HingeService.swift
│   │   ├── RemoteVerificationClient.swift
│   │   └── TrajectoryValidator.swift
│   ├── ViewModels/
│   │   └── ChallengeViewModel.swift
│   └── Views/
│       ├── ChallengeView.swift
│       ├── DebugHingeControls.swift
│       ├── FoldVisualizer.swift
│       └── VerificationSuccessView.swift
├── backend/
│   ├── package.json
│   └── server.mjs
└── docs/
    ├── APPLE_API_NOTES.md
    ├── ARCHITECTURE.md
    ├── BITRIG_PLAN_PROMPT.md
    ├── PRODUCT_SPEC.md
    ├── SECURITY_NOTES.md
    └── UI_SPEC.md
```

## Run the iOS app

Use **Xcode 27.1 beta or newer** with the iPhone Duo simulator/runtime installed.

1. Open `FoldCaptcha.xcodeproj`.
2. Choose an iPhone Duo simulator.
3. Run the app.
4. Change the Duo pose/hinge angle in Simulator.
5. The live fold line should move with the physical simulator hinge.

On a normal non-Duo simulator, the DEBUG build also shows a hinge slider so the flow can still be tested.

## Run the optional backend

No npm dependencies are required.

```bash
cd backend
npm start
```

It runs on `http://localhost:8787` by default.

Endpoints:

- `POST /api/challenge`
- `POST /api/verify`

The backend is intentionally small and in-memory for the hackathon. Read `docs/SECURITY_NOTES.md` before treating it like production security.

## Core demo

The entire idea should be understandable in a few seconds:

> “Traditional CAPTCHAs make you solve something on the screen. Ours makes the physical device itself the challenge.”

Then:

**68° → 121° → hold 47° → Human Verified**

## Bitrig

Read the specs first, then use the planning prompt in:

`docs/BITRIG_PLAN_PROMPT.md`

The codebase is already scaffolded, so Bitrig should focus on compiling against the installed iOS 27.1 SDK, polishing the interaction, and testing on the Duo simulator rather than rebuilding the architecture from scratch.
