import SwiftUI

enum GaiaShadow {
    static let smColor = GaiaColor.broccoliBrown500.opacity(0.10)
    static let mdColor = GaiaColor.broccoliBrown500.opacity(0.16)
    static let lgColor = GaiaColor.broccoliBrown500.opacity(0.24)

    static let softColor = GaiaColor.shadowSoft
    static let smallColor = GaiaColor.shadowSmall
    static let storyColor = GaiaColor.shadowStory
    static let darkColor = GaiaColor.shadowDark
    static let navColor = GaiaColor.shadowNav
    static let projectHeroColor = GaiaColor.shadowProjectHero

    static let smRadius: CGFloat = 8
    static let mdRadius: CGFloat = 20
    static let lgRadius: CGFloat = 40
    static let smallRadius: CGFloat = 20
    static let storyRadius: CGFloat = 24
    static let navRadius: CGFloat = 40
    static let projectHeroRadius: CGFloat = 16.2

    static let smYOffset: CGFloat = 2
    static let mdYOffset: CGFloat = 4
    static let lgYOffset: CGFloat = 8
    static let smallYOffset: CGFloat = 4
    static let storyYOffset: CGFloat = 4
    static let navYOffset: CGFloat = 8
    static let projectHeroYOffset: CGFloat = 4

    static let mediumColor = mdColor
    static let cardColor = GaiaColor.broccoliBrown500.opacity(0.20)
    static let cardRadius: CGFloat = 24
    static let greenGlow = GaiaColor.greenGlow.opacity(0.45)
}
