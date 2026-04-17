import SwiftUI

struct GaiaMetricCardItem: Identifiable, Hashable {
    let id: String
    let label: String
    let value: String
}

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

// figma: https://www.figma.com/design/4e4G3tnSR7AdPbf0jAYPP1/Gaia?node-id=1711-180823
struct GaiaMetricsCard: View {
    let items: [GaiaMetricCardItem]
    var minHeight: CGFloat = 101

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                metricColumn(item)

                if index < items.count - 1 {
                    Rectangle()
                        .fill(GaiaColor.border)
                        .frame(width: 0.5, height: 53)
                        .accessibilityHidden(true)
                }
            }
        }
        .padding(.horizontal, GaiaSpacing.cardContentInsetWide)
        .padding(.vertical, GaiaSpacing.lg)
        .frame(maxWidth: .infinity, minHeight: minHeight, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: GaiaRadius.card, style: .continuous)
                .fill(GaiaColor.paperWhite50)
                .overlay(
                    RoundedRectangle(cornerRadius: GaiaRadius.card, style: .continuous)
                        .strokeBorder(GaiaColor.border, lineWidth: 0.5)
                )
        )
        .accessibilityElement(children: .contain)
    }

    private func metricColumn(_ item: GaiaMetricCardItem) -> some View {
        VStack(alignment: .center, spacing: GaiaSpacing.cardInset) {
            Text(item.label)
                .gaiaFont(.caption2)
                .foregroundStyle(GaiaColor.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
                .multilineTextAlignment(.center)

            Text(item.value)
                .gaiaFont(.displayMedium)
                .foregroundStyle(GaiaColor.oliveGreen400)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(item.label), \(item.value)")
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
