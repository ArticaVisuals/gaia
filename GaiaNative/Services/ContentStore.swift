import Foundation

struct ProfileLogContent: Codable, Hashable {
    let totalFindsLabel: String
    let listSections: [ProfileLogSection]
    let gridItems: [ProfileLogGridItem]
}

struct ProfileLogSection: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let countLabel: String
    let entries: [ProfileLogEntry]
}

struct ProfileLogEntry: Identifiable, Codable, Hashable {
    let id: String
    let commonName: String
    let scientificName: String
    let metaLabel: String
    let statusLabel: String
    let statusKind: ProfileLogStatusKind
    let imageSource: String
}

struct ProfileLogGridItem: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let imageSource: String
}

enum ProfileLogStatusKind: String, Codable, Hashable {
    case researchGrade
    case casualGrade
    case ungraded
    case needsID
    case draft
}

@MainActor
final class ContentStore: ObservableObject {
    @Published var appCopy: AppCopy = .default
    @Published var species: [Species] = PreviewSpecies.all
    @Published var stories: [StoryCard] = PreviewStories.all
    @Published var profile: ProfileSummary = PreviewProfile.me
    @Published var profileLog: ProfileLogContent = PreviewProfileLog.content
    @Published var activityEvents: [ActivityEvent] = PreviewActivity.events
    @Published var communityPosts: [CommunityPost] = PreviewActivity.community
    @Published var observations: [Observation] = [
        Observation(id: "obs-1", speciesID: "coast-live-oak", latitude: 34.1368, longitude: -118.1256, thumbnailAssetName: "coast-live-oak-hero"),
        Observation(id: "obs-2", speciesID: "coast-live-oak", latitude: 34.1292, longitude: -118.1421, thumbnailAssetName: "coast-live-oak-gallery-1"),
        Observation(id: "obs-3", speciesID: "coast-live-oak", latitude: 34.1456, longitude: -118.1134, thumbnailAssetName: "coast-live-oak-gallery-2"),
        Observation(id: "obs-4", speciesID: "coast-live-oak", latitude: 34.1237, longitude: -118.1033, thumbnailAssetName: "coast-live-oak-gallery-3")
    ]

    var primarySpecies: Species {
        species.first ?? PreviewSpecies.coastLiveOak
    }

    func loadBundledContentIfAvailable() {
        appCopy = load("app-copy", as: AppCopy.self) ?? appCopy
        species = load("species", as: [Species].self) ?? species
        stories = load("stories", as: [StoryCard].self) ?? stories
        profile = load("profile", as: ProfileSummary.self) ?? profile
        profileLog = load("profile-log", as: ProfileLogContent.self) ?? profileLog
        activityEvents = load("activity", as: [ActivityEvent].self) ?? activityEvents
        communityPosts = load("community", as: [CommunityPost].self) ?? communityPosts
        observations = load("map-observations", as: [Observation].self) ?? observations
    }

    private func load<T: Decodable>(_ name: String, as type: T.Type) -> T? {
        guard let url = Bundle.main.url(forResource: name, withExtension: "json", subdirectory: "Content") ?? Bundle.main.url(forResource: name, withExtension: "json") else {
            return nil
        }

        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            return nil
        }
    }
}

