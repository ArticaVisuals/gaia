import SwiftUI

struct GaiaAssetImage: View {
    let name: String
    var contentMode: ContentMode = .fill
    var fallbackTint: Color = GaiaColor.greyMuted

    var body: some View {
        Group {
            if let image = AssetCatalog.image(named: name) {
                image
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else {
                ZStack {
                    LinearGradient(
                        colors: [GaiaColor.paperWhite100, GaiaColor.oliveGreen100],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    Image(systemName: "photo")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(fallbackTint)
                }
            }
        }
    }
}

enum GaiaIconKind {
    case target
    case search
    case microphone
    case back
    case close
    case plus
    case share
    case expand
    case explore(selected: Bool)
    case log(selected: Bool)
    case observe(selected: Bool)
    case activity(selected: Bool)
    case profile(selected: Bool)
    case circleArrowRight

    fileprivate var layout: GaiaIconLayout {
        switch self {
        case .target:
            return GaiaIconLayout(
                baseCanvas: 24,
                layers: [
                    .direct(assetPath: "Icons/System/target-24-dot.png", insets: .css(37.9, 37.9, 37.91, 37.91)),
                    .direct(assetPath: "Icons/System/target-24-ring.png", insets: .css(12.5, 12.5, 12.51, 12.5))
                ]
            )
        case .search:
            return GaiaIconLayout(
                baseCanvas: 20,
                layers: [
                    .direct(assetPath: "Icons/System/search-20.png", insets: .css(15.62, 15.63, 15.63, 15.62))
                ]
            )
        case .microphone:
            return GaiaIconLayout(
                baseCanvas: 20,
                layers: [
                    .direct(assetPath: "Icons/System/microphone-20-head-olive.png", insets: .css(16.1, 35.64, 37.89, 36.04)),
                    .direct(assetPath: "Icons/System/microphone-20-base-olive.png", insets: .css(45.55, 24.79, 16.1, 25.19))
                ]
            )
        case .back:
            return GaiaIconLayout(
                baseCanvas: 32,
                layers: [
                    .slotted(
                        assetPath: "Icons/System/left-arrow-32.png",
                        slotInsets: .css(25.96, 16.73, 25.32, 20.45),
                        intrinsicSize: CGSize(width: 15.59, height: 20.103),
                        rotation: .degrees(-90)
                    )
                ]
            )
        case .close:
            return GaiaIconLayout(
                baseCanvas: 32,
                layers: [
                    .slotted(
                        assetPath: "Icons/System/cross-32.png",
                        slotInsets: .css(5.23, 4.79, 4.36, 4.79),
                        intrinsicSize: CGSize(width: 20, height: 20.918),
                        rotation: .degrees(-45)
                    )
                ]
            )
        case .plus:
            return GaiaIconLayout(
                baseCanvas: 24,
                layers: [
                    .direct(assetPath: "Icons/System/plus-24.png", insets: .css(17.75, 18.75, 16.88, 18.75))
                ]
            )
        case .share:
            return GaiaIconLayout(
                baseCanvas: 24,
                layers: [
                    .direct(assetPath: "Icons/System/share-24-base.png", insets: .css(36.86, 23.58, 12.5, 22.71)),
                    .direct(assetPath: "Icons/System/share-24-arrow.png", insets: .css(12.5, 35.8, 37.03, 34.92))
                ]
            )
        case .expand:
            return GaiaIconLayout(
                baseCanvas: 24,
                layers: [
                    .slotted(
                        assetPath: "Icons/System/expand-24-a.png",
                        slotInsets: .css(36.74, 36.74, 0, 0),
                        intrinsicSize: CGSize(width: 20.359, height: 21.148),
                        rotation: .degrees(-135)
                    ),
                    .slotted(
                        assetPath: "Icons/System/expand-24-b.png",
                        slotInsets: .css(0, 0, 36.74, 36.74),
                        intrinsicSize: CGSize(width: 20.359, height: 21.148),
                        rotation: .degrees(45)
                    )
                ]
            )
        case .explore(let selected):
            return GaiaIconLayout(
                baseCanvas: 32,
                layers: [
                    .direct(
                        assetPath: "Icons/System/explore-32-ring\(selected ? "-olive" : "").png",
                        insets: .css(15.76, 15.49, 15.49, 15.76)
                    ),
                    .direct(
                        assetPath: "Icons/System/explore-32-dot\(selected ? "-olive" : "").png",
                        insets: .css(34.52, 32.86, 32.85, 34.52)
                    )
                ]
            )
        case .log(let selected):
            return GaiaIconLayout(
                baseCanvas: 32,
                layers: [
                    .direct(
                        assetPath: selected ? "Icons/System/logbook-32-composite-olive.png" : "Icons/System/logbook-32-figma.png",
                        insets: .css(15.63, 20.95, 15.83, 18.39)
                    )
                ]
            )
        case .observe(let selected):
            return GaiaIconLayout(
                baseCanvas: 32,
                layers: [
                    .direct(
                        assetPath: selected ? "Icons/System/binoculars-32-olive.png" : "Icons/System/binoculars-32-figma.png",
                        insets: .css(25.5, 16.06, 25.5, 15.19)
                    )
                ]
            )
        case .activity(let selected):
            return GaiaIconLayout(
                baseCanvas: 32,
                layers: [
                    .direct(
                        assetPath: selected ? "Icons/System/bell-32-olive.png" : "Icons/System/bell-32-figma.png",
                        insets: .css(15.52, 20.6, 15.73, 20.07)
                    )
                ]
            )
        case .profile(let selected):
            return GaiaIconLayout(
                baseCanvas: 32,
                layers: [
                    .direct(
                        assetPath: selected ? "Icons/System/profile-32-olive.png" : "Icons/System/profile-32-figma.png",
                        insets: .css(15.4, 15.84, 15.52, 15.4)
                    )
                ]
            )
        case .circleArrowRight:
            return GaiaIconLayout(
                baseCanvas: 16,
                layers: [
                    .slotted(
                        assetPath: "Icons/System/chevron-16.png",
                        slotInsets: .css(16.3, 35.16, 16.51, 30.2),
                        intrinsicSize: CGSize(width: 21.5, height: 11.086),
                        rotation: .degrees(90)
                    )
                ]
            )
        }
    }
}

struct GaiaIcon: View {
    let kind: GaiaIconKind
    var size: CGFloat? = nil
    var tint: Color? = nil

    var body: some View {
        let layout = kind.layout
        let canvasSize = size ?? layout.baseCanvas

        Group {
            if case .microphone = kind {
                GaiaMicrophoneIcon(tint: tint ?? GaiaColor.inkBlack900)
            } else {
                ZStack {
                    ForEach(Array(layout.layers.enumerated()), id: \.offset) { _, layer in
                        GaiaIconLayerView(layer: layer, canvasSize: canvasSize, baseCanvas: layout.baseCanvas)
                    }
                }
            }
        }
        .frame(width: canvasSize, height: canvasSize)
        .compositingGroup()
        .accessibilityHidden(true)
    }
}

private struct GaiaMicrophoneIcon: View {
    let tint: Color

    private let headInsets = GaiaIconInsets.css(16.1, 35.64, 37.89, 36.04)
    private let baseInsets = GaiaIconInsets.css(45.55, 24.79, 16.1, 25.19)

    var body: some View {
        GeometryReader { proxy in
            let canvasSize = CGSize(width: proxy.size.width, height: proxy.size.height)
            let headFrame = rect(for: headInsets, in: canvasSize, baseCanvas: 20)
            let baseFrame = rect(for: baseInsets, in: canvasSize, baseCanvas: 20)

            ZStack {
                Capsule(style: .continuous)
                    .fill(tint)
                    .frame(width: headFrame.width, height: headFrame.height)
                    .position(x: headFrame.midX, y: headFrame.midY)

                GaiaMicrophoneBaseShape()
                    .fill(tint)
                    .frame(width: baseFrame.width, height: baseFrame.height)
                    .position(x: baseFrame.midX, y: baseFrame.midY)
            }
        }
        .drawingGroup()
    }

    private func rect(for insets: GaiaIconInsets, in size: CGSize, baseCanvas: CGFloat) -> CGRect {
        let scaleX = size.width / baseCanvas
        let scaleY = size.height / baseCanvas
        let left = insets.left * 0.01 * baseCanvas * scaleX
        let right = insets.right * 0.01 * baseCanvas * scaleX
        let top = insets.top * 0.01 * baseCanvas * scaleY
        let bottom = insets.bottom * 0.01 * baseCanvas * scaleY

        return CGRect(
            x: left,
            y: top,
            width: max(0, size.width - left - right),
            height: max(0, size.height - top - bottom)
        )
    }
}

private struct GaiaMicrophoneBaseShape: Shape {
    func path(in rect: CGRect) -> Path {
        let scaleX = rect.width / 10.0053
        let scaleY = rect.height / 7.67168

        func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: rect.minX + (x * scaleX), y: rect.minY + (y * scaleY))
        }

        var path = Path()
        path.move(to: point(10.0053, 0.451126))
        path.addCurve(
            to: point(9.50614, 0.00249347),
            control1: point(10.0053, 0.185738),
            control2: point(9.77695, -0.0254897)
        )
        path.addCurve(
            to: point(9.10264, 0.470083),
            control1: point(9.27325, 0.0268659),
            control2: point(9.10355, 0.236288)
        )
        path.addCurve(
            to: point(5.00266, 4.55111),
            control1: point(9.09271, 2.72227),
            control2: point(7.25666, 4.55111)
        )
        path.addCurve(
            to: point(0.902682, 0.470083),
            control1: point(2.74867, 4.55111),
            control2: point(0.912611, 2.72227)
        )
        path.addCurve(
            to: point(0.499183, 0.00249347),
            control1: point(0.901779, 0.235385),
            control2: point(0.732075, 0.0259632)
        )
        path.addCurve(
            to: point(0, 0.451126),
            control1: point(0.228379, -0.0254897),
            control2: point(0, 0.186641)
        )
        path.addCurve(
            to: point(4.16588, 5.38248),
            control1: point(0, 2.92447),
            control2: point(1.80446, 4.98349)
        )
        path.addCurve(
            to: point(4.55132, 5.83923),
            control1: point(4.38884, 5.42039),
            control2: point(4.55132, 5.61266)
        )
        path.addLine(to: point(4.55132, 6.30502))
        path.addCurve(
            to: point(4.08734, 6.769),
            control1: point(4.55132, 6.56138),
            control2: point(4.3437, 6.769)
        )
        path.addLine(to: point(2.28198, 6.769))
        path.addCurve(
            to: point(1.81349, 7.17611),
            control1: point(2.04638, 6.769),
            control2: point(1.83605, 6.94141)
        )
        path.addCurve(
            to: point(2.26302, 7.67168),
            control1: point(1.78821, 7.44511),
            control2: point(1.99854, 7.67168)
        )
        path.addLine(to: point(7.70258, 7.67168))
        path.addCurve(
            to: point(8.17108, 7.26457),
            control1: point(7.93818, 7.67168),
            control2: point(8.14851, 7.49927)
        )
        path.addCurve(
            to: point(7.72154, 6.769),
            control1: point(8.19635, 6.99557),
            control2: point(7.98603, 6.769)
        )
        path.addLine(to: point(5.91708, 6.769))
        path.addCurve(
            to: point(5.4531, 6.30502),
            control1: point(5.66072, 6.769),
            control2: point(5.4531, 6.56138)
        )
        path.addLine(to: point(5.4531, 5.83923))
        path.addCurve(
            to: point(5.83855, 5.38248),
            control1: point(5.4531, 5.61356),
            control2: point(5.61649, 5.42039)
        )
        path.addCurve(
            to: point(10.0044, 0.451126),
            control1: point(8.19996, 4.98259),
            control2: point(10.0044, 2.92447)
        )
        path.addLine(to: point(10.0053, 0.451126))
        path.closeSubpath()
        return path
    }
}

