# Color Accessibility Guide

Reference for WCAG compliance, color blindness, and inclusive color design.

## WCAG Contrast Requirements

### WCAG 2.2 Contrast Ratios

| Level | Normal Text (<18pt / <14pt bold) | Large Text (>=18pt / >=14pt bold) | Non-Text UI Components |
|-------|----------------------------------|-----------------------------------|------------------------|
| AA (minimum) | 4.5:1 | 3:1 | 3:1 |
| AAA (enhanced) | 7:1 | 4.5:1 | Not specified |

- "Large text" = 18pt (24px) regular weight or 14pt (18.66px) bold
- Non-text UI components include icons, form borders, focus indicators, chart elements
- Decorative elements and logos are exempt
- Disabled controls are exempt but should still be visually identifiable as disabled

### Relative Luminance Calculation

Contrast ratio = (L1 + 0.05) / (L2 + 0.05) where L1 is the lighter color's luminance.

Relative luminance formula:

```
L = 0.2126 * R_linear + 0.7152 * G_linear + 0.0722 * B_linear

Where for each channel:
  if sRGB_value <= 0.04045:
    linear = sRGB_value / 12.92
  else:
    linear = ((sRGB_value + 0.055) / 1.055) ^ 2.4

  sRGB_value = 8-bit value / 255
```

Key insight: green contributes ~72% of perceived luminance. Two colors can differ dramatically in hue but have identical luminance (and thus 1:1 contrast ratio). This is why red and green with matched luminance are indistinguishable to colorblind users and have poor contrast for everyone.

## APCA (Advanced Perceptual Contrast Algorithm)

APCA is the successor contrast model being developed for WCAG 3.0. Key differences from WCAG 2.x:

- **Polarity-aware.** Light text on dark backgrounds requires different thresholds than dark text on light backgrounds (dark-on-light is more readable at the same ratio).
- **Font-size-aware.** Contrast requirements scale with text size and weight — small thin text needs more contrast than large bold text.
- **Perceptually linear.** Based on actual human contrast sensitivity, not the simplified luminance ratio.

APCA reports contrast as **Lc (Lightness Contrast)** values:

| Use Case | Minimum Lc |
|----------|------------|
| Body text (16px normal) | Lc 75 |
| Large text (24px+) | Lc 60 |
| Non-text elements | Lc 45 |
| Placeholder/disabled | Lc 30 |
| Invisible/decorative | Lc 15 |

When WCAG 3.0 ships, APCA will become the standard. For now, meet WCAG 2.2 AA as baseline and use APCA as a supplementary check for better perceptual accuracy.

## Color Blindness

### Types and Prevalence

| Type | Affects | Prevalence (Males) | Prevalence (Females) | Colors Confused |
|------|---------|--------------------|-----------------------|-----------------|
| Deuteranomaly | Green cones (reduced) | ~5% | ~0.4% | Red-green, reduced green sensitivity |
| Protanomaly | Red cones (reduced) | ~1% | ~0.01% | Red-green, reds appear darker |
| Deuteranopia | Green cones (absent) | ~1% | ~0.01% | Red-green, severe |
| Protanopia | Red cones (absent) | ~1% | ~0.01% | Red-green, severe; reds appear very dark |
| Tritanopia | Blue cones (absent) | ~0.003% | ~0.003% | Blue-yellow |
| Achromatopsia | All cones (absent) | ~0.003% | ~0.003% | All color; sees only luminance |

**Total: ~8% of males and ~0.5% of females have some form of color vision deficiency.** Deuteranomaly alone affects 1 in 20 males.

### What Colorblind Users Actually See

- **Deuteranopia/Protanopia (red-green):** The entire red-to-green spectrum collapses into a yellow-blue continuum. Red, green, brown, and olive become near-identical. Blue, yellow, and gray remain distinguishable.
- **Protanopia specifically:** Reds additionally appear much darker (reduced luminance), so a red warning on a dark background may become invisible.
- **Tritanopia (blue-yellow):** Blue and green become confused; yellow and pink become confused. Much rarer and often overlooked.

### Problematic Color Pairs

Never use these pairs as the **sole** differentiator:

| Pair | Problem |
|------|---------|
| Red and green | Classic CVD failure — affects 8% of males |
| Red and brown | Indistinguishable in protanopia/deuteranopia |
| Green and brown | Indistinguishable in protanopia/deuteranopia |
| Blue and purple | Difficult for deuteranopia |
| Light green and yellow | Difficult for deuteranomaly |
| Pink and gray | Difficult for protanopia |

### Safe Color Pairs

These remain distinguishable across most CVD types:

- Blue and orange
- Blue and yellow
- Dark blue and light yellow
- Purple and yellow/orange
- Black and any saturated color

## Design Strategies for Color Blindness

### Primary Strategy: Redundant Coding

Never rely on color alone to convey meaning. Add redundant visual channels:

- **Icons/shapes** alongside color: checkmark for success, X for error, triangle for warning
- **Patterns/textures** in charts: hatching, dots, dashes for different data series
- **Labels/text** on colored elements: "Error", "Success", "Active" as text
- **Position** as a cue: left-to-right progression, top-to-bottom ranking
- **Luminance contrast** between adjacent colored elements (even if hues are confused, different brightness levels remain visible)

### Palette Design for Inclusivity

When building a palette with accessibility as a constraint:

1. **Start with luminance.** Assign each palette role a distinct lightness value. If the palette works in grayscale, it works for achromatopsia and is more robust for all CVD types.
2. **Choose hues from safe axes.** Blue-orange and blue-yellow axes maintain contrast across most CVD types.
3. **Test with simulation.** Run the palette through deuteranopia and protanopia simulation. If critical distinctions collapse, adjust hue or luminance.
4. **Provide alternatives for red-green.** If red/green are needed (e.g., success/error), ensure they also differ in luminance and have icons/text.

## Testing Methods and Tools

### Simulation Tools

- **Figma:** Built-in Vision Simulation (Menu → View → Color blindness simulation)
- **Chrome DevTools:** Rendering tab → Emulate vision deficiencies
- **macOS:** System Preferences → Accessibility → Display → Color Filters
- **Photoshop:** View → Proof Setup → Color Blindness (Protanopia / Deuteranopia)
- **Online:** Coblis (Color Blindness Simulator), Sim Daltonism (macOS app)

### Contrast Checking Tools

- **WebAIM Contrast Checker** — Quick ratio check for two colors
- **Chrome DevTools** — Hover over elements in Elements panel to see contrast ratio
- **Lighthouse** — Automated audit of all text contrast on a page
- **axe DevTools** — Browser extension for comprehensive accessibility audits
- **Stark** — Figma/Sketch plugin for contrast and CVD simulation

### Automated Testing

- Include contrast ratio checks in CI/CD with tools like `axe-core`, `pa11y`, or `jest-axe`
- Lint CSS for hardcoded color values that bypass the token system (which should guarantee contrast)
- Flag color-only indicators in design review checklists

### Manual Verification Checklist

1. Does every color-coded element have a non-color redundant cue?
2. Does the UI remain usable in grayscale?
3. Do all text/background pairs meet WCAG AA minimum (4.5:1 / 3:1)?
4. Are focus indicators visible against all background colors?
5. Do charts/graphs use patterns or labels in addition to color?
6. Are error states communicated with icons and text, not just red color?
