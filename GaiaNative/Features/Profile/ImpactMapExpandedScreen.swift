import SwiftUI

struct ImpactMapExpandedScreen: View {
    let observations: [Observation]
    let dismiss: () -> Void

    var body: some View {
        ZStack(alignment: .topLeading) {
            ExploreMapView(
                observations: observations,
                recenterRequestID: nil,
                markerMode: .compactDots
            )
                .ignoresSafeArea()
            ToolbarGlassButton(icon: .back, accessibilityLabel: "Back", action: dismiss)
                .padding(.leading, GaiaSpacing.md)
                .safeAreaPadding(.top, 8)
        }
    }
}
