// figma: https://www.figma.com/design/4e4G3tnSR7AdPbf0jAYPP1/Gaia?node-id=1711-181366 (Profile Information), 870-13599 (Profile Pictures)
import SwiftUI

struct ProfileHeaderCard: View {
    let profile: ProfileSummary

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            GaiaProfileAvatar(
                imageName: "find-avatar-alice",
                size: 72,
                strokeColor: Color.black.opacity(0.1)
            )

            VStack(alignment: .leading, spacing: 8) {
                Text(profile.displayName)
                    .gaiaFont(.title1Medium)
                    .foregroundStyle(GaiaColor.oliveGreen500)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)

                HStack(spacing: 4) {
                    GaiaIcon(kind: .binoculars, size: 22, tint: GaiaColor.blackishGrey500)
                        .frame(width: 22, height: 15.678)

                    Text(findsCount)
                        .font(GaiaTypography.subheadline)
                        .foregroundStyle(GaiaColor.blackishGrey500)
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, GaiaSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(profile.displayName), \(findsCount) finds")
    }

    private var findsCount: String {
        let parts = profile.impactSummary.split(separator: " ")
        if let first = parts.first, Int(first) != nil {
            return String(first)
        }
        return "127"
    }
}
