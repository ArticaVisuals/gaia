// figma: https://www.figma.com/design/X0NcuRE0WKmsqR36cvlcij/Write-Test-Pro?node-id=22-1646&m=dev
import SwiftUI

private enum StoryPreviewCardLayout {
    static let imageAspectRatio: CGFloat = 2912.0 / 1632.0
    static let imageHeightScale: CGFloat = 1.2022
    static let imageVerticalOffsetRatio: CGFloat = 0.134
    static let contentPadding: CGFloat = GaiaSpacing.md
    static let sectionSpacing: CGFloat = GaiaSpacing.md
    static let headerSpacing: CGFloat = GaiaSpacing.cardInset
    static let titleMaxWidth: CGFloat = 257
    static let titleHeight: CGFloat = 56
    static let summaryMaxWidth: CGFloat = 252
    static let summaryHeight: CGFloat = 53
    static let arrowSize: CGFloat = GaiaSpacing.iconXl
    static let arrowVerticalOffset: CGFloat = -21.36
    static let borderWidth: CGFloat = 0.5
}

struct StoryPreviewCard: View {
    let story: StoryCard
    var action: () -> Void = {}

    private var cardShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: GaiaRadius.lg, style: .continuous)
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                storyImage
                    .aspectRatio(StoryPreviewCardLayout.imageAspectRatio, contentMode: .fit)
                    .clipped()

                VStack(alignment: .leading, spacing: StoryPreviewCardLayout.sectionSpacing) {
                    VStack(alignment: .leading, spacing: StoryPreviewCardLayout.headerSpacing) {
                        Text(story.eyebrow)
                            .gaiaFont(.caption)
                            .foregroundStyle(GaiaColor.paperWhite50)
                            .textCase(.uppercase)

                        ZStack(alignment: .topTrailing) {
                            Text(story.title)
                                .gaiaFont(.displayMedium)
                                .foregroundStyle(GaiaColor.paperWhite50)
                                .frame(maxWidth: StoryPreviewCardLayout.titleMaxWidth, alignment: .leading)
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(height: StoryPreviewCardLayout.titleHeight, alignment: .topLeading)
                                .clipped()

                            storyArrow
                                .offset(y: StoryPreviewCardLayout.arrowVerticalOffset)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Text(story.summary)
                        .gaiaFont(.caption2)
                        .foregroundStyle(GaiaColor.paperWhite50)
                        .frame(maxWidth: StoryPreviewCardLayout.summaryMaxWidth, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(height: StoryPreviewCardLayout.summaryHeight, alignment: .topLeading)
                        .clipped()
                }
                .padding(StoryPreviewCardLayout.contentPadding)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(storyContentBackground)
            }
            .clipShape(cardShape)
            .overlay {
                cardShape
                    .strokeBorder(Color.black.opacity(0.1), lineWidth: StoryPreviewCardLayout.borderWidth)
            }
        }
        .buttonStyle(GaiaPressableCardStyle())
    }

    private var storyContentBackground: some View {
        GaiaColor.broccoliBrown400
            .shadow(
                color: GaiaShadow.smallColor,
                radius: GaiaShadow.smallRadius,
                x: 0,
                y: GaiaShadow.smallYOffset
            )
    }

    private var storyImage: some View {
        GeometryReader { proxy in
            ZStack {
                GaiaAssetImage(name: story.imageAssetName, contentMode: .fill)
                    .frame(
                        width: proxy.size.width,
                        height: proxy.size.height * StoryPreviewCardLayout.imageHeightScale
                    )
                    .offset(y: -(proxy.size.height * StoryPreviewCardLayout.imageVerticalOffsetRatio))

                LinearGradient(
                    stops: [
                        .init(color: GaiaColor.siskin500.opacity(0.5), location: 0),
                        .init(color: GaiaColor.paperWhite50.opacity(0.82), location: 0.48),
                        .init(color: GaiaColor.paperWhite50.opacity(0), location: 1)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .clipped()
    }

    private var storyArrow: some View {
        ZStack {
            GaiaAssetImage(name: "learn-story-arrow-circle", contentMode: .fit)
                .frame(width: StoryPreviewCardLayout.arrowSize, height: StoryPreviewCardLayout.arrowSize)

            GaiaAssetImage(name: "learn-story-arrow", contentMode: .fit)
                .frame(width: 15.6, height: 20.1)
                .rotationEffect(.degrees(90))
        }
        .frame(width: StoryPreviewCardLayout.arrowSize, height: StoryPreviewCardLayout.arrowSize)
        .accessibilityHidden(true)
    }
}
