// figma: https://www.figma.com/design/4e4G3tnSR7AdPbf0jAYPP1/Gaia?node-id=451-702
import SwiftUI
import UIKit

enum ToolbarGlassButtonIcon {
    case search
    case back
    case rightArrow
    case close
    case plus
    case share
    case expand
    case filter
    case gear
    case grid
    case list
    case map
    case binoculars
    case more

    var slotSize: CGFloat { 32 }
}

enum ToolbarGlassStyle {
    static let iconTint = GaiaColor.inkBlack900
    static let buttonSize: CGFloat = 48
}

struct ToolbarGlassButton: View {
    let icon: ToolbarGlassButtonIcon
    let accessibilityLabel: String
    var showsShadow: Bool = true
    let action: () -> Void

    var body: some View {
        GlassCircleButton(
            size: ToolbarGlassStyle.buttonSize,
            showsShadow: showsShadow,
            surfaceStyle: .toolbarButton,
            action: action
        ) {
            ToolbarGlassIconArtwork(icon: icon)
                .frame(width: icon.slotSize, height: icon.slotSize)
        }
        .accessibilityLabel(accessibilityLabel)
    }
}

struct ToolbarGlassTitleBar: View {
    let title: String
    var leadingIcon: ToolbarGlassButtonIcon? = nil
    var leadingAccessibilityLabel: String? = nil
    var leadingAction: (() -> Void)? = nil
    var trailingTitle: String? = nil
    var trailingAccessibilityLabel: String? = nil
    var trailingAction: (() -> Void)? = nil
    var showsShadow: Bool = true

    var body: some View {
        HStack(spacing: GaiaSpacing.md) {
            if let leadingIcon, let leadingAccessibilityLabel, let leadingAction {
                ToolbarGlassButton(
                    icon: leadingIcon,
                    accessibilityLabel: leadingAccessibilityLabel,
                    showsShadow: showsShadow,
                    action: leadingAction
                )
            } else {
                Color.clear
                    .frame(width: 48, height: 48)
                    .accessibilityHidden(true)
            }

            Text(title)
                .gaiaFont(.titleSansMedium)
                .foregroundStyle(GaiaColor.inkBlack900)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
                .frame(maxWidth: .infinity, alignment: .center)

            if let trailingTitle, let trailingAccessibilityLabel, let trailingAction {
                ToolbarGlassTextButton(
                    title: trailingTitle,
                    accessibilityLabel: trailingAccessibilityLabel,
                    showsShadow: showsShadow,
                    action: trailingAction
                )
            } else {
                Color.clear
                    .frame(width: 48, height: 48)
                    .accessibilityHidden(true)
            }
        }
    }
}

struct ToolbarGlassTextButton: View {
    let title: String
    let accessibilityLabel: String
    var showsShadow: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .gaiaFont(.bodyMedium)
                .foregroundStyle(GaiaColor.paperWhite50)
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: true)
                .padding(.horizontal, GaiaSpacing.md)
                .frame(height: 40)
                .background(backgroundSurface)
                .clipShape(Capsule())
        }
        .buttonStyle(GlassReactiveButtonStyle())
        .accessibilityLabel(accessibilityLabel)
    }

    @ViewBuilder
    private var backgroundSurface: some View {
        if #available(iOS 26.0, *) {
            GaiaMaterialBackground(
                cornerRadius: GaiaRadius.full,
                interactive: true,
                showsShadow: showsShadow,
                prominence: .prominent,
                tint: GaiaColor.broccoliBrown500.opacity(0.28)
            )
        } else {
            Capsule(style: .continuous)
                .fill(GaiaColor.broccoliBrown500)
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(GaiaColor.broccoliBrown200, lineWidth: 1)
                )
                .shadow(
                    color: showsShadow ? GaiaShadow.mdColor : .clear,
                    radius: GaiaShadow.mdRadius,
                    x: 0,
                    y: GaiaShadow.mdYOffset
                )
        }
    }
}

struct ToolbarGlassSearchBar: View {
    enum Style {
        case regular
        case compact
    }

