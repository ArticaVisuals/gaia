// figma: https://www.figma.com/design/4e4G3tnSR7AdPbf0jAYPP1/Gaia?node-id=1377-100167 (Find Details Activity Contracted)
import SwiftUI

struct ActivityTabView: View {
    let species: Species
    let bottomInset: CGFloat
    let showsFooter: Bool

    init(species: Species, bottomInset: CGFloat = 64, showsFooter: Bool = true) {
        self.species = species
        self.bottomInset = bottomInset
        self.showsFooter = showsFooter
    }

    private var visibleEvents: [ActivityEvent] {
        [
            ActivityEvent(
                id: "find-details-suggestion",
                groupLabel: nil,
                title: "Noah Erdos",
                subtitle: species.scientificName,
                timestampLabel: "5h ago",
                actionLabel: "suggested an ID",
                categoryIDs: nil,
                thumbnailAssetName: "activity-suggestion-thumb"
            ),
            ActivityEvent(
                id: "find-details-comment-liam",
                groupLabel: nil,
                title: "Liam Poplawski",
                subtitle: "Great find. Leaf margins and acorn shape strongly match Coast Live Oak.",
                timestampLabel: "2h ago",
                actionLabel: "commented",
                categoryIDs: nil
            ),
            ActivityEvent(
                id: "find-details-comment-sarah",
                groupLabel: nil,
                title: "Sarah Pinkham",
                subtitle: "I've been seeing a lot of these nearby! I agree with the identification :)",
                timestampLabel: "1h ago",
                actionLabel: "commented",
                categoryIDs: nil
            )
        ]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: ActivityMetrics.sectionGap) {
            ActivityThreadSection(events: visibleEvents)

            if showsFooter {
                ActivityFooterBar()
            }
        }
        .padding(.top, ActivityMetrics.cardPadding)
        .padding(.horizontal, GaiaSpacing.md)
        .padding(.bottom, bottomInset)
    }
}

private struct ActivityThreadSection: View {
    let events: [ActivityEvent]

    var body: some View {
        VStack(alignment: .leading, spacing: ActivityMetrics.cardGap) {
            if let featuredEvent = events.first {
                ActivitySuggestionCard(
                    event: featuredEvent,
                    avatarImageName: activityAvatarImageName(for: featuredEvent)
                )
            }

            if events.count > 1 {
                ActivityCommentRail(events: Array(events.dropFirst()))
            }
        }
    }
}

private func activityAvatarImageName(for event: ActivityEvent) -> String {
    switch event.title {
    case "Noah Erdos":
        return "profile-avatar-noah"
    case "Liam Poplawski":
        return "profile-avatar-maya"
    case "Sarah Pinkham":
        return "profile-avatar-lena"
    default:
        return "find-avatar-alice"
    }
}

private enum ActivityMetrics {
    static let sectionGap: CGFloat = 24
    static let cardGap: CGFloat = 16
    static let cardPadding: CGFloat = 12
    static let headerGap: CGFloat = 8
    static let authorActionGap: CGFloat = 4
    static let contentGap: CGFloat = 16
    static let pillGap: CGFloat = 10
    static let pillHeight: CGFloat = 34
    static let pillHorizontalPadding: CGFloat = 14
    static let timestampWidth: CGFloat = 77
    static let avatarSize: CGFloat = 48
    static let borderWidth: CGFloat = 1
    static let dividerWidth: CGFloat = 0.5
    static let readMoreStemHeight: CGFloat = 15
    static let footerGap: CGFloat = 12
}

private struct ActivityCardHeader: View {
    let author: String
    let actionText: String
    let timestamp: String
    let avatarImageName: String
    let actionTextStyle: GaiaTextStyle

