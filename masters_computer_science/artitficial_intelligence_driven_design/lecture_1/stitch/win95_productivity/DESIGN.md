# Design System Strategy: The Industrial Logic

## 1. Overview & Creative North Star
**Creative North Star: "The Mechanical Architect"**

This design system rejects the ephemeral, "airy" trends of modern SaaS in favor of the rigid, structural certainty of 1997 industrial computing. We are not just building an interface; we are constructing a digital machine. The aesthetic is driven by **Extreme Functionality**—where every pixel must justify its existence through utility. 

We break the "modern template" look by utilizing a high-density, high-contrast information hierarchy. While modern design hides complexity behind "breathing room," this system celebrates complexity through intentional nesting and mechanical depth. We utilize the 2px bevel not as a decorative flourish, but as a tactile signifier of "the clickable." If it is raised (outset), it is a lever; if it is sunken (inset), it is a vessel for data.

## 2. Colors
Our palette is rooted in the "Standard Silver" era, where color was used as a structural tool rather than an emotional one.

- **Background & Surface (`#C0C0C0`):** The universal substrate. This color represents the physical "chassis" of the application.
- **The "No-Line" Rule:** 1px solid flat borders are strictly prohibited for layout sectioning. Boundaries must be defined by the **3D Bevel Logic**. To separate a sidebar from a main content area, use a 2px vertical "Outset" ridge or an "Inset" trough. 
- **Surface Hierarchy & Nesting:** 
    - **Surface (`#faf9f9`):** Used for the primary workspace area to ensure maximum text legibility.
    - **Surface-Container-Low (`#f3f4f4`):** Used for inactive background tabs or status bars.
    - **Surface-Container-Highest (`#dfe3e4`):** Reserved for header bars and modal titles.
- **The "Mechanical Texture" Rule:** To provide "soul," use subtle linear gradients on primary buttons, transitioning from `primary` (#4b53bc) to `primary_dim` (#3f46af) to mimic the slight light-catch of a plastic physical key.
- **Strict Contrast:** All primary text must be `on_surface` (#2e3334) or absolute `#000000` to ensure industrial-grade readability.

## 3. Typography
We utilize the "Workhorse Sans-Serif" philosophy. The typography is built to be scanned, not just read.

- **Display & Headlines:** Using **WorkSans** (a modern interpretation of the utilitarian Tahoma/Verdana spirit). Headlines are set with tight letter-spacing and zero kerning adjustments, emphasizing the "system font" aesthetic.
- **Body & Labels:** All body text must be high-contrast. **Body-md** (0.875rem) is the default for task descriptions.
- **The Link Protocol:** Links must utilize `tertiary` (#0000e1). They remain plain text until hovered, at which point they must trigger a `text-decoration: underline`. This creates a reactive, "live-wire" feel.

## 4. Elevation & Depth
In this system, "Elevation" is a literal mechanical state, not a visual suggestion.

- **The Layering Principle:** We achieve depth through **3D Beveling** (Inset/Outset).
    - **Outset (Raised):** `border-top: 2px solid #ffffff; border-left: 2px solid #ffffff; border-right: 2px solid #808080; border-bottom: 2px solid #808080;` Used for buttons, tabs, and draggable headers.
    - **Inset (Sunken):** `border-top: 2px solid #808080; border-left: 2px solid #808080; border-right: 2px solid #ffffff; border-bottom: 2px solid #ffffff;` Used for input fields, checkbox wells, and the main task list container.
- **Ambient Shadows:** Prohibited. Shadows are replaced by the high-contrast light/dark edges of the bevels to define light source (top-left).
- **The "Ghost Border" Fallback:** In extreme high-density tables where 2px bevels would consume too much real estate, use `outline_variant` at 20% opacity to create a "grid-line" that guides the eye without breaking the mechanical flow.

## 5. Components

### Buttons (Mechanical Triggers)
- **Primary:** `#4b53bc` background, white text, 2px outset bevel. On click (active state), the bevel flips to "inset" and the text shifts 1px down and to the right to simulate physical depression.
- **Secondary:** `#C0C0C0` background, black text, 2px outset bevel.

### Input Fields (Data Vessels)
- **Styling:** 2px **Inset** bevel with a white background. Padding should be tight (Scale 1.5 - 0.225rem) to maintain high information density.
- **Focus State:** A 1px dotted black line inside the bevel to indicate keyboard focus.

### Task Cards & Lists
- **The Container:** Forbid the use of soft dividers. Every task item sits within a high-density list.
- **Separation:** Use a "Groove" (a 2px inset line) between list items.
- **Density:** Use the Spacing Scale `2` (0.3rem) for vertical cell padding. The goal is to fit as many tasks on screen as possible.

### Checkboxes
- **Unchecked:** A 2px Inset square with a white background.
- **Checked:** A high-contrast `#000000` "X" or checkmark rendered in a jagged, non-aliased style.

### Tooltips
- **Styling:** Absolute square corners (0px), `#ffffca` (pale yellow) background, 1px solid `#000000` border. No animation; instant appearance.

## 6. Do's and Don'ts

### Do:
- **Use "Gray-out" for Disabled States:** Use a checkered dithering pattern or a flat `#808080` for disabled text.
- **Embrace Information Density:** If there is white space, fill it with data, metadata, or structural dividers.
- **Align to the Pixel:** Ensure all bevels and text baseline alignments are snapped to a strict pixel grid.

### Don't:
- **No Rounded Corners:** Any `border-radius` above `0px` is a violation of the system's industrial integrity.
- **No Transitions:** Interactive states (hover/active) should be instantaneous. Fluidity is seen as a lack of mechanical precision.
- **No Soft Shadows:** Depth must be communicated through the 2px bevel logic only.