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
                        .font(GaiaTypography.title)
                        .foregroundStyle(GaiaColor.paperStrong)
                    Text(species.scientificName.uppercased())
                        .font(GaiaTypography.caption2)
                        .foregroundStyle(GaiaColor.paperWhite100.opacity(0.92))
                    Text(species.summary)
                        .font(GaiaTypography.footnote)
                        .foregroundStyle(GaiaColor.paperWhite100.opacity(0.9))
                        .lineLimit(2)
                }
                .padding(GaiaSpacing.md)
            }
            .clipShape(RoundedRectangle(cornerRadius: GaiaRadius.card, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: GaiaRadius.card, style: .continuous)
                    .stroke(GaiaColor.broccoliBrown100, lineWidth: 1)
            )
            .shadow(color: GaiaShadow.smallColor, radius: 20, x: 0, y: 6)
        }
        .buttonStyle(.plain)
    }
}
