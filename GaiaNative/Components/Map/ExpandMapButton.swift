// figma: https://www.figma.com/design/4e4G3tnSR7AdPbf0jAYPP1/Gaia?node-id=870-15537
import SwiftUI

struct ExpandMapButton: View {
    let action: () -> Void

    var body: some View {
        GlassCircleButton(size: 44, action: action) {
            GaiaIcon(kind: .expand, size: 24, tint: GaiaColor.inkBlack900)
        }
        .accessibilityLabel("Expand map")
    }
}
