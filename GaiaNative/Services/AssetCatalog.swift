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
        "figma-left-arrow-tight": "Icons/System/left-arrow-32-tight.png",
        "figma-plus-tight": "Icons/System/plus-24-tight.png",
        "figma-share-base-tight": "Icons/System/share-24-base-tight.png",
        "figma-share-arrow-tight": "Icons/System/share-24-arrow-tight.png",
        "figma-expand-a-tight": "Icons/System/expand-24-a-tight.png",
        "figma-expand-b-tight": "Icons/System/expand-24-b-tight.png",
        "learn-category-badge": "Icons/System/category-badge-plant.png",
        "learn-story-arrow-circle": "Icons/System/story-arrow-circle.png",
        "learn-story-arrow": "Icons/System/story-arrow.png",
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
        "find-biome-riparian": "assets/find-details/find-tab/biome-riparian.png",
        "find-weather-bg": "assets/find-details/find-tab/weather-bg.png",
        "find-project-creek": "assets/find-details/find-tab/project-creek-recovery.png",
        "find-project-pollinator": "assets/find-details/find-tab/project-pollinator-corridor.png"
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