enum PreviewProfileLog {
    static let content = ProfileLogContent(
        totalFindsLabel: "127 finds",
        listSections: [
            .init(
                id: "today",
                title: "Today",
                countLabel: "3 finds",
                entries: [
                    .init(
                        id: "red-fox",
                        commonName: "Red Fox",
                        scientificName: "Vulpes vulpes",
                        metaLabel: "Eaton Canyon · 2:15 PM",
                        statusLabel: "Ungraded",
                        statusKind: .ungraded,
                        imageSource: "https://www.figma.com/api/mcp/asset/f99a6cfd-ae56-4e80-aac0-92c673a070b5"
                    ),
                    .init(
                        id: "annas-hummingbird",
                        commonName: "Anna's Hummingbird",
                        scientificName: "Calypte anna",
                        metaLabel: "Arlington Garden · 1:42 PM",
                        statusLabel: "Ungraded",
                        statusKind: .ungraded,
                        imageSource: "https://www.figma.com/api/mcp/asset/3de8ff3b-8537-438e-9014-164c92cd7265"
                    ),
                    .init(
                        id: "coast-live-oak",
                        commonName: "Coast Live Oak",
                        scientificName: "Quercus agrifolia",
                        metaLabel: "Arlington Garden · 1:42 PM",
                        statusLabel: "Casual Grade",
                        statusKind: .casualGrade,
                        imageSource: "coast-live-oak-hero"
                    )
                ]
            ),
            .init(
                id: "yesterday",
                title: "Yesterday",
                countLabel: "3 finds",
                entries: [
                    .init(
                        id: "western-fence-lizard",
                        commonName: "Western Fence Lizard",
                        scientificName: "Sceloporus occidentalis",
                        metaLabel: "Eaton Canyon · 2:15 PM",
                        statusLabel: "Research Grade",
                        statusKind: .researchGrade,
                        imageSource: "observe-photo-square"
                    ),
                    .init(
                        id: "black-phoebe",
                        commonName: "Black Phoebe",
                        scientificName: "Sayornis nigricans",
                        metaLabel: "Rose Bowl Trail · 1:20 PM",
                        statusLabel: "Research Grade",
                        statusKind: .researchGrade,
                        imageSource: "https://www.figma.com/api/mcp/asset/5480f314-a42a-4aff-b091-ade77472cf43"
                    ),
                    .init(
                        id: "california-poppy",
                        commonName: "California Poppy",
                        scientificName: "Eschscholzia californica",
                        metaLabel: "Arroyo Seco · 10:15 AM",
                        statusLabel: "Research Grade",
                        statusKind: .researchGrade,
                        imageSource: "https://www.figma.com/api/mcp/asset/56a574ab-72a6-4985-a207-e84398659de6"
                    )
                ]
            ),
            .init(
                id: "mar-25",
                title: "Mar 25",
                countLabel: "2 finds",
                entries: [
                    .init(
                        id: "red-tailed-hawk",
                        commonName: "Red-tailed Hawk",
                        scientificName: "Buteo jamaicensis",
                        metaLabel: "JPL Trail · 4:10 PM",
                        statusLabel: "Research Grade",
                        statusKind: .researchGrade,
                        imageSource: "observe-photo-portrait"
                    ),
                    .init(
                        id: "buckwheat",
                        commonName: "Buckwheat",
                        scientificName: "Eriogonum fasciculatum",
                        metaLabel: "Altadena Trail · 9:30 AM",
                        statusLabel: "Draft",
                        statusKind: .draft,
                        imageSource: "coast-live-oak-gallery-2"
                    )
                ]
            )
        ],
        gridItems: [
            .init(id: "cacti", title: "Cacti", imageSource: "https://www.figma.com/api/mcp/asset/2e4ece4a-e9f3-4a6a-b76c-2146c08e35e0"),
            .init(id: "indian-cormorant", title: "Indian\nCormorant", imageSource: "https://www.figma.com/api/mcp/asset/f99a6cfd-ae56-4e80-aac0-92c673a070b5"),
            .init(id: "european-roller", title: "European\nRoller", imageSource: "https://www.figma.com/api/mcp/asset/dfbddfc8-fc8f-458e-b30e-21497d574985"),
            .init(id: "bindweed-tribe", title: "Bindweed\nTribe", imageSource: "https://www.figma.com/api/mcp/asset/f2391b2e-1a45-435b-acd7-1207dda76c0e"),
            .init(id: "emperor-gum-moth", title: "Emperor\nGum Moth", imageSource: "https://www.figma.com/api/mcp/asset/3de8ff3b-8537-438e-9014-164c92cd7265"),
            .init(id: "garden-orbweaver", title: "Garden\nOrbweaver", imageSource: "https://www.figma.com/api/mcp/asset/7911b149-22d8-416f-b72d-3bcd00c42a5b"),
            .init(id: "southern-black-korhaan", title: "Southern Black\nKorhaan", imageSource: "https://www.figma.com/api/mcp/asset/5480f314-a42a-4aff-b091-ade77472cf43"),
            .init(id: "phlogistus", title: "Phlogistus", imageSource: "https://www.figma.com/api/mcp/asset/0b80c8ea-d015-4df0-ac86-82f4da3979fe"),
            .init(id: "spiny-starwort", title: "Spiny\nStarowort", imageSource: "https://www.figma.com/api/mcp/asset/56a574ab-72a6-4985-a207-e84398659de6"),
            .init(id: "annas-hummingbird-grid", title: "Anna's\nHummingbird", imageSource: "https://www.figma.com/api/mcp/asset/3de8ff3b-8537-438e-9014-164c92cd7265"),
            .init(id: "red-fox-grid", title: "Red Fox", imageSource: "https://www.figma.com/api/mcp/asset/f99a6cfd-ae56-4e80-aac0-92c673a070b5"),
            .init(id: "coast-live-oak-grid", title: "Coast Live\nOak", imageSource: "coast-live-oak-hero"),
            .init(id: "western-fence-lizard-grid", title: "Western Fence\nLizard", imageSource: "observe-photo-square"),
            .init(id: "black-phoebe-grid", title: "Black\nPhoebe", imageSource: "https://www.figma.com/api/mcp/asset/5480f314-a42a-4aff-b091-ade77472cf43"),
            .init(id: "california-poppy-grid", title: "California\nPoppy", imageSource: "https://www.figma.com/api/mcp/asset/56a574ab-72a6-4985-a207-e84398659de6"),
            .init(id: "red-tailed-hawk-grid", title: "Red-tailed\nHawk", imageSource: "observe-photo-portrait"),
            .init(id: "buckwheat-grid", title: "Buckwheat", imageSource: "coast-live-oak-gallery-2"),
            .init(id: "sage-sparrow-grid", title: "Sage\nSparrow", imageSource: "coast-live-oak-gallery-3")
        ]
    )
}
