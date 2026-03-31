import Foundation

struct StoryCard: Identifiable, Codable, Hashable {
    let id: String
    let eyebrow: String
    let title: String
    let summary: String
    let imageAssetName: String
}
