# Remediation Playbook

## Typography Violations

Problem patterns:
- `.font(.system(...))`
- `.font(.custom(...))` outside token plumbing
- ad-hoc `.tracking(...)` / `.lineSpacing(...)` without `gaiaFont`

Preferred fixes:
- Use `.gaiaFont(<GaiaTextStyle>)` for screen text.
- Use `GaiaTypography.<token>` only for justified low-level custom composition.

## Color Violations

Problem patterns:
- `Color(red:..., green:..., blue:...)`
- `Color(hex:...)`
- `#RRGGBB` literals in SwiftUI files

Preferred fixes:
- Replace with `GaiaColor.<token>`.
- If token missing, propose a new token and pause for user approval.

## Spacing And Radius Violations

Problem patterns:
- `.padding(17)` / `spacing: 14`
- `.cornerRadius(13)` or `RoundedRectangle(cornerRadius: 13)`

Preferred fixes:
- Replace with `GaiaSpacing.<token>` and `GaiaRadius.<token>`.
- If value is not represented by current scale, treat as design-system decision.

## Component Mapping Decisions

Trigger:
- New feature view introduces a DS-like pattern (Card/Pill/Badge/Button/Row/Header/etc.) with no obvious existing component mapping.

Required user checkpoint:
```text
I found unmatched UI pieces that are not clearly mapped to the current design system.
Should we:
1. Create a new component/token?
2. Map this to an existing component/token?
```

After user selects:
- Option 1: create scoped component/token and document usage.
- Option 2: replace with existing component and align styling/interaction.
