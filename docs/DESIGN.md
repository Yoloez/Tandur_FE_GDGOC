---
name: AgriLink Ecosystem
colors:
  surface: "#fafaf4"
  surface-dim: "#dadad5"
  surface-bright: "#fafaf4"
  surface-container-lowest: "#ffffff"
  surface-container-low: "#f4f4ee"
  surface-container: "#eeeee9"
  surface-container-high: "#e8e8e3"
  surface-container-highest: "#e3e3de"
  on-surface: "#1a1c19"
  on-surface-variant: "#3f4a3d"
  inverse-surface: "#2f312e"
  inverse-on-surface: "#f1f1ec"
  outline: "#6f7a6c"
  outline-variant: "#becaba"
  surface-tint: "#006e24"
  primary: "#006b23"
  on-primary: "#ffffff"
  primary-container: "#1c8634"
  on-primary-container: "#f7fff1"
  inverse-primary: "#78dc7e"
  secondary: "#615e57"
  on-secondary: "#ffffff"
  secondary-container: "#e7e2d9"
  on-secondary-container: "#67645d"
  tertiary: "#74554b"
  on-tertiary: "#ffffff"
  tertiary-container: "#8f6d62"
  on-tertiary-container: "#fffbff"
  error: "#ba1a1a"
  on-error: "#ffffff"
  error-container: "#ffdad6"
  on-error-container: "#93000a"
  primary-fixed: "#93f998"
  primary-fixed-dim: "#78dc7e"
  on-primary-fixed: "#002106"
  on-primary-fixed-variant: "#005319"
  secondary-fixed: "#e7e2d9"
  secondary-fixed-dim: "#cac6be"
  on-secondary-fixed: "#1d1c16"
  on-secondary-fixed-variant: "#494740"
  tertiary-fixed: "#ffdbd0"
  tertiary-fixed-dim: "#e7bdb1"
  on-tertiary-fixed: "#2c160e"
  on-tertiary-fixed-variant: "#5d4037"
  background: "#fafaf4"
  on-background: "#1a1c19"
  surface-variant: "#e3e3de"
typography:
  display-lg:
    fontFamily: Be Vietnam Pro
    fontSize: 48px
    fontWeight: "700"
    lineHeight: 56px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Be Vietnam Pro
    fontSize: 32px
    fontWeight: "600"
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: Be Vietnam Pro
    fontSize: 28px
    fontWeight: "600"
    lineHeight: 36px
  title-md:
    fontFamily: Be Vietnam Pro
    fontSize: 20px
    fontWeight: "600"
    lineHeight: 28px
  body-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: "400"
    lineHeight: 28px
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: "400"
    lineHeight: 24px
  label-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: "500"
    lineHeight: 20px
    letterSpacing: 0.01em
  label-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: "600"
    lineHeight: 16px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 8px
  container-margin-mobile: 20px
  container-margin-desktop: 64px
  gutter: 16px
  stack-sm: 8px
  stack-md: 16px
  stack-lg: 32px
---

## Brand & Style

The design system is built upon the concept of **"Digital Agronomy"**—a fusion of raw, organic vitality and precise, modern technology. It targets a dual audience: the tech-forward young farmer requiring efficient utility and the urban consumer seeking transparency and freshness.

The visual style is **Modern-Organic Minimalism**. It utilizes heavy whitespace to evoke a sense of open fields, punctuated by high-fidelity glassmorphism to represent the "digital lens" through which we view modern agriculture. The aesthetic avoids the cluttered feel of traditional marketplaces, opting instead for an elegant, editorial-inspired interface that treats fresh produce with the same reverence as luxury goods.

## Colors

The palette is rooted in the natural world but refined for digital legibility.

- **Primary (Fresh Green):** Used for primary actions, growth indicators, and brand-heavy moments. It represents vitality and the marketplace's core mission.
- **Secondary (Natural Beige):** This serves as the primary background alternative to white. It adds warmth and reduces eye strain, moving away from "clinical" white to an "organic" surface.
- **Tertiary (Earthy Brown):** Reserved for grounded elements, secondary accents, and deep-toned typography. It provides the "soil" to the "green."
- **Neutrals:** High-contrast blacks and soft greys provide the professional structure needed for a complex marketplace.

## Typography

This design system employs a two-tier typographic strategy.

**Be Vietnam Pro** is used for headlines and display text. Its slightly wider character set and contemporary humanist terminals feel approachable yet modern, echoing the friendly nature of a local market.

**Inter** is the functional workhorse for all UI elements, body copy, and data-dense tables. Its high x-height ensures maximum legibility for farmers in outdoor conditions and for urban users quickly browsing on the move. Use `font-weight: 600` for price points to ensure they stand out within the product grid.

## Layout & Spacing

The layout is governed by a **8px soft-grid system**, ensuring all dimensions are multiples of 8.

- **Mobile:** A 4-column fluid grid with 20px side margins. Cards typically span the full width or appear in 2-column sets.
- **Desktop:** A 12-column fixed-width grid (max-width 1280px) with 64px margins.
- **Rhythm:** Vertical stack spacing should be generous to maintain the "Clean & Elegant" feel. Use `stack-lg` (32px) between major content sections (e.g., "Trending Crops" vs "Top Farmers").

## Elevation & Depth

Depth in this design system is created through **Atmospheric Layering** rather than heavy shadows.

1.  **Base Layer:** The secondary beige surface.
2.  **Product Cards:** Use a very soft, diffused ambient shadow (`0px 10px 30px rgba(63, 163, 77, 0.05)`) to create a subtle lift that feels natural.
3.  **Glassmorphism:** Use for navigation bars and "Quick Buy" overlays. Apply a `backdrop-filter: blur(12px)` with a `white / 70% opacity` background. This allows the organic patterns and product photos to peek through, maintaining the "fresh" vibe.
4.  **Borders:** Use 1px solid borders in a very light grey/beige (`#E0E0E0`) for form fields and list items instead of shadows to keep the UI professional and "tight."

## Shapes

The shape language is defined by high-radius curves that feel soft and non-threatening.

- **Primary Radius:** 20px (1.25rem). This is applied to all product cards, category containers, and large buttons.
- **Secondary Radius:** 12px (0.75rem). Used for smaller input fields and inner nested elements.
- **Visual Accents:** Incorporate subtle organic SVG patterns—such as abstract leaf veins or topographical field lines—as low-opacity background watermarks (2-4% opacity) within large containers to reinforce the agricultural theme.

## Components

- **Buttons:** Primary buttons use the 20px radius and Primary Green. Text should be white and bold. Secondary buttons use the Earthy Brown outline for a grounded feel.
- **Product Cards:** Images should have no border but use the 20px clip. The price should be prominently displayed in the bottom-left of the info area. Include a small "Origin" label (e.g., "From Highland Farm") using `label-sm` typography.
- **Chips/Tags:** Use for categories (e.g., "Organic," "Hydroponic"). These should have pill-shaped rounding and use a light tint of the primary green background with dark green text.
- **Input Fields:** Backgrounds should be White or a very light Beige. On focus, the border transitions to Primary Green with a soft glow.
- **Farmer Profiles:** Use circular avatars for farmers. Include a "Verified" badge using the primary color to build trust.
- **Navigation Bar:** Apply glassmorphism with a subtle Primary Green top-border (2px) to indicate the active section.
