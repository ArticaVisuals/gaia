import SwiftUI

enum GaiaColor {
    static let oliveGreen50 = Color(hex: 0xF2F4F0)
    static let oliveGreen100 = Color(hex: 0xE3E7DF)
    static let oliveGreen200 = Color(hex: 0xC8CFBF)
    static let oliveGreen300 = Color(hex: 0xA3AE95)
    static let oliveGreen400 = Color(hex: 0x8A9B7E)
    static let oliveGreen500 = Color(hex: 0x67765B)
    static let oliveGreen600 = Color(hex: 0x5B6850)
    static let oliveGreen700 = Color(hex: 0x4F5A45)
    static let oliveGreen800 = Color(hex: 0x3D4535)
    static let oliveGreen900 = Color(hex: 0x282D22)

    static let grassGreen100 = Color(hex: 0xB0D1A5)
    static let grassGreen300 = Color(hex: 0x95C287)
    static let grassGreen500 = Color(hex: 0x7BB369)
    static let grassGreen700 = Color(hex: 0x628F54)

    static let paperWhite50 = Color(hex: 0xFEFDF9)
    static let paperWhite100 = Color(hex: 0xFEFCF7)
    static let paperWhite200 = Color(hex: 0xFDFBF4)
    static let paperWhite500 = Color(hex: 0xFCFAF0)
    static let paperWhite700 = Color(hex: 0xBDBBB4)

    static let broccoliBrown50 = Color(hex: 0xF6F2EE)
    static let broccoliBrown100 = Color(hex: 0xEDE5DC)
    static let broccoliBrown200 = Color(hex: 0xD8C9B8)
    static let broccoliBrown400 = Color(hex: 0xAC9479)
    static let broccoliBrown500 = Color(hex: 0x9B856B)
    static let broccoliBrown800 = Color(hex: 0x5A4C3E)

    static let blackishGrey200 = Color(hex: 0xB1B2B5)
    static let blackishGrey400 = Color(hex: 0x6D6E73)
    static let blackishGrey500 = Color(hex: 0x5B5C61)

    static let inkBlack900 = Color(hex: 0x0D0C0D)
    static let inkBlack300 = Color(hex: 0x7D7981)
    static let inkBlack500 = Color(hex: 0x252024)

    static let indigoBlue500 = Color(hex: 0x4F638D)
    static let vermillion500 = Color(hex: 0xB5493A)
    static let siskin500 = Color(hex: 0xC8C76F)

    static let olive = oliveGreen500
    static let oliveDark = oliveGreen800
    static let paper = paperWhite500
    static let paperStrong = paperWhite50
    static let brown = broccoliBrown500
    static let grey = blackishGrey500
    static let greyMuted = blackishGrey400
    static let border = broccoliBrown200
    static let borderStrong = oliveGreen100
    static let greenGlow = grassGreen500
    static let overlay = Color.black.opacity(0.18)
    static let fillVibrantTertiary = Color(hex: 0xE6EDE3)

    static let surfacePrimary = paperWhite200
    static let surfaceSheet = paperWhite100
    static let surfaceCard = paperWhite50
    static let surfaceStory = broccoliBrown50
    static let textPrimary = inkBlack500
    static let textSecondary = blackishGrey500
    static let textWarmSecondary = broccoliBrown500
    static let textInverse = paperWhite500
    static let textInverseSecondary = oliveGreen200
    static let brandPrimary = oliveGreen500
    static let brandSecondary = broccoliBrown500
    static let brandAccent = siskin500
}

private extension Color {
    init(hex: UInt, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}