    @Binding var text: String
    let placeholder: String
    var style: Style = .regular
    var showsShadow: Bool = true
    var onSubmit: (() -> Void)? = nil
    var microphoneAction: (() -> Void)? = nil

    var body: some View {
        let isCompact = style == .compact

        HStack(spacing: isCompact ? 8 : 10) {
            GaiaIcon(
                kind: .search,
                size: isCompact ? 26 : 20,
                tint: ToolbarGlassStyle.iconTint
            )

            TextField(
                "",
                text: $text,
                prompt: Text(placeholder)
            )
            .gaiaFont(isCompact ? .subheadline : .bodyMedium)
            .foregroundStyle(GaiaColor.inkBlack900)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled(true)
            .submitLabel(.search)
            .onSubmit {
                onSubmit?()
            }

            if let microphoneAction {
                Button(action: microphoneAction) {
                    GaiaIcon(
                        kind: .microphone,
                        size: isCompact ? 32 : 20,
                        tint: ToolbarGlassStyle.iconTint
                    )
                    .frame(width: isCompact ? 32 : 20, height: isCompact ? 32 : 20)
                }
                .buttonStyle(GlassReactiveButtonStyle())
                .accessibilityLabel("Voice search")
            }
        }
        .padding(.horizontal, isCompact ? 12 : 16)
        .frame(height: isCompact ? 40 : 48)
        .background(searchBackground(isCompact: isCompact))
    }

    @ViewBuilder
    private func searchBackground(isCompact: Bool) -> some View {
        let shape = Capsule(style: .continuous)

        if isCompact {
            shape
                .fill(GaiaColor.paperStrong)
                .overlay(
                    shape
                        .stroke(GaiaColor.broccoliBrown200, lineWidth: 1)
                )
        } else {
            GaiaMaterialBackground(
                cornerRadius: GaiaRadius.full,
                interactive: true,
                showsShadow: showsShadow
            )
        }
    }
}

struct ToolbarGlassLearnButton: View {
    let title: String
    let accessibilityLabel: String
    var showsShadow: Bool = true
    let action: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var shimmerPhase: CGFloat = 0

    private enum Layout {
        static let horizontalPadding: CGFloat = 20
        static let verticalPadding: CGFloat = 14
        static let contentSpacing: CGFloat = 8
        static let borderWidth: CGFloat = 0.5
        static let arrowAssetWidth: CGFloat = 15.59
        static let arrowAssetHeight: CGFloat = 20.103
        static let arrowWidth: CGFloat = 20.103
        static let arrowHeight: CGFloat = 15.59
        static let shadowColor = GaiaColor.broccoliBrown500
        static let strokeHighlight = GaiaColor.broccoliBrown200
        static let strokeShadow = GaiaColor.broccoliBrown600
    }

    private var strokeGradient: AngularGradient {
        AngularGradient(
            stops: [
                .init(color: Layout.strokeHighlight, location: 0),
                .init(color: Layout.strokeShadow, location: 0.275),
                .init(color: Layout.strokeHighlight, location: 0.5),
                .init(color: Layout.strokeShadow, location: 0.775),
                .init(color: Layout.strokeHighlight, location: 1)
            ],
            center: .center,
            angle: .degrees(shimmerPhase)
        )
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: Layout.contentSpacing) {
                Text(title)
                    .font(GaiaTypography.bodyMedium)
                    .foregroundStyle(GaiaColor.paperWhite50)
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: true)
                    .layoutPriority(1)

