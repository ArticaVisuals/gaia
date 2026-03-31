import SwiftUI

struct ExpandMapButton: View {
    let action: () -> Void

    var body: some View {
        GlassCircleButton(size: 44, action: action) {
            GaiaIcon(kind: .expand, size: 24)
        }
        .accessibilityLabel("Expand map")
    }
}
