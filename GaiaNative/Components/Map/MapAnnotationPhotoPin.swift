// figma: https://www.figma.com/design/4e4G3tnSR7AdPbf0jAYPP1/Gaia?node-id=624-2133
import SwiftUI
import UIKit

struct MapAnnotationPhotoPin: View {
    var imageName: String?

    var body: some View {
        MapAnnotationPinFrame {
            GaiaAssetImage(name: imageName ?? "none")
                .frame(
                    width: MapAnnotationPinStyle.innerDiameter,
                    height: MapAnnotationPinStyle.innerDiameter
                )
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(MapAnnotationPinStyle.ringColor, lineWidth: MapAnnotationPinStyle.ringStrokeWidth)
                )
        }
    }
}

struct MapAnnotationBlankPin: View {
    var body: some View {
        MapAnnotationFilledOrb()
    }
}

struct MapAnnotationDotPin: View {
    private let pinSize: CGFloat = 22

    var body: some View {
        Circle()
            .fill(
                LinearGradient(
                    colors: [
                        GaiaColor.grassGreen500,
                        GaiaColor.oliveGreen500
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: pinSize, height: pinSize)
            .shadow(color: GaiaColor.greenGlow.opacity(0.55), radius: 2, x: 0.5, y: 1)
            .shadow(color: GaiaColor.greenGlow.opacity(0.18), radius: 6, x: 0, y: 3)
    }
}

struct MapAnnotationPinFrame<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack { content }
        .frame(width: MapAnnotationPinStyle.pinSize, height: MapAnnotationPinStyle.pinSize)
        .gaiaPinGlow()
    }
}

struct MapAnnotationFilledOrb: View {
    var body: some View {
        MapAnnotationPinFrame {
            Circle()
                .fill(MapAnnotationPinStyle.fillGradient)
                .frame(
                    width: MapAnnotationPinStyle.innerDiameter,
                    height: MapAnnotationPinStyle.innerDiameter
                )
                .overlay(
                    Circle()
                        .stroke(MapAnnotationPinStyle.ringColor, lineWidth: MapAnnotationPinStyle.ringStrokeWidth)
                )
                .overlay(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    GaiaColor.neutralWhite.opacity(0.16),
                                    GaiaColor.neutralWhite.opacity(0.04),
                                    .clear
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                )
                .compositingGroup()
                .clipShape(Circle())
        }
    }
}

struct MapAnnotationCountPinLabel: View {
    let count: Int

    var body: some View {
        Text("\(count)")
            .font(MapAnnotationPinStyle.numberFont)
            .tracking(MapAnnotationPinStyle.numberTracking)
            .monospacedDigit()
            .foregroundStyle(MapAnnotationPinStyle.numberColor)
            .shadow(color: GaiaShadow.smallColor, radius: GaiaShadow.smallRadius, x: 0, y: GaiaShadow.smallYOffset)
            .lineLimit(1)
            .minimumScaleFactor(0.72)
            .padding(.horizontal, GaiaSpacing.xs)
            .offset(y: -0.5)
    }
}

struct MapAnnotationCountPin: View {
    let count: Int

    var body: some View {
        ZStack {
            MapAnnotationFilledOrb()
            MapAnnotationCountPinLabel(count: count)
        }
    }
}

enum MapAnnotationPinStyle {
    static let pinSize: CGFloat = 62
    static let innerDiameter: CGFloat = 57.343
    static let ringStrokeWidth: CGFloat = 1.5
    static let ringColor = GaiaColor.pinRing
    static let fillGradient = LinearGradient(
        colors: [
            GaiaColor.pinFillTop,
            GaiaColor.pinFillBottom
        ],
        startPoint: .top,
        endPoint: .bottom
    )
    static let numberColor = GaiaColor.pinText
    static let numberSize: CGFloat = 32.512
    static let numberTracking: CGFloat = -2
    static let numberFontCandidates = [
        "IBM Plex Mono",
        "IBMPlexMono",
        "IBMPlexMono-Regular"
    ]
    static let glowLayers: [(x: CGFloat, y: CGFloat, radius: CGFloat, opacity: Double)] = [
        (0.9683, 1.9366, 4.8415, 0.55),
        (3.8732, 8.7147, 9.6830, 0.48),
        (9.6830, 19.3660, 12.5879, 0.28),
        (16.4611, 33.8904, 15.4928, 0.08),
        (25.1757, 53.2564, 16.4611, 0.01)
    ]

    static var numberFont: Font {
        if let name = numberFontCandidates.first(where: { UIFont(name: $0, size: numberSize) != nil }) {
            return .custom(name, size: numberSize)
        }
        return .system(size: numberSize, weight: .regular, design: .monospaced)
    }
}

private struct GaiaPinGlowModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .shadow(
                color: GaiaColor.greenGlow.opacity(MapAnnotationPinStyle.glowLayers[0].opacity),
                radius: MapAnnotationPinStyle.glowLayers[0].radius,
                x: MapAnnotationPinStyle.glowLayers[0].x,
                y: MapAnnotationPinStyle.glowLayers[0].y
            )
            .shadow(
                color: GaiaColor.greenGlow.opacity(MapAnnotationPinStyle.glowLayers[1].opacity),
                radius: MapAnnotationPinStyle.glowLayers[1].radius,
                x: MapAnnotationPinStyle.glowLayers[1].x,
                y: MapAnnotationPinStyle.glowLayers[1].y
            )
            .shadow(
                color: GaiaColor.greenGlow.opacity(MapAnnotationPinStyle.glowLayers[2].opacity),
                radius: MapAnnotationPinStyle.glowLayers[2].radius,
                x: MapAnnotationPinStyle.glowLayers[2].x,
                y: MapAnnotationPinStyle.glowLayers[2].y
            )
            .shadow(
                color: GaiaColor.greenGlow.opacity(MapAnnotationPinStyle.glowLayers[3].opacity),
                radius: MapAnnotationPinStyle.glowLayers[3].radius,
                x: MapAnnotationPinStyle.glowLayers[3].x,
                y: MapAnnotationPinStyle.glowLayers[3].y
            )
            .shadow(
                color: GaiaColor.greenGlow.opacity(MapAnnotationPinStyle.glowLayers[4].opacity),
                radius: MapAnnotationPinStyle.glowLayers[4].radius,
                x: MapAnnotationPinStyle.glowLayers[4].x,
                y: MapAnnotationPinStyle.glowLayers[4].y
            )
    }
}

private extension View {
    func gaiaPinGlow() -> some View {
        modifier(GaiaPinGlowModifier())
    }
}
