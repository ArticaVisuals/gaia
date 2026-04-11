// figma: https://www.figma.com/design/4e4G3tnSR7AdPbf0jAYPP1/Gaia?node-id=995-15449
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
                .frame(height: 48, alignment: .bottom)
                .padding(.top, GaiaSpacing.cardInset)
                .padding(.horizontal, GaiaSpacing.md)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: GaiaSpacing.sm) {
                    ForEach(filters, id: \.self) { filter in
                        Button {
                            onSelect(filter)
                        } label: {
                            GaiaPill(
                                title: filter,
                                style: filter == selectedFilter ? .prominent : .soft
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, GaiaSpacing.md)
            }
            .scrollIndicators(.hidden)
        }
        .padding(.bottom, GaiaSpacing.lg)
        .frame(maxWidth: .infinity)
        .background {
            Rectangle()
                .fill(GaiaColor.paperWhite50)
                .ignoresSafeArea(edges: .top)
                .shadow(color: GaiaShadow.mdColor, radius: GaiaShadow.mdRadius, x: 0, y: GaiaShadow.mdYOffset)
        }
        .overlay(alignment: .bottom) {
            ActivityHairline(color: GaiaColor.broccoliBrown200)
        }
        .zIndex(1)
    }
}

struct ActivityNotificationItem: View {
    let event: ActivityEvent

    var body: some View {
        HStack(alignment: .center, spacing: GaiaSpacing.cardInset) {
            ActivityRowThumbnail(assetName: event.mediaAssetNames.first)

            VStack(alignment: .leading, spacing: GaiaSpacing.sm) {
                HStack(alignment: .top, spacing: GaiaSpacing.sm) {
                    Text(event.title)
                        .gaiaFont(.subheadSerifMedium)
                        .foregroundStyle(GaiaColor.textPrimary)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text(event.timestampLabel)
                        .gaiaFont(.caption)
                        .foregroundStyle(GaiaColor.textSecondary)
                        .monospacedDigit()
                        .fixedSize()
                }

                Text(event.subtitle)
                    .gaiaFont(.callout)
                    .foregroundStyle(GaiaColor.textSecondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }

            if event.showsNotificationStyle {
                Circle()
                    .fill(GaiaColor.vermillion500)
                    .frame(width: 12, height: 12)
                    .accessibilityHidden(true)
            }
        }
        .padding(.horizontal, GaiaSpacing.md)
        .padding(.vertical, GaiaSpacing.md)
        .frame(maxWidth: .infinity, minHeight: 107, alignment: .leading)
        .background(event.showsNotificationStyle ? GaiaColor.broccoliBrown50 : GaiaColor.paperWhite50)
        .contentShape(Rectangle())
        .accessibilityElement(children: .contain)
    }
}

private struct ActivityRowThumbnail: View {
    let assetName: String?
    private let size: CGFloat = 52

    var body: some View {
        Group {
            if let assetName {
                GaiaAssetImage(name: assetName, contentMode: .fill)
            } else {
                RoundedRectangle(cornerRadius: GaiaRadius.sm, style: .continuous)
                    .fill(GaiaColor.oliveGreen100)
                    .overlay(
                        Image(systemName: "bell.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 14, height: 14)
                            .foregroundStyle(GaiaColor.olive)
                    )
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: GaiaRadius.sm, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: GaiaRadius.sm, style: .continuous)
                .stroke(GaiaColor.border, lineWidth: 0.5)
        )
        .accessibilityHidden(true)
    }
}

struct ActivityCard: View {
    let event: ActivityEvent

    var body: some View {
        ActivityNotificationItem(event: event)
    }
}
