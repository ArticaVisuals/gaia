import SwiftUI

struct LearnTabView: View {
    let species: Species
    let observations: [Observation]
    let stories: [StoryCard]
    let onExpandMap: () -> Void
    let onOpenStory: (StoryCard) -> Void

    private var galleryImages: [String] {
        let images = species.galleryAssetNames
        guard images.count >= 5 else {
            return Array(images.dropFirst())
        }

        return [
            images[1],
            images[2],
            images[0],
            images[4],
            images[3]
        ]
    }

    private var relatedStories: [StoryCard] {
        let matchedStories = stories.filter { species.storyIDs.contains($0.id) }
        guard matchedStories.isEmpty else { return matchedStories }
        return [stories.first ?? PreviewStories.keystone]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: GaiaSpacing.xl) {
            LearnSpeciesCard(species: species)
                .padding(.horizontal, GaiaSpacing.md)
                .padding(.top, GaiaSpacing.sm)

            section(title: "Gallery", insetContentHorizontally: false) {
                GalleryRail(imageNames: galleryImages)
            }

            section(title: "Stats") {
                StatsCard(species: species)
            }

            section(title: "Map") {
                LearnMapCard(observations: observations, action: onExpandMap)
            }

            section(title: relatedStories.count == 1 ? "Story" : "Stories") {
                ForEach(relatedStories) { story in
                    StoryPreviewCard(story: story) {
                        onOpenStory(story)
                    }
                }
            }
        }
    }

    private func section<Content: View>(
        title: String,
        insetContentHorizontally: Bool = true,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: GaiaSpacing.cardInset) {
            sectionTitle(title)
                .padding(.horizontal, GaiaSpacing.md)

            if insetContentHorizontally {
                content()
                    .padding(.horizontal, GaiaSpacing.md)
            } else {
                content()
            }
        }
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .gaiaFont(.title3)
            .foregroundStyle(GaiaColor.inkBlack300)
    }
}

private struct LearnMapCard: View {
    let observations: [Observation]
    let action: () -> Void

    private let cornerRadius = GaiaRadius.md
    private let cardHeight: CGFloat = 214

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Button(action: action) {
                ExploreMapView(
                    observations: observations,
                    recenterRequestID: nil,
                    onSelectObservation: nil,
                    showsMarkers: true,
                    initialZoomOverride: nil
                )
                .allowsHitTesting(false)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(GaiaColor.broccoliBrown50)
                .contentShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Sightings map preview")
            .accessibilityHint("Opens the expanded map")

            ExpandMapButton(action: action)
                .padding(GaiaSpacing.cardInset)
        }
        .frame(height: cardHeight)
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(GaiaColor.broccoliBrown200, lineWidth: 0.5)
        )
        .shadow(color: GaiaShadow.mdColor, radius: GaiaShadow.mdRadius, x: 0, y: GaiaShadow.mdYOffset)
    }
}
