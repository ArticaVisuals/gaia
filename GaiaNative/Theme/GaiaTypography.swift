import SwiftUI
import UIKit

// MARK: - Text Style (font + tracking + lineSpacing from Figma)

enum GaiaTextStyle {
    // Serif (New Spirit)
    case display, displayMedium
    case title1, title1Medium
    case title2, title2Medium
    case title3, title3Medium          // serif 20px
    case subheadSerif, subheadSerifMedium
    case bodySerif, bodySerifMedium

    // Sans (Neue Haas Unica)
    case titleSans, titleSansMedium    // sans 20px
    case body, bodyMedium, bodyBold
    case callout, calloutMedium
    case subheadline, subheadlineMedium, subheadlineBold
    case footnote, footnoteMedium
    case pill
    case caption, captionMedium
    case caption2, caption2Medium
    case nav

    var font: Font { spec.font }
    var tracking: CGFloat { spec.tracking }
    /// Extra line spacing to add via `.lineSpacing()`.
    /// Computed as `(lineHeightMultiplier × fontSize) − fontSize` for ratio-based,
    /// or `fixedLineHeight − fontSize` for pixel-based values.
    var lineSpacing: CGFloat { spec.lineSpacing }

    private var spec: (font: Font, tracking: CGFloat, lineSpacing: CGFloat) {
        switch self {
        // ── Serif ──────────────────────────────────────
        case .display:          return (GaiaTypography.display,          -0.5,  32 * 0.1)   // LH 1.1
        case .displayMedium:    return (GaiaTypography.displayMedium,    -0.5,  0)           // LH 1.0
        case .title1:           return (GaiaTypography.title1,           -0.3,  28 * 0.1)   // LH 1.1
        case .title1Medium:     return (GaiaTypography.title1Medium,     -0.3,  28 * 0.1)   // LH 1.1
        case .title2:           return (GaiaTypography.title2,           -0.2,  24 * 0.1)   // LH 1.1
        case .title2Medium:     return (GaiaTypography.title2Medium,     -0.2,  24 * 0.1)   // LH 1.1
        case .title3:           return (GaiaTypography.titleRegular,      0,    20 * 0.3)   // LH 1.3
        case .title3Medium:     return (GaiaTypography.title,             0,    20 * 0.3)   // LH 1.3
        case .subheadSerif:     return (GaiaTypography.subheadSerif,      0,    16 * 0.3)   // LH 1.3
        case .subheadSerifMedium: return (GaiaTypography.subheadSerifMedium, 0, 16 * 0.3)   // LH 1.3
        case .bodySerif:        return (GaiaTypography.bodySerif,         0,    14 * 0.2)   // LH 1.2
        case .bodySerifMedium:  return (GaiaTypography.bodySerifMedium,   0,    14 * 0.3)   // LH 1.3

        // ── Sans ───────────────────────────────────────
        case .titleSans:        return (GaiaTypography.titleSans,        -0.45, 5)          // LH 25px
        case .titleSansMedium:  return (GaiaTypography.titleSansMedium,  -0.45, 5)          // LH 25px
        case .body:             return (GaiaTypography.body,              0,    17 * 0.3)   // LH 1.3
        case .bodyMedium:       return (GaiaTypography.bodyMedium,        0,    17 * 0.3)   // LH 1.3
        case .bodyBold:         return (GaiaTypography.bodyBold,          0,    17 * 0.3)   // LH 1.3
        case .callout:          return (GaiaTypography.callout,          -0.31, 5)          // LH 21px
        case .calloutMedium:    return (GaiaTypography.calloutMedium,    -0.31, 5)          // LH 21px
        case .subheadline:      return (GaiaTypography.subheadline,       0,    15 * 0.3)   // LH 1.3
        case .subheadlineMedium:return (GaiaTypography.subheadlineMedium, 0,    15 * 0.2)   // LH 1.2
        case .subheadlineBold:  return (GaiaTypography.subheadlineBold,   0,    5)          // LH 20px
        case .footnote:         return (GaiaTypography.footnote,         -0.08, 5)          // LH 18px
        case .footnoteMedium:   return (GaiaTypography.footnoteMedium,   -0.08, 5)          // LH 18px
        case .pill:             return (GaiaTypography.footnote,         -0.08, 13 * 0.2)   // LH 1.2
        case .caption:          return (GaiaTypography.caption,           0.25, 11 * 0.3)   // LH 1.3
        case .captionMedium:    return (GaiaTypography.captionMedium,     0.25, 11 * 0.3)   // LH 1.3
        case .caption2:         return (GaiaTypography.caption2,          0,    12 * 0.2)   // LH 1.2
        case .caption2Medium:   return (GaiaTypography.caption2Medium,    0,    12 * 0.2)   // LH 1.2
        case .nav:              return (GaiaTypography.nav,               0.25, 11 * 0.3)   // LH 1.3
        }
    }
}

// MARK: - View modifier

struct GaiaFontModifier: ViewModifier {
    let style: GaiaTextStyle
    func body(content: Content) -> some View {
        content
            .font(style.font)
            .tracking(style.tracking)
            .lineSpacing(style.lineSpacing)
    }
}

extension View {
    func gaiaFont(_ style: GaiaTextStyle) -> some View {
        modifier(GaiaFontModifier(style: style))
    }
}

// MARK: - Raw Font tokens (kept for custom / decorative uses)

