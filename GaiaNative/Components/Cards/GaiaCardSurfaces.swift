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
                    .overlay(
                        RoundedRectangle(cornerRadius: GaiaRadius.card, style: .continuous)
                            .stroke(GaiaColor.broccoliBrown100, lineWidth: 1)
                    )
                    .shadow(color: GaiaShadow.smallColor, radius: 14, x: 0, y: 4)
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
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: GaiaRadius.card, style: .continuous)
                            .stroke(GaiaColor.oliveGreen100, lineWidth: 1)
                    )
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
                RoundedRectangle(cornerRadius: GaiaRadius.lg, style: .continuous)
                    .fill(GaiaColor.surfaceStory)
                    .overlay(
                        RoundedRectangle(cornerRadius: GaiaRadius.lg, style: .continuous)
                            .stroke(GaiaColor.broccoliBrown100, lineWidth: 1)
                    )
                    .shadow(color: GaiaShadow.smallColor, radius: 24, x: 0, y: 8)
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
        )
        .clipShape(RoundedRectangle(cornerRadius: GaiaRadius.card, style: .continuous))
    }
}
