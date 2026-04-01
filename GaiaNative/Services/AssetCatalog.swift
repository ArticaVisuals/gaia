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
        "Icons/System/pin-20.png": "gaia-icon-pin-20",
        "Icons/System/grid-32.png": "gaia-icon-grid-32",
        "Icons/System/list-32.png": "gaia-icon-list-32",
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
        "find-biome-riparian": "assets/find-details/find-tab-final/biome-riparian.png",
        "find-weather-bg": "assets/find-details/find-tab-final/weather-bg.png",
        "find-project-creek": "assets/find-details/find-tab-final/project-creek-recovery.png",
        "find-project-pollinator": "assets/find-details/find-tab-final/project-pollinator-corridor.png",
        "activity-suggestion-thumb": "assets/find-details/activity-tab-final/suggestion-thumb.png"
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
