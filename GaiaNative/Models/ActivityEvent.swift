import Foundation

struct ActivityEvent: Identifiable, Codable, Hashable {
    let id: String
    let groupLabel: String?
    let title: String
    let subtitle: String
    let timestampLabel: String
    let actionLabel: String?
    let categoryIDs: [String]?
    let thumbnailAssetName: String?

    init(
        id: String,
        groupLabel: String?,
        title: String,
        subtitle: String,
        timestampLabel: String,
        actionLabel: String?,
        categoryIDs: [String]?,
        thumbnailAssetName: String? = nil
    ) {
        self.id = id
        self.groupLabel = groupLabel
        self.title = title
        self.subtitle = subtitle
        self.timestampLabel = timestampLabel
        self.actionLabel = actionLabel
        self.categoryIDs = categoryIDs
        self.thumbnailAssetName = thumbnailAssetName
    }
}
