import SwiftUI

struct LearnTabView: View {
    let species: Species
    let stories: [StoryCard]
    let onExpandMap: () -> Void
    let onOpenStory: (StoryCard) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: GaiaSpacing.lg) {
            LearnSpeciesCard(species: species)
            GaiaSectionHeader(title: "Gallery")
            GalleryRail(imageNames: species.galleryAssetNames)
            GaiaSectionHeader(title: "Stats")
            StatsCard(species: species)
            GaiaSectionHeader(title: "Map")
            ZStack(alignment: .topTrailing) {
                GaiaAssetImage(name: "learn-map-fallback")
                    .frame(height: 220)
                    .overlay(
                        ExploreMapView(
                            observations: [Observation(id: "oak-1", speciesID: species.id, latitude: species.mapCoordinate.latitude, longitude: species.mapCoordinate.longitude, thumbnailAssetName: species.galleryAssetNames.first)],
                            recenterRequestID: nil
                        )
                        .clipShape(RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous))
                    )
                    .clipShape(RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                            .stroke(GaiaColor.oliveGreen100, lineWidth: 1)
                    )
                ExpandMapButton(action: onExpandMap)
                    .padding(GaiaSpacing.sm)
            }
            GaiaSectionHeader(title: "Stories")
            ForEach(stories) { story in
                StoryPreviewCard(story: story) {
                    onOpenStory(story)
                }
            }
        }
        .padding(.horizontal, GaiaSpacing.md)
    }
}
