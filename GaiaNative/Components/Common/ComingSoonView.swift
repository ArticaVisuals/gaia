import SwiftUI

struct ComingSoonView: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: GaiaSpacing.md) {
            Text(title)
                .font(GaiaTypography.display)
                .foregroundStyle(GaiaColor.olive)
                .multilineTextAlignment(.center)
            Text(subtitle)
                .font(GaiaTypography.body)
                .foregroundStyle(GaiaColor.grey)
                .multilineTextAlignment(.center)
        }
        .padding(GaiaSpacing.lg)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(GaiaColor.paper)
    }
}
