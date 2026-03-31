import Foundation

@MainActor
final class ContentStore: ObservableObject {
    @Published var appCopy: AppCopy = .default
    @Published var species: [Species] = PreviewSpecies.all
    @Published var stories: [StoryCard] = PreviewStories.all
    @Published var profile: ProfileSummary = PreviewProfile.me
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
