import SwiftUI

struct LearnSpeciesCard: View {
    let species: Species

    var body: some View {
        GaiaStoryCardSurface {
            VStack(alignment: .leading, spacing: GaiaSpacing.md) {
                GaiaBadge(title: species.category)
                Text("An ecosystem lives here.")
                    .font(GaiaTypography.title1)
                    .foregroundStyle(GaiaColor.textPrimary)
                Text(species.summary)
                    .font(GaiaTypography.subheadline)
                    .foregroundStyle(GaiaColor.textSecondary)
                VStack(alignment: .leading, spacing: 4) {
                    Text(species.commonName)
                        .font(GaiaTypography.title)
                        .foregroundStyle(GaiaColor.olive)
                    Text(species.scientificName)
                        .font(GaiaTypography.footnote)
                        .foregroundStyle(GaiaColor.textWarmSecondary)
                }
            }
        }
    }
}
