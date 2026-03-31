import SwiftUI
import UIKit

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

    static let body = sans(size: 17, weight: .regular, fallbackStyle: .body)
    static let bodyMedium = sans(size: 17, weight: .medium, fallbackStyle: .body)
    static let bodyBold = sans(size: 17, weight: .bold, fallbackStyle: .body)
    static let callout = sans(size: 16, weight: .regular, fallbackStyle: .callout)
    static let calloutMedium = sans(size: 16, weight: .medium, fallbackStyle: .callout)
    static let subheadline = sans(size: 15, weight: .regular, fallbackStyle: .subheadline)
    static let subheadlineMedium = sans(size: 15, weight: .medium, fallbackStyle: .subheadline)
    static let footnote = sans(size: 13, weight: .regular, fallbackStyle: .footnote)
    static let footnoteMedium = sans(size: 13, weight: .medium, fallbackStyle: .footnote)
    static let caption = sans(size: 12, weight: .regular, fallbackStyle: .caption)
    static let captionMedium = sans(size: 12, weight: .medium, fallbackStyle: .caption)
    static let caption2 = sans(size: 10, weight: .regular, fallbackStyle: .caption2)
    static let caption2Medium = sans(size: 10, weight: .medium, fallbackStyle: .caption2)
    static let nav = sans(size: 10, weight: .regular, fallbackStyle: .caption2)

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
                "NeueHaasUnica-Bold"
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
        case .bold:
            return "\(base)-Bold"
        case .medium:
            return "\(base)-Medium"
        default:
            return "\(base)-Regular"
        }
    }
}
