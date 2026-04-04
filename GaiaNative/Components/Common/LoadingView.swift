import SwiftUI

struct LoadingView: View {
    let title: String

    var body: some View {
        VStack(spacing: GaiaSpacing.md) {
            ProgressView()
                .tint(GaiaColor.olive)
            Text(title)
                .gaiaFont(.footnote)
                .foregroundStyle(GaiaColor.grey)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
