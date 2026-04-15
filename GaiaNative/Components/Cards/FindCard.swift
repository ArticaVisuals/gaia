// figma: https://www.figma.com/design/4e4G3tnSR7AdPbf0jAYPP1/Gaia?node-id=466-2648 (Organism Card), 465-2606 (Project Card)
import SwiftUI

struct FindCard: View {
    let species: Species
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .bottomLeading) {
                GaiaAssetImage(name: species.galleryAssetNames.first ?? "coast-live-oak-hero")
                    .frame(height: 184)
                    .clipped()

                LinearGradient(
                    colors: [.clear, GaiaColor.inkBlack500.opacity(0.72)],
                    startPoint: .top,
                    endPoint: .bottom
                )

                VStack(alignment: .leading, spacing: 4) {
                    Text(species.commonName)
                        .gaiaFont(.title3Medium)
                        .foregroundStyle(GaiaColor.paperStrong)
                    Text(species.scientificName.uppercased())
                        .gaiaFont(.caption2)
                        .foregroundStyle(GaiaColor.paperWhite100.opacity(0.92))
                    Text(species.summary)
                        .gaiaFont(.footnote)
                        .foregroundStyle(GaiaColor.paperWhite100.opacity(0.9))
                        .lineLimit(2)
                }
                .padding(GaiaSpacing.md)
            }
            .clipShape(RoundedRectangle(cornerRadius: GaiaRadius.card, style: .continuous))
        }
        .buttonStyle(GaiaPressableCardStyle())
    }
}
