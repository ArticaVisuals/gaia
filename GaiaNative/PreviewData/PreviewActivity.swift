import Foundation

enum PreviewActivity {
    static let events: [ActivityEvent] = [
        ActivityEvent(id: "evt-1", title: "Community agreed with your ID", subtitle: "Coast Live Oak was confirmed by 4 observers.", timestampLabel: "2h ago"),
        ActivityEvent(id: "evt-2", title: "New observation saved", subtitle: "You added a Western fence lizard to your log.", timestampLabel: "Yesterday"),
        ActivityEvent(id: "evt-3", title: "Project request nearby", subtitle: "A habitat recovery group is looking for more oak sightings in your area.", timestampLabel: "3d ago")
    ]

    static let community: [CommunityPost] = [
        CommunityPost(id: "post-1", author: "Alice Edwards", title: "A quiet stand of oaks near the arroyo", subtitle: "Sharing a cluster of recent finds and notes from the trail."),
        CommunityPost(id: "post-2", author: "Sam Rivera", title: "Acorn drop timing seems early this year", subtitle: "Curious whether others are seeing the same pattern along the canyon edge.")
    ]
}
