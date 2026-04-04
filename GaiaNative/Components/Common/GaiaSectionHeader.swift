import SwiftUI

struct GaiaSectionHeader: View {
    let title: String
    var eyebrow: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            if let eyebrow {
                Text(eyebrow)
                    .gaiaFont(.caption2)
                    .foregroundStyle(GaiaColor.greyMuted)
                    .textCase(.uppercase)
            }
            Text(title)
                .gaiaFont(.title3Medium)
                .foregroundStyle(GaiaColor.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
