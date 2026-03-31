# NullSignal Design Principles

Think of this as the intersection of Linear's interface, a flight instrument panel, and a terminal.
Not cyberpunk, not military, not sci-fi. Just extremely precise, purposeful, and dark.

### Typography
- One font: **Inter**.
- Two weights only: **Regular** for body, **Semibold** for labels and values.
- No decorative type.

### Whitespace
- Maximum whitespace. **Black background (#000000)**.
- Every element floats. Generous padding, wide margins.
- Empty black space is not wasted—it reinforces the "void" concept.

### Palette & Interactive States
- **Normal (Almond Cream #E5D3B3 on Black)**: Used for all standard labels, text, and primary non-emergency UI.
- **Active/Mesh (Deep Ocean #0047AB)**: Used for mesh network status, active connections, and non-SOS primary actions.
- **Emergency (Crimson Carrot #E34234)**: Reserved **EXCLUSIVELY** for SOS-related elements. The moment it appears, it should be the only color on screen.

### Elements
- No decorative elements (illustrations, patterns, gradients, icons for decoration).
- Functional icons only—minimal use.
- **Rounded but not bubbly**: 12px border radius on cards, 8px on smaller elements.
- Every pixel must earn its place.