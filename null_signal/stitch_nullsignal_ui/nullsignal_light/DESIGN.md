# Design System Specification: Technical Light Mode

## 1. Overview & Creative North Star: "The Analog Precisionist"

This design system is a high-fidelity translation of cockpit instrumentation into a modern, light-mode interface. The Creative North Star is **"The Analog Precisionist."** We are moving away from the "web-standard" look of flat white boxes and moving toward the aesthetic of a high-end physical instrument or a technical flight manual. 

The goal is to evoke the feeling of matte-finished ivory panels, laser-etched black typography, and precision-engineered controls. We break the "template" look through **intentional density**, **asymmetrical information clusters**, and a total rejection of traditional 1px borders in favor of **tonal layering**.

---

## 2. Colors & Surface Architecture

The palette is rooted in a warm, sophisticated neutral base, punctuated by high-contrast black and a deep, authoritative blue.

### The "No-Line" Rule
**Strict Mandate:** Designers are prohibited from using 1px solid borders to define sections. Boundaries must be established solely through background color shifts. For example, a `surface-container-low` component should sit on a `surface` background to define its edge. 

### Surface Hierarchy (Material Tiering)
Instead of a flat grid, treat the UI as a series of physical layers.
- **Surface (Base):** `#fff8f2` (The foundation).
- **Surface-Container-Lowest:** `#ffffff` (Elevated interaction points).
- **Surface-Container-Low:** `#fff2de` (Subtle inset areas).
- **Surface-Container-Highest:** `#f3e0c0` (Deeply recessed or highly emphasized technical zones).

### The "Glass & Gradient" Rule
To prevent the UI from feeling static, use **Glassmorphism** for floating overlays (e.g., Command Palettes, Modals). Use semi-transparent surface colors with a `20px` backdrop blur. For primary CTAs, use a subtle linear gradient from `primary` (#00327d) to `primary-container` (#0047ab) at a 135-degree angle to provide "visual soul."

---

## 3. Typography: The Inter Technical Scale

We use **Inter** exclusively. The hierarchy is designed to mimic technical documentation where information density is high but legibility is paramount.

| Level | Size | Weight | Role |
| :--- | :--- | :--- | :--- |
| **Display-LG** | 3.5rem | 700 | Primary KPIs or hero impact statements. |
| **Headline-SM** | 1.5rem | 600 | Section headers; should feel like etched labels. |
| **Title-SM** | 1.0rem | 500 | Card titles and primary navigation items. |
| **Body-MD** | 0.875rem | 400 | The primary reading grade; high-contrast black. |
| **Label-SM** | 0.6875rem | 700 | Monospace-style data labels (all caps recommended). |

**Editorial Note:** Use `label-sm` for metadata and status indicators. This small, bold, all-caps treatment provides the "cockpit instrument" feel when paired with the high-contrast `on-surface` (#231a06) color.

---

## 4. Elevation & Depth: Tonal Layering

Traditional shadows are too "software-generic." This system uses physics-based light and depth.

*   **The Layering Principle:** Depth is achieved by stacking. Place a `surface-container-lowest` card on a `surface-dim` background. The shift in "creaminess" provides the edge, not a line.
*   **Ambient Shadows:** If an element must float (e.g., a dropdown), use an ultra-diffused shadow: `box-shadow: 0 12px 40px rgba(35, 26, 6, 0.08)`. Notice the shadow is tinted with the `on-surface` color, not pure black.
*   **The "Ghost Border" Fallback:** If accessibility requires a stroke, use `outline-variant` (#c3c6d5) at **15% opacity**. It should be felt, not seen.

---

## 5. Components & Interaction Patterns

### Buttons (The Control Switches)
*   **Primary:** Background: `primary` (#00327d). Text: `on-primary` (#ffffff). Corner Radius: `ROUND_TWELVE` (0.75rem). Use a 1px inner glow (top only) for a physical "keycap" feel.
*   **Secondary:** Background: `surface-container-highest` (#f3e0c0). Text: `on-surface`. No border.
*   **Tertiary:** No background. `primary` text. Use for low-priority actions in dense data tables.

### Data Inputs & Fields
*   **Field Style:** Use `surface-container-low` (#fff2de) as the fill. 
*   **Active State:** Transitions to a `primary` (#00327d) "Ghost Border" (20% opacity) and a high-contrast cursor.
*   **Forbid Dividers:** In forms or lists, never use a horizontal line. Use `spacing-4` (0.9rem) or a subtle background shift between groups.

### Functional "Instrument" Chips
*   Used for status (e.g., ACTIVE, STANDBY). 
*   **Style:** `label-sm` typography, `secondary-container` background, and `primary` text for active states.

### Status Indicators
*   **Error:** `error` (#ba1a1a).
*   **Deep Ocean Accent:** Use `primary-container` (#0047ab) for all "Active" or "In-Progress" states. This blue must feel like a glowing LED on a physical dash.

---

## 6. Do’s and Don’ts

### Do:
*   **DO** use asymmetric layouts. Align text to the left but place data values in staggered positions to mimic a physical manual.
*   **DO** use `ROUND_TWELVE` (0.75rem) for all containers and buttons to maintain the "high-end physical product" feel.
*   **DO** use `surface-dim` (#ead8b8) for background "cutouts" where secondary information lives.

### Don’t:
*   **DON'T** use 1px solid black borders. It destroys the premium, tonal aesthetic.
*   **DON'T** use standard grey shadows. Shadows must always be low-opacity and tinted with the background's warmth.
*   **DON'T** use pure white (#ffffff) for large background areas. It creates eye strain and breaks the "Almond Cream" instrument feel. Reserve pure white only for the highest "raised" interactive surfaces.

---

## 7. Signature Detail: The Technical Inset
When nesting content (like a code snippet or a data read-out), use `surface-container-highest` (#f3e0c0) with a `0.1rem` (spacing-0.5) inner shadow. This creates a "recessed" look, making the screen feel like a physical panel where instruments have been mounted into the dashboard.