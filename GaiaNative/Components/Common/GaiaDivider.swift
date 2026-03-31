import SwiftUI

struct GaiaDivider: View {
    var body: some View {
        Rectangle()
            .fill(GaiaColor.border.opacity(0.75))
            .frame(height: 1)
    }
}
