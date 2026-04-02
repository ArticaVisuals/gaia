// figma: https://www.figma.com/design/4e4G3tnSR7AdPbf0jAYPP1/Gaia?node-id=2-123
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
