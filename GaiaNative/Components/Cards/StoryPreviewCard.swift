// figma: https://www.figma.com/design/4e4G3tnSR7AdPbf0jAYPP1/Gaia?node-id=815-17733
import SwiftUI

struct StoryPreviewCard: View {
    let story: StoryCard
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                ZStack {
                    LinearGradient(
                        stops: [
                            .init(color: GaiaColor.siskin500.opacity(0.22), location: 0),
                            .init(color: GaiaColor.paperWhite500.opacity(0.06), location: 0.52),
                            .init(color: GaiaColor.paperWhite500.opacity(0), location: 1)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )

                    GaiaAssetImage(name: story.imageAssetName, contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.horizontal, 10)
                        .padding(.top, 10)
                        .padding(.bottom, 2)
                        .frame(maxHeight: .infinity, alignment: .bottom)
                }
                .aspectRatio(2912.0 / 1632.0, contentMode: .fit)
                .clipped()

                VStack(alignment: .leading, spacing: 12) {
                    Text(story.eyebrow)
                        .font(.custom("Neue Haas Unica W1G", size: 11))
                        .foregroundStyle(GaiaColor.paperWhite50)
                        .tracking(0.25)
                        .textCase(.uppercase)

                    HStack(alignment: .top, spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(story.title)
                                .font(GaiaTypography.displayMedium)
                                .foregroundStyle(GaiaColor.paperWhite50)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .multilineTextAlignment(.leading)

                            Text(story.summary)
                                .font(.custom("Neue Haas Unica W1G", size: 12))
                                .foregroundStyle(GaiaColor.paperWhite500)
                                .lineSpacing(2.4)
                                .frame(maxWidth: 252, alignment: .leading)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        ZStack {
                            GaiaAssetImage(name: "learn-story-arrow-circle", contentMode: .fit)
                                .frame(width: 40, height: 40)
                            GaiaAssetImage(name: "learn-story-arrow", contentMode: .fit)
                                .frame(width: 15.6, height: 20.1)
                                .rotationEffect(.degrees(90))
                        }
                        .frame(width: 40, height: 40)
                        .padding(.top, -4)
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(GaiaColor.broccoliBrown500)
            }
            .clipShape(RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                    .stroke(Color.black.opacity(0.1), lineWidth: 0.5)
            )
            .shadow(color: GaiaColor.broccoliBrown500.opacity(0.55), radius: 20, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}
