// figma: https://www.figma.com/design/4e4G3tnSR7AdPbf0jAYPP1/Gaia?node-id=601-19045
import SwiftUI

struct GaiaPill: View {
    let title: String
    var fill: Color = GaiaColor.brown
    var foreground: Color = GaiaColor.paperStrong

    var body: some View {
        Text(title)
            .gaiaFont(.footnote)
            .foregroundStyle(foreground)
            .padding(.horizontal, 16)
            .frame(height: 29)
            .background(fill, in: Capsule())
    }
}
