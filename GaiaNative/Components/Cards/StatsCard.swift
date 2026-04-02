// figma: https://www.figma.com/design/4e4G3tnSR7AdPbf0jAYPP1/Gaia?node-id=578-14941
import SwiftUI

struct StatsCard: View {
    let species: Species

    var body: some View {
        HStack(spacing: 15) {
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
                            .font(.custom("NewSpirit-Bold", size: 21.8))
                            .foregroundStyle(GaiaColor.olive)
                    }
            }

            divider

            statColumn(label: "Finds") {
                Text(species.findCountLabel)
                    .font(.custom("NewSpirit-Medium", size: 30.5))
                    .foregroundStyle(GaiaColor.olive)
                    .tracking(-0.27)
                    .frame(height: 59)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
        .padding(.vertical, 24)
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
            .frame(width: 1, height: 57)
    }

    private func statColumn<Content: View>(label: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 12) {
            Text(label)
                .font(.custom("Neue Haas Unica W1G", size: 12))
                .foregroundStyle(GaiaColor.olive)

            content()
                .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
    }
}