    var body: some View {
        HStack(alignment: .top, spacing: ActivityMetrics.headerGap) {
            FindProfilePicture(size: .large, imageName: avatarImageName)

            HStack(alignment: .top, spacing: ActivityMetrics.headerGap) {
                HStack(alignment: .lastTextBaseline, spacing: ActivityMetrics.authorActionGap) {
                    Text(author)
                        .gaiaFont(.callout)
                        .foregroundStyle(GaiaColor.olive)
                        .lineLimit(1)

                    Text(actionText)
                        .gaiaFont(actionTextStyle)
                        .foregroundStyle(GaiaColor.broccoliBrown500)
                        .lineLimit(1)
                }
                .frame(
                    maxWidth: .infinity,
                    minHeight: ActivityMetrics.avatarSize,
                    alignment: .bottomLeading
                )

                Text(timestamp)
                    .gaiaFont(.caption)
                    .foregroundStyle(GaiaColor.inkBlack200)
                    .monospacedDigit()
                    .lineLimit(1)
                    .frame(
                        width: ActivityMetrics.timestampWidth,
                        height: ActivityMetrics.avatarSize,
                        alignment: .topTrailing
                    )
                    .multilineTextAlignment(.trailing)
            }
        }
        .padding(ActivityMetrics.cardPadding)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(GaiaColor.border)
                .frame(height: ActivityMetrics.dividerWidth)
        }
    }
}

private struct ActivitySuggestionCard: View {
    let event: ActivityEvent
    let avatarImageName: String

    var body: some View {
        ActivityHighlightedCardShell {
            VStack(alignment: .leading, spacing: ActivityMetrics.cardPadding) {
                ActivityCardHeader(
                    author: event.title,
                    actionText: event.actionLabel ?? "suggested an ID",
                    timestamp: event.timestampLabel,
                    avatarImageName: avatarImageName,
                    actionTextStyle: .caption2
                )

                ActivitySuggestionBody(
                    scientificName: event.subtitle,
                    thumbnailAssetName: event.thumbnailAssetName
                )

                HStack(spacing: ActivityMetrics.pillGap) {
                    ActivityOutlinedPill(title: "Agree")
                    ActivityOutlinedPill(title: "Comment")
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.horizontal, ActivityMetrics.cardPadding)
                .padding(.bottom, ActivityMetrics.cardPadding)
            }
        }
    }
}

private struct ActivitySuggestionBody: View {
    let scientificName: String
    let thumbnailAssetName: String?

    var body: some View {
        HStack(alignment: .center, spacing: ActivityMetrics.contentGap) {
            ActivitySuggestionThumbnail(assetName: thumbnailAssetName)

            VStack(alignment: .leading, spacing: ActivityMetrics.headerGap) {
                Text(scientificName)
                    .gaiaFont(.title3)
                    .foregroundStyle(GaiaColor.oliveGreen500)
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)

                Text("Original suggested ID")
                    .gaiaFont(.caption2)
                    .foregroundStyle(GaiaColor.inkBlack300)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: 283, alignment: .leading)
        .padding(.horizontal, ActivityMetrics.cardPadding)
    }
}

private struct ActivitySuggestionThumbnail: View {
    let assetName: String?
    private let size = CGSize(width: 104, height: 64)

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: GaiaRadius.sm, style: .continuous)
                .fill(GaiaColor.blackishGrey100)

            if let assetName {
                GaiaAssetImage(name: assetName, contentMode: .fill)
                    .frame(width: size.width, height: size.height)
                    .clipped()
            }
        }
        .frame(width: size.width, height: size.height)
        .clipShape(RoundedRectangle(cornerRadius: GaiaRadius.sm, style: .continuous))
    }
}

private struct ActivityCommentRail: View {
    let events: [ActivityEvent]

