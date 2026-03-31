import SwiftUI

struct GaiaPill: View {
    let title: String
    var fill: Color = GaiaColor.brown
    var foreground: Color = GaiaColor.paperStrong

    var body: some View {
        Text(title)
            .font(GaiaTypography.caption)
            .foregroundStyle(foreground)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(fill, in: Capsule())
    }
}
