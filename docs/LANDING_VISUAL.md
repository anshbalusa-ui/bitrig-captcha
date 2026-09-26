# Landing Visual

The landing page should feel like a visual demonstration of the hardware before it feels like a menu.

## Composition

```text
                HUMAN
        PHYSICAL VERIFICATION


         0°               180°
           ╭────────────╮
        ╱        •        ╲
      ╱          │          ╲
     ╱           │           ╲
                 │

               112°
            LIVE HINGE


           Bend to begin
      Your phone is the challenge.

       [ Start verification ]
```

The actual SwiftUI version is smoother and more minimal than this text sketch.

## Hero behavior

The semicircle is a visualized 0°–180° hinge range.

As the physical Duo folds:

- the large center number changes live
- the needle rotates live
- the point on the outer arc travels with the angle
- the travelled portion of the ring fills subtly
- the glow remains understated
- the page automatically enters the challenge after meaningful movement

## Design goal

The first reaction should be:

> “Oh, the screen is literally reading the fold of the phone.”

The landing page should show the core hack before the user even begins the CAPTCHA.

## Implementation

```text
FoldCaptcha/Views/LandingView.swift
FoldCaptcha/Views/LandingHeroVisual.swift
```

No rendered image is required. The visual is native SwiftUI and reacts directly to live hinge data.