                rightArrowArtwork
                    .frame(width: Layout.arrowAssetWidth, height: Layout.arrowAssetHeight)
                    .rotationEffect(.degrees(90))
                    .frame(width: Layout.arrowWidth, height: Layout.arrowHeight)
            }
            .padding(.horizontal, Layout.horizontalPadding)
            .padding(.vertical, Layout.verticalPadding)
            .background(backgroundSurface)
            .contentShape(Capsule())
        }
        .buttonStyle(GlassReactiveButtonStyle())
        .accessibilityLabel(accessibilityLabel)
        .onAppear {
            shimmerPhase = 0
            guard !reduceMotion else { return }

            withAnimation(
                .linear(duration: 6)
                    .repeatForever(autoreverses: false)
            ) {
                shimmerPhase = 360
            }
        }
    }

    private var backgroundSurface: some View {
        let shape = Capsule(style: .continuous)

        return shape
            .fill(GaiaColor.broccoliBrown500)
            .overlay(
                shape
                    .stroke(strokeGradient, lineWidth: Layout.borderWidth)
            )
            .shadow(
                color: showsShadow ? Layout.shadowColor : .clear,
                radius: GaiaShadow.mdRadius,
                x: 0,
                y: GaiaShadow.mdYOffset
            )
    }

    @ViewBuilder
    private var rightArrowArtwork: some View {
        ToolbarGlassRenderedAssetImage(
            assetName: "gaia-icon-back-32",
            tint: GaiaColor.paperWhite50
        )
    }
}

struct ToolbarGlassIconArtwork: View {
    let icon: ToolbarGlassButtonIcon

    var body: some View {
        ZStack {
            switch icon {
            case .search:
                GaiaIcon(kind: .search, size: 20, tint: ToolbarGlassStyle.iconTint)
            case .back:
                ToolbarGlassRotatedAssetArtwork(
                    assetName: "gaia-icon-back-32",
                    tint: nil,
                    assetWidth: 15.59,
                    assetHeight: 20.103,
                    rotation: .degrees(-90)
                )
            case .rightArrow:
                ToolbarGlassRotatedAssetArtwork(
                    assetName: "gaia-icon-back-32",
                    tint: nil,
                    assetWidth: 15.59,
                    assetHeight: 20.103,
                    rotation: .degrees(90)
                )
            case .close:
                GaiaIcon(kind: .close, size: 32, tint: ToolbarGlassStyle.iconTint)
            case .plus:
                ToolbarGlassInsetAssetArtwork(
                    assetName: "gaia-icon-plus-24",
                    tint: nil,
                    insets: .css(17.75, 18.75, 16.88, 18.75)
                )
            case .share:
                ZStack {
                    ToolbarGlassInsetAssetArtwork(
                        assetName: "gaia-icon-share-base-24",
                        tint: nil,
                        insets: .css(36.86, 23.58, 12.5, 22.71)
                    )
                    ToolbarGlassInsetAssetArtwork(
                        assetName: "gaia-icon-share-arrow-24",
                        tint: nil,
                        insets: .css(12.5, 35.8, 37.03, 34.92)
                    )
                }
            case .expand:
                GaiaIcon(kind: .expand, size: GaiaSpacing.iconLg, tint: ToolbarGlassStyle.iconTint)
            case .filter:
                GaiaIcon(kind: .filter, size: 32, tint: ToolbarGlassStyle.iconTint)
            case .gear:
                GaiaIcon(kind: .gear, size: 20, tint: ToolbarGlassStyle.iconTint)
            case .grid:
                GaiaIcon(kind: .grid, size: 32, tint: ToolbarGlassStyle.iconTint)
            case .list:
                GaiaIcon(kind: .list, size: 32, tint: ToolbarGlassStyle.iconTint)
            case .map:
                GaiaIcon(kind: .map, size: 32, tint: ToolbarGlassStyle.iconTint)
            case .binoculars:
                GaiaIcon(kind: .binoculars, size: 20, tint: ToolbarGlassStyle.iconTint)
            case .more:
                ToolbarGlassMoreGlyph()
            }
        }
        .frame(width: 32, height: 32)
    }
}

private struct ToolbarGlassMoreGlyph: View {
    var body: some View {
        HStack(spacing: GaiaSpacing.xs) {
            Circle()
                .fill(ToolbarGlassStyle.iconTint)
                .frame(width: 4, height: 4)
            Circle()
                .fill(ToolbarGlassStyle.iconTint)
                .frame(width: 4, height: 4)
            Circle()
                .fill(ToolbarGlassStyle.iconTint)
                .frame(width: 4, height: 4)
        }
        .accessibilityHidden(true)
    }
}

private struct ToolbarGlassInsetAssetArtwork: View {
    let assetName: String
    let tint: Color?
    let insets: ToolbarGlassPercentInsets

