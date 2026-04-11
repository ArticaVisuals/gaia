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

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
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

            section(title: "Stories") {
                ForEach(stories) { story in
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
        VStack(alignment: .leading, spacing: 12) {
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

    var body: some View {
        SightingsMapPreviewCard(observations: observations, onExpandMap: action)
    }
}
