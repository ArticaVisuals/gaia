import SwiftUI

struct MapOverlayProfileCard: View {
    let name: String
    let subtitle: String

    var body: some View {
        HStack(spacing: GaiaSpacing.sm) {
            Circle()
                .fill(GaiaColor.border.opacity(0.4))
                .frame(width: 48, height: 48)
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(GaiaTypography.title)
                    .foregroundStyle(GaiaColor.olive)
                Text(subtitle)
                    .font(GaiaTypography.caption)
                    .foregroundStyle(GaiaColor.greyMuted)
            }
            Spacer()
        }
        .padding(8)
        .background(GlassCardBackground(cornerRadius: GaiaRadius.md))
    }
}
