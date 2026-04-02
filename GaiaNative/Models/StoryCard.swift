import Foundation

struct StoryDeckPage: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let body: String
    let imageAssetName: String
}

struct StoryCard: Identifiable, Codable, Hashable {
    let id: String
    let eyebrow: String
    let title: String
    let summary: String
    let imageAssetName: String
    let pages: [StoryDeckPage]

    init(
        id: String,
        eyebrow: String,
        title: String,
        summary: String,
        imageAssetName: String,
        pages: [StoryDeckPage] = []
    ) {
        self.id = id
        self.eyebrow = eyebrow
        self.title = title
        self.summary = summary
        self.imageAssetName = imageAssetName
        self.pages = pages
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case eyebrow
        case title
        case summary
        case imageAssetName
        case pages
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        eyebrow = try container.decode(String.self, forKey: .eyebrow)
        title = try container.decode(String.self, forKey: .title)
        summary = try container.decode(String.self, forKey: .summary)
        imageAssetName = try container.decode(String.self, forKey: .imageAssetName)
        pages = try container.decodeIfPresent([StoryDeckPage].self, forKey: .pages) ?? []
    }
}
