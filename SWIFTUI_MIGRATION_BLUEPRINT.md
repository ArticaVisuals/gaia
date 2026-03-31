# Gaia SwiftUI Migration Blueprint

This document is the working blueprint for moving the current Gaia HTML prototype into a native SwiftUI app while keeping the design workflow friendly for a non-developer.

## Recommendation

Use this stack:

1. `Figma` for component and screen design
2. `SwiftUI + Xcode` for the real app
3. `VS Code` only for simple content editing if desired
4. `JSON` and optional `Markdown` files for editable content

Do not use Warp to manage content. Warp is useful as a terminal, but not as the main place to manage design or app copy.

## What This Repo Already Has

Current prototype reference:

1. [index.html](/Users/micahhoang/My%20Drive/CD5%20VXD/Gaia-Prototype/index.html)
2. [find-details.html](/Users/micahhoang/My%20Drive/CD5%20VXD/Gaia-Prototype/find-details.html)
3. [observe.html](/Users/micahhoang/My%20Drive/CD5%20VXD/Gaia-Prototype/observe.html)
4. [activity.html](/Users/micahhoang/My%20Drive/CD5%20VXD/Gaia-Prototype/activity.html)
5. [story-cards.html](/Users/micahhoang/My%20Drive/CD5%20VXD/Gaia-Prototype/story-cards.html)
6. [design-tokens.css](/Users/micahhoang/My%20Drive/CD5%20VXD/Gaia-Prototype/design-tokens.css)

Existing mobile stepping stone:

1. [expo-preview/App.tsx](/Users/micahhoang/My%20Drive/CD5%20VXD/Gaia-Prototype/expo-preview/App.tsx)
2. [expo-preview/package.json](/Users/micahhoang/My%20Drive/CD5%20VXD/Gaia-Prototype/expo-preview/package.json)

The Expo preview is useful as a temporary mobile wrapper, but it should not be the long-term implementation path if the goal is a premium native Apple look and feel.

## Core Migration Principles

1. Keep the current HTML screens as visual reference only.
2. Move all reusable visual decisions into a native design system first.
3. Keep user-editable content outside the SwiftUI views.
4. Rebuild shared interactions before rebuilding every screen.
5. Do visual parity passes screen by screen, not all at once.
6. Save the motion pass for after the layouts are stable.

## Recommended Xcode App Structure

Create a new Xcode project named `GaiaNative`.

Suggested folder structure:

```text
GaiaNative/
  GaiaNativeApp.swift

  App/
    AppRootView.swift
    AppRouter.swift
    AppState.swift
    DeepLink.swift

  Theme/
    GaiaColor.swift
    GaiaTypography.swift
    GaiaSpacing.swift
    GaiaRadius.swift
    GaiaShadow.swift
    GaiaMaterial.swift
    GaiaMotion.swift

  Models/
    Species.swift
    Observation.swift
    ObservationCluster.swift
    StoryCard.swift
    Profile.swift
    ImpactStats.swift
    ActivityEvent.swift
    CommunityPost.swift
    AppCopy.swift

  Content/
    app-copy.json
    species.json
    stories.json
    profile.json
    activity.json
    community.json
    map-observations.json

  Services/
    ContentStore.swift
    AssetCatalog.swift
    MapDataService.swift
    CameraService.swift
    HapticsService.swift
    AnimationCoordinator.swift

  Components/
    Navigation/
      BottomNavBar.swift
      BottomNavItem.swift
      DraggableTabSwitch.swift
      ToolbarGlassButton.swift
      ToolbarGlassPill.swift

    Glass/
      GaiaMaterialBackground.swift
      GlassCircleButton.swift
      GlassPillButton.swift
      GlassCardBackground.swift

    Cards/
      FindCard.swift
      LearnSpeciesCard.swift
      StatsCard.swift
      StoryPreviewCard.swift
      ImpactSummaryCard.swift
      ActivityCard.swift
      ProfileHeaderCard.swift

    Map/
      ExploreMapView.swift
      MapAnnotationPhotoPin.swift
      MapAnnotationClusterPin.swift
      ExpandMapButton.swift
      MapOverlayProfileCard.swift

    Media/
      HeroCarousel.swift
      ProgressiveBlurImage.swift
      GalleryRail.swift
      SwipeableStoryDeck.swift

    Common/
      GaiaAsyncImage.swift
      GaiaBadge.swift
      GaiaPill.swift
      GaiaSectionHeader.swift
      GaiaDivider.swift
      LoadingView.swift

  Features/
    Explore/
      ExploreScreen.swift
      ExploreViewModel.swift
      ExploreBottomSheet.swift

    FindDetails/
      FindDetailsScreen.swift
      FindDetailsViewModel.swift
      FindTabView.swift
      ActivityTabView.swift
      LearnTabView.swift
      LearnMapExpandedScreen.swift

    Observe/
      ObserveCameraScreen.swift
      ObserveLoadingScreen.swift
      ObserveDetailsScreen.swift
      ObserveShareScreen.swift
      ObserveViewModel.swift

    Profile/
      ProfileScreen.swift
      ProfileImpactTab.swift
      ProfileLogTab.swift
      ProfileCommunityTab.swift
      ImpactMapExpandedScreen.swift
      ProfileViewModel.swift

    Activity/
      ActivityScreen.swift
      ActivityViewModel.swift

    Stories/
      StoryDeckScreen.swift
      StoryDeckViewModel.swift

  PreviewData/
    PreviewSpecies.swift
    PreviewProfile.swift
    PreviewStories.swift
    PreviewActivity.swift

  Resources/
    Assets.xcassets
    Fonts/
    Localizable.xcstrings
```

