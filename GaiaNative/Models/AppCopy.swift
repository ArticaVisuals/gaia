import Foundation

struct AppCopy: Codable, Hashable {
    let exploreTitle: String
    let profileTitle: String
    let activityTitle: String
    let observeTitle: String

    static let `default` = AppCopy(
        exploreTitle: "Explore nearby life",
        profileTitle: "Your Gaia profile",
        activityTitle: "Recent activity",
        observeTitle: "Observe"
    )
}
