import SwiftUI

struct StatsCard: View {
    let species: Species

    var body: some View {
        GaiaDataCard {
            VStack(alignment: .leading, spacing: GaiaSpacing.md) {
                Text("Stats")
                    .font(GaiaTypography.titleRegular)
                    .foregroundStyle(GaiaColor.textPrimary)
                HStack(spacing: GaiaSpacing.md) {
                    stat(label: "Category", value: species.category)
                    GaiaDivider().frame(width: 1, height: 42)
                    stat(label: "Status", value: species.status)
                    GaiaDivider().frame(width: 1, height: 42)
                    stat(label: "Finds", value: species.findCountLabel)
                }
            }
        }
    }

    private func stat(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(value)
                .font(GaiaTypography.title2Medium)
                .foregroundStyle(GaiaColor.olive)
            Text(label)
                .font(GaiaTypography.footnote)
                .foregroundStyle(GaiaColor.greyMuted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
