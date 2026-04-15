import Foundation

enum PreviewStories {
    private static let keystoneStoryPageImage = "story-keystone-page-figma"

    static let keystone = StoryCard(
        id: "story-keystone",
        eyebrow: "WHY IT MATTERS",
        title: "The Story of a Keystone",
        summary: "270+ species. 5000 years of human history. A disease that could end it all.",
        imageAssetName: "story-keystone-tree",
        pages: [
            StoryDeckPage(
                id: "ecosystem",
                title: "An Ecosystem\nLives Here.",
                body: "Over 270 species of birds, mammals, and insects depend on the Coast Live Oak for food and shelter. From acorn woodpeckers storing their harvest in its bark to the California oak moth whose caterpillars feed exclusively on its leaves.",
                imageAssetName: keystoneStoryPageImage
            ),
            StoryDeckPage(
                id: "history",
                title: "5,000 Years\nof History.",
                body: "Indigenous communities across California — from the Ohlone to the Chumash — relied on acorns as a dietary staple for millennia. A single mature oak can produce up to 20,000 acorns in a good mast year, each one a vital food source.",
                imageAssetName: keystoneStoryPageImage
            ),
            StoryDeckPage(
                id: "disease",
                title: "A Disease\nSpreads Fast.",
                body: "Sudden Oak Death, caused by Phytophthora ramorum, has killed millions of tanoaks and Coast Live Oaks. It spreads through wind-blown rain, infected soil, and nursery plants — often outpacing detection and removal efforts.",
                imageAssetName: keystoneStoryPageImage
            ),
            StoryDeckPage(
                id: "roots",
                title: "Deep Roots,\nLong Memory.",
                body: "A mature Coast Live Oak can live over 250 years and extend roots 30 meters in every direction. Its deep taproot accesses groundwater during California's long summer droughts, making it remarkably resilient.",
                imageAssetName: keystoneStoryPageImage
            ),
            StoryDeckPage(
                id: "economy",
                title: "The Acorn\nEconomy.",
                body: "When acorn crops fail in mast failure years, the ripple reaches deer, bear, woodpeckers, and jays all the way up the food chain. The oak isn't just a tree. It's the engine of the entire woodland community.",
                imageAssetName: keystoneStoryPageImage
            )
        ]
    )

    static let all: [StoryCard] = [keystone]
}
