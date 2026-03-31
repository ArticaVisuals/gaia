import SwiftUI

struct ActivityScreen: View {
    @EnvironmentObject private var contentStore: ContentStore

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: GaiaSpacing.lg) {
                Text("Activity")
                    .font(GaiaTypography.displayMedium)
                    .foregroundStyle(GaiaColor.textPrimary)

                GaiaActionCard(accent: GaiaColor.vermillion500) {
                    VStack(alignment: .leading, spacing: GaiaSpacing.sm) {
                        Text("Spring migration alert")
                            .font(GaiaTypography.calloutMedium)
                            .foregroundStyle(GaiaColor.textPrimary)
                        Text("Warblers are passing through your area this week. Great time to spot rare visitors.")
                            .font(GaiaTypography.subheadline)
                            .foregroundStyle(GaiaColor.textSecondary)
                        GaiaPill(title: "Go Explore", fill: GaiaColor.vermillion500, foreground: GaiaColor.paperStrong)
                    }
                }

                ForEach(contentStore.activityEvents) { event in
                    ActivityCard(event: event)
                }
            }
            .padding(GaiaSpacing.md)
            .padding(.bottom, 120)
        }
        .background(GaiaColor.surfacePrimary)
    }
}
