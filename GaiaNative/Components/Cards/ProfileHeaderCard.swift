// figma: https://www.figma.com/design/4e4G3tnSR7AdPbf0jAYPP1/Gaia?node-id=748-3677 (Person card), 870-13599 (Profile Pictures)
import SwiftUI

struct ProfileHeaderCard: View {
    let profile: ProfileSummary

    var body: some View {
        HStack(alignment: .top, spacing: GaiaSpacing.md) {
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

            VStack(alignment: .leading, spacing: 6) {
                Text(profile.displayName)
                    .font(GaiaTypography.displayMedium)
                    .foregroundStyle(GaiaColor.textPrimary)
                Text(profile.headline)
                    .font(GaiaTypography.subheadline)
                    .foregroundStyle(GaiaColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(.top, 12)
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
}
