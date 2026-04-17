// figma: https://www.figma.com/design/4e4G3tnSR7AdPbf0jAYPP1/Gaia?node-id=578-14941
import SwiftUI

struct StatsCard: View {
    let species: Species

    private let columnWidth: CGFloat = 92

    var body: some View {
        HStack(spacing: GaiaSpacing.detailInset) {
            statColumn(label: "Category") {
                GaiaAssetImage(name: "learn-category-badge", contentMode: .fit)
                    .frame(width: 53.3, height: 53.3)
            }

            divider

            statColumn(label: "Status") {
                Circle()
                    .stroke(GaiaColor.olive, lineWidth: 3.265)
                    .frame(width: 54.4, height: 54.4)
                    .overlay {
                        Text(species.status)
                            .font(GaiaTypography.learnStatStatus)
                            .foregroundStyle(GaiaColor.olive)
                    }
            }

            divider

            statColumn(label: "Finds") {
                Text(species.findCountLabel)
                    .gaiaFont(.statValue)
                    .foregroundStyle(GaiaColor.olive)
                    .frame(height: 59)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, GaiaSpacing.cardContentInsetWide)
        .padding(.vertical, GaiaSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                .fill(GaiaColor.paperWhite50)
                .overlay(
                    RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                        .stroke(GaiaColor.broccoliBrown200, lineWidth: 0.5)
                )
                .shadow(color: GaiaShadow.mdColor, radius: GaiaShadow.mdRadius, x: 0, y: GaiaShadow.mdYOffset)
        )
    }

    private var divider: some View {
        Rectangle()
            .fill(GaiaColor.broccoliBrown200)
            .frame(width: 1, height: 54)
    }

    private func statColumn<Content: View>(label: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: GaiaSpacing.cardInset) {
            Text(label)
                .gaiaFont(.caption2)
                .foregroundStyle(GaiaColor.olive)

            content()
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .frame(width: columnWidth)
    }
}
