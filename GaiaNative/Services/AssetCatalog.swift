import SwiftUI
import UIKit

enum AssetCatalog {
    private static let aliases: [String: String] = [
        "coast-live-oak-hero": "assets/find-details/learn-v2/hero.png",
        "coast-live-oak-gallery-1": "assets/find-details/learn-v2/gallery-1.png",
        "coast-live-oak-gallery-2": "assets/find-details/learn-v2/gallery-2.png",
        "coast-live-oak-gallery-3": "assets/find-details/learn-v2/gallery-3.png",
        "coast-live-oak-gallery-4": "assets/find-details/learn-v2/gallery-4.png",
        "story-keystone-tree": "assets/find-details/learn-v2/story-tree.png",
        "story-keystone-page-image": "assets/find-details/hero-coast-live-oak.png",
        "learn-map-fallback": "assets/find-details/learn-v2/map-fallback.png",
        "figma-left-arrow-tight": "gaia-icon-back-32",
        "figma-plus-tight": "gaia-icon-plus-24",
        "figma-share-base-tight": "gaia-icon-share-base-24",
        "figma-share-arrow-tight": "gaia-icon-share-arrow-24",
        "figma-expand-a-tight": "gaia-icon-expand-a-24",
        "figma-expand-b-tight": "gaia-icon-expand-b-24",
        "learn-category-badge": "gaia-learn-category-badge",
        "learn-story-arrow-circle": "gaia-learn-story-arrow-circle",
        "learn-story-arrow": "gaia-learn-story-arrow",
        "badge/animal/amphibian": "gaia-profile-medal-category-amphibian",
        "badge/animal/bird": "gaia-profile-medal-category-bird",
        "badge/animal/fish": "gaia-profile-medal-category-fish",
        "badge/animal/fungi": "gaia-profile-medal-category-fungus",
        "badge/animal/fungus": "gaia-profile-medal-category-fungus",
        "badge/animal/insect": "gaia-profile-medal-category-insect",
        "badge/animal/mammal": "gaia-profile-medal-category-mammal",
        "badge/animal/mollusk": "gaia-profile-medal-category-mollusk",
        "badge/animal/plant": "gaia-profile-medal-category-plant",
        "badge/animal/reptile": "gaia-profile-medal-category-reptile",
        "find-dq-casual": "gaia-find-dq-casual",
        "find-dq-needs-id": "gaia-find-dq-needs-id",
        "find-dq-research": "gaia-find-dq-research",
        "find-dq-checked": "assets/find-details/find-tab-final/dq-checked.svg",
        "find-dq-unchecked": "assets/find-details/find-tab-final/dq-unchecked.svg",
        "Icons/System/target-24-ring.png": "gaia-icon-target-ring-24",
        "Icons/System/target-24-dot.png": "gaia-icon-target-dot-24",
        "Icons/System/search-20.png": "gaia-icon-search-20",
        "Icons/System/microphone-20-head-olive.png": "gaia-icon-microphone-head-20",
        "Icons/System/microphone-20-base-olive.png": "gaia-icon-microphone-base-20",
        "Icons/System/left-arrow-32.png": "gaia-icon-back-32",
        "Icons/System/left-arrow-32-tight.png": "gaia-icon-back-32",
        "Icons/System/cross-32.png": "gaia-icon-close-32",
        "Icons/System/plus-24.png": "gaia-icon-plus-24",
        "Icons/System/plus-24-tight.png": "gaia-icon-plus-24",
        "Icons/System/share-24-base.png": "gaia-icon-share-base-24",
        "Icons/System/share-24-base-tight.png": "gaia-icon-share-base-24",
        "Icons/System/share-24-arrow.png": "gaia-icon-share-arrow-24",
        "Icons/System/share-24-arrow-tight.png": "gaia-icon-share-arrow-24",
        "Icons/System/expand-24-a.png": "gaia-icon-expand-a-24",
        "Icons/System/expand-24-a-tight.png": "gaia-icon-expand-a-24",
        "Icons/System/expand-24-b.png": "gaia-icon-expand-b-24",
        "Icons/System/expand-24-b-tight.png": "gaia-icon-expand-b-24",
        "Icons/System/explore-32-ring.png": "gaia-icon-explore-ring-32",
        "Icons/System/explore-32-ring-olive.png": "gaia-icon-explore-ring-32",
        "Icons/System/explore-32-dot.png": "gaia-icon-explore-dot-32",
        "Icons/System/explore-32-dot-olive.png": "gaia-icon-explore-dot-32",
        "Icons/System/logbook-32-figma.png": "gaia-icon-log-32",
        "Icons/System/logbook-32-outline.png": "gaia-icon-log-32",
        "Icons/System/logbook-32-outline-olive.png": "gaia-icon-log-32",
        "Icons/System/logbook-32-line-1.png": "gaia-icon-log-32",
        "Icons/System/logbook-32-line-1-olive.png": "gaia-icon-log-32",
        "Icons/System/logbook-32-line-2.png": "gaia-icon-log-32",
        "Icons/System/logbook-32-line-2-olive.png": "gaia-icon-log-32",
        "Icons/System/logbook-32-line-3.png": "gaia-icon-log-32",
        "Icons/System/logbook-32-line-3-olive.png": "gaia-icon-log-32",
        "Icons/System/binoculars-32.png": "gaia-icon-observe-32",
        "Icons/System/binoculars-32-figma.png": "gaia-icon-observe-32",
        "Icons/System/binoculars-32-olive.png": "gaia-icon-observe-32",
        "Icons/System/bell-32.png": "gaia-icon-activity-32",
        "Icons/System/bell-32-figma.png": "gaia-icon-activity-32",
        "Icons/System/bell-32-olive.png": "gaia-icon-activity-32",
        "Icons/System/profile-32.png": "gaia-icon-profile-32",
        "Icons/System/profile-32-figma.png": "gaia-icon-profile-32",
        "Icons/System/profile-32-olive.png": "gaia-icon-profile-32",
        "Icons/System/chevron-16.png": "gaia-icon-chevron-16",
        "Icons/System/chevron-20.png": "gaia-icon-chevron-20",
        "Icons/System/circle-arrow-right-16-ring.png": "assets/find-details/find-tab-final/circle-arrow-right-ring.svg",
        "Icons/System/circle-arrow-right-16-chevron.png": "assets/find-details/find-tab-final/circle-arrow-right-chevron.svg",
        "Icons/System/pin-20.png": "gaia-icon-pin-20",
        "Icons/System/grid-32.png": "gaia-icon-grid-32",
        "Icons/System/list-32.png": "gaia-icon-list-32",
        "Icons/System/map-32.png": "gaia-icon-map-32",
        "Icons/System/filter-32.png": "gaia-icon-filter-32",
        "Icons/System/gear-20.png": "gaia-icon-gear-20",
        "Icons/System/binoculars-20.png": "gaia-icon-binoculars-20",
        "observe-camera-background": "assets/observe/camera-bg.png",
        "observe-camera-thumb": "assets/observe/camera-thumb.png",
        "observe-loading-front": "assets/observe/loading-card-front.png",
        "observe-loading-middle": "assets/observe/loading-card-middle.png",
        "observe-loading-back": "assets/observe/loading-card-back.png",
        "observe-photo-square": "assets/observe/photo-square.png",
        "observe-photo-portrait": "assets/observe/photo-portrait.png",
        "observe-photo-highlight": "assets/observe/photo-highlight.png",
        "observe-suggestion-top": "assets/observe/suggestion-top.png",
        "observe-suggestion-secondary-1": "assets/observe/suggestion-secondary-1.png",
        "observe-suggestion-secondary-2": "assets/observe/suggestion-secondary-2.png",
        "observe-location-map": "assets/observe/location-map.png",
        "observe-share-impact": "assets/observe/share-impact.png",
        "observe-share-why-matters": "assets/observe/share-why-matters.png",
        "find-avatar-alice": "assets/find-details/find-tab/avatar-alice.png",
        "profile-avatar-noah": "assets/profile/all-people/avatar-noah.png",
        "profile-avatar-maya": "assets/profile/all-people/avatar-maya.png",
        "profile-avatar-lena": "assets/profile/all-people/avatar-lena.png",
        "find-biome-riparian": "assets/find-details/find-tab-final/biome-riparian.png",
        "find-weather-bg": "assets/find-details/find-tab-final/weather-bg.png",
        "find-project-creek": "assets/find-details/find-tab-final/project-creek-recovery.png",
        "find-project-pollinator": "assets/find-details/find-tab-final/project-pollinator-corridor.png",
        "activity-suggestion-thumb": "assets/find-details/activity-tab-final/suggestion-thumb.png",
        "project-detail-hero-pollinator": "assets/find-details/project-details/hero-pollinator.png",
        "project-detail-founder-alice-edwards": "assets/find-details/project-details/founder-alice-edwards.png",
        "project-detail-contributor-1": "assets/find-details/project-details/contributor-1.png",
        "project-detail-contributor-2": "assets/find-details/project-details/contributor-2.png",
        "project-detail-contributor-3": "assets/find-details/project-details/contributor-3.png",
        "project-detail-contributor-4": "assets/find-details/project-details/contributor-4.png",
        "project-detail-contributor-5": "assets/find-details/project-details/contributor-5.png",
        "project-detail-contributor-6": "assets/find-details/project-details/contributor-6.png",
        "project-detail-profile-stack": "assets/find-details/project-details/profile-stack.png",
        "project-detail-recent-cacti": "assets/find-details/project-details/recent-cacti.png",
        "project-detail-recent-indian-cormorant": "assets/find-details/project-details/recent-indian-cormorant.png",
        "project-detail-recent-european-roller": "assets/find-details/project-details/recent-european-roller.png",
        "project-detail-recent-bindweed-tribe": "assets/find-details/project-details/recent-bindweed-tribe.png",
        "project-detail-recent-emperor-gum-moth": "assets/find-details/project-details/recent-emperor-gum-moth.png",
        "project-detail-recent-garden-orbweaver": "assets/find-details/project-details/recent-garden-orbweaver.png",
        "project-detail-update-highlight": "assets/find-details/project-details/update-highlight.png",
        "project-detail-update-weekend-goals": "assets/find-details/project-details/update-weekend-goals.png",
        "project-detail-update-spring-bloom": "assets/find-details/project-details/update-spring-bloom.png",
        "activity-feed-new-find-logged": "assets/find-details/activity-tab-final/activity-feed-new-find-logged.png",
        "activity-feed-community-agreed": "assets/find-details/activity-tab-final/activity-feed-community-agreed.png",
        "activity-feed-research-grade": "assets/find-details/activity-tab-final/activity-feed-research-grade.png",
        "activity-feed-draft-saved": "assets/find-details/activity-tab-final/activity-feed-draft-saved.png",
        "activity-feed-id-refined": "assets/find-details/activity-tab-final/activity-feed-id-refined.png",
        "activity-feed-needs-detail": "assets/find-details/activity-tab-final/activity-feed-needs-detail.png"
    ]

    static func resolvedPath(for key: String) -> String {
        aliases[key] ?? key
    }

    static func uiImage(named key: String) -> UIImage? {
        let path = resolvedPath(for: key)

        if let image = UIImage(named: path) {
            return image
        }

        if let direct = Bundle.main.resourceURL?.appendingPathComponent(path),
           let image = UIImage(contentsOfFile: direct.path) {
            return image
        }

        let nsPath = path as NSString
        let base = nsPath.deletingPathExtension
        let ext = nsPath.pathExtension
        if !ext.isEmpty,
           let url = Bundle.main.url(forResource: base, withExtension: ext),
           let image = UIImage(contentsOfFile: url.path) {
            return image
        }

        return nil
    }

    static func image(named key: String) -> Image? {
        guard let uiImage = uiImage(named: key) else {
            return nil
        }
        return Image(uiImage: uiImage)
    }
}
