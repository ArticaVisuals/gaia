import SwiftUI

struct GaiaSurfaceCard<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .padding(GaiaSpacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: GaiaRadius.card, style: .continuous)
                    .fill(GaiaColor.surfaceCard)
                    .shadow(color: GaiaShadow.cardColor, radius: GaiaShadow.cardRadius, x: 0, y: GaiaShadow.mdYOffset)
            )
    }
}

struct GaiaDataCard<Content: View>: View {
    var cornerRadius: CGFloat = GaiaRadius.card
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .padding(GaiaSpacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(GaiaColor.paperWhite50)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(GaiaColor.broccoliBrown200, lineWidth: 0.5)
                    )
                    .shadow(color: GaiaShadow.cardColor, radius: GaiaShadow.cardRadius, x: 0, y: GaiaShadow.mdYOffset)
            )
    }
}

struct GaiaStoryCardSurface<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: GaiaRadius.card, style: .continuous)
                    .fill(GaiaColor.surfaceStory)
                    .overlay(
                        RoundedRectangle(cornerRadius: GaiaRadius.card, style: .continuous)
                            .stroke(GaiaColor.broccoliBrown200, lineWidth: 0.5)
                    )
                    .shadow(color: GaiaShadow.smallColor, radius: GaiaShadow.smallRadius, x: 0, y: GaiaShadow.smallYOffset)
            )
    }
}

struct GaiaActionCard<Content: View>: View {
    var accent: Color = GaiaColor.brandPrimary
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(accent)
                .frame(height: 4)
            content()
                .padding(GaiaSpacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(
            RoundedRectangle(cornerRadius: GaiaRadius.card, style: .continuous)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: GaiaRadius.card, style: .continuous)
                        .stroke(GaiaColor.oliveGreen100, lineWidth: 1)
                )
                .shadow(color: GaiaShadow.cardColor, radius: GaiaShadow.cardRadius, x: 0, y: GaiaShadow.mdYOffset)
        )
        .clipShape(RoundedRectangle(cornerRadius: GaiaRadius.card, style: .continuous))
    }
}
