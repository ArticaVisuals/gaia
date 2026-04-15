Priorities, in order:
1. Native-feeling iOS UX
2. Fidelity to the intended design system
3. Clean, maintainable SwiftUI architecture
4. Performance and accessibility
5. Minimal, well-scoped code changes

Treat:
- Figma as the main source of visual truth
- HTML prototypes as reference for structure, interaction intent, and motion
- Existing app codebase as the source of truth for architecture and patterns

Do not translate HTML/CSS literally into SwiftUI unless explicitly asked.

---

## Workflow rules
- For SwiftUI implementation, review, refactoring, state management, view composition, and performance-sensitive UI work, use the `swiftui-expert` skill.
- Start by inspecting existing nearby files, shared components, tokens, routing, and state patterns before creating new code.
- For any Figma-driven task, default to Figma MCP reads for exact measurements, spacing, typography, radii, shadows, and asset references before relying on screenshots.
- If a full-frame MCP read is too large or hits token limits, split the audit into smaller node-level MCP reads instead of falling back to screenshot-only guessing.
- For larger or ambiguous UI tasks, make a short plan first before editing files.
- Prefer the smallest set of focused edits over broad rewrites.
- Reuse existing components before creating new ones.
- Do not introduce new dependencies unless clearly justified and requested.

---

## Design translation rules
When implementing from Figma:
- Match layout, spacing rhythm, hierarchy, typography scale, corner radius, and interaction intent as closely as practical.
- Treat Figma MCP metadata and design-context output as the measurement source of truth for custom UI.
- Use screenshots as a secondary visual QA aid, not as the primary source for extracting specs when MCP measurements are available.
- Prefer tokenized colors, spacing, typography, and radius values over hardcoded magic numbers.
- If an exact design token is missing, infer from surrounding patterns and existing design system primitives.
- If the mockup conflicts with platform conventions, preserve a native iOS feel and call out the tradeoff.
- Preserve safe areas and ergonomic touch targets.
- Support light mode and dark mode unless the product explicitly excludes one.
- Support Dynamic Type unless the screen is clearly a fixed-format marketing composition.

When using an HTML prototype:
- Use it to understand behavior, state changes, hierarchy, timing, and edge cases.
- Do not mirror DOM structure or CSS implementation details unless there is a strong reason.
- Convert web interactions into native SwiftUI patterns.

---

## SwiftUI implementation standards
- Prefer modern SwiftUI APIs and patterns.
- Keep views small, composable, and readable.
- Prefer extracting repeated UI into reusable subviews.
- Follow the app's existing navigation, state, dependency injection, and async patterns before introducing new ones.
- Avoid UIKit wrappers unless SwiftUI cannot reasonably achieve the required result.
- Prefer system-native behavior for:
  - navigation
  - sheets
  - alerts
  - focus
  - scrolling
  - keyboard management
  - pull-to-refresh
  - haptics
  - text input
- Make loading, empty, error, and success states explicit.
- Avoid massive single-file views when a screen can be split into logical sections.

---

## State management rules
- Use the simplest state model that fits the feature.
- Prefer local state for local concerns.
- Lift state only when multiple child views genuinely need shared ownership.
- Avoid duplicating state across parent and child views.
- Derive display state from source-of-truth state whenever practical.
- Keep business logic out of leaf UI views when it starts to grow.
- Prefer predictable one-way data flow.

---

## Performance rules
- Avoid unnecessary view recomputation.
- Be careful with large lists, expensive modifiers, nested geometry readers, and over-complex view trees.
- Use lazy containers when rendering larger collections.
- Prefer lightweight composition over deeply nested conditional wrappers.
- Load images and async content in a way that avoids visible jank.
- Optimize only where needed, but do not ignore obviously expensive patterns.

---

## Accessibility and quality bar
Every shipped UI change should aim to:
- have clear tap targets
- have readable contrast
- work with VoiceOver labels where relevant
- behave well with Dynamic Type
- respect safe areas
- avoid clipped text in common states
- avoid layout jumps during loading/state changes

If a design choice harms accessibility, preserve the spirit of the design while improving usability.

---

## Liquid Glass / newer visual effects
The `swiftui-expert` skill includes guidance for Liquid Glass and newer SwiftUI styling patterns.

Rules:
- Do not introduce Liquid Glass or similar high-stylization materials unless the design explicitly calls for them.
- If used, apply them intentionally and sparingly.
- Prefer clarity, legibility, and hierarchy over novelty.
- Keep compatibility with the project's deployment target and visual system.

---

## File and code editing behavior
- Read before writing.
- Preserve surrounding style and naming conventions.
- Do not rename files, types, or public interfaces unless necessary.
- Do not make unrelated cleanup changes in the same pass unless they are tiny and clearly beneficial.
- When refactoring, preserve behavior unless the task explicitly asks for behavior changes.
- Leave concise comments only where logic is non-obvious. Do not add decorative comments.

---

## Verification
Before considering a task complete:
- run the most targeted build, test, or preview validation available
- verify Figma-driven UI against MCP-derived measurements first, then use screenshots/device captures as a secondary sanity check
- verify the touched screen compiles
- verify obvious states if the screen has multiple states
- check for warnings or errors introduced by the change
- summarize what was changed and what was verified

Preferred verification order:
1. Targeted SwiftUI preview sanity check
2. Targeted build for the touched feature/module
3. Relevant tests, if they exist
4. Full app build only when necessary

Simulator default for this repo:
- Prefer `iPhone 16` for simulator testing when it is available, since it matches the user's physical device.
- If `iPhone 16` is unavailable on the active Xcode install, fall back directly to `iPhone 17`.
- If `iPhone 16` support exists in the current Xcode runtime/device types but no device instance has been created yet, create the simulator instead of assuming the Mac cannot run it.
- If exact simulator availability is unclear, inspect the local simulator list instead of guessing.

If exact commands are unclear, inspect the repo first instead of guessing.

Suggested commands if the repo uses standard Xcode setup:
- `xcodebuild -scheme [APP_SCHEME] -destination 'platform=iOS Simulator,name=iPhone 16' build`
- `xcodebuild test -scheme [APP_SCHEME] -destination 'platform=iOS Simulator,name=iPhone 16'`
- If `iPhone 16` is not available, use `-destination 'platform=iOS Simulator,name=iPhone 17'` instead.

Replace `[APP_SCHEME]` with the real scheme name for this project.

---

## Definition of done
A task is done when:
- the implementation matches the intended design closely
- the solution feels native to iOS
- the code fits existing architecture and conventions
- the changed UI compiles
- major states are accounted for
- accessibility and responsiveness were considered
- the final response includes any notable tradeoffs or follow-up items

---

## Prompting defaults for this repo
When given a UI task, assume the user wants:
- production-minded SwiftUI
- good structure, not just visual mimicry
- native behavior over web-style hacks
- reusable components where appropriate
- concise explanation of decisions and tradeoffs
