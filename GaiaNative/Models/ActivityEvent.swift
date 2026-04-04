import Foundation

enum ActivityEventStyle: String, Codable, Hashable {
    case standard
    case notification
}

struct ActivityEvent: Identifiable, Codable, Hashable {
    let id: String
    let groupLabel: String?
    let title: String
    let subtitle: String
    let timestampLabel: String
    let actionLabel: String?
    let secondaryActionLabel: String?
    let categoryIDs: [String]?
    let style: ActivityEventStyle
    let actorName: String?
    let actorAction: String?
    let avatarAssetName: String?
    let thumbnailAssetName: String?
    let thumbnailAssetNames: [String]?

    init(
        id: String,
        groupLabel: String?,
        title: String,
        subtitle: String,
        timestampLabel: String,
        actionLabel: String?,
        secondaryActionLabel: String? = nil,
        categoryIDs: [String]?,
        style: ActivityEventStyle = .standard,
        actorName: String? = nil,
        actorAction: String? = nil,
        avatarAssetName: String? = nil,
        thumbnailAssetName: String? = nil,
        thumbnailAssetNames: [String]? = nil
    ) {
        self.id = id
        self.groupLabel = groupLabel
        self.title = title
        self.subtitle = subtitle
        self.timestampLabel = timestampLabel
        self.actionLabel = actionLabel
        self.secondaryActionLabel = secondaryActionLabel
        self.categoryIDs = categoryIDs
        self.style = style
        self.actorName = actorName
        self.actorAction = actorAction
        self.avatarAssetName = avatarAssetName
        self.thumbnailAssetName = thumbnailAssetName
        self.thumbnailAssetNames = thumbnailAssetNames
    }

    var mediaAssetNames: [String] {
        if let thumbnailAssetNames, !thumbnailAssetNames.isEmpty {
            return thumbnailAssetNames
        }

        if let thumbnailAssetName {
            return [thumbnailAssetName]
        }

        return []
    }

    var showsNotificationStyle: Bool {
        style == .notification
    }

    var hasActorHeader: Bool {
        actorName != nil || avatarAssetName != nil
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case groupLabel
        case title
        case subtitle
        case timestampLabel
        case actionLabel
        case secondaryActionLabel
        case categoryIDs
        case style
        case actorName
        case actorAction
        case avatarAssetName
        case thumbnailAssetName
        case thumbnailAssetNames
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)
        groupLabel = try container.decodeIfPresent(String.self, forKey: .groupLabel)
        title = try container.decode(String.self, forKey: .title)
        subtitle = try container.decode(String.self, forKey: .subtitle)
        timestampLabel = try container.decode(String.self, forKey: .timestampLabel)
        actionLabel = try container.decodeIfPresent(String.self, forKey: .actionLabel)
        secondaryActionLabel = try container.decodeIfPresent(String.self, forKey: .secondaryActionLabel)
        categoryIDs = try container.decodeIfPresent([String].self, forKey: .categoryIDs)
        style = try container.decodeIfPresent(ActivityEventStyle.self, forKey: .style) ?? .standard
        actorName = try container.decodeIfPresent(String.self, forKey: .actorName)
        actorAction = try container.decodeIfPresent(String.self, forKey: .actorAction)
        avatarAssetName = try container.decodeIfPresent(String.self, forKey: .avatarAssetName)
        thumbnailAssetName = try container.decodeIfPresent(String.self, forKey: .thumbnailAssetName)
        thumbnailAssetNames = try container.decodeIfPresent([String].self, forKey: .thumbnailAssetNames)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(groupLabel, forKey: .groupLabel)
        try container.encode(title, forKey: .title)
        try container.encode(subtitle, forKey: .subtitle)
        try container.encode(timestampLabel, forKey: .timestampLabel)
        try container.encodeIfPresent(actionLabel, forKey: .actionLabel)
        try container.encodeIfPresent(secondaryActionLabel, forKey: .secondaryActionLabel)
        try container.encodeIfPresent(categoryIDs, forKey: .categoryIDs)
        try container.encode(style, forKey: .style)
        try container.encodeIfPresent(actorName, forKey: .actorName)
        try container.encodeIfPresent(actorAction, forKey: .actorAction)
        try container.encodeIfPresent(avatarAssetName, forKey: .avatarAssetName)
        try container.encodeIfPresent(thumbnailAssetName, forKey: .thumbnailAssetName)
        try container.encodeIfPresent(thumbnailAssetNames, forKey: .thumbnailAssetNames)
    }
}
