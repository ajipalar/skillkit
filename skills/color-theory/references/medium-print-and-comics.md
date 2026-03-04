# Print and Comics Color Guide

Reference for CMYK print production, spot colors, and comics coloring.

## CMYK Fundamentals

### Why RGB Colors Don't Print Accurately

RGB is additive (light emission); CMYK is subtractive (ink absorption). The CMYK gamut is smaller than sRGB:

- Vivid blues, greens, and oranges achievable on screen often fall outside CMYK gamut
- When out-of-gamut RGB colors are converted, they shift toward duller equivalents
- Always design in CMYK (or a CMYK-aware workflow) for print — never design in RGB and convert at the end

### Total Ink Coverage (TIC)

The sum of C + M + Y + K percentages on any area must not exceed the printer's limit:

| Print Type | Typical TIC Limit |
|------------|-------------------|
| Sheetfed coated | 320-340% |
| Web offset coated | 300-320% |
| Newspaper/uncoated | 240-280% |
| Digital/inkjet | Varies, check with printer |

Exceeding TIC causes: ink not drying, offsetting onto other sheets, smearing, and paper cockling.

### Key CMYK Values

| Color | CMYK Values | Notes |
|-------|-------------|-------|
| Rich black | C60 M40 Y40 K100 | Deep, warm black for large areas |
| Cool rich black | C70 M50 Y30 K100 | Cooler tone |
| Registration black | C100 M100 Y100 K100 | NEVER use in production — for registration marks only |
| 100K black | C0 M0 Y0 K100 | Text and fine lines only — appears dark gray in large fills |
| Clean red | C0 M100 Y100 K0 | Closest to pure red |
| Clean blue | C100 M70 Y0 K0 | Strong blue |
| Clean yellow | C0 M0 Y100 K0 | Pure yellow — fragile, shifts easily |

### When to Use Rich Black vs 100K

- **100K**: Body text, thin lines, small type. Adding CMY to small type causes registration issues that make text fuzzy.
- **Rich black**: Large areas (backgrounds, headers >24pt), color bars, solid fills. 100K alone looks washed-out in large areas.
- **Never** use registration black (C100 M100 Y100 K100) — it's 400% ink and will destroy the print.

## Spot Colors and Pantone

### When to Use Spot Colors

- **Brand consistency.** When a specific color must match exactly across all materials (Coca-Cola red, Tiffany blue). CMYK builds vary between printers; Pantone numbers don't.
- **Colors outside CMYK gamut.** Neon/fluorescent colors, metallics (gold, silver, copper), and very vivid blues/oranges are impossible in CMYK.
- **Special inks.** White ink (on dark stock), varnish (spot gloss/matte), and security inks require spot channels.
- **Cost consideration.** A 2-color spot job (e.g., black + one Pantone) is cheaper than 4-color CMYK for simple designs.

### Pantone Systems

| System | Suffix | Use |
|--------|--------|-----|
| Coated | C | Glossy/coated paper stock |
| Uncoated | U | Matte/uncoated paper stock |
| The same Pantone number looks different on coated vs uncoated stock — always specify both when relevant |

## Paper Stock Effects on Color

### Coated vs Uncoated

- **Coated (gloss/silk/matte coated):** Ink sits on top of the coating. Colors appear more vibrant, sharper, higher contrast. Good for photography and saturated palettes.
- **Uncoated:** Ink absorbs into the paper fibers. Colors appear softer, warmer, lower contrast. Dot gain is higher (halftone dots spread). Good for text-heavy pieces and organic/artisanal aesthetics.

### Paper Shade

- **Bright white:** Neutral, high contrast, makes colors pop. Standard for corporate/modern.
- **Natural/cream white:** Warmer tone, reduces perceived contrast, softens colors. Preferred for books, literary publications, some luxury brands.
- **Colored stock:** The paper color mixes with ink colors. Blue ink on cream stock shifts green. Plan accordingly — there is no white ink in standard CMYK.

### Dot Gain Compensation

Halftone dots spread when ink hits paper (dot gain). Typical values:

| Paper Type | Dot Gain |
|------------|----------|
| Coated | 10-15% |
| Uncoated | 20-25% |
| Newsprint | 30-40% |

Compensate by reducing midtone density in the source file. A 50% tint on uncoated stock may print as 70-75% — muddying colors.

## Registration and Trapping

**Registration** is the alignment of CMYK plates. Misregistration (plates shifting) causes visible color fringing.

- Avoid fine lines that combine multiple ink colors (e.g., thin text in a 4-color build)
- **Trapping** (spreading/choking) adds small overlaps between adjacent colors to prevent white gaps from misregistration. Most print workflows handle this automatically, but design with tolerance:
  - Avoid thin colored lines on differently-colored backgrounds
  - Keep small text in a single ink color (ideally 100K)
  - If colored text is required, use it at large sizes (18pt+) to tolerate misregistration

## Comics Coloring

### Digital Comics Color Workflow

Modern comics coloring pipeline:

1. **Flatting** — Fill enclosed areas with flat, arbitrary colors to create selectable regions. Speed technique; flatted colors are not final palette colors.
2. **Color selection** — Replace flat colors with the actual palette. Work with a limited, intentional palette per scene.
3. **Rendering** — Add lighting, shadows, highlights, and effects. Typically multiply/overlay layers over the flats.
4. **Color holds** — Change black ink line art to a colored line (often darker version of the fill color) to soften edges and integrate line art with color. Use for: backgrounds, soft objects, magical effects, mood areas.

### Genre Color Conventions

| Genre | Palette Characteristics |
|-------|------------------------|
| Superhero | High saturation, strong primaries, bold contrast. Costumes in pure hues. |
| Noir/crime | Desaturated, heavy shadows, limited palette (2-3 hues). Spot color for emphasis (red lips, neon signs). |
| Horror | Muted base with jarring accent colors. Heavy blacks, sickly greens/yellows, desaturated flesh tones. |
| Sci-fi | Cool blues and teals for tech; warm accents for organic. High contrast lighting. |
| Slice of life | Natural, muted palette. Earth tones, soft pastels. Avoid oversaturation. |
| Fantasy | Rich, jewel tones. Warm golds and ambers for magic, cool blues for mystery. |
| Manga (color pages) | Often high-key with pastels. Flat shading more common than rendered. Screen tones for gray values. |

### Panel Mood Through Color

- **Time of day** shifts the entire palette: warm golden for morning/evening, cool blue for night, harsh neutral for midday
- **Emotional beats** use color temperature: warm for comfort/intimacy, cool for isolation/tension, desaturated for shock/numbness
- **Flashbacks** conventionally use a shifted palette: sepia, reduced saturation, single-tint wash, or complementary hue shift from the present-day scenes
- **Focus/emphasis** through saturation: the focal character/object maintains full color while the surroundings desaturate

### Print Comics vs Digital-Only Comics

- **Print comics** must account for CMYK gamut, dot gain, paper stock, and the constraints above
- **Digital-only comics (webtoons, webcomics)** can use full sRGB or P3 gamut, but should still consider:
  - Mobile screen brightness and viewing conditions (many readers use low brightness at night)
  - Scroll-based formats need color continuity between panels — abrupt shifts break flow
  - File size: highly saturated gradients compress poorly in JPEG
