import SwiftUI

struct ProfileCommunityTab: View {
    let posts: [CommunityPost]

    var body: some View {
        VStack(alignment: .leading, spacing: GaiaSpacing.lg) {
            GaiaActionCard(accent: GaiaColor.indigoBlue500) {
                VStack(alignment: .leading, spacing: GaiaSpacing.sm) {
                    Text("Join a local project")
                        .font(GaiaTypography.calloutMedium)
                        .foregroundStyle(GaiaColor.textPrimary)
                    Text("Your recent oak observations could help a nearby habitat recovery group build a stronger record.")
                        .font(GaiaTypography.subheadline)
                        .foregroundStyle(GaiaColor.textSecondary)
                    GaiaPill(title: "Explore Projects", fill: GaiaColor.indigoBlue500, foreground: GaiaColor.paperStrong)
                }
            }

            GaiaSectionHeader(title: "Community")

            ForEach(posts) { post in
                GaiaDataCard {
                    VStack(alignment: .leading, spacing: GaiaSpacing.xs) {
                        Text(post.author)
                            .font(GaiaTypography.caption2)
                            .foregroundStyle(GaiaColor.greyMuted)
                        Text(post.title)
                            .font(GaiaTypography.calloutMedium)
                            .foregroundStyle(GaiaColor.textPrimary)
                        Text(post.subtitle)
                            .font(GaiaTypography.subheadline)
                            .foregroundStyle(GaiaColor.textSecondary)
                    }
                }
            }
        }
    }
}
