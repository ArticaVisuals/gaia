// figma: https://www.figma.com/design/4e4G3tnSR7AdPbf0jAYPP1/Gaia?node-id=466-2648 (Organism Card), 465-2606 (Project Card)
import SwiftUI

enum GaiaFindCardStyle {
    static let blurRadius: CGFloat = 2.3
    static let blurMask = LinearGradient(
        stops: [
            .init(color: .clear, location: 0),
            .init(color: .clear, location: 0.22),
            .init(color: .black.opacity(0.58), location: 0.72),
            .init(color: .black, location: 1)
        ],
        startPoint: .top,
        endPoint: .bottom
    )
    static let overlayGradient = LinearGradient(
        stops: [
            .init(color: .clear, location: 0),
            .init(color: .clear, location: 0.22),
            .init(color: Color.black.opacity(0.56), location: 1)
        ],
        startPoint: .top,
        endPoint: .bottom
    )
}

struct GaiaFindCardArtwork<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        ZStack {
            content()

            content()
                .blur(radius: GaiaFindCardStyle.blurRadius)
                .mask(GaiaFindCardStyle.blurMask)

            GaiaFindCardStyle.overlayGradient
        }
    }
}

struct FindCard: View {
    let species: Species
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .bottomLeading) {
                GaiaFindCardArtwork {
                    GaiaAssetImage(name: species.galleryAssetNames.first ?? "coast-live-oak-hero")
                        .frame(maxWidth: .infinity)
                        .frame(height: 184)
                        .clipped()
                }

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
        .buttonStyle(.plain)
    }
}
