import SwiftUI

struct LearnTabView: View {
    let species: Species
    let stories: [StoryCard]
    let onExpandMap: () -> Void
    let onOpenStory: (StoryCard) -> Void

    private var galleryImages: [String] {
        let images = Array(species.galleryAssetNames.dropFirst())
        return images.isEmpty ? species.galleryAssetNames : images
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            LearnSpeciesCard(species: species)

            section(title: "Gallery") {
                GalleryRail(imageNames: galleryImages)
            }

            section(title: "Stats") {
                StatsCard(species: species)
            }

            VStack(alignment: .leading, spacing: 10) {
                sectionTitle("Map")

                ZStack(alignment: .topTrailing) {
                    GaiaAssetImage(name: "learn-map-fallback")
                        .frame(height: 270)
                        .overlay {
                            ExploreMapView(
                                observations: [
                                    Observation(
                                        id: "oak-1",
                                        speciesID: species.id,
                                        latitude: species.mapCoordinate.latitude,
                                        longitude: species.mapCoordinate.longitude,
                                        thumbnailAssetName: species.galleryAssetNames.first
                                    )
                                ],
                                recenterRequestID: nil
                            )
                        }
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                                .stroke(GaiaColor.broccoliBrown200, lineWidth: 0.5)
                        )
                        .clipped()
                        .shadow(color: GaiaShadow.smallColor, radius: GaiaShadow.smallRadius, x: 0, y: GaiaShadow.smallYOffset)

                    ExpandMapButton(action: onExpandMap)
                        .padding(.top, 16)
                        .padding(.trailing, 16)
                }
                .frame(maxWidth: .infinity)
            }

            VStack(alignment: .leading, spacing: 10) {
                sectionTitle("Stories")

                ForEach(stories) { story in
                    StoryPreviewCard(story: story) {
                        onOpenStory(story)
                    }
                }
            }
            .padding(.horizontal, GaiaSpacing.md)
    }
    }

    private func section<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle(title)
            content()
        }
        .padding(.horizontal, GaiaSpacing.md)
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(GaiaTypography.titleRegular)
            .foregroundStyle(GaiaColor.inkBlack300)
    }
}
