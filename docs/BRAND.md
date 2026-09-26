# Brand and Landing Experience

## Name

**HUMAN**

Supporting line:

> **Your phone is the challenge.**

The app can still be referred to technically as Fold CAPTCHA, but the product-facing landing experience uses HUMAN as the simple brand.

## Logo

The logo is implemented directly in SwiftUI in:

`FoldCaptcha/Brand/HumanLogo.swift`

It is not a static image. The mark between **HU** and **MAN** is a tiny live hinge graphic that mirrors the actual Duo angle.

Conceptually:

```text
HU  /  MAN
```

As the phone folds, the center mark folds with it. This makes the logo itself part of the Duo interaction instead of adding a decorative logo unrelated to the product.

## Landing page

On first open, the user sees:

- HUMAN logo
- “Your phone is the challenge.”
- central frosted/Liquid Glass surface
- **live semicircle protractor/ring showing the Duo hinge from 0°–180°**
- **live current hinge angle in degrees**
- “Bend to begin”
- accessibility fallback button: “Start verification”

The landing visual should use the same protractor language as the challenge: a semicircle ring, a live current-angle needle, and a large numeric angle that updates continuously while the Duo is physically being bent.

Example:

```text
132° → 125° → 114° → 103°
```

The user should immediately understand that the software is reacting to the physical shape of the phone.

## Automatic transition

When a real Duo hinge is available, the landing page records the angle at entry. If the user changes the hinge by roughly 12° or more, the app interprets that as intentional interaction and transitions smoothly into the verification challenge.

The button remains available for accessibility and for non-Duo simulator testing.

## Visual direction

Keep the landing page native and restrained:

- system typography
- native SwiftUI Liquid Glass
- soft system/accent light bloom
- no loud neon or web-style glass effects
- large empty space around the logo and fold graphic
- live numeric angle uses monospaced digits
- smooth number transitions
- subtle spring motion on the hinge mark
- no unnecessary menus or onboarding carousel

The physical device is the visual centerpiece.
