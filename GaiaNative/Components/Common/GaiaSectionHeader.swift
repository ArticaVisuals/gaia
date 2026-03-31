import SwiftUI

struct GaiaSectionHeader: View {
    let title: String
    var eyebrow: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            if let eyebrow {
                Text(eyebrow)
                    .font(GaiaTypography.caption2)
                    .foregroundStyle(GaiaColor.greyMuted)
                    .textCase(.uppercase)
            }
            Text(title)
                .font(GaiaTypography.title)
                .foregroundStyle(GaiaColor.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
