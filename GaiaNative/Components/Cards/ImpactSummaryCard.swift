// figma: https://www.figma.com/design/4e4G3tnSR7AdPbf0jAYPP1/Gaia?node-id=815-15410
import SwiftUI

struct ImpactSummaryCard: View {
    let profile: ProfileSummary

    var body: some View {
        GaiaDataCard {
            VStack(alignment: .leading, spacing: GaiaSpacing.md) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("CURRENT LEVEL")
                            .font(GaiaTypography.caption2)
                            .foregroundStyle(GaiaColor.greyMuted)
                        HStack(alignment: .firstTextBaseline, spacing: 10) {
                            Text("3")
                                .font(GaiaTypography.displayMedium)
                                .foregroundStyle(GaiaColor.textPrimary)
                            Text("4")
                                .font(GaiaTypography.title2Medium)
                                .foregroundStyle(GaiaColor.greyMuted)
                        }
                    }
                    Spacer()
                    GaiaPill(title: profile.medalsLabel, fill: GaiaColor.oliveGreen50, foreground: GaiaColor.olive)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Capsule()
                        .fill(GaiaColor.oliveGreen100)
                        .frame(height: 6)
                        .overlay(alignment: .leading) {
                            Capsule()
                                .fill(GaiaColor.olive)
                                .frame(width: 132, height: 6)
                        }
                    Text("12 finds to level 4")
                        .font(GaiaTypography.footnote)
                        .foregroundStyle(GaiaColor.textSecondary)
                }

                Text(profile.impactSummary)
                    .font(GaiaTypography.subheadline)
                    .foregroundStyle(GaiaColor.textSecondary)
            }
        }
    }
}
