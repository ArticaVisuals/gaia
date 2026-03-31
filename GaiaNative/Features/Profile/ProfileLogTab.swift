import SwiftUI

struct ProfileLogTab: View {
    let events: [ActivityEvent]
    @EnvironmentObject private var contentStore: ContentStore

    var body: some View {
        VStack(alignment: .leading, spacing: GaiaSpacing.lg) {
            GaiaSectionHeader(title: "Recent Finds")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: GaiaSpacing.sm) {
                    ForEach(contentStore.species) { species in
                        FindCard(species: species, action: {})
                            .frame(width: 220)
                    }
                }
            }

            GaiaSectionHeader(title: "Log Activity")

            ForEach(events) { event in
                ActivityCard(event: event)
            }
        }
    }
}
