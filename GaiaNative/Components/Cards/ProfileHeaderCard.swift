// figma: https://www.figma.com/design/4e4G3tnSR7AdPbf0jAYPP1/Gaia?node-id=748-3677 (Person card), 870-13599 (Profile Pictures)
import SwiftUI

struct ProfileHeaderCard: View {
    let profile: ProfileSummary
    private let avatarSize: CGFloat = 72

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            GaiaProfileAvatar(
                imageName: "find-avatar-alice",
                size: avatarSize,
                borderWidth: 0.5,
                strokeColor: GaiaColor.oliveGreen100
            )

            VStack(alignment: .leading, spacing: 2) {
                Text(profile.displayName)
                    .gaiaFont(.title1Medium)
                    .foregroundStyle(GaiaColor.oliveGreen500)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)

                Text(findsLabel)
                    .gaiaFont(.subheadline)
                    .foregroundStyle(GaiaColor.blackishGrey200)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, GaiaSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var findsLabel: String {
        let parts = profile.impactSummary.split(separator: " ")
        if let first = parts.first, Int(first) != nil {
            return "\(first) finds"
        }
        return "127 finds"
    }
}
