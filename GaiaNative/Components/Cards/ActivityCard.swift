// figma: https://www.figma.com/design/4e4G3tnSR7AdPbf0jAYPP1/Gaia?node-id=870-14978
import SwiftUI

struct ActivityTopBar: View {
    let title: String
    let filters: [String]
    let selectedFilter: String
    let onSelect: (String) -> Void

    var body: some View {
        VStack(spacing: GaiaSpacing.md) {
            ZStack {
                Text(title)
                    .gaiaFont(.title1Medium)
                    .foregroundStyle(GaiaColor.oliveGreen500)
                    .frame(maxWidth: .infinity)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }
            .frame(height: 48)
            .padding(.horizontal, GaiaSpacing.md)
            .padding(.top, 10)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: GaiaSpacing.sm) {
                    ForEach(filters, id: \.self) { filter in
                        Button {
                            onSelect(filter)
                        } label: {
                            Text(filter)
                                .gaiaFont(.footnote)
                                .foregroundStyle(filter == selectedFilter ? GaiaColor.paperWhite50 : GaiaColor.inkBlack300)
                                .padding(.horizontal, 14)
                                .frame(height: 34)
                                .background(
                                    Capsule()
                                        .fill(filter == selectedFilter ? GaiaColor.oliveGreen500 : GaiaColor.paperWhite50)
                                        .overlay(
                                            Capsule()
                                                .stroke(
                                                    filter == selectedFilter
                                                        ? GaiaColor.oliveGreen500
                                                        : GaiaColor.oliveGreen200,
                                                    lineWidth: 0.5
                                                )
                                        )
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, GaiaSpacing.md)
            }
            .scrollIndicators(.hidden)
        }
        .padding(.bottom, GaiaSpacing.md)
        .frame(maxWidth: .infinity)
        .frame(height: 185, alignment: .top)
        .background(GaiaColor.paperWhite50)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(GaiaColor.broccoliBrown200)
                .frame(height: 0.5)
        }
        .shadow(color: GaiaShadow.mdColor, radius: GaiaShadow.mdRadius, x: 0, y: GaiaShadow.mdYOffset)
    }
}

struct ActivityNotificationThumbnail: View {
    let assetName: String?
    var size: CGFloat = 32

    var body: some View {
        Group {
            if let assetName, let image = AssetCatalog.image(named: assetName) {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size, height: size)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(GaiaColor.oliveGreen500.opacity(0.15))
                    .overlay(
                        Circle()
                            .stroke(GaiaColor.oliveGreen500.opacity(0.30), lineWidth: 1)
                    )
                    .frame(width: size, height: size)
            }
        }
        .frame(width: size, height: size)
    }
}

struct ActivityNotificationItem: View {
    let event: ActivityEvent
    let showsDivider: Bool

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 14) {
                ActivityNotificationThumbnail(assetName: event.thumbnailAssetName)
                    .padding(.top, 2)

                VStack(alignment: .leading, spacing: GaiaSpacing.sm) {
                    VStack(alignment: .leading, spacing: GaiaSpacing.sm) {
                        HStack(alignment: .top, spacing: GaiaSpacing.sm) {
                            Text(event.title)
                                .gaiaFont(.subheadSerif)
                                .foregroundStyle(GaiaColor.textPrimary)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Text(event.timestampLabel)
                                .gaiaFont(.caption2)
                                .foregroundStyle(GaiaColor.textSecondary)
                                .fixedSize()
                        }

                        subtitleText
                    }

                    if let actionLabel = event.actionLabel {
                        Text(actionLabel)
                            .gaiaFont(.footnoteMedium)
                            .foregroundStyle(GaiaColor.grassGreen500)
                    }
                }
            }
            .padding(.horizontal, GaiaSpacing.md)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, minHeight: 100, alignment: .leading)

            if showsDivider {
                Rectangle()
                    .fill(GaiaColor.oliveGreen100)
                    .frame(height: 1)
                    .padding(.horizontal, GaiaSpacing.md)
            }
        }
    }

    private var subtitleText: Text {
        let fragments = event.subtitle.components(separatedBy: "**")

        return fragments.enumerated().reduce(Text("")) { partial, fragment in
            let isHighlight = fragment.offset.isMultiple(of: 2) == false
            let piece = Text(fragment.element)
                .font(isHighlight ? GaiaTypography.footnoteMedium : GaiaTypography.footnote)
                .foregroundStyle(isHighlight ? GaiaColor.vermillion300 : GaiaColor.textSecondary)

            return partial + piece
        }
    }
}

struct ActivityCard: View {
    let event: ActivityEvent

    var body: some View {
        GaiaDataCard {
            VStack(alignment: .leading, spacing: GaiaSpacing.sm) {
                HStack(alignment: .firstTextBaseline, spacing: GaiaSpacing.sm) {
                    Text(event.title)
                        .gaiaFont(.calloutMedium)
                        .foregroundStyle(GaiaColor.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text(event.timestampLabel)
                        .gaiaFont(.caption2)
                        .foregroundStyle(GaiaColor.greyMuted)
                        .fixedSize()
                }

                Text(event.subtitle)
                    .gaiaFont(.subheadline)
                    .foregroundStyle(GaiaColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