private struct GaiaIconLayout {
    let baseCanvas: CGFloat
    let layers: [GaiaIconLayer]
}

private struct GaiaIconLayer {
    let assetPath: String
    let insets: GaiaIconInsets?
    let slotInsets: GaiaIconInsets?
    let intrinsicSize: CGSize?
    let rotation: Angle

    static func direct(assetPath: String, insets: GaiaIconInsets) -> GaiaIconLayer {
        GaiaIconLayer(assetPath: assetPath, insets: insets, slotInsets: nil, intrinsicSize: nil, rotation: .zero)
    }

    static func slotted(
        assetPath: String,
        slotInsets: GaiaIconInsets,
        intrinsicSize: CGSize,
        rotation: Angle = .zero
    ) -> GaiaIconLayer {
        GaiaIconLayer(
            assetPath: assetPath,
            insets: nil,
            slotInsets: slotInsets,
            intrinsicSize: intrinsicSize,
            rotation: rotation
        )
    }
}

private struct GaiaIconInsets {
    let top: CGFloat
    let right: CGFloat
    let bottom: CGFloat
    let left: CGFloat

    static func css(_ top: CGFloat, _ right: CGFloat, _ bottom: CGFloat, _ left: CGFloat) -> GaiaIconInsets {
        GaiaIconInsets(top: top, right: right, bottom: bottom, left: left)
    }
}

