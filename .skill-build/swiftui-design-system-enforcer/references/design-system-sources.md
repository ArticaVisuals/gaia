# Design System Sources

## Token Sources

- `GaiaNative/Theme/GaiaColor.swift`
- `GaiaNative/Theme/GaiaTypography.swift`
- `GaiaNative/Theme/GaiaSpacing.swift`
- `GaiaNative/Theme/GaiaRadius.swift`
- `GaiaNative/Theme/GaiaShadow.swift`
- `GaiaNative/Theme/GaiaMaterial.swift`
- `GaiaNative/Theme/GaiaMotion.swift`

## Component Sources

- `GaiaNative/Components/**/*.swift`

## External Design References

- Figma files/nodes used for the active task (visual truth)
- `design-system-preview.html` and `design-tokens.css` (reference only)
- `tokens.json` (reference token dump)

## Fast Commands

List token files:
```bash
rg --files GaiaNative/Theme
```

List shared components:
```bash
rg --files GaiaNative/Components
```

Inspect typography APIs:
```bash
rg -n "enum GaiaTextStyle|enum GaiaTypography|func gaiaFont" GaiaNative/Theme/GaiaTypography.swift
```

Inspect color tokens:
```bash
rg -n "static let" GaiaNative/Theme/GaiaColor.swift
```

Inspect spacing/radius tokens:
```bash
rg -n "static let" GaiaNative/Theme/GaiaSpacing.swift GaiaNative/Theme/GaiaRadius.swift
```

## Notes

- Prefer tokenized usage (`GaiaColor`, `GaiaSpacing`, `GaiaRadius`, `gaiaFont`).
- Allow exceptions only when a mismatch is deliberate and user-approved.
- Treat any unmatched pattern as a decision gate, not an automatic assumption.
