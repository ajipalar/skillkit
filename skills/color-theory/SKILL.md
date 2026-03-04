---
name: color-theory
description: >-
  Expert color theory guidance for designing color palettes and choosing colors
  across any medium. Use when a user asks to "choose colors," "pick a color
  palette," "design a color scheme," "what colors should I use for," "create
  brand colors," "make accessible colors," or any task involving color selection,
  color harmony, color accessibility, or color psychology. Covers web, mobile,
  tablet, video games, print, and comics. Triggers on: color palette, color
  scheme, color harmony, brand colors, dark mode colors, WCAG contrast, color
  blindness, complementary colors, analogous colors, print colors, CMYK, game
  UI colors, comic coloring, color accessibility, color psychology.
---

# Color Theory

Expert guidance for designing color palettes across screen, print, and interactive media.

## Workflow

Follow these steps when designing or advising on a color palette:

1. Clarify project context
2. Route to medium-specific guidance
3. Select harmony type
4. Build the palette in a perceptual color space
5. Verify accessibility
6. Apply psychological and emotional considerations (if relevant)
7. Deliver the palette in the appropriate format

### Step 1: Clarify Project Context

Gather these before proceeding:

- **Medium**: Web, mobile app, tablet, video game, print, comics, or multi-medium?
- **Brand constraints**: Existing brand colors that must be incorporated?
- **Mood/tone**: What emotional response should the palette evoke?
- **Audience**: Age range, cultural context, accessibility requirements?
- **Functional requirements**: How many distinct states need color coding (errors, warnings, success, info)?
- **Light/dark mode**: Does the project need both?

If the user provides a vague request ("pick some nice colors"), ask clarifying questions about at least medium and mood before proceeding.

### Step 2: Route to Medium-Specific Guidance

Based on the medium identified in Step 1:

- **Web, mobile, tablet, or video games** → Read [references/medium-screen.md](references/medium-screen.md) for color space implementation, dark mode strategy, platform-specific systems, and game rendering considerations.
- **Print or comics** → Read [references/medium-print-and-comics.md](references/medium-print-and-comics.md) for CMYK workflow, ink limits, spot colors, paper effects, and comics coloring conventions.
- **Multi-medium projects** → Read both references. Design in the most constrained color space first (usually CMYK for print) and adapt outward.

### Step 3: Select Harmony Type

Choose based on the project's goals:

| Harmony | Hue Relationship | Character | Best For |
|---------|-----------------|-----------|----------|
| Monochromatic | Single hue, varied lightness/chroma | Cohesive, elegant, minimal | Brand-focused, minimal UI, text-heavy |
| Analogous | 2-3 adjacent hues (30-60 degrees apart) | Harmonious, calm, natural | Nature themes, comfortable reading, low-contrast UIs |
| Complementary | Opposite hues (180 degrees) | High energy, vibrant, tense | CTAs, sports, high-impact visuals |
| Split-complementary | One hue + two hues flanking its complement | Vibrant but less tense than complementary | Balanced designs needing contrast without harshness |
| Triadic | Three hues equally spaced (120 degrees) | Balanced, colorful, playful | Children's products, creative brands, games |
| Tetradic (double-complementary) | Two complementary pairs | Rich, complex, full spectrum | Complex UIs with many states, dashboards, data viz |

**Guidelines for harmony selection:**

- Fewer hues = easier to maintain visual coherence
- More hues = more flexibility but higher risk of visual noise
- Start with fewer and add only when functionally necessary
- **Most UIs need only 1-2 hues** plus neutrals and semantic colors (error/warning/success/info)

### Step 4: Build the Palette

#### Use Perceptual Color Spaces

**Always build palettes in OKLCH or OKLAB**, not HSL. Reason: HSL's lightness channel is mathematically uniform but perceptually non-uniform. Two HSL colors at `L: 50%` can have drastically different perceived brightness depending on hue (yellow appears much brighter than blue at the same HSL lightness).

OKLCH provides perceptual uniformity: rotating the hue at constant lightness and chroma produces colors that genuinely look equally bright.

```
oklch(L C H)
  L = perceptual lightness (0 = black, 1 = white)
  C = chroma (0 = gray, ~0.4 = maximum saturation)
  H = hue angle (0-360 degrees)
```

To generate harmonious palettes: fix L and C, rotate H by the harmony angle.

#### The 60-30-10 Rule

Distribute color area by visual weight:

- **60% — Dominant/base color.** Background, large surfaces. Low chroma, neutral or tinted neutral.
- **30% — Secondary color.** Cards, sections, secondary buttons. Moderate chroma.
- **10% — Accent color.** CTAs, highlights, active states. Full chroma allowed.

This creates visual hierarchy. Breaking this ratio is valid for expressive/artistic projects but increases the risk of visual fatigue. If breaking it, do so deliberately.

#### Saturation Discipline

- **Base/background colors**: Keep chroma below 0.03 in OKLCH. These are near-neutral with a subtle tint.
- **Secondary/surface colors**: Chroma 0.03-0.08. Visible hue but not dominant.
- **Primary/action colors**: Chroma 0.1-0.2. Clear, identifiable hue.
- **Accent/emphasis colors**: Chroma 0.15-0.3. Maximum vibrancy, used sparingly.

Over-saturating the full palette causes visual fatigue and makes nothing stand out. Reserve high chroma for elements that need attention.

