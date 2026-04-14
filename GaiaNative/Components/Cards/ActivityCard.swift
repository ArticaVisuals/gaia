// figma: https://www.figma.com/design/4e4G3tnSR7AdPbf0jAYPP1/Gaia?node-id=1462-130207
import SwiftUI

struct ActivityTopBar: View {
    let title: String
    let filters: [String]
    let selectedFilter: String
    let onSelect: (String) -> Void

    var body: some View {
        VStack(spacing: GaiaSpacing.sm) {
            Text(title)
                .gaiaFont(.title1Medium)
                .foregroundStyle(GaiaColor.oliveGreen500)
                .frame(maxWidth: .infinity)
                .frame(height: GaiaSpacing.xxl, alignment: .bottom)
                .padding(.top, GaiaSpacing.space4)
                .padding(.horizontal, GaiaSpacing.md)

            HStack(spacing: GaiaSpacing.sm) {
                ForEach(filters, id: \.self) { filter in
                    Button {
                        onSelect(filter)
                    } label: {
                        Text(filter)
                            .gaiaFont(.subheadline)
                            .foregroundStyle(filter == selectedFilter ? GaiaColor.paperWhite50 : GaiaColor.textDisabled)
                            .padding(.horizontal, GaiaSpacing.buttonHorizontalLarge)
                            .frame(height: 34)
                            .background(
                                Capsule()
                                    .fill(filter == selectedFilter ? GaiaColor.oliveGreen500 : GaiaColor.textDisabled.opacity(0.20))
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, GaiaSpacing.md)
        }
        .padding(.bottom, GaiaSpacing.lg)
        .frame(maxWidth: .infinity)
        .background(GaiaColor.paperWhite50)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(GaiaColor.broccoliBrown200)
                .frame(height: 0.5)
        }
    }
}

struct ActivityNotificationThumbnail: View {
    let assetName: String?
    var size: CGFloat = 52

    var body: some View {
        RoundedRectangle(cornerRadius: GaiaRadius.sm, style: .continuous)
            .fill(GaiaColor.broccoliBrown50)
            .overlay {
                if let assetName, let image = AssetCatalog.image(named: assetName) {
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: size, height: size)
                        .clipped()

                    LinearGradient(
                        colors: [.clear, Color.black.opacity(0.24)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                } else {
                    RoundedRectangle(cornerRadius: GaiaRadius.sm, style: .continuous)
                        .fill(GaiaColor.oliveGreen500.opacity(0.15))
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: GaiaRadius.sm, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: GaiaRadius.sm, style: .continuous)
                    .stroke(GaiaColor.broccoliBrown200, lineWidth: 0.5)
            )
            .frame(width: size, height: size)
    }
}

struct ActivityNotificationItem: View {
    let event: ActivityEvent
    private let unreadIndicatorTrailingInset = GaiaSpacing.space6 + GaiaSpacing.sm + GaiaSpacing.xxs

    var body: some View {
        HStack(alignment: .top, spacing: GaiaSpacing.space4) {
            ActivityNotificationThumbnail(assetName: event.thumbnailAssetName)

            VStack(alignment: .leading, spacing: GaiaSpacing.space4) {
                HStack(alignment: .top, spacing: GaiaSpacing.sm) {
                    Text(event.title)
                        .gaiaFont(.bodyMedium)
                        .foregroundStyle(GaiaColor.inkBlack500)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text(event.timestampLabel)
                        .gaiaFont(.caption)
                        .foregroundStyle(GaiaColor.blackishGrey500)
                        .monospacedDigit()
                        .multilineTextAlignment(.trailing)
                        .fixedSize()
                }

                Text(event.subtitle)
                    .gaiaFont(.callout)
                    .foregroundStyle(GaiaColor.blackishGrey500)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.trailing, event.showsUnreadIndicator ? 28 : 0)
        }
        .padding(.horizontal, GaiaSpacing.md)
        .padding(.vertical, GaiaSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(event.showsUnreadIndicator ? GaiaColor.broccoliBrown50 : GaiaColor.paperWhite50)
        .overlay(alignment: .trailing) {
            if event.showsUnreadIndicator {
                Circle()
                    .fill(GaiaColor.vermillion500)
                    .frame(width: GaiaSpacing.space4, height: GaiaSpacing.space4)
                    .padding(.trailing, unreadIndicatorTrailingInset)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
    }

    private var accessibilityLabel: String {
        if event.showsUnreadIndicator {
            return "\(event.title), \(event.subtitle), \(event.timestampLabel), unread"
        }

        return "\(event.title), \(event.subtitle), \(event.timestampLabel)"
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
