import SwiftUI

struct ActivityCard: View {
    let event: ActivityEvent

    var body: some View {
        GaiaDataCard {
            VStack(alignment: .leading, spacing: GaiaSpacing.xs) {
                Text(event.title)
                    .font(GaiaTypography.calloutMedium)
                    .foregroundStyle(GaiaColor.textPrimary)
                Text(event.subtitle)
                    .font(GaiaTypography.subheadline)
                    .foregroundStyle(GaiaColor.textSecondary)
                Text(event.timestampLabel)
                    .font(GaiaTypography.caption2)
                    .foregroundStyle(GaiaColor.greyMuted)
                    .padding(.top, 4)
            }
        }
    }
}