## What Goes In Each Layer

### `Theme/`

This is the native version of [design-tokens.css](/Users/micahhoang/My%20Drive/CD5%20VXD/Gaia-Prototype/design-tokens.css).

Put these here:

1. all colors
2. typography roles
3. spacing
4. radii
5. shadow tokens
6. material recipes
7. animation timing curves

This should be the first thing built.

### `Content/`

This is the layer you can edit most safely.

Put these here:

1. screen copy
2. species metadata
3. story summaries
4. profile numbers
5. activity feed content
6. community content
7. map seed data

Goal: if you want to change text, stats, labels, story summaries, or map pin data, you should not need to touch SwiftUI view code.

### `Components/`

This is the reusable design system.

Anything used in more than one place should live here:

1. glass toolbar buttons
2. bottom navigation
3. draggable tab switch
4. cards
5. map overlays
6. hero carousels
7. progressive blur image treatments

### `Features/`

This is where screens live.

Each feature gets:

1. screen view
2. supporting subviews
3. view model
4. navigation actions

## Content Model for a Non-Developer Workflow

The content layer should be simple and forgiving.

Recommended editable files:

1. `Content/app-copy.json`
2. `Content/species.json`
3. `Content/stories.json`
4. `Content/profile.json`
5. `Content/activity.json`
6. `Content/community.json`

Recommended JSON shape:

```json
{
  "species": [
    {
      "id": "coast-live-oak",
      "commonName": "Coast Live Oak",
      "scientificName": "Quercus agrifolia",
      "category": "Plant",
      "status": "LC",
      "findCountLabel": "56k",
      "summary": "An iconic, majestic tree that serves as a cornerstone for wildlife and the surrounding ecosystem.",
      "storyIds": ["story-keystone"],
      "galleryAssetNames": [
        "coast-live-oak-hero",
        "coast-live-oak-gallery-1",
        "coast-live-oak-gallery-2"
      ],
      "mapCoordinate": {
        "latitude": 34.1368,
        "longitude": -118.1256
      }
    }
  ]
}
```

For longer editorial content, use Markdown:

1. `Content/Stories/story-keystone.md`
2. `Content/Species/coast-live-oak.md`

That gives you clean, readable content editing without touching layout code.

## Recommended Migration Order

Build in this sequence.

### Phase 1: App Shell

Goal: establish the native foundation.

Build:

1. native design tokens
2. glass toolbar button
3. toolbar pill
4. bottom nav
5. draggable tab switch
6. shared routing shell

Output:

1. `AppRootView`
2. `BottomNavBar`
3. `ToolbarGlassButton`
4. `ToolbarGlassPill`
5. `DraggableTabSwitch`

### Phase 2: Find Details

This is the best visual benchmark in the current prototype.

Build:

1. hero carousel
2. Find / Activity / Learn tab switch
3. Learn card stack
4. stats card
5. map card + expand state
6. story card

Output:

1. `FindDetailsScreen`
2. `LearnTabView`
3. `LearnMapExpandedScreen`

### Phase 3: Explore

Build:

1. full-screen map
2. real coordinates for photo pins
3. cluster pins
4. bottom sheet
5. routing into Find Details

Output:

1. `ExploreScreen`
2. `ExploreMapView`
3. `MapAnnotationPhotoPin`
4. `MapAnnotationClusterPin`

### Phase 4: Story Experience

Build:

1. swipeable story deck
2. layered card depth
3. progressive blur
4. story header

