import Foundation

enum PreviewSpecies {
    static let coastLiveOak = Species(
        id: "coast-live-oak",
        commonName: "Coast Live Oak",
        scientificName: "Quercus agrifolia",
        category: "Plant",
        status: "LC",
        findCountLabel: "56k",
        summary: "an iconic, majestic tree that serves as a cornerstone for wildlife and the surrounding ecosystem. It is easily-recognized by its gnarled branches and grand canopy.",
        storyIDs: ["story-keystone"],
        galleryAssetNames: [
            "coast-live-oak-hero",
            "coast-live-oak-gallery-1",
            "coast-live-oak-gallery-2",
            "coast-live-oak-gallery-3",
            "coast-live-oak-gallery-4"
        ],
        mapCoordinate: .init(latitude: 34.1368, longitude: -118.1256)
    )

    static let all: [Species] = [coastLiveOak]
}
