import SwiftUI

struct ExpandMapButton: View {
    let action: () -> Void

    var body: some View {
        GlassCircleButton(size: 44, action: action) {
            ZStack {
                GaiaAssetImage(name: "figma-expand-a-tight", contentMode: .fit)
                    .frame(width: 10.53, height: 10.94)
                    .rotationEffect(.degrees(-135))
                    .offset(x: -4.2, y: 4.2)

                GaiaAssetImage(name: "figma-expand-b-tight", contentMode: .fit)
                    .frame(width: 10.53, height: 10.94)
                    .rotationEffect(.degrees(45))
                    .offset(x: 4.2, y: -4.2)
            }
            .frame(width: 24, height: 24)
        }
        .accessibilityLabel("Expand map")
    }
}