    var body: some View {
        HStack(alignment: .top, spacing: ActivityMetrics.cardGap) {
            ActivityThreadRule()

            VStack(alignment: .leading, spacing: ActivityMetrics.cardGap) {
                ForEach(events) { event in
                    ActivityCommentCard(
                        event: event,
                        avatarImageName: activityAvatarImageName(for: event)
                    )
                }

                ActivityReadMoreRow()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

private struct ActivityCommentCard: View {
    let event: ActivityEvent
    let avatarImageName: String

    var body: some View {
        ActivityCardBackground(cornerRadius: GaiaRadius.card) {
            VStack(alignment: .leading, spacing: ActivityMetrics.cardPadding) {
                ActivityCardHeader(
                    author: event.title,
                    actionText: event.actionLabel ?? "commented",
                    timestamp: event.timestampLabel,
                    avatarImageName: avatarImageName,
                    actionTextStyle: .caption2
                )

                Text(event.subtitle)
                    .gaiaFont(.subheadline)
                    .foregroundStyle(GaiaColor.blackishGrey300)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, ActivityMetrics.cardPadding)
                    .padding(.bottom, ActivityMetrics.cardPadding)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct ActivityReadMoreRow: View {
    var body: some View {
        HStack(spacing: ActivityMetrics.cardGap) {
            Rectangle()
                .fill(GaiaColor.border)
                .frame(width: ActivityMetrics.dividerWidth, height: ActivityMetrics.readMoreStemHeight)
                .accessibilityHidden(true)

            Text("Read more")
                .gaiaFont(.subheadline)
                .foregroundStyle(GaiaColor.oliveGreen500)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
}

private struct ActivityThreadRule: View {
    var body: some View {
        Rectangle()
            .fill(GaiaColor.border)
            .frame(width: ActivityMetrics.dividerWidth)
            .frame(maxHeight: .infinity, alignment: .top)
            .accessibilityHidden(true)
    }
}

private struct ActivityOutlinedPill: View {
    let title: String
    var action: () -> Void = {}

    var body: some View {
        Button {
            HapticsService.selectionChanged()
            action()
        } label: {
            Text(title)
                .gaiaFont(.subheadline)
                .foregroundStyle(GaiaColor.oliveGreen400)
                .padding(.horizontal, ActivityMetrics.pillHorizontalPadding)
                .frame(height: ActivityMetrics.pillHeight)
                .overlay(
                    Capsule()
                        .stroke(GaiaColor.oliveGreen400, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

private struct ActivityPrimaryButton: View {
    let title: String
    var action: () -> Void = {}

    var body: some View {
        Button {
            HapticsService.selectionChanged()
            action()
        } label: {
            Text(title)
                .gaiaFont(.titleSans)
                .foregroundStyle(GaiaColor.paperWhite50)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    Capsule(style: .continuous)
                        .fill(GaiaColor.oliveGreen300)
                        .overlay(
                            Capsule(style: .continuous)
                                .stroke(GaiaColor.oliveGreen200, lineWidth: 1)
                        )
                )
        }
        .buttonStyle(.plain)
    }
}

struct ActivityFooterBar: View {
    var body: some View {
        HStack(spacing: ActivityMetrics.footerGap) {
            ActivityPrimaryButton(title: "Suggest ID")
            ActivityPrimaryButton(title: "Comment")
        }
    }
}

private struct ActivityCardBackground<Content: View>: View {
    let cornerRadius: CGFloat
    @ViewBuilder let content: () -> Content

    var body: some View {
        let cardShape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

        content()
            .background(
                cardShape
                    .fill(GaiaColor.paperWhite50)
                    .overlay {
                        cardShape
                            .strokeBorder(GaiaColor.border, lineWidth: ActivityMetrics.borderWidth)
                    }
            )
            .clipShape(cardShape)
    }
}

private struct ActivityHighlightedCardShell<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        let outerShape = RoundedRectangle(cornerRadius: GaiaRadius.lg, style: .continuous)
        let innerShape = RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)

        content()
            .background(
                innerShape
                    .fill(GaiaColor.paperWhite50)
            )
            .clipShape(innerShape)
            .background(
                outerShape
                    .fill(GaiaColor.oliveGreen500)
            )
            .overlay(
                outerShape
                    .strokeBorder(GaiaColor.border, lineWidth: ActivityMetrics.borderWidth)
            )
            .clipShape(outerShape)
    }
}

private struct FindProfilePicture: View {
    enum Size {
        case small
        case large

        var dimension: CGFloat {
            switch self {
            case .small:
                return 32
            case .large:
                return 48
            }
        }

        var borderWidth: CGFloat {
            switch self {
            case .small:
                return 0.33
            case .large:
                return 0.5
            }
        }
    }

    let size: Size
    var imageName: String = "find-avatar-alice"

    var body: some View {
        GaiaProfileAvatar(
            imageName: imageName,
            size: size.dimension,
            borderWidth: size.borderWidth
        )
    }
}
