import SwiftUI

struct ToolbarGlassPill: View {
    let primaryAction: () -> Void
    let secondaryAction: () -> Void
    var showsShadow: Bool = true

    var body: some View {
        GlassPillButton(showsShadow: showsShadow) {
            Button(action: primaryAction) {
                GaiaAssetImage(name: "gaia-icon-plus-24", contentMode: .fit)
                    .frame(width: 20, height: 20.92)
                    .frame(width: 36, height: 36)
            }
            .buttonStyle(GlassReactiveButtonStyle())
            .accessibilityLabel("Add")

            Button(action: secondaryAction) {
                ZStack {
                    GaiaAssetImage(name: "gaia-icon-share-base-24", contentMode: .fit)
                        .frame(width: 17.19, height: 16.21)
                        .offset(x: -0.14, y: 3.9)
                    GaiaAssetImage(name: "gaia-icon-share-arrow-24", contentMode: .fit)
                        .frame(width: 9.37, height: 16.15)
                        .offset(x: -0.14, y: -3.93)
                }
                .frame(width: 36, height: 36)
            }
            .buttonStyle(GlassReactiveButtonStyle())
            .accessibilityLabel("Share")
        }
    }
}
