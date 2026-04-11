// figma: https://www.figma.com/design/4e4G3tnSR7AdPbf0jAYPP1/Gaia?node-id=454-932, https://www.figma.com/design/4e4G3tnSR7AdPbf0jAYPP1/Gaia?node-id=793-16887
import SwiftUI

struct GaiaPill: View {
    enum Style {
        case prominent
        case soft
        case bordered

        fileprivate var fill: Color {
            switch self {
            case .prominent:
                return GaiaColor.oliveGreen500
            case .soft:
                return GaiaColor.oliveGreen500.opacity(0.20)
            case .bordered:
                return .clear
            }
        }

        fileprivate var foreground: Color {
            switch self {
            case .prominent:
                return GaiaColor.paperWhite50
            case .soft:
                return GaiaColor.inkBlack300
            case .bordered:
                return GaiaColor.oliveGreen500
            }
        }

        fileprivate var stroke: Color? {
            switch self {
            case .bordered:
                return GaiaColor.oliveGreen500
            case .prominent, .soft:
                return nil
            }
        }

        fileprivate var strokeWidth: CGFloat {
            switch self {
            case .bordered:
                return 1
            case .prominent, .soft:
                return 0
            }
        }
    }

    let title: String
    private let fill: Color
    private let foreground: Color
    private let stroke: Color?
    private let strokeWidth: CGFloat

    init(title: String, style: Style = .prominent) {
        self.init(
            title: title,
            fill: style.fill,
            foreground: style.foreground,
            stroke: style.stroke,
            strokeWidth: style.strokeWidth
        )
    }

    init(
        title: String,
        fill: Color = GaiaColor.oliveGreen500,
        foreground: Color = GaiaColor.paperWhite50,
        stroke: Color? = nil,
        strokeWidth: CGFloat = 0.5
    ) {
        self.title = title
        self.fill = fill
        self.foreground = foreground
        self.stroke = stroke
        self.strokeWidth = strokeWidth
    }

    var body: some View {
        Text(title)
            .gaiaFont(.pill)
            .foregroundStyle(foreground)
            .lineLimit(1)
            .padding(.horizontal, GaiaSpacing.pillHorizontal)
            .padding(.vertical, GaiaSpacing.xs)
            .frame(minHeight: 28)
            .background(
                Capsule(style: .continuous)
                    .fill(fill)
                    .overlay {
                        if let stroke {
                            Capsule(style: .continuous)
                                .stroke(stroke, lineWidth: strokeWidth)
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
