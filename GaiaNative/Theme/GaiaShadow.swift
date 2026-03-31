import SwiftUI

enum GaiaShadow {
    static let navColor = Color.black.opacity(0.12)
    static let navRadius: CGFloat = 40

    static let smallColor = GaiaColor.broccoliBrown500.opacity(0.10)
    static let mediumColor = GaiaColor.broccoliBrown500.opacity(0.16)
    static let darkColor = Color(red: 50 / 255, green: 40 / 255, blue: 8 / 255).opacity(0.35)
    static let ambientColor = Color(red: 94 / 255, green: 98 / 255, blue: 98 / 255).opacity(0.20)
    static let greenGlow = GaiaColor.greenGlow.opacity(0.45)

    static let cardColor = mediumColor
    static let cardRadius: CGFloat = 20
}
