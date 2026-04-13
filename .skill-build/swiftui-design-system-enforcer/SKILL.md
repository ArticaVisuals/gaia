---
name: swiftui-design-system-enforcer
description: Enforce Gaia design-system fidelity for SwiftUI UI work in Gaia-Prototype. Use after any visual SwiftUI change, design implementation, or UI refactor to audit typography, color, spacing/radius, and component usage against current Gaia tokens/components before continuing or committing.
---

# SwiftUI Design System Enforcer

## Quick Start

1. Run the audit after every SwiftUI UI edit:
   ```bash
   python3 "${CODEX_HOME:-$HOME/.codex}/skills/swiftui-design-system-enforcer/scripts/audit_swiftui_design_system.py" \
     --repo "/Users/micahhoang/My Drive/CD5 VXD/Gaia-Prototype"
   ```
2. Audit specific files when needed:
   ```bash
   python3 "${CODEX_HOME:-$HOME/.codex}/skills/swiftui-design-system-enforcer/scripts/audit_swiftui_design_system.py" \
     --repo "/Users/micahhoang/My Drive/CD5 VXD/Gaia-Prototype" \
     --files GaiaNative/Features/Explore/ExploreScreen.swift
   ```
3. Stop when the script reports `BLOCKER` or `DECISION`.
4. Ask the user for a decision before proceeding when `DECISION` findings exist.

## Enforce Source-Of-Truth Priority

1. Treat Figma as visual truth.
2. Treat HTML prototypes as interaction reference only.
3. Treat the existing SwiftUI codebase as architecture truth.
4. Preserve native iOS behavior when design details conflict with platform conventions.

## Audit Workflow

1. Gather target files.
Use `--files` when the changed surface is known. Otherwise let the script discover changed Swift files from git diff.
2. Run `scripts/audit_swiftui_design_system.py`.
3. Triage findings:
`BLOCKER`: non-token typography/color usage that breaks design-system rules.
`DECISION`: unmatched spacing/radius values or potential net-new component mapping.
`WARN`: non-blocking but should be normalized to design-system primitives.
4. Resolve all `BLOCKER` findings.
5. Pause on `DECISION` findings and ask the user what to do.
6. Re-run the audit until only acceptable warnings remain.

## Required User Checkpoint

When the audit reports `DECISION`, ask this exact style of question:

```text
I found unmatched UI pieces that are not clearly mapped to the current design system:
- <file>:<line> <summary>

How do you want to proceed?
1. Create a new design-system component/token for this pattern.
2. Link this pattern to an existing component/token (I can suggest the closest match).
```

Do not continue implementation past a `DECISION` without user direction.

## What The Script Checks

1. Typography usage against `GaiaTextStyle` and `GaiaTypography`.
2. Color usage against `GaiaColor` and direct literal color usage.
3. Spacing/radius literals vs `GaiaSpacing` and `GaiaRadius` token values.
4. Potential net-new component definitions outside the known component catalog.

## References

1. Read `references/design-system-sources.md` for canonical source files and extraction patterns.
2. Read `references/remediation-playbook.md` for standard fix patterns and decision framing.
