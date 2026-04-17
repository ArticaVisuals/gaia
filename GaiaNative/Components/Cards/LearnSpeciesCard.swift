// figma: https://www.figma.com/design/4e4G3tnSR7AdPbf0jAYPP1/Gaia?node-id=815-17693
import SwiftUI

struct LearnSpeciesCard: View {
    let species: Species
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 12) {
                Text(species.scientificName)
                    .gaiaFont(.displayMedium)
                    .foregroundStyle(GaiaColor.paperWhite50)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                descriptionText
            }

            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            } label: {
                Text(isExpanded ? "Read Less" : "Read More")
                    .gaiaFont(.pill)
                    .foregroundStyle(GaiaColor.olive)
                    .padding(.horizontal, GaiaSpacing.pillHorizontal)
                    .frame(height: 28)
                    .background(GaiaColor.paperWhite50, in: Capsule())
            }
            .buttonStyle(GaiaPressableCardStyle())
        }
        .padding(.horizontal, GaiaSpacing.lg)
        .padding(.vertical, GaiaSpacing.cardContentInsetWide)
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

    @ViewBuilder
    private var descriptionText: some View {
        let text = Text(species.summary)
            .gaiaFont(.caption2)
            .foregroundStyle(GaiaColor.paperWhite50)
            .frame(maxWidth: 274, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)

        if isExpanded {
            text
        } else {
            text
                .frame(height: 51, alignment: .topLeading)
                .clipped()
        }
    }
}
