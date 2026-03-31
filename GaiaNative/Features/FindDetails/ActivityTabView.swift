import SwiftUI

struct ActivityTabView: View {
    let events: [ActivityEvent]

    var body: some View {
        VStack(alignment: .leading, spacing: GaiaSpacing.lg) {
            GaiaActionCard(accent: GaiaColor.indigoBlue500) {
                VStack(alignment: .leading, spacing: GaiaSpacing.sm) {
                    Text("Bay Area Raptor Watch 2026")
                        .font(GaiaTypography.calloutMedium)
                        .foregroundStyle(GaiaColor.textPrimary)
                    Text("This species is being tracked as part of an active monitoring project. Your observation can contribute.")
                        .font(GaiaTypography.subheadline)
                        .foregroundStyle(GaiaColor.textSecondary)
                    GaiaPill(title: "Contribute My Sighting", fill: GaiaColor.indigoBlue500, foreground: GaiaColor.paperStrong)
                }
            }

            GaiaSectionHeader(title: "Recent Activity")

            ForEach(events) { event in
                ActivityCard(event: event)
            }
        }
        .padding(.horizontal, GaiaSpacing.md)
    }
}