Output:

1. `StoryDeckScreen`
2. `SwipeableStoryDeck`

### Phase 5: Observe Flow

Build:

1. live camera start state
2. shutter progression
3. loading stack
4. details confirm screen
5. share state

Output:

1. `ObserveCameraScreen`
2. `ObserveDetailsScreen`
3. `ObserveShareScreen`

### Phase 6: Profile

Build:

1. profile shell
2. Impact tab
3. Log tab
4. Community tab
5. expanded map state

Output:

1. `ProfileScreen`
2. `ProfileImpactTab`
3. `ProfileLogTab`
4. `ProfileCommunityTab`

### Phase 7: Activity

Build:

1. activity feed
2. nav transitions
3. state handoff polish

Output:

1. `ActivityScreen`

### Phase 8: Motion and Polish

Do this only after layouts are stable.

Add:

1. bottom nav drag interpolation
2. tab switch interpolation
3. hero image transitions
4. card swipe springs
5. haptics
6. map expand transitions
7. toolbar material tuning

## Component Inventory to Rebuild First

These are the most important shared pieces from the current prototype:

1. glass back button
2. glass action pill
3. draggable tab switch
4. bottom nav with draggable pill
5. progressive blur hero
6. story preview card
7. map expand button
8. explore map photo pin
9. explore map cluster pin
10. profile impact map card

If these are correct, the app will start to feel cohesive very quickly.

## Microinteraction Strategy

Keep motion intentional and sparse.

Use SwiftUI for:

1. `matchedGeometryEffect` for tab indicators, cards, and nav pill transitions
2. spring animations for drag release and sheet movement
3. `PhaseAnimator` or keyframe animation for subtle state choreography
4. haptics for saves, tab commits, and shutter actions
5. scroll-based transitions only where they add clarity

Avoid:

1. animation on every element
2. long easing chains
3. multiple competing gesture systems on one screen

The right feel for Gaia is calm, smooth, and premium, not hyperactive.

## What You Edit vs What I Edit

### You Edit

These should be safe for you:

1. Figma components and frames
2. copy in `Content/*.json`
3. longer editorial text in `Content/**/*.md`
4. image choices and image replacement requests
5. map pin data in `map-observations.json`
6. labels, counts, and story summaries

### I Edit

These should stay on my side:

1. SwiftUI view code
2. navigation logic
3. gesture logic
4. animation tuning
5. materials and visual effects
6. map integration
7. camera integration
8. reusable components
9. asset slicing and icon rendering details

### Shared Review Loop

Best workflow:

1. you update Figma or content
2. I sync the SwiftUI implementation
3. we review on device and in Xcode previews
4. we tune motion after the layout is approved

## Best Tool Setup for You

### Use `Xcode` for

1. viewing the real app
2. running the Simulator
3. checking SwiftUI previews
4. approving motion and polish

### Use `VS Code` for

1. editing JSON content
2. editing Markdown stories
3. searching copy
4. lightweight repo browsing

### Use `Figma` for

1. component refinement
2. icon updates
3. spacing changes
4. visual QA reference

### Use `Warp` for

1. running commands only

It should not be your primary content or design tool.

## Simplest Non-Developer Workflow

If we want this to stay easy for you, I recommend:

1. one canonical Figma file
2. one canonical SwiftUI app
3. one content folder with human-readable JSON and Markdown
4. no custom CMS until the product direction is stable

That gives you:

1. beautiful native visuals
2. room for microinteractions
3. content that you can still manage
4. a workflow that does not ask you to become a developer

## Definition of Done for the Migration

The migration is successful when:

1. the app no longer depends on the HTML prototype for core screens
2. Find Details, Explore, Observe, Profile, Activity, and Stories all exist in SwiftUI
3. all major text content can be changed without editing SwiftUI views
4. shared components come from one native design system
5. iPhone interaction quality is clearly better than the HTML prototype

## Immediate Next Build Step

Start with Phase 1 and build these first:

1. `GaiaColor`
2. `GaiaTypography`
3. `GaiaMaterial`
4. `ToolbarGlassButton`
5. `ToolbarGlassPill`
6. `BottomNavBar`
7. `DraggableTabSwitch`
8. `AppRootView`

Once those exist, rebuild the Find Details Learn screen as the first native reference screen.

## Suggested Follow-Up

The next practical step after this blueprint is:

1. scaffold a new `GaiaNative` SwiftUI Xcode project
2. add the `Theme/`, `Content/`, `Components/`, and `Features/` folders
3. build the shared shell components
4. migrate the Find Details Learn screen first
