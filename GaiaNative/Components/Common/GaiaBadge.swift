import SwiftUI

struct GaiaBadge: View {
    let title: String

    var body: some View {
        Text(title)
            .font(GaiaTypography.caption)
            .foregroundStyle(GaiaColor.olive)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(GaiaColor.paperStrong, in: Capsule())
    }
}
