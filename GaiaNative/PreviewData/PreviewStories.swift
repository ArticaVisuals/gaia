import Foundation

enum PreviewStories {
    static let keystone = StoryCard(
        id: "story-keystone",
        eyebrow: "WHY IT MATTERS",
        title: "The Story of a Keystone",
        summary: "270+ species. 5000 years of human history. A disease that could end it all.",
        imageAssetName: "story-keystone-tree"
    )

    static let all: [StoryCard] = [keystone]
}
