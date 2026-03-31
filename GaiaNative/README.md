# GaiaNative

This folder is the native SwiftUI scaffold for Gaia.

## What this is

This is a source-first SwiftUI app structure that mirrors the migration blueprint in [SWIFTUI_MIGRATION_BLUEPRINT.md](/Users/micahhoang/My%20Drive/CD5%20VXD/Gaia-Prototype/SWIFTUI_MIGRATION_BLUEPRINT.md).

It includes:

1. app shell
2. theme system
3. editable content JSON
4. shared component folders
5. feature folders for the core Gaia flows

## Best way to use this

1. Open [GaiaNative.xcodeproj](/Users/micahhoang/My%20Drive/CD5%20VXD/Gaia-Prototype/GaiaNative.xcodeproj) in Xcode
2. Select the `GaiaNative` scheme
3. Run it on an iPhone simulator like `iPhone 17 Pro`
4. Use the files in `GaiaNative/Content` for copy and seed data updates
5. Use the files in `GaiaNative/Theme` and `GaiaNative/Components` for design-system adjustments

## Suggested first native build target

After the shell is in Xcode, build the `Find Details` Learn screen first. It is the best quality benchmark for the rest of Gaia.

## Current status

1. `GaiaNative.xcodeproj` has been generated at the repo root
2. The project builds successfully in the iOS simulator
3. `content-map.html` remains untouched and is still only flow reference material

## Optional next Xcode step

If you want to run on a physical iPhone later, sign into your Apple ID in Xcode and pick your personal team under Signing & Capabilities.