#### Build the Neutral Scale

Every palette needs a neutral scale. Pure gray (#808080) is rarely the best choice — tint neutrals with the primary hue for cohesion:

- **Warm neutrals** (hue toward primary): Cozy, approachable, organic
- **Cool neutrals** (hue toward blue-gray): Clean, professional, technical
- Generate 5-9 neutral steps spanning OKLCH lightness from ~0.15 (near-black) to ~0.97 (near-white)

#### Simultaneous Contrast

Colors shift in perceived hue, lightness, and chroma depending on their neighbors:

- A medium gray square appears warmer on a blue background and cooler on an orange background
- A color looks more saturated against a neutral background and less saturated against a similarly-saturated background
- Small colored text on a colored background shifts unpredictably

**Implication:** Always evaluate colors in the context where they will actually appear, not in isolation. A color that looks perfect in a swatch grid may look wrong in the final layout.

#### Temperature Balance

Every palette has an overall warm-cool temperature:

- **All-warm palettes** feel energetic but can become aggressive — add a cool neutral to anchor
- **All-cool palettes** feel calm but can become sterile — add a warm accent for life
- **Balanced palettes** use warm foreground elements on cool backgrounds (or vice versa) for maximum visual separation

### Step 5: Verify Accessibility

**Always check accessibility.** Read [references/accessibility.md](references/accessibility.md) for WCAG contrast ratios, APCA guidance, color blindness design strategies, and testing tools.

Non-negotiable minimums:

- **All text** must meet WCAG 2.2 AA contrast (4.5:1 normal, 3:1 large)
- **Interactive elements** (buttons, form borders, focus rings) must meet 3:1 against adjacent colors
- **Never use color alone** to convey information — always provide redundant cues (icons, text, patterns)
- **Test with CVD simulation** (at minimum: deuteranopia and protanopia)

### Step 6: Apply Color Psychology (When Relevant)

If the user has expressed emotional or psychological goals for the palette (e.g., "trustworthy," "energetic," "calming," "luxurious"), or if the project targets a specific industry or cultural context, read [references/color-psychology.md](references/color-psychology.md) for evidence-based associations, cultural variations, and industry conventions.

Key caution: color psychology is **context-dependent**, not absolute. Do not apply it as a simple lookup table ("blue = trust" without considering the specific design context).

### Step 7: Deliver the Palette

#### Output Format

Present every palette with:

1. **Named roles** for each color (not just swatches):
   - Primary, Secondary, Accent
   - Background, Surface, Surface-variant
   - On-primary, On-secondary, On-background (text colors on each)
   - Error, Warning, Success, Info (semantic states)
   - Neutral scale (50, 100, 200, ... 900)

2. **Color values** in the medium-appropriate format:
   - Screen: hex, `oklch()`, and/or `hsl()` values
   - Print: CMYK percentages (and Pantone codes if applicable)
   - Both: if multi-medium

3. **Contrast ratios** for every text/background pair

4. **Light and dark mode variants** if applicable

5. **Visual swatch preview** if possible (markdown table with labeled colors)

#### Example Output Structure

```
## Palette: [Project Name]

### Core Colors
| Role       | Light Mode          | Dark Mode           | OKLCH                    |
|------------|--------------------|--------------------|--------------------------|
| Primary    | #2563eb            | #60a5fa            | oklch(0.55 0.2 250)      |
| Secondary  | #7c3aed            | #a78bfa            | oklch(0.50 0.19 290)     |
| Accent     | #f59e0b            | #fbbf24            | oklch(0.75 0.17 75)      |

### Neutral Scale
| Step | Light Mode | Dark Mode |
|------|-----------|-----------|
| 50   | #f8fafc   | #0f172a   |
| 100  | #f1f5f9   | #1e293b   |
| ...  | ...       | ...       |

### Contrast Ratios
| Pair                       | Ratio | WCAG AA |
|----------------------------|-------|---------|
| Primary on Background      | 7.2:1 | Pass    |
| On-primary on Primary      | 8.1:1 | Pass    |
```

## Common Anti-Patterns

Avoid these frequent mistakes:

1. **Pure black on pure white** (#000 on #FFF). The 21:1 contrast ratio causes halation (glowing edges) and eye strain. Use near-black on near-white (e.g., #1a1a2e on #f8f9fa) for comfortable reading.

2. **Dark mode as color inversion.** Inverting light mode colors produces garish, eye-straining results. Dark mode requires: elevated surfaces (lighter = higher), reduced chroma, off-white text, and tinted dark backgrounds. See medium-screen.md for details.

3. **Color as the only information channel.** Red for error, green for success — without icons or text, this fails for ~8% of male users (colorblind) and is a WCAG violation. Always add redundant cues.

4. **Over-saturated palettes.** When every color is at maximum chroma, nothing stands out and everything causes fatigue. Follow saturation discipline: reserve high chroma for accents.

5. **Ignoring simultaneous contrast.** Testing colors in isolation (swatch grids) and being surprised when they look different in context. Always evaluate in the actual layout.

6. **Random hex values.** Picking colors by typing hex codes or using a basic color picker produces perceptually imbalanced palettes. Use OKLCH to ensure perceptual harmony.

7. **Untested small sizes.** A color pair that passes contrast at 24px may be illegible at 12px. Test at actual use sizes, especially for mobile.
