import SwiftUI

enum GaiaShadow {
    static let smColor = GaiaColor.broccoliBrown500.opacity(0.10)
    static let mdColor = GaiaColor.broccoliBrown500.opacity(0.16)
    static let lgColor = GaiaColor.broccoliBrown500.opacity(0.24)

    static let softColor = Color(red: 94 / 255, green: 98 / 255, blue: 98 / 255).opacity(0.20)
    static let smallColor = Color(red: 128 / 255, green: 105 / 255, blue: 38 / 255).opacity(0.09)
    static let storyColor = Color(red: 89 / 255, green: 48 / 255, blue: 7 / 255).opacity(0.08)
    static let darkColor = Color(red: 50 / 255, green: 40 / 255, blue: 8 / 255).opacity(0.35)
    static let navColor = Color.black.opacity(0.12)

    static let smRadius: CGFloat = 8
    static let mdRadius: CGFloat = 20
    static let lgRadius: CGFloat = 40
    static let smallRadius: CGFloat = 20
    static let storyRadius: CGFloat = 24
    static let navRadius: CGFloat = 40

    static let smYOffset: CGFloat = 2
    static let mdYOffset: CGFloat = 4
    static let lgYOffset: CGFloat = 8
    static let smallYOffset: CGFloat = 4
    static let storyYOffset: CGFloat = 4
    static let navYOffset: CGFloat = 8

    static let mediumColor = mdColor
    static let cardColor = GaiaColor.textPrimary.opacity(0.10)
    static let cardRadius = mdRadius
    static let greenGlow = GaiaColor.greenGlow.opacity(0.45)
}
