// figma: https://www.figma.com/design/4e4G3tnSR7AdPbf0jAYPP1/Gaia?node-id=815-17693
import SwiftUI

struct LearnSpeciesCard: View {
    let species: Species

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 12) {
                Text(species.scientificName)
                    .font(GaiaTypography.displayMedium)
                    .foregroundStyle(GaiaColor.paperWhite50)
                    .tracking(-0.5)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                Text(species.summary)
                    .font(.custom("Neue Haas Unica W1G", size: 12))
                    .foregroundStyle(GaiaColor.paperWhite50)
                    .lineSpacing(2.4)
                    .frame(maxWidth: 274, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Button(action: {}) {
                Text("Read More")
                .font(.custom("Neue Haas Unica W1G", size: 13))
                    .foregroundStyle(GaiaColor.olive)
                    .padding(.horizontal, 10)
                    .frame(height: 28)
                    .background(GaiaColor.paperWhite50, in: Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
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
