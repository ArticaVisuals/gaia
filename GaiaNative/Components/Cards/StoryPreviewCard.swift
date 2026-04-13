// figma: https://www.figma.com/design/4e4G3tnSR7AdPbf0jAYPP1/Gaia?node-id=1146-18394
import SwiftUI

struct StoryPreviewCard: View {
    let story: StoryCard
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                StoryPreviewCardHeroImage(assetName: story.imageAssetName)

                StoryPreviewCardBody(
                    eyebrow: story.eyebrow,
                    title: story.title,
                    summary: story.summary
                )
            }
            .clipShape(RoundedRectangle(cornerRadius: StoryPreviewCardLayout.cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: StoryPreviewCardLayout.cornerRadius, style: .continuous)
                    .stroke(GaiaColor.broccoliBrown200, lineWidth: StoryPreviewCardLayout.borderWidth)
            )
        }
        .buttonStyle(StoryPreviewButtonStyle())
        .accessibilityLabel("\(story.eyebrow). \(story.title). \(story.summary)")
        .accessibilityHint("Opens the story deck")
    }
}

private struct StoryPreviewButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .brightness(configuration.isPressed ? -0.015 : 0)
            .scaleEffect(configuration.isPressed ? 0.987 : 1)
            .offset(y: configuration.isPressed ? 4 : 0)
            .shadow(
                color: configuration.isPressed ? GaiaShadow.smallColor.opacity(0.3) : .clear,
                radius: configuration.isPressed ? 10 : 0,
                x: 0,
                y: configuration.isPressed ? 2 : 0
            )
            .animation(.timingCurve(0.2, 0.8, 0.2, 1, duration: 0.18), value: configuration.isPressed)
    }
}

private enum StoryPreviewCardLayout {
    static let cornerRadius: CGFloat = GaiaRadius.card
    static let borderWidth: CGFloat = 0.5
    static let imageAspectRatio: CGFloat = 2912.0 / 1632.0
    static let imageHeightScale: CGFloat = 1962.0 / 1632.0
    static let imageTopOffsetRatio: CGFloat = 0.134
    static let contentPadding: CGFloat = GaiaSpacing.md
    static let copySpacing: CGFloat = GaiaSpacing.md
    static let headingSpacing: CGFloat = GaiaSpacing.cardInset
    static let titleHeight: CGFloat = 56
    static let titleMaxWidth: CGFloat = 257
    static let summaryMaxWidth: CGFloat = 252
    static let arrowSize: CGFloat = 40
    static let arrowTrailingInset: CGFloat = 13
    static let arrowBottomInset: CGFloat = GaiaSpacing.md
}

private struct StoryPreviewCardHeroImage: View {
    let assetName: String

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .top) {
                LinearGradient(
                    stops: [
                        .init(color: GaiaColor.siskin500.opacity(0.5), location: 0),
                        .init(color: GaiaColor.paperWhite50, location: 0.48016)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                GaiaAssetImage(name: assetName, contentMode: .fill)
                    .frame(
                        width: proxy.size.width,
                        height: proxy.size.height * StoryPreviewCardLayout.imageHeightScale,
                        alignment: .top
                    )
                    .offset(y: -proxy.size.height * StoryPreviewCardLayout.imageTopOffsetRatio)
                    .accessibilityHidden(true)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(StoryPreviewCardLayout.imageAspectRatio, contentMode: .fit)
        .clipped()
    }
}

private struct StoryPreviewCardBody: View {
    let eyebrow: String
    let title: String
    let summary: String

    var body: some View {
        VStack(alignment: .leading, spacing: StoryPreviewCardLayout.copySpacing) {
            VStack(alignment: .leading, spacing: StoryPreviewCardLayout.headingSpacing) {
                Text(eyebrow)
                    .gaiaFont(.caption)
                    .foregroundStyle(GaiaColor.paperWhite50)
                    .textCase(.uppercase)

                Text(title)
                    .gaiaFont(.displayMedium)
                    .foregroundStyle(GaiaColor.paperWhite50)
                    .frame(
                        maxWidth: StoryPreviewCardLayout.titleMaxWidth,
                        minHeight: StoryPreviewCardLayout.titleHeight,
                        maxHeight: StoryPreviewCardLayout.titleHeight,
                        alignment: .leading
                    )
                    .lineLimit(2, reservesSpace: true)
                    .multilineTextAlignment(.leading)
            }

            Text(summary)
                .gaiaFont(.caption2)
                .foregroundStyle(GaiaColor.paperWhite50)
                .frame(maxWidth: StoryPreviewCardLayout.summaryMaxWidth, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(StoryPreviewCardLayout.contentPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(GaiaColor.broccoliBrown500)
        .overlay(alignment: .bottomTrailing) {
            StoryPreviewCardArrow()
                .padding(.trailing, StoryPreviewCardLayout.arrowTrailingInset)
                .padding(.bottom, StoryPreviewCardLayout.arrowBottomInset)
        }
    }
}

private struct StoryPreviewCardArrow: View {
    var body: some View {
        ZStack {
            GaiaAssetImage(name: "learn-story-arrow-circle", contentMode: .fit)
                .frame(
                    width: StoryPreviewCardLayout.arrowSize,
                    height: StoryPreviewCardLayout.arrowSize
                )
            GaiaAssetImage(name: "learn-story-arrow", contentMode: .fit)
                .frame(width: 15.6, height: 20.1)
                .rotationEffect(.degrees(90))
        }
        .frame(width: StoryPreviewCardLayout.arrowSize, height: StoryPreviewCardLayout.arrowSize)
        .accessibilityHidden(true)
    }
}
