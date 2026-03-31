import SwiftUI

struct SwipeableStoryDeck: View {
    let stories: [StoryCard]
    @State private var selection = 0

    var body: some View {
        VStack(spacing: GaiaSpacing.md) {
            TabView(selection: $selection) {
                ForEach(Array(stories.enumerated()), id: \.element.id) { index, story in
                    StoryPreviewCard(story: story)
                        .padding(.horizontal, GaiaSpacing.md)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 470)

            HStack(spacing: 8) {
                ForEach(stories.indices, id: \.self) { index in
                    Circle()
                        .fill(index == selection ? GaiaColor.olive : GaiaColor.border)
                        .frame(width: 8, height: 8)
                }
            }
        }
    }
}
