// figma: https://www.figma.com/design/4e4G3tnSR7AdPbf0jAYPP1/Gaia?node-id=1462-130207
import SwiftUI

enum ActivityFilter: String, CaseIterable, Identifiable {
    case all = "all"
    case needsID = "needs-id"
    case verified = "verified"
    case comments = "comments"

    var id: String { rawValue }

    var displayTitle: String {
        switch self {
        case .all:
            return "All"
        case .needsID:
            return "Identification"
        case .verified:
            return "Verified"
        case .comments:
            return "Comments"
        }
    }

    var categoryID: String { rawValue }
}

struct ActivityTopBar: View {
    let title: String
    let filters: [ActivityFilter]
    let selectedFilter: ActivityFilter
    let onSelect: (ActivityFilter) -> Void

    var body: some View {
        VStack(spacing: GaiaSpacing.sm) {
            Text(title)
                .gaiaFont(.title1Medium)
                .foregroundStyle(GaiaColor.oliveGreen400)
                .frame(maxWidth: .infinity)
                .frame(height: GaiaSpacing.xxl, alignment: .bottom)
                .padding(.top, GaiaSpacing.space4)
                .padding(.horizontal, GaiaSpacing.md)

            HStack(spacing: GaiaSpacing.sm) {
                ForEach(filters) { filter in
                    Button {
                        onSelect(filter)
                    } label: {
                        Text(filter.displayTitle)
                            .gaiaFont(.subheadline)
                            .foregroundStyle(filter == selectedFilter ? GaiaColor.paperWhite50 : GaiaColor.blackishGrey200)
                            .padding(.horizontal, GaiaSpacing.buttonHorizontalLarge)
                            .frame(height: 34)
                            .background(
                                Capsule()
                                    .fill(
                                        filter == selectedFilter
                                            ? GaiaColor.oliveGreen400
                                            : GaiaColor.blackishGrey200.opacity(0.2)
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(filter.displayTitle)
                    .accessibilityAddTraits(filter == selectedFilter ? [.isSelected] : [])
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
                .fill(GaiaColor.border)
                .frame(height: 0.5)
        }
        .shadow(color: GaiaColor.broccoliBrown500.opacity(0.16), radius: 20, x: 0, y: 4)
    }
}

struct ActivityNotificationThumbnail: View {
    let assetName: String?
    var size: CGFloat = 52

    var body: some View {
        RoundedRectangle(cornerRadius: GaiaRadius.sm, style: .continuous)
            .fill(GaiaColor.paperWhite50)
            .overlay {
                if let assetName, let image = AssetCatalog.image(named: assetName) {
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: size, height: size)
                        .clipped()

                    LinearGradient(
                        colors: [.clear, Color.black.opacity(0.5)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                } else {
                    RoundedRectangle(cornerRadius: GaiaRadius.sm, style: .continuous)
                        .fill(GaiaColor.oliveGreen500.opacity(0.10))
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: GaiaRadius.sm, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: GaiaRadius.sm, style: .continuous)
                    .stroke(GaiaColor.border, lineWidth: 0.5)
            )
            .frame(width: size, height: size)
    }
}

struct ActivityNotificationItem: View {
    let event: ActivityEvent
    let action: () -> Void
    private let unreadIndicatorTrailingInset = GaiaSpacing.space6 + GaiaSpacing.sm + GaiaSpacing.xxs

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: GaiaSpacing.space4) {
                ActivityNotificationThumbnail(assetName: event.thumbnailAssetName)

                VStack(alignment: .leading, spacing: GaiaSpacing.space4) {
                    HStack(alignment: .top, spacing: GaiaSpacing.sm) {
                        Text(event.title)
                            .gaiaFont(.bodyMedium)
                            .foregroundStyle(GaiaColor.inkBlack500)
                            .lineLimit(1)
                            .frame(maxWidth: 250, alignment: .leading)

                        Text(event.timestampLabel)
                            .font(.custom("Neue Haas Unica W1G", size: 11))
                            .foregroundStyle(GaiaColor.blackishGrey500)
                            .monospacedDigit()
                            .multilineTextAlignment(.trailing)
                            .fixedSize()
                            .frame(width: 114, alignment: .trailing)
                    }

                    Text(event.subtitle)
                        .gaiaFont(.callout)
                        .foregroundStyle(GaiaColor.inkBlack300)
                        .lineLimit(2)
                        .frame(maxWidth: 245, alignment: .leading)
                }
                .padding(.trailing, event.showsUnreadIndicator ? 28 : 0)
            }
            .padding(.horizontal, GaiaSpacing.md)
            .padding(.vertical, GaiaSpacing.md)
            .frame(minHeight: 107, alignment: .leading)
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
        }
        .buttonStyle(GaiaPressableCardStyle())
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
                        .gaiaFont(.bodyMedium)
                        .foregroundStyle(GaiaColor.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text(event.timestampLabel)
                        .gaiaFont(.caption)
                        .foregroundStyle(GaiaColor.greyMuted)
                        .fixedSize()
                }

                Text(event.subtitle)
                    .gaiaFont(.callout)
                    .foregroundStyle(GaiaColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
