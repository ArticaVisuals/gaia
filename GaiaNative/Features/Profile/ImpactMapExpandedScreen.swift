// figma: https://www.figma.com/design/4e4G3tnSR7AdPbf0jAYPP1/Gaia?node-id=1711-181330 (Profile Impact / expanded map overlay)
import SwiftUI

struct ImpactMapExpandedScreen: View {
    let observations: [Observation]
    let dismiss: () -> Void

    var body: some View {
        ZStack(alignment: .topLeading) {
            ExploreMapView(observations: observations, recenterRequestID: nil)
                .ignoresSafeArea()
            ToolbarGlassButton(icon: .back, accessibilityLabel: "Back", action: dismiss)
                .padding(.leading, GaiaSpacing.md)
                .safeAreaPadding(.top, 8)
        }
    }
}
