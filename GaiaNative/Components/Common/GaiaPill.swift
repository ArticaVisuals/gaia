// figma: https://www.figma.com/design/4e4G3tnSR7AdPbf0jAYPP1/Gaia?node-id=601-19045
import SwiftUI

struct GaiaPill: View {
    let title: String
    var fill: Color = GaiaColor.brown
    var foreground: Color = GaiaColor.paperStrong
    var stroke: Color? = nil

    var body: some View {
        Text(title)
            .gaiaFont(.pill)
            .foregroundStyle(foreground)
            .padding(.horizontal, GaiaSpacing.pillHorizontal)
            .padding(.vertical, GaiaSpacing.xs)
            .frame(height: 28)
            .background(
                Capsule(style: .continuous)
                    .fill(fill)
                    .overlay {
                        if let stroke {
                            Capsule(style: .continuous)
                                .stroke(stroke, lineWidth: 0.5)
                        }
                    }
            )
    }
}

enum GaiaStatusPillVariant {
    case research
    case casual
    case ungraded
    case needsID
    case draft

    fileprivate var fill: Color {
        switch self {
        case .research:
            return GaiaColor.oliveGreen100
        case .casual, .ungraded:
            return .clear
        case .needsID:
            return GaiaColor.broccoliBrown100
        case .draft:
            return GaiaColor.blackishGrey50
        }
    }

    fileprivate var stroke: Color {
        switch self {
        case .research, .casual:
            return GaiaColor.brandPrimary
        case .ungraded, .draft:
            return GaiaColor.blackishGrey200
        case .needsID:
            return GaiaColor.broccoliBrown500
        }
    }

    fileprivate var foreground: Color {
        switch self {
        case .research, .casual:
            return GaiaColor.brandPrimary
        case .ungraded:
            return GaiaColor.blackishGrey200
        case .needsID:
            return GaiaColor.broccoliBrown500
        case .draft:
            return GaiaColor.textSecondary
        }
    }
}

struct GaiaStatusPill: View {
    let title: String
    let variant: GaiaStatusPillVariant

    var body: some View {
        GaiaPill(
            title: title,
            fill: variant.fill,
            foreground: variant.foreground,
            stroke: variant.stroke
        )
        .fixedSize()
    }
}
