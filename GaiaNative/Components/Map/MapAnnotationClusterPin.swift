import SwiftUI

struct MapAnnotationClusterPin: View {
    let count: Int

    private let pinSize: CGFloat = 62
    private let innerSize: CGFloat = 57

    var body: some View {
        ZStack {
            MapAnnotationGlassShell(size: pinSize)

            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 123 / 255, green: 179 / 255, blue: 105 / 255),
                            Color(red: 110 / 255, green: 145 / 255, blue: 82 / 255)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: innerSize, height: innerSize)

            Text("\(count)")
                .font(.system(size: 30, weight: .regular, design: .monospaced))
                .tracking(-2)
                .foregroundStyle(Color(red: 224 / 255, green: 242 / 255, blue: 218 / 255))
        }
        .frame(width: pinSize, height: pinSize)
        .shadow(color: GaiaShadow.greenGlow, radius: 18, x: 0, y: 12)
    }
}
