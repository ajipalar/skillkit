# Screen-Based Media Color Guide

Reference for web, mobile, tablet, and video game color implementation.

## Color Spaces and CSS Systems

### sRGB vs Display P3

- **sRGB**: Standard gamut supported everywhere. Use as baseline.
- **Display P3**: ~25% wider gamut. Supported on modern Apple devices, some Android flagships, and recent desktop monitors. Use for richer greens, reds, and oranges when targeting these devices.
- Always provide sRGB fallback when using P3:
  ```css
  .element {
    color: #e63946;                          /* sRGB fallback */
    color: color(display-p3 0.92 0.2 0.28);  /* P3 when supported */
  }
  ```

### CSS Color Formats

| Format | Use Case |
|--------|----------|
| Hex (`#rrggbb`) | Static values, design tokens, broad compat |
| `rgb()` | When computing channels programmatically |
| `hsl()` | Quick hue variations; **unreliable for perceived lightness** |
| `oklch()` | Perceptually uniform; best for generating harmonious palettes in CSS |
| `color(display-p3 r g b)` | Wide-gamut colors on supported displays |

### OKLCH in CSS

OKLCH is natively supported in modern browsers. Prefer it for palette generation because rotating the hue channel produces colors with consistent perceived brightness:

```css
/* Generate a palette by rotating hue at constant lightness and chroma */
--primary:   oklch(0.65 0.2 250);  /* blue */
--secondary: oklch(0.65 0.2 310);  /* purple, same perceived brightness */
--accent:    oklch(0.65 0.2 30);   /* orange, same perceived brightness */
```

In HSL, the same lightness value produces wildly different perceived brightness across hues (yellow at 50% lightness looks much brighter than blue at 50% lightness).

### Design Tokens Architecture

Structure color tokens in three layers:

1. **Primitive tokens** — Raw color values: `--blue-500: oklch(0.55 0.2 250)`
2. **Semantic tokens** — Intent-based aliases: `--color-primary: var(--blue-500)`
3. **Component tokens** — Scoped usage: `--button-bg: var(--color-primary)`

This enables theme switching (light/dark, brand variants) by remapping semantic tokens without touching components.

## Web

### Dark Mode Strategy

Dark mode is NOT color inversion. Key principles:

- **Elevate with lightness, not shadow.** Higher surfaces are lighter (the opposite of light mode). Use `oklch` lightness increments of ~0.02-0.04 per elevation level.
- **Reduce chroma.** Colors that work at full saturation in light mode cause eye strain in dark mode. Reduce chroma by 20-40%.
- **Base surface is not pure black.** Use a dark gray (`oklch(0.15-0.20 0.01-0.02 <hue>)`) to allow elevation. Pure black (#000) is acceptable only on OLED for power savings if deliberate.
- **Text contrast.** Use off-white (`oklch(0.93-0.97 0.005 <hue>)`) not pure white to reduce glare.
- **Colored surfaces.** Tint dark surfaces with the brand hue at very low chroma for personality without distraction.

Implementation with `prefers-color-scheme`:

```css
:root {
  --surface: oklch(0.98 0.005 250);
  --on-surface: oklch(0.15 0.02 250);
}

@media (prefers-color-scheme: dark) {
  :root {
    --surface: oklch(0.18 0.015 250);
    --on-surface: oklch(0.93 0.005 250);
  }
}
```

### Responsive Color Considerations

- Small screens benefit from slightly higher contrast ratios than the WCAG minimum
- Touch targets on mobile need clear visual boundaries — use borders or filled backgrounds, not subtle color differences alone
- Reduce the number of accent colors on smaller viewports to avoid visual clutter

## Mobile

### iOS Color System

Apple's semantic colors adapt automatically to light/dark/high-contrast modes:

| Semantic Color | Purpose |
|----------------|---------|
| `systemBlue` | Interactive elements, links |
| `label` | Primary text (adapts to mode) |
| `secondaryLabel` | Secondary text |
| `systemBackground` | Root background |
| `secondarySystemBackground` | Grouped content background |
| `separator` | Thin dividers |

Design palettes that complement these system colors rather than fighting them. Custom colors should still adapt to appearance modes using dynamic color providers or asset catalog color sets.

### Android Material Color System

Material Design 3 generates tonal palettes from a source color:

- A **tonal palette** has 13 tones (0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 95, 99, 100) for each key color
- Light theme uses tone 40 for primary, tone 99 for background
- Dark theme uses tone 80 for primary, tone 10 for background
- The **HCT color space** (Hue, Chroma, Tone) is Material's perceptual space — similar philosophy to OKLCH

When designing for Android, either use Material's color generation tools or ensure custom palettes provide the same tonal range.

### OLED Considerations

- True black (`#000000`) turns off OLED pixels entirely — saves battery but creates "black smearing" during scrolling on some panels
- Use near-black (`#0a0a0a` to `#121212`) for backgrounds to reduce smearing while preserving battery benefits
- High-contrast elements on pure black backgrounds appear to "float" — this can be a feature or a bug depending on intent

## Tablet

Tablets straddle phone and desktop contexts:

- **Reading distance varies.** Users hold tablets at 15-20 inches (closer than desktop, farther than phone). Text contrast needs to work at both distances.
- **Split-screen contexts.** Colors must remain distinguishable when the app occupies half the screen next to another app.
- **Stylus input.** Color-picker UI and precision color work is common on tablets — ensure color swatches are large enough for accurate stylus selection.

## Video Games

### Color Pipeline

Game engines render in **linear color space** internally and apply gamma correction (sRGB transfer function) at output. This means:

- Colors authored in Photoshop/Figma (sRGB/gamma) will look wrong if imported as linear values without conversion
- Multiply blend operations in linear space produce physically correct results; in gamma space they darken excessively
- When providing hex values for game teams, specify whether they are sRGB-encoded or linear — this distinction is critical

### UI vs Environment Color

Maintain clear visual separation between:

- **Diegetic color** (in-world: sky, terrain, lighting, character materials)
- **UI color** (HUD, menus, health bars, minimaps)

UI colors must remain readable over any environment background. Strategies:
- Semi-transparent dark panels behind UI text
- Outline/drop-shadow on UI elements
- Reserved hue ranges that don't appear in the environment palette

### Game-Specific Palette Strategies

- **Biome/level palettes.** Each zone should have a dominant hue to create visual identity and wayfinding cues. Adjacent zones benefit from contrasting dominant hues.
- **Faction/team colors.** Must be distinguishable under all lighting conditions including shadows and colored light. Test under warm, cool, and desaturated lighting.
- **Loot/rarity systems.** Common convention: white → green → blue → purple → orange/gold. Players recognize this hierarchy instinctively. Deviating requires clear onboarding.
- **Damage/status effects.** Use consistent color coding: red for damage/health, blue/cyan for shields/mana, green for healing/poison (context-dependent), yellow for caution/electricity.

### HDR Considerations

HDR displays support brightness values above 1.0 (SDR white). When targeting HDR:

- Reserve high-brightness values (>1.0 in scene-referred) for specular highlights, emissive surfaces, and UI emphasis
- UI on HDR should still use SDR-range values for comfort — don't blast the player with 1000-nit menu backgrounds
- Provide SDR and HDR color variants; never simply scale SDR values up

### Colorblind Modes in Games

Many games implement post-process color filters for colorblind players. Better alternatives:

- Use luminance contrast AND hue contrast (don't rely on hue alone)
- Add pattern/shape differentiation (striped vs solid vs dotted health bars)
- Offer customizable UI colors rather than fixed "colorblind mode" presets
- Test with deuteranopia and protanopia simulation at minimum
