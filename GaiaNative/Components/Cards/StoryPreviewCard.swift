// figma: https://www.figma.com/design/4e4G3tnSR7AdPbf0jAYPP1/Gaia?node-id=815-17733
import SwiftUI

struct StoryPreviewCard: View {
    let story: StoryCard
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                storyImage
                    .aspectRatio(2912.0 / 1632.0, contentMode: .fit)
                    .clipped()

                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(story.eyebrow)
                            .gaiaFont(.caption)
                            .foregroundStyle(GaiaColor.paperWhite50)
                            .textCase(.uppercase)

                        HStack(alignment: .top, spacing: 12) {
                            Text(story.title)
                                .gaiaFont(.displayMedium)
                                .foregroundStyle(GaiaColor.paperWhite50)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .fixedSize(horizontal: false, vertical: true)

                            storyArrow
                                .padding(.top, -4)
                        }
                    }

                    Text(story.summary)
                        .gaiaFont(.caption2)
                        .foregroundStyle(GaiaColor.paperWhite100)
                        .frame(maxWidth: 252, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(GaiaSpacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(GaiaColor.broccoliBrown400)
            }
            .clipShape(RoundedRectangle(cornerRadius: GaiaRadius.lg, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: GaiaRadius.lg, style: .continuous)
                    .stroke(Color.black.opacity(0.1), lineWidth: 0.5)
            )
            .shadow(color: GaiaShadow.smallColor, radius: GaiaShadow.smallRadius, x: 0, y: GaiaShadow.smallYOffset)
        }
        .buttonStyle(GaiaPressableCardStyle())
    }

    private var storyImage: some View {
        GeometryReader { proxy in
            ZStack {
                GaiaAssetImage(name: story.imageAssetName, contentMode: .fill)
                    .frame(
                        width: proxy.size.width,
                        height: proxy.size.height * 1.20
                    )
                    .offset(y: -(proxy.size.height * 0.13))

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
                .frame(width: 40, height: 40)

            GaiaAssetImage(name: "learn-story-arrow", contentMode: .fit)
                .frame(width: 15.6, height: 20.1)
                .rotationEffect(.degrees(90))
        }
        .frame(width: 40, height: 40)
    }
}
