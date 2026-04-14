import Foundation

enum PreviewActivity {
    static let events: [ActivityEvent] = [
        ActivityEvent(
            id: "evt-1",
            groupLabel: "Today",
            title: "New find logged",
            subtitle: "Anna's Hummingbird in Arlington Garden, Pasadena",
            timestampLabel: "10:42 AM",
            actionLabel: nil,
            categoryIDs: [],
            isUnread: true,
            thumbnailAssetName: "activity-feed-new-find-logged"
        ),
        ActivityEvent(
            id: "evt-2",
            groupLabel: "Today",
            title: "Community agreed",
            subtitle: "Your Western Fence Lizard find now matches the community ID.",
            timestampLabel: "9:18 AM",
            actionLabel: nil,
            categoryIDs: ["verified"],
            isUnread: true,
            thumbnailAssetName: "activity-feed-community-agreed"
        ),
        ActivityEvent(
            id: "evt-3",
            groupLabel: "Today",
            title: "Research-grade reached",
            subtitle: "Monarch Butterfly is now research grade. Your find can now support biodiversity research.",
            timestampLabel: "10:42 AM",
            actionLabel: nil,
            categoryIDs: ["verified"],
            thumbnailAssetName: "activity-feed-research-grade"
        ),
        ActivityEvent(
            id: "evt-4",
            groupLabel: "Yesterday",
            title: "Draft saved",
            subtitle: "You started an find and saved it for later: Unknown Plant",
            timestampLabel: "6:14 PM",
            actionLabel: nil,
            categoryIDs: ["needs-id"],
            thumbnailAssetName: "activity-feed-draft-saved"
        ),
        ActivityEvent(
            id: "evt-5",
            groupLabel: "Yesterday",
            title: "ID refined by community",
            subtitle: "Your find was updated from Red-tailed Hawk to Cooper's Hawk.",
            timestampLabel: "6:14 PM",
            actionLabel: nil,
            categoryIDs: ["verified"],
            thumbnailAssetName: "activity-feed-id-refined"
        ),
        ActivityEvent(
            id: "evt-6",
            groupLabel: "Yesterday",
            title: "Find needs more detail",
            subtitle: "Your mushroom find may need a clearer photo for identification.",
            timestampLabel: "6:14 PM",
            actionLabel: nil,
            categoryIDs: ["needs-id"],
            thumbnailAssetName: "activity-feed-needs-detail"
        )
    ]

    static let community: [CommunityPost] = [
        CommunityPost(id: "post-1", author: "Alice Edwards", title: "A quiet stand of oaks near the arroyo", subtitle: "Sharing a cluster of recent finds and notes from the trail."),
        CommunityPost(id: "post-2", author: "Sam Rivera", title: "Acorn drop timing seems early this year", subtitle: "Curious whether others are seeing the same pattern along the canyon edge.")
    ]
}
