# UI Specification

## Visual direction

The experience should feel closer to a native Apple system sheet than a conventional CAPTCHA: minimal, glassy, precise, calm, and centered around direct manipulation.

## Challenge screen

The main screen should contain:

- title: **Verify you're here**
- instruction: **Match the fold** or **Hold here**
- ghosted target fold shape
- live current fold shape
- **live numeric current-angle readout that updates continuously while the phone is being bent; this is required, not optional**
- tiny step progress indicator such as **● ● ○**
- short status text such as **Getting close**, **Matched**, or **Hold steady**

The live fold visualization is the hero. It should mirror the physical Duo continuously as the user moves the hinge. **Directly alongside the visualization, show the current measured hinge angle in degrees and update it in real time with every hinge change so the user can literally watch the number change while bending the phone.** The target visualization should appear as a translucent or ghosted reference shape behind or alongside the live state.

The user should not need to understand what “68°” looks like. The intended behavior is simply: **make the real phone match the ghosted phone.**

## Glassmorphic treatment

Use restrained, native-feeling glassmorphism:

- system material / frosted blur
- subtle translucency
- thin border or separator treatment
- soft depth
- large continuous corner radius
- muted system background or gentle gradient behind the card
- no neon glow, loud gradients, or decorative effects that compete with the fold visualization

The challenge should feel like a premium iOS system interaction, not a web CAPTCHA.

## Proximity feedback

Suggested behavior:

- **far from target** → neutral visualization
- **within about 10–15°** → slightly increased emphasis
- **within about 5–7°** → subtle “getting close” feedback
- **inside ±3°** → visual snap/alignment + haptic confirmation

The exact proximity thresholds can be tuned during the hackathon.

## Hold behavior

For hold challenges:

1. user enters the ±3° valid range
2. progress begins filling
3. user remains in range for about 0.7–1.0 seconds
4. step completes automatically

If the device leaves the valid range, hold progress should **pause or reset gently**. There should be no punitive error animation or harsh vibration.

## Haptics

- entering the valid range → crisp light tick
- completing a normal step → medium confirmation
- completing a hold step → slightly stronger confirmation
- completing the full challenge → native success haptic
- minor drift → no negative buzz

Haptics should be sparse enough that each signal has meaning.

## Step transitions

A completed target should not open a new screen. Instead:

1. current shape aligns
2. brief confirmation appears
3. target smoothly morphs to the next requested fold
4. progress indicator advances
5. user immediately continues

This should make a three-step challenge feel like one continuous motion.

## Success state

Keep success brief:

```text
✓

Human Verified

Returning…
```

Then automatically dismiss or return to the requesting experience.

## Accessibility

Support:

- Dynamic Type
- VoiceOver descriptions for current angle, target state, progress, and success
- high contrast without relying only on color
- forgiving default tolerance
- optional wider tolerance for accessibility needs
- large touch targets for any fallback or retry actions
- reduced motion behavior
- no requirement to precisely read numerical angles

## Duo-specific layout behavior

- respect safe areas and reserved hinge regions
- avoid putting critical controls directly across the fold
- allow the fold visualization to visually reference the center because the hinge itself is the interaction
- keep secondary controls stable and reachable
- preserve hierarchy across compact, partially folded, and expanded configurations
