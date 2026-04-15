import SwiftUI

struct GaiaSurfaceCard<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .padding(GaiaSpacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: GaiaRadius.card, style: .continuous)
                    .fill(GaiaColor.paperWhite50)
                    .overlay(
                        RoundedRectangle(cornerRadius: GaiaRadius.card, style: .continuous)
                            .strokeBorder(GaiaColor.border, lineWidth: 0.5)
                    )
                    .shadow(color: GaiaShadow.cardColor, radius: GaiaShadow.cardRadius, x: 0, y: GaiaShadow.mdYOffset)
            )
    }
}

struct GaiaDataCard<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .padding(GaiaSpacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: GaiaRadius.card, style: .continuous)
                    .fill(GaiaColor.paperWhite50)
                    .overlay(
                        RoundedRectangle(cornerRadius: GaiaRadius.card, style: .continuous)
                            .strokeBorder(GaiaColor.border, lineWidth: 0.5)
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
                RoundedRectangle(cornerRadius: GaiaRadius.storyCard, style: .continuous)
                    .fill(GaiaColor.surfaceStory)
                    .overlay(
                        RoundedRectangle(cornerRadius: GaiaRadius.storyCard, style: .continuous)
                            .strokeBorder(GaiaColor.broccoliBrown100, lineWidth: 1)
                    )
                    .shadow(color: GaiaShadow.storyColor, radius: GaiaShadow.storyRadius, x: 0, y: GaiaShadow.storyYOffset)
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
                .fill(GaiaColor.paperWhite50)
                .overlay(
                    RoundedRectangle(cornerRadius: GaiaRadius.card, style: .continuous)
                        .strokeBorder(GaiaColor.borderStrong, lineWidth: 1)
                )
                .shadow(color: GaiaShadow.cardColor, radius: GaiaShadow.cardRadius, x: 0, y: GaiaShadow.mdYOffset)
        )
        .clipShape(RoundedRectangle(cornerRadius: GaiaRadius.card, style: .continuous))
    }
}
