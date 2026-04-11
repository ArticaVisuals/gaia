// figma: https://www.figma.com/design/4e4G3tnSR7AdPbf0jAYPP1/Gaia?node-id=815-17733
import SwiftUI

struct StoryPreviewCard: View {
    let story: StoryCard
    var action: () -> Void = {}

    private let imageAspectRatio: CGFloat = 2912.0 / 1632.0
    private let imageTopOffsetRatio: CGFloat = 0.134
    private let arrowReserveWidth: CGFloat = 40 + GaiaSpacing.md - GaiaSpacing.xs

    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                GeometryReader { proxy in
                    ZStack(alignment: .top) {
                        LinearGradient(
                            stops: [
                                .init(color: GaiaColor.siskin500.opacity(0.5), location: 0),
                                .init(color: GaiaColor.paperWhite50, location: 0.48)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )

                        GaiaAssetImage(name: story.imageAssetName, contentMode: .fit)
                            .frame(width: proxy.size.width)
                            .frame(maxHeight: .infinity, alignment: .top)
                            .offset(y: -proxy.size.height * imageTopOffsetRatio)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
                }
                .frame(maxWidth: .infinity)
                .aspectRatio(imageAspectRatio, contentMode: .fit)
                .clipped()

                VStack(alignment: .leading, spacing: 12) {
                    Text(story.eyebrow)
                        .gaiaFont(.caption)
                        .foregroundStyle(GaiaColor.paperWhite50)
                        .textCase(.uppercase)

                    ZStack(alignment: .topTrailing) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(story.title)
                                .gaiaFont(.displayMedium)
                                .foregroundStyle(GaiaColor.paperWhite50)
                                .frame(maxWidth: 257, alignment: .leading)
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)

                            Text(story.summary)
                                .gaiaFont(.caption2)
                                .foregroundStyle(GaiaColor.paperWhite50)
                                .frame(maxWidth: 252, alignment: .leading)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.trailing, arrowReserveWidth)

                        ZStack {
                            GaiaAssetImage(name: "learn-story-arrow-circle", contentMode: .fit)
                                .frame(width: 40, height: 40)
                            GaiaAssetImage(name: "learn-story-arrow", contentMode: .fit)
                                .frame(width: 15.6, height: 20.1)
                                .rotationEffect(.degrees(90))
                        }
                        .frame(width: 40, height: 40)
                        .offset(y: -20)
                    }
                }
                .padding(GaiaSpacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(GaiaColor.broccoliBrown500)
            }
            .clipShape(RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                    .stroke(Color.black.opacity(0.1), lineWidth: 0.5)
            )
        }
        .buttonStyle(StoryPreviewButtonStyle())
        .accessibilityHint("Opens the story deck")
    }
}

private struct StoryPreviewButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .brightness(configuration.isPressed ? -0.015 : 0)
            .scaleEffect(configuration.isPressed ? 0.987 : 1)
            .offset(y: configuration.isPressed ? 6 : 0)
            .shadow(
                color: GaiaColor.broccoliBrown500.opacity(configuration.isPressed ? 0.24 : 0.55),
                radius: configuration.isPressed ? 14 : 20,
                x: 0,
                y: configuration.isPressed ? 2 : 4
            )
            .animation(.timingCurve(0.2, 0.8, 0.2, 1, duration: 0.18), value: configuration.isPressed)
    }
}