    var body: some View {
        GeometryReader { proxy in
            let frame = insets.rect(in: proxy.size)

            ToolbarGlassRenderedAssetImage(assetName: assetName, tint: tint)
                .frame(width: frame.width, height: frame.height)
                .position(x: frame.midX, y: frame.midY)
        }
        .frame(width: 32, height: 32)
    }
}

private struct ToolbarGlassRotatedAssetArtwork: View {
    let assetName: String
    let tint: Color?
    let assetWidth: CGFloat
    let assetHeight: CGFloat
    let rotation: Angle

    var body: some View {
        ToolbarGlassRenderedAssetImage(assetName: assetName, tint: tint)
            .frame(width: assetWidth, height: assetHeight)
            .rotationEffect(rotation)
            .frame(width: 32, height: 32)
    }
}

private struct ToolbarGlassRenderedAssetImage: View {
    let assetName: String
    let tint: Color?

    var body: some View {
        if let uiImage = renderedUIImage {
            Image(uiImage: uiImage)
                .renderingMode(.original)
                .resizable()
                .interpolation(.high)
                .scaledToFit()
        } else if let spec = ToolbarGlassPathSpec.spec(for: assetName) {
            ToolbarGlassSVGPathShape(
                pathData: spec.pathData,
                viewBox: spec.viewBox
            )
            .fill(tint ?? ToolbarGlassStyle.iconTint)
        }
    }

    private var renderedUIImage: UIImage? {
        guard let baseImage = UIImage(named: assetName) else {
            return nil
        }
        guard let tint else {
            return baseImage
        }
        return baseImage.withTintColor(UIColor(tint), renderingMode: .alwaysOriginal)
    }
}

private struct ToolbarGlassPathSpec {
    let pathData: String
    let viewBox: CGSize

