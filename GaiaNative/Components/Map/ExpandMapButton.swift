// figma: https://www.figma.com/design/4e4G3tnSR7AdPbf0jAYPP1/Gaia?node-id=870-15537
import SwiftUI

struct ExpandMapButton: View {
    let action: () -> Void

    private enum Layout {
        static let buttonSize: CGFloat = 40
        static let iconSize: CGFloat = 24
    }

    var body: some View {
        GlassCircleButton(size: Layout.buttonSize, action: action) {
            GaiaIcon(kind: .expand, size: Layout.iconSize)
        }
        .accessibilityLabel("Expand map")
    }
}
