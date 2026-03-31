import SwiftUI

struct ObserveLoadingScreen: View {
    let onComplete: () -> Void
    @State private var didSchedule = false

    var body: some View {
        ZStack {
            GaiaColor.surfacePrimary.ignoresSafeArea()

            VStack(spacing: GaiaSpacing.xl) {
                Spacer()

                ZStack {
                    card(name: "observe-loading-back", y: 26, rotation: -6)
                    card(name: "observe-loading-middle", y: 14, rotation: 5)
                    card(name: "observe-loading-front", y: 0, rotation: 0)
                }
                .frame(height: 360)

                VStack(spacing: GaiaSpacing.sm) {
                    Text("Looking closely...")
                        .font(GaiaTypography.title1)
                        .foregroundStyle(GaiaColor.textPrimary)
                    Text("We’re comparing shape, texture, and habitat cues with recent observations nearby.")
                        .font(GaiaTypography.subheadline)
                        .foregroundStyle(GaiaColor.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, GaiaSpacing.xl)
                }

                Spacer()
            }
        }
        .onAppear {
            guard !didSchedule else { return }
            didSchedule = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                onComplete()
            }
        }
    }

    private func card(name: String, y: CGFloat, rotation: Double) -> some View {
        GaiaAssetImage(name: name)
            .frame(width: 252, height: 312)
            .clipShape(RoundedRectangle(cornerRadius: GaiaRadius.lg, style: .continuous))
            .rotationEffect(.degrees(rotation))
            .offset(y: y)
            .shadow(color: GaiaShadow.smallColor, radius: 18, x: 0, y: 10)
    }
}
