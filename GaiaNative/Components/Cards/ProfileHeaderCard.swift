// figma: https://www.figma.com/design/4e4G3tnSR7AdPbf0jAYPP1/Gaia?node-id=748-3677 (Person card), 870-13599 (Profile Pictures)
import SwiftUI

struct ProfileHeaderCard: View {
    let profile: ProfileSummary

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [GaiaColor.oliveGreen200, GaiaColor.oliveGreen500],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 72, height: 72)
                .overlay(
                    Text(initials)
                        .font(GaiaTypography.title2Medium)
                        .foregroundStyle(GaiaColor.paperStrong)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(profile.displayName)
                    .font(GaiaTypography.title1Medium)
                    .foregroundStyle(GaiaColor.oliveGreen500)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)

                Text(findsLabel)
                    .font(GaiaTypography.subheadline)
                    .foregroundStyle(GaiaColor.blackishGrey200)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var initials: String {
        profile.displayName
            .split(separator: " ")
            .prefix(2)
            .compactMap { $0.first }
            .map(String.init)
            .joined()
    }

    private var findsLabel: String {
        let parts = profile.impactSummary.split(separator: " ")
        if let first = parts.first, Int(first) != nil {
            return "\(first) finds"
        }
        return "127 finds"
    }
}
