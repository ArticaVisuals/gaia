import SwiftUI

struct StoryPreviewCard: View {
    let story: StoryCard
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            GaiaStoryCardSurface {
                VStack(alignment: .leading, spacing: GaiaSpacing.md) {
                    GaiaAssetImage(name: story.imageAssetName)
                        .frame(maxWidth: .infinity)
                        .frame(height: 176)
                        .clipShape(RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous))

                    Text(story.eyebrow)
                        .font(GaiaTypography.caption2Medium)
                        .foregroundStyle(GaiaColor.textWarmSecondary)
                        .textCase(.uppercase)

                    HStack(alignment: .top, spacing: GaiaSpacing.md) {
                        VStack(alignment: .leading, spacing: GaiaSpacing.sm) {
                            Text(story.title)
                                .font(GaiaTypography.title1)
                                .foregroundStyle(GaiaColor.textPrimary)
                            Text(story.summary)
                                .font(GaiaTypography.subheadline)
                                .foregroundStyle(GaiaColor.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        Spacer(minLength: 0)

                        Circle()
                            .fill(GaiaColor.paperStrong.opacity(0.92))
                            .frame(width: 36, height: 36)
                            .overlay(
                                GaiaIcon(kind: .circleArrowRight)
                                    .frame(width: 14, height: 14)
                                    .foregroundStyle(GaiaColor.olive)
                            )
                            .overlay(
                                Circle()
                                    .stroke(GaiaColor.broccoliBrown100, lineWidth: 1)
                            )
                    }
                }
            }
        }
        .buttonStyle(.plain)
    }
}
