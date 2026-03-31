import SwiftUI

struct ToolbarGlassPill: View {
    let primaryAction: () -> Void
    let secondaryAction: () -> Void

    var body: some View {
        GlassPillButton {
            Button(action: primaryAction) {
                GaiaAssetImage(name: "figma-plus-tight", contentMode: .fit)
                    .frame(width: 22.5, height: 23.5)
                    .frame(width: 36, height: 36)
            }
            .buttonStyle(GlassReactiveButtonStyle())
            .accessibilityLabel("Add")

            Button(action: secondaryAction) {
                ZStack {
                    GaiaAssetImage(name: "figma-share-base-tight", contentMode: .fit)
                        .frame(width: 19.3, height: 18.2)
                        .offset(x: 0.16, y: 4.38)
                    GaiaAssetImage(name: "figma-share-arrow-tight", contentMode: .fit)
                        .frame(width: 10.5, height: 18.2)
                        .offset(x: 0.16, y: -4.42)
                }
                .frame(width: 36, height: 36)
            }
            .buttonStyle(GlassReactiveButtonStyle())
            .accessibilityLabel("Share")
        }
    }
}
