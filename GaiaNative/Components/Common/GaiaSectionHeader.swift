import SwiftUI

struct GaiaSectionHeader: View {
    let title: String
    var eyebrow: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            if let eyebrow {
                Text(eyebrow)
                    .gaiaFont(.caption2)
                    .foregroundStyle(GaiaColor.greyMuted)
                    .textCase(.uppercase)
            }
            Text(title)
                .gaiaFont(.title3Medium)
                .foregroundStyle(GaiaColor.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct GaiaDayDivider: View {
    let title: String
    var detail: String? = nil
    var background: Color = GaiaColor.paperWhite50

    var body: some View {
        HStack(alignment: .bottom, spacing: GaiaSpacing.pillHorizontal) {
            Text(title)
                .gaiaFont(.title1Medium)
                .foregroundStyle(GaiaColor.inkBlack300)

            if let detail, !detail.isEmpty {
                Text(detail)
                    .gaiaFont(.caption2)
                    .foregroundStyle(GaiaColor.brandPrimary)
                    .padding(.bottom, GaiaSpacing.xs)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, GaiaSpacing.md)
        .padding(.top, GaiaSpacing.lg)
        .padding(.bottom, GaiaSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(background)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(GaiaColor.border)
                .frame(height: 0.5)
        }
    }
}
