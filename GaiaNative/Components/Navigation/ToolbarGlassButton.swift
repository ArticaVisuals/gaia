// figma: https://www.figma.com/design/4e4G3tnSR7AdPbf0jAYPP1/Gaia?node-id=451-702
import SwiftUI

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

struct ToolbarGlassButton: View {
    let icon: ToolbarGlassButtonIcon
    let accessibilityLabel: String
    var showsShadow: Bool = true
    let action: () -> Void

    var body: some View {
        GlassCircleButton(showsShadow: showsShadow, action: action) {
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
                .padding(.horizontal, 16)
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
                tint: GaiaColor.broccoliBrown500
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
                        tint: GaiaColor.broccoliBrown500
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

    private enum Layout {
        static let horizontalPadding: CGFloat = 20
        static let verticalPadding: CGFloat = 14
        static let contentSpacing: CGFloat = 8
        static let arrowAssetWidth: CGFloat = 15.59
        static let arrowAssetHeight: CGFloat = 20.103
        static let arrowWidth: CGFloat = 20.103
        static let arrowHeight: CGFloat = 15.59
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: Layout.contentSpacing) {
                Text(title)
                    .font(GaiaTypography.bodyMedium)
                    .tracking(0)
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
    }

    @ViewBuilder
    private var backgroundSurface: some View {
        if #available(iOS 26.0, *) {
            GaiaMaterialBackground(
                cornerRadius: GaiaRadius.full,
                interactive: true,
                showsShadow: showsShadow,
                prominence: .prominent,
                tint: GaiaColor.broccoliBrown500.opacity(0.34)
            )
        } else {
            let shape = Capsule(style: .continuous)

            shape
                .fill(GaiaColor.broccoliBrown500)
                .overlay(
                    shape
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

    @ViewBuilder
    private var rightArrowArtwork: some View {
        if let image = AssetCatalog.image(named: "gaia-icon-back-32") {
            image
                .resizable()
                .renderingMode(.template)
                .interpolation(.high)
                .antialiased(true)
                .scaledToFit()
                .foregroundStyle(GaiaColor.paperWhite50)
        }
    }
}

private struct ToolbarGlassIconArtwork: View {
    let icon: ToolbarGlassButtonIcon

    var body: some View {
        ZStack {
            switch icon {
            case .search:
                GaiaIcon(kind: .search, size: 20)
            case .back:
                GaiaAssetImage(name: "gaia-icon-back-32", contentMode: .fit)
                    .frame(width: 15.6, height: 20.1)
                    .rotationEffect(.degrees(-90))
            case .rightArrow:
                GaiaAssetImage(name: "gaia-icon-back-32", contentMode: .fit)
                    .frame(width: 15.6, height: 20.1)
                    .rotationEffect(.degrees(90))
            case .close:
                GaiaIcon(kind: .close, size: 32)
            case .plus:
                GaiaIcon(kind: .plus, size: GaiaSpacing.iconLg)
            case .share:
                GaiaIcon(kind: .share, size: GaiaSpacing.iconLg)
            case .expand:
                GaiaIcon(kind: .expand, size: GaiaSpacing.iconLg)
            case .filter:
                GaiaIcon(kind: .filter, size: 32)
            case .gear:
                GaiaIcon(kind: .gear, size: 20)
            case .grid:
                GaiaIcon(kind: .grid, size: 32)
            case .list:
                GaiaIcon(kind: .list, size: 32)
            case .map:
                GaiaIcon(kind: .map, size: 32)
            case .binoculars:
                GaiaIcon(kind: .binoculars, size: 20)
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
                .fill(GaiaColor.inkBlack900)
                .frame(width: 4, height: 4)
            Circle()
                .fill(GaiaColor.inkBlack900)
                .frame(width: 4, height: 4)
            Circle()
                .fill(GaiaColor.inkBlack900)
                .frame(width: 4, height: 4)
        }
        .accessibilityHidden(true)
    }
}
