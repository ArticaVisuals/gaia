import SwiftUI

struct ComingSoonView: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: GaiaSpacing.md) {
            Text(title)
                .gaiaFont(.display)
                .foregroundStyle(GaiaColor.olive)
                .multilineTextAlignment(.center)
            Text(subtitle)
                .gaiaFont(.body)
                .foregroundStyle(GaiaColor.grey)
                .multilineTextAlignment(.center)
        }
        .padding(GaiaSpacing.lg)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(GaiaColor.paper)
    }
}