    static func spec(for assetName: String) -> ToolbarGlassPathSpec? {
        switch assetName {
        case "gaia-icon-back-32":
            return ToolbarGlassPathSpec(
                pathData: "M8.49347 0.283963C8.289 0.0780811 8.0088 -0.0210474 7.73239 0.00373465C7.72104 0.00373465 7.71157 0.00564105 7.70021 0.00754736C7.47681 0.0266105 7.26098 0.121926 7.09817 0.283963L0.276884 7.15242C-0.0922946 7.52415 -0.0922946 8.12845 0.276884 8.50018C0.646062 8.87191 1.24621 8.87191 1.61539 8.50018L6.2216 3.86212C6.45258 3.62955 6.84826 3.79349 6.84826 4.12328V19.1088C6.84826 19.6064 7.20986 20.0505 7.7021 20.0982C8.26628 20.1516 8.74148 19.7074 8.74148 19.1489V4.12137C8.74148 3.79158 9.13717 3.62764 9.36814 3.86021L13.9743 8.49827C14.3435 8.87001 14.9437 8.87001 15.3129 8.49827C15.682 8.12654 15.682 7.52224 15.3129 7.15051L8.49158 0.282056L8.49347 0.283963Z",
                viewBox: CGSize(width: 15.5897, height: 20.1026)
            )
        case "gaia-icon-plus-24":
            return ToolbarGlassPathSpec(
                pathData: "M14.2307 7.10592H8.78635C8.48339 7.10592 8.23819 6.86072 8.23819 6.55776V0.769324C8.23819 0.364942 7.92624 0.0131945 7.52314 0.000356977C7.12004 -0.0124805 6.76188 0.322578 6.76188 0.738514V6.55776C6.76188 6.86072 6.51668 7.10592 6.21371 7.10592H0.769324C0.364942 7.10592 0.0131945 7.41787 0.000356977 7.82097C-0.0124805 8.22407 0.322579 8.58224 0.738514 8.58224H6.21371C6.51668 8.58224 6.76188 8.82743 6.76188 9.1304V14.9188C6.76188 15.3232 7.07383 15.675 7.47693 15.6878C7.88002 15.7006 8.23819 15.3656 8.23819 14.9496V9.1304C8.23819 8.82743 8.48339 8.58224 8.78635 8.58224H14.2616C14.6762 8.58224 15.0113 8.23947 14.9997 7.82097C14.9882 7.40247 14.6351 7.10592 14.2307 7.10592Z",
                viewBox: CGSize(width: 15, height: 15.6882)
            )
        case "gaia-icon-share-base-24":
            return ToolbarGlassPathSpec(
                pathData: "M11.1779 12.1545H1.71263C0.76853 12.1545 0 11.386 0 10.4419V1.71263C0 0.76853 0.76853 0 1.71263 0H4.13072C4.42089 0 4.65639 0.2355 4.65639 0.52567C4.65639 0.81584 4.42089 1.05134 4.13072 1.05134H1.71263C1.34782 1.05134 1.05134 1.34782 1.05134 1.71263V10.4419C1.05134 10.8067 1.34782 11.1032 1.71263 11.1032H11.1779C11.5427 11.1032 11.8391 10.8067 11.8391 10.4419V1.71263C11.8391 1.34782 11.5427 1.05134 11.1779 1.05134H8.75977C8.4696 1.05134 8.2341 0.81584 8.2341 0.52567C8.2341 0.2355 8.4696 0 8.75977 0H11.1779C12.122 0 12.8905 0.76853 12.8905 1.71263V10.4419C12.8905 11.386 12.122 12.1545 11.1779 12.1545Z",
                viewBox: CGSize(width: 12.8905, height: 12.1545)
            )
        case "gaia-icon-share-arrow-24":
            return ToolbarGlassPathSpec(
                pathData: "M6.87327 3.88575C6.77024 3.98773 6.63567 4.03925 6.5011 4.03925C6.36652 4.03925 6.23195 3.98773 6.12997 3.88575L4.39211 2.14789C4.26174 2.01752 4.03886 2.11004 4.03886 2.29402V11.5637C4.03886 11.8381 3.83805 12.0831 3.5647 12.1093C3.2514 12.1398 2.98752 11.8938 2.98752 11.5858V2.29402C2.98752 2.11004 2.76463 2.01752 2.63427 2.14789L0.897451 3.88575C0.691388 4.09077 0.359164 4.09077 0.154153 3.88575C-0.0508583 3.68074 -0.0519097 3.34747 0.154153 3.14246L3.1305 0.167163L3.14311 0.154547C3.18201 0.115647 3.22617 0.0830559 3.27243 0.0588751C3.2861 0.0515157 3.30187 0.0452076 3.31659 0.0388996C3.36284 0.0199755 3.41226 0.00735938 3.46062 0.00315402C3.47849 0.00105134 3.49636 0 3.51424 0C3.53211 0 3.54998 0.00105134 3.56786 0.00315402C3.61727 0.00735938 3.66563 0.0199755 3.71189 0.0388996C3.72345 0.043105 3.73502 0.0483617 3.74553 0.0536184C3.796 0.0788505 3.84436 0.112493 3.88641 0.154547L6.87432 3.14246C7.07933 3.34747 7.07933 3.67969 6.87432 3.88575H6.87327Z",
                viewBox: CGSize(width: 7.02808, height: 12.1119)
            )
        default:
            return nil
        }
    }
}

private struct ToolbarGlassSVGPathShape: Shape {
    let pathData: String
    let viewBox: CGSize

    func path(in rect: CGRect) -> Path {
        ToolbarGlassSVGPathBuilder(pathData: pathData, viewBox: viewBox, rect: rect).build()
    }
}

private struct ToolbarGlassSVGPathBuilder {
    let pathData: String
    let viewBox: CGSize
    let rect: CGRect

