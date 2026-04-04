// figma: https://www.figma.com/design/4e4G3tnSR7AdPbf0jAYPP1/Gaia?node-id=815-17693
import SwiftUI

struct LearnSpeciesCard: View {
    let species: Species

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 12) {
                Text(species.scientificName)
                    .gaiaFont(.displayMedium)
                    .foregroundStyle(GaiaColor.paperWhite50)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                Text(species.summary)
                    .gaiaFont(.subheadline)
                    .foregroundStyle(GaiaColor.textInverseSecondary)
                    .frame(maxWidth: 305, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Button(action: {}) {
                Text("Read More")
                    .gaiaFont(.subheadline)
                    .foregroundStyle(GaiaColor.olive)
                    .padding(.horizontal, 14)
                    .frame(height: 34)
                    .background(GaiaColor.paperWhite50, in: Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                .fill(GaiaColor.olive)
                .overlay(
                    RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                        .stroke(GaiaColor.broccoliBrown200, lineWidth: 0.5)
                )
                .shadow(color: GaiaShadow.mdColor, radius: GaiaShadow.mdRadius, x: 0, y: GaiaShadow.mdYOffset)
        )
    }
}
