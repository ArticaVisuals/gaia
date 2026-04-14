import SwiftUI

struct LearnMapExpandedScreen: View {
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

private enum FindMapExpandedLayout {
    static let singleObservationZoom: CGFloat = 14.0
}

struct FindMapExpandedScreen: View {
    let observation: Observation
    let dismiss: () -> Void

    var body: some View {
        ZStack(alignment: .topLeading) {
            ExploreMapView(
                observations: [observation],
                recenterRequestID: nil,
                onSelectObservation: nil,
                showsMarkers: true,
                initialZoomOverride: FindMapExpandedLayout.singleObservationZoom
            )
            .ignoresSafeArea()

            ToolbarGlassButton(icon: .back, accessibilityLabel: "Back", action: dismiss)
                .padding(.leading, GaiaSpacing.md)
                .safeAreaPadding(.top, 8)
        }
    }
}
