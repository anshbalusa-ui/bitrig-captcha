# Bitrig Planning Prompt

Paste the following into Bitrig `/plan`:

> Read `README.md`, `docs/PRODUCT_SPEC.md`, `docs/UI_SPEC.md`, and `docs/ARCHITECTURE.md`. Create a concrete implementation plan for this iPhone Duo hackathon prototype. Prioritize getting real-time Duo hinge tracking and the core challenge state machine working first. Then implement the live fold visualizer, ±3° tolerance, hold timing, trajectory validation, native haptics, restrained glassmorphic UI, accessibility, and the final short-lived verification-result flow. Keep the implementation optimized for a polished sub-3-minute hackathon demo. Preserve a clean separation between hinge input, challenge generation, validation, haptics, view-model state, and SwiftUI views. Use a simulator/mock hinge provider until the real Duo hinge API is wired so UI and logic can be tested independently. Do not add unrelated features, AI, monetization, accounts, dashboards, or extra product scope.

## Build order

1. Verify the current iPhone Duo SDK/API names in the installed Xcode/Bitrig environment.
2. Wire continuous real hinge-angle updates behind `HingeService`.
3. Build the randomized three-step challenge generator.
4. Build the challenge state machine with ±3° tolerance.
5. Implement hold timing.
6. Build live/ghost fold visualization.
7. Add haptics.
8. Record and validate the full trajectory.
9. Add success + short-lived verification result.
10. Polish glassmorphic UI, transitions, accessibility, and the sub-3-minute demo flow.
