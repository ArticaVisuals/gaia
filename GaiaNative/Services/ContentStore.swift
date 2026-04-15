import Foundation

private struct BundledContent {
    let appCopy: AppCopy?
    let species: [Species]?
    let stories: [StoryCard]?
    let profile: ProfileSummary?
    let profileLog: ProfileLogContent?
    let activityEvents: [ActivityEvent]?
    let communityPosts: [CommunityPost]?
    let observations: [Observation]?
}

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
    case needsID
    case draft
}

@MainActor
final class ContentStore: ObservableObject {
    private var bundledContentLoadTask: Task<Void, Never>?
    private var hasLoadedBundledContent = false

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

    init() {
        loadBundledContentIfAvailable()
    }

    var primarySpecies: Species {
        species.first ?? PreviewSpecies.coastLiveOak
    }

    func loadBundledContentIfAvailable() {
        guard !hasLoadedBundledContent, bundledContentLoadTask == nil else {
            return
        }

        bundledContentLoadTask = Task(priority: .userInitiated) { [weak self] in
            let loadedContent = await Task.detached(priority: .userInitiated) {
                Self.loadBundledContent()
            }.value

            await MainActor.run { [weak self] in
                guard let self else { return }
                self.applyBundledContent(loadedContent)
                self.hasLoadedBundledContent = true
                self.bundledContentLoadTask = nil
            }
        }
    }

    private func applyBundledContent(_ content: BundledContent) {
        if let appCopy = content.appCopy {
            self.appCopy = appCopy
        }

        if let species = content.species {
            self.species = species
        }

        if let stories = content.stories {
            self.stories = stories
        }

        if let profile = content.profile {
            self.profile = profile
        }

        if let profileLog = content.profileLog {
            self.profileLog = profileLog
        }

        if let activityEvents = content.activityEvents {
            self.activityEvents = activityEvents
        }

        if let communityPosts = content.communityPosts {
            self.communityPosts = communityPosts
        }

        if let observations = content.observations {
            self.observations = observations
        }
    }

    nonisolated private static func loadBundledContent() -> BundledContent {
        let rawObservations = load("map-observations", as: [Observation].self)
        let mapDataService = MapDataService()

        return BundledContent(
            appCopy: load("app-copy", as: AppCopy.self),
            species: load("species", as: [Species].self),
            stories: load("stories", as: [StoryCard].self),
            profile: load("profile", as: ProfileSummary.self),
            profileLog: load("profile-log", as: ProfileLogContent.self),
            activityEvents: load("activity", as: [ActivityEvent].self),
            communityPosts: load("community", as: [CommunityPost].self),
            observations: rawObservations.map { mapDataService.prototypeObservations(from: $0) }
        )
    }

    nonisolated private static func load<T: Decodable>(_ name: String, as type: T.Type) -> T? {
        guard let url = Bundle.main.url(forResource: name, withExtension: "json", subdirectory: "Content") ?? Bundle.main.url(forResource: name, withExtension: "json") else {
            return nil
        }

        do {
            let data = try Data(contentsOf: url, options: [.mappedIfSafe])
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
                countLabel: "2 finds",
                entries: [
                    .init(
                        id: "red-fox",
                        commonName: "Red Fox",
                        scientificName: "Vulpes vulpes",
                        metaLabel: "Eaton Canyon · 2:15 PM",
                        statusLabel: "Research Grade",
                        statusKind: .researchGrade,
                        imageSource: "coast-live-oak-gallery-1"
                    ),
                    .init(
                        id: "unknown-moth",
                        commonName: "Unknown Moth",
                        scientificName: "Needs ID",
                        metaLabel: "Eaton Canyon · 2:08 PM",
                        statusLabel: "Needs ID",
                        statusKind: .needsID,
                        imageSource: "coast-live-oak-gallery-4"
                    )
                ]
            ),
            .init(
                id: "yesterday",
                title: "Yesterday",
                countLabel: "1 find",
                entries: [
                    .init(
                        id: "coast-live-oak",
                        commonName: "Coast Live Oak",
                        scientificName: "Quercus agrifolia",
                        metaLabel: "Arroyo Seco · 10:30 AM",
                        statusLabel: "Research Grade",
                        statusKind: .researchGrade,
                        imageSource: "coast-live-oak-hero"
                    )
                ]
            ),
            .init(
                id: "mar-25",
                title: "Mar 25",
                countLabel: "3 finds",
                entries: [
                    .init(
                        id: "western-fence-lizard",
                        commonName: "Western Fence Lizard",
                        scientificName: "Needs ID",
                        metaLabel: "Hahamongna · 3:45 PM",
                        statusLabel: "Needs ID",
                        statusKind: .needsID,
                        imageSource: "observe-photo-square"
                    ),
                    .init(
                        id: "black-phoebe",
                        commonName: "Black Phoebe",
                        scientificName: "Sayornis nigricans",
                        metaLabel: "Rose Bowl Trail · 1:20 PM",
                        statusLabel: "Research Grade",
                        statusKind: .researchGrade,
                        imageSource: "coast-live-oak-gallery-3"
                    ),
                    .init(
                        id: "california-poppy",
                        commonName: "California Poppy",
                        scientificName: "Eschscholzia californica",
                        metaLabel: "Eaton Canyon · 11:00 AM",
                        statusLabel: "Research Grade",
                        statusKind: .researchGrade,
                        imageSource: "observe-photo-highlight"
                    )
                ]
            ),
            .init(
                id: "mar-24",
                title: "Mar 24",
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
            .init(id: "cacti", title: "Cacti", imageSource: "coast-live-oak-hero"),
            .init(id: "indian-cormorant", title: "Indian\nCormorant", imageSource: "coast-live-oak-gallery-1"),
            .init(id: "european-roller", title: "European\nRoller", imageSource: "coast-live-oak-gallery-2"),
            .init(id: "bindweed-tribe", title: "Bindweed\nTribe", imageSource: "coast-live-oak-gallery-3"),
            .init(id: "emperor-gum-moth", title: "Emperor\nGum Moth", imageSource: "coast-live-oak-gallery-4"),
            .init(id: "garden-orbweaver", title: "Garden\nOrbweaver", imageSource: "observe-photo-square"),
            .init(id: "southern-black-korhaan", title: "Southern Black\nKorhaan", imageSource: "observe-photo-portrait"),
            .init(id: "phlogistus", title: "Phlogistus", imageSource: "observe-photo-highlight"),
            .init(id: "spiny-starwort", title: "Spiny\nStarowort", imageSource: "find-project-pollinator")
        ]
    )
}
