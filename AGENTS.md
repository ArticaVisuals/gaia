# Additional Workflow Rules

- Never infer or invent design measurements when aligning UI to Figma. Use exact values from Figma whenever they are available.
- If an exact Figma measurement is unavailable, state that explicitly and do not claim pixel-perfect parity.
- For stateful headers or animated surfaces, prefer measurements from the full-screen Figma frame over an isolated component frame when they differ.
- For multi-state or animated UI, it is acceptable to add internal-only QA flags that freeze intermediate states for screenshot comparison, as long as they do not change normal product behavior.
- When matching Figma typography inside fixed text boxes, preserve the Figma container alignment first and avoid synthetic baseline offsets unless they are directly justified by measured Figma output.
- Do not treat a task as complete after code changes or a successful build alone. Always perform a visual parity pass against the relevant Figma node or frame using a live SwiftUI run, preview, or screenshot comparison, and iterate until mismatches are fixed or explicitly called out as blockers.
- If a mismatch comes from a shared asset, icon, style primitive, or reusable component, update the shared source rather than only patching the local screen so all linked surfaces stay aligned with Figma.
- If a visual comparison could not be performed, say that explicitly and do not claim the UI fully matches Figma.
- Before calling a visual pass complete, verify live or screenshot states for text clipping, icon overlap, and duplicate image treatments in every affected state.