private struct GaiaIconLayerView: View {
    let layer: GaiaIconLayer
    let canvasSize: CGFloat
    let baseCanvas: CGFloat

    var body: some View {
        GeometryReader { proxy in
            let scale = canvasSize / baseCanvas

            if let insets = layer.insets {
                let frame = rect(for: insets, in: proxy.size)
                iconImage
                    .frame(width: frame.width, height: frame.height)
                    .position(x: frame.midX, y: frame.midY)
            } else if let slotInsets = layer.slotInsets, let intrinsicSize = layer.intrinsicSize {
                let slotFrame = rect(for: slotInsets, in: proxy.size)
                ZStack {
                    iconImage
                        .frame(width: intrinsicSize.width * scale, height: intrinsicSize.height * scale)
                        .rotationEffect(layer.rotation)
                }
                .frame(width: slotFrame.width, height: slotFrame.height)
                .position(x: slotFrame.midX, y: slotFrame.midY)
            }
        }
        .frame(width: canvasSize, height: canvasSize)
    }

    private var iconImage: some View {
        Group {
            if let image = AssetCatalog.image(named: layer.assetPath) {
                image
                    .resizable()
                    .renderingMode(.original)
                    .interpolation(.high)
                    .antialiased(true)
                    .scaledToFit()
            }
        }
    }

    private func rect(for insets: GaiaIconInsets, in size: CGSize) -> CGRect {
        let scaleX = size.width / baseCanvas
        let scaleY = size.height / baseCanvas
        let left = insets.left * 0.01 * baseCanvas * scaleX
        let right = insets.right * 0.01 * baseCanvas * scaleX
        let top = insets.top * 0.01 * baseCanvas * scaleY
        let bottom = insets.bottom * 0.01 * baseCanvas * scaleY

        return CGRect(
            x: left,
            y: top,
            width: max(0, size.width - left - right),
            height: max(0, size.height - top - bottom)
        )
    }
}