    func build() -> Path {
        let tokens = ToolbarGlassSVGTokenizer.tokenize(pathData)
        var index = 0
        var path = Path()
        var currentRaw = CGPoint.zero
        var startRaw = CGPoint.zero

        func nextNumber() -> CGFloat? {
            guard index < tokens.count else { return nil }
            guard case let .number(value) = tokens[index] else { return nil }
            index += 1
            return value
        }

        func hasNumber() -> Bool {
            guard index < tokens.count else { return false }
            if case .number = tokens[index] {
                return true
            }
            return false
        }

        func scaled(_ raw: CGPoint) -> CGPoint {
            CGPoint(
                x: rect.minX + (raw.x / viewBox.width) * rect.width,
                y: rect.minY + (raw.y / viewBox.height) * rect.height
            )
        }

        while index < tokens.count {
            guard case let .command(command) = tokens[index] else {
                index += 1
                continue
            }
            index += 1

            switch command {
            case "M":
                var isFirstPoint = true
                while hasNumber() {
                    guard let x = nextNumber(), let y = nextNumber() else { break }
                    let rawPoint = CGPoint(x: x, y: y)
                    if isFirstPoint {
                        path.move(to: scaled(rawPoint))
                        startRaw = rawPoint
                        isFirstPoint = false
                    } else {
                        path.addLine(to: scaled(rawPoint))
                    }
                    currentRaw = rawPoint
                }
            case "L":
                while hasNumber() {
                    guard let x = nextNumber(), let y = nextNumber() else { break }
                    let rawPoint = CGPoint(x: x, y: y)
                    path.addLine(to: scaled(rawPoint))
                    currentRaw = rawPoint
                }
            case "H":
                while hasNumber() {
                    guard let x = nextNumber() else { break }
                    currentRaw = CGPoint(x: x, y: currentRaw.y)
                    path.addLine(to: scaled(currentRaw))
                }
            case "V":
                while hasNumber() {
                    guard let y = nextNumber() else { break }
                    currentRaw = CGPoint(x: currentRaw.x, y: y)
                    path.addLine(to: scaled(currentRaw))
                }
            case "C":
                while hasNumber() {
                    guard
                        let x1 = nextNumber(),
                        let y1 = nextNumber(),
                        let x2 = nextNumber(),
                        let y2 = nextNumber(),
                        let x = nextNumber(),
                        let y = nextNumber()
                    else { break }

                    let control1 = CGPoint(x: x1, y: y1)
                    let control2 = CGPoint(x: x2, y: y2)
                    let endPoint = CGPoint(x: x, y: y)
                    path.addCurve(
                        to: scaled(endPoint),
                        control1: scaled(control1),
                        control2: scaled(control2)
                    )
                    currentRaw = endPoint
                }
            case "Z":
                path.closeSubpath()
                currentRaw = startRaw
            default:
                break
            }
        }

        return path
    }
}

private enum ToolbarGlassSVGToken {
    case command(Character)
    case number(CGFloat)
}

private enum ToolbarGlassSVGTokenizer {
    static func tokenize(_ data: String) -> [ToolbarGlassSVGToken] {
        var tokens: [ToolbarGlassSVGToken] = []
        let characters = Array(data)
        var index = 0

        while index < characters.count {
            let character = characters[index]

            if character.isWhitespace || character == "," {
                index += 1
                continue
            }

            if character.isLetter {
                tokens.append(.command(character))
                index += 1
                continue
            }

            var number = String(character)
            index += 1

            while index < characters.count {
                let nextCharacter = characters[index]
                if nextCharacter.isWhitespace || nextCharacter == "," || nextCharacter.isLetter {
                    break
                }
                number.append(nextCharacter)
                index += 1
            }

            if let value = Double(number) {
                tokens.append(.number(CGFloat(value)))
            }
        }

        return tokens
    }
}

private struct ToolbarGlassPercentInsets {
    let top: CGFloat
    let right: CGFloat
    let bottom: CGFloat
    let left: CGFloat

    static func css(_ top: CGFloat, _ right: CGFloat, _ bottom: CGFloat, _ left: CGFloat) -> ToolbarGlassPercentInsets {
        ToolbarGlassPercentInsets(
            top: top * 0.01,
            right: right * 0.01,
            bottom: bottom * 0.01,
            left: left * 0.01
        )
    }

    func rect(in size: CGSize) -> CGRect {
        let x = size.width * left
        let y = size.height * top
        let width = size.width * max(0, 1 - left - right)
        let height = size.height * max(0, 1 - top - bottom)

        return CGRect(x: x, y: y, width: width, height: height)
    }
}
