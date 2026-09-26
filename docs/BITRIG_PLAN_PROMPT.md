# Bitrig Planning Prompt

The core architecture and starter implementation are already in this repository. Use Bitrig to verify, debug, and polish it rather than rebuilding the project from scratch.

Paste this into Bitrig `/plan`:

> Read `README.md`, `docs/PRODUCT_SPEC.md`, `docs/UI_SPEC.md`, `docs/ARCHITECTURE.md`, `docs/APPLE_API_NOTES.md`, and the existing Swift source. First build the current `FoldCaptcha.xcodeproj` with Xcode 27.1 and the iPhone Duo simulator. Fix any beta-SDK signature changes against the installed SDK rather than replacing the architecture. Verify that `View.onHingeChange` continuously drives both the live fold visualization and a **visible numeric current-angle readout** using `DeviceHinge.angle.degrees`. The UI must visibly update the angle in real time while the user is physically bending the Duo; do not hide this as debug-only information. Then verify the HUMAN landing page, fold-reactive logo, **semicircle protractor/ring angle visualizer**, live numeric hinge readout, and bend-to-begin transition. The protractor should span 0°–180°, show a solid live needle, ghosted target needle, and highlighted ±3° target band. After that, test the randomized three-step sequence, ±3° tolerance, 0.75 s hold behavior, 50 ms hold sampling, trajectory validation, native haptics, reserved-region layout behavior, Liquid Glass UI, accessibility, retry state, and short-lived verification result. Keep the experience optimized for a polished sub-3-minute hackathon demo. Do not add unrelated AI, monetization, accounts, dashboards, or extra product scope.

## Recommended order

1. Open/build `FoldCaptcha.xcodeproj` in Xcode 27.1.
2. Run on the iPhone Duo simulator.
3. Confirm `onHingeChange` receives real simulator pose/hinge updates.
4. Confirm live and ghost fold geometry visually match the physical pose.
5. Tune challenge angle range if the simulator/device has practical limits.
6. Tune ±3° tolerance only if physical testing shows it is too strict/loose.
7. Test hold timing while the hinge remains steady.
8. Confirm haptics on real hardware when available.
9. Confirm active reserved regions do not obstruct text or controls.
10. Polish transitions and the success animation.
11. Optionally run `backend/server.mjs` and exercise the remote verification client.
12. Rehearse the final 30–60 second interaction inside the sub-3-minute demo.

## Demo target

A judge should understand the entire project immediately:

**68° → 121° → hold 47° → Human Verified**

The physical fold is the product. Keep everything else quiet and native.