enum GaiaTypography {
    static let display = serif(size: 32, weight: .regular, fallbackStyle: .largeTitle)
    static let displayMedium = serif(size: 32, weight: .medium, fallbackStyle: .largeTitle)
    static let title1 = serif(size: 28, weight: .regular, fallbackStyle: .title)
    static let title1Medium = serif(size: 28, weight: .medium, fallbackStyle: .title)
    static let title2 = serif(size: 24, weight: .regular, fallbackStyle: .title2)
    static let title2Medium = serif(size: 24, weight: .medium, fallbackStyle: .title2)
    static let title = serif(size: 20, weight: .medium, fallbackStyle: .title3)
    static let titleRegular = serif(size: 20, weight: .regular, fallbackStyle: .title3)
    static let subheadSerif = serif(size: 16, weight: .regular, fallbackStyle: .body)
    static let subheadSerifMedium = serif(size: 16, weight: .medium, fallbackStyle: .body)
    static let bodySerif = serif(size: 14, weight: .regular, fallbackStyle: .body)
    static let bodySerifMedium = serif(size: 14, weight: .medium, fallbackStyle: .body)

    static let titleSans = sans(size: 20, weight: .regular, fallbackStyle: .title3)
    static let titleSansMedium = sans(size: 20, weight: .medium, fallbackStyle: .title3)
    static let body = sans(size: 17, weight: .regular, fallbackStyle: .body)
    static let bodyMedium = sans(size: 17, weight: .medium, fallbackStyle: .body)
    static let bodyBold = sans(size: 17, weight: .bold, fallbackStyle: .body)
    static let callout = sans(size: 16, weight: .regular, fallbackStyle: .callout)
    static let calloutMedium = sans(size: 16, weight: .medium, fallbackStyle: .callout)
    static let subheadline = sans(size: 15, weight: .regular, fallbackStyle: .subheadline)
    static let subheadlineMedium = sans(size: 15, weight: .medium, fallbackStyle: .subheadline)
    static let subheadlineBold = sans(size: 15, weight: .heavy, fallbackStyle: .subheadline)
    static let footnote = sans(size: 13, weight: .regular, fallbackStyle: .footnote)
    static let footnoteMedium = sans(size: 13, weight: .medium, fallbackStyle: .footnote)
    static let caption = sans(size: 11, weight: .regular, fallbackStyle: .caption)
    static let captionMedium = sans(size: 11, weight: .medium, fallbackStyle: .caption)
    static let caption2 = sans(size: 12, weight: .regular, fallbackStyle: .caption2)
    static let caption2Medium = sans(size: 12, weight: .medium, fallbackStyle: .caption2)
    static let nav = caption

    private static func serif(size: CGFloat, weight: Font.Weight, fallbackStyle: Font.TextStyle) -> Font {
        customFont(
            candidates: serifCandidates(for: weight),
            size: size,
            fallback: .system(fallbackStyle, design: .serif, weight: weight)
        )
    }

    private static func sans(size: CGFloat, weight: Font.Weight, fallbackStyle: Font.TextStyle) -> Font {
        customFont(
            candidates: [
                "neue-haas-unica",
                postScriptName(base: "Neue Haas Unica", weight: weight),
                postScriptName(base: "NeueHaasUnica", weight: weight),
                "Neue Haas Unica",
                "Neue Haas Unica W1G",
                "NeueHaasUnica",
                "NeueHaasUnica-Regular",
                "NeueHaasUnica-Medium",
                "NeueHaasUnica-Bold",
                "NeueHaasUnica-ExtraBold"
            ],
            size: size,
            fallback: .system(fallbackStyle, design: .default, weight: weight)
        )
    }

    private static func customFont(candidates: [String], size: CGFloat, fallback: Font) -> Font {
        if let name = candidates.first(where: { UIFont(name: $0, size: size) != nil }) {
            return .custom(name, size: size)
        }
        return fallback
    }

    private static func serifCandidates(for weight: Font.Weight) -> [String] {
        switch weight {
        case .bold:
            return [
                "NewSpirit-SemiBold",
                "NewSpirit-Bold",
                "NewSpirit-SemiBoldCondensed",
                "NewSpirit-BoldCondensed",
                "NewSpirit-SemiBoldItalic",
                "NewSpirit-BoldItalic",
                "NewSpirit-SemiBoldCondensedItalic",
                "NewSpirit-BoldCondensedItalic",
                "new-spirit",
                "NewSpirit",
                "NatureSpiritRegular",
                "Nature Spirit"
            ]
        case .medium:
            return [
                "NewSpirit-Medium",
                "NewSpirit-SemiBold",
                "NewSpirit-MediumCondensed",
                "NewSpirit-MediumItalic",
                "NewSpirit-SemiBoldItalic",
                "NewSpirit-MediumCondensedItalic",
                "new-spirit",
                "NewSpirit",
                "NatureSpiritRegular",
                "Nature Spirit"
            ]
        default:
            return [
                "NewSpirit-Regular",
                "NewSpirit-RegularCondensed",
                "NewSpirit-Light",
                "NewSpirit-RegularItalic",
                "NewSpirit-RegularCondensedItalic",
                "NewSpirit-LightItalic",
                "new-spirit",
                "NewSpirit",
                "NatureSpiritRegular",
                "Nature Spirit"
            ]
        }
    }

    private static func postScriptName(base: String, weight: Font.Weight) -> String {
        switch weight {
        case .heavy, .black:
            return "\(base)-ExtraBold"
        case .bold:
            return "\(base)-Bold"
        case .medium:
            return "\(base)-Medium"
        default:
            return "\(base)-Regular"
        }
    }
}
