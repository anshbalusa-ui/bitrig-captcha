# Product Specification

## Product concept

This product is a physical CAPTCHA designed specifically for iPhone Duo. When an app or website requests verification, the user receives a short randomized folding sequence such as **“Fold to 68°,” “Now 121°,” and “Hold at 47°.”** The experience continuously tracks the Duo’s hinge position and validates the full motion trajectory rather than checking only whether the user eventually reaches the requested angles.

Each target uses a forgiving tolerance range, such as **±3°**, so the user never needs to position the device with unrealistic precision. Once the device enters the valid range, the system confirms the step through immediate visual and haptic feedback and automatically advances to the next movement. Hold challenges require the user to remain within the tolerance range briefly before completing the step. The entire interaction should take only a few seconds and feel like physically manipulating the device rather than completing a traditional CAPTCHA.

## UI and interaction design

The interface should follow Apple’s Human Interface Guidelines and feel completely native to iPhone Duo. The challenge screen remains intentionally minimal, with a short instruction such as **“Match the fold”**, a live visualization of the Duo’s current physical position, a ghosted representation of the target fold, and subtle progress information showing how many movements remain.

The live device visualization should continuously mirror the real hinge angle so that when the user folds the physical device, the on-screen model moves with it in real time. Rather than requiring the user to understand what a numerical angle such as 68° looks like, the primary interaction is simply to visually align the live device shape with the ghosted target shape.

As the user approaches the target, the interface should gradually communicate proximity without becoming distracting. When the current hinge angle is still far from the target, the visualization remains neutral. As the device approaches the valid range, subtle visual feedback can increase. Once the user reaches the **±3° tolerance**, the target and live representation should visually snap into alignment while a precise haptic confirms the step.

A hold challenge should use a simple progress indicator that begins filling only while the user remains inside the valid range. If the user drifts outside it, progress should pause rather than immediately fail. Completed steps should transition smoothly into the next target without unnecessary screens or buttons. After the final movement, the interface should display a brief native success state such as **“Human Verified”** and automatically return the user to the requesting app or website.

The visual direction should use restrained glassmorphism rather than a loud or decorative style. The central challenge can sit inside a soft frosted-material surface with subtle depth, thin system-consistent borders, and a muted background. The fold visualization remains the visual focus. The ghosted target should be visibly distinct from the live device representation without requiring strong color coding. Transitions between targets should morph smoothly, and the success state should remain brief and confident.

The haptic language should be consistent and sparse:

- entering the accepted tolerance range → crisp light haptic
- completing a normal target → medium confirmation
- completing a hold target → slightly stronger confirmation
- completing the entire CAPTCHA → native success haptic
- drifting outside the range during a hold → no harsh error vibration; simply pause progress

The interface should use system typography, SF Symbols where appropriate, familiar Apple materials, high-contrast states, generous touch targets, Dynamic Type, VoiceOver support, and restrained animation. Success, retry, and guidance states should remain obvious and non-punitive.

The experience should respect safe areas and reserved hinge regions, avoid placing critical controls directly across the physical fold, and maintain a stable visual hierarchy while the Duo transitions between closed, partially folded, and fully open states. The fold itself should remain the visual and interaction focus, making the device’s changing physical shape feel directly connected to the software.

## Backend and verification system

The verification system should generate a new randomized folding challenge whenever an app or website requests proof of human presence. A challenge consists of a short sequence of target hinge positions and optional hold requirements, with each target defining an allowed tolerance range rather than requiring an exact angle.

While the challenge is active, the system continuously receives hinge-position updates and records the user’s motion trajectory, including:

- angle samples over time
- direction and progression between targets
- whether targets are reached in the requested order
- whether the device enters each accepted tolerance range
- whether required hold periods are completed
- whether the interaction behaves like one continuous physical sequence

Verification should not be based only on snapshots such as “the device reached 68°.” Instead, the complete sequence should be validated as one continuous physical interaction. For example, if the challenge requests **68° → 121° → hold at 47°**, the system should verify that the device moved through those stages in the correct order, entered each target’s tolerance range, and remained within the final range for the required amount of time.

Once the full sequence has been validated, the system should issue a **short-lived human-presence verification result** tied to the requesting session or action. The result should expire quickly so it cannot simply be reused later. The requesting experience should receive only the information necessary to know that the physical challenge was successfully completed.

Failed or interrupted attempts should be safely discarded and regenerated rather than trapping the user in a punitive state.

## Core idea

The overall experience should feel like one continuous Duo-native interaction:

**request verification → generate randomized fold sequence → match physical hinge targets → validate complete motion trajectory → return short-lived verification result**

The central concept is that **the physical shape of the device becomes the CAPTCHA itself**.
