import SwiftUI

struct ActivityTabView: View {
    let species: Species
    let bottomInset: CGFloat
    let showsFooter: Bool
    private let collapsedCommentCount = 2

    init(species: Species, bottomInset: CGFloat = GaiaSpacing.cardInset, showsFooter: Bool = true) {
        self.species = species
        self.bottomInset = bottomInset
        self.showsFooter = showsFooter
    }

    @State private var showsAllComments = false

    private let comments: [FindDetailComment] = [
        .init(
            id: "comment-1",
            author: "Liam Poplawski",
            timestamp: "2h ago",
            body: "Great find. Leaf margins and acorn shape strongly match Coast Live Oak.",
            avatarImageName: "profile-avatar-maya"
        ),
        .init(
            id: "comment-2",
            author: "Sarah Pinkham",
            timestamp: "1h ago",
            body: "I've been seeing a lot of these nearby! I agree with the identification :)",
            avatarImageName: "profile-avatar-lena"
        ),
        .init(
            id: "comment-3",
            author: "Maya Chen",
            timestamp: "6h ago",
            body: "The acorn cap texture also lines up with Coast Live Oak.",
            avatarImageName: "find-avatar-alice"
        )
    ]

    private var visibleComments: [FindDetailComment] {
        showsAllComments ? comments : Array(comments.prefix(collapsedCommentCount))
    }

    private var showsReadMore: Bool {
        !showsAllComments && comments.count > visibleComments.count
    }

    private var suggestion: FindDetailSuggestion {
        FindDetailSuggestion(
            author: "Noah Erdos",
            timestamp: "5h ago",
            scientificName: species.scientificName,
            subtitle: "Original suggested ID",
            avatarImageName: "profile-avatar-noah",
            imageName: "activity-suggestion-thumb"
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: showsFooter ? GaiaSpacing.lg : GaiaSpacing.md) {
            VStack(alignment: .leading, spacing: GaiaSpacing.md) {
                ActivitySuggestionCard(suggestion: suggestion)

                ActivityCommentThread(
                    comments: visibleComments,
                    showsReadMore: showsReadMore,
                    onReadMore: {
                        HapticsService.selectionChanged()
                        withAnimation(GaiaMotion.spring) {
                            showsAllComments = true
                        }
                    }
                )
            }

            if showsFooter {
                ActivityFooterBar()
            }
        }
        .padding(.horizontal, GaiaSpacing.md)
        .padding(.top, GaiaSpacing.cardInset)
        .padding(.bottom, bottomInset)
    }
}

private struct FindDetailSuggestion {
    let author: String
    let timestamp: String
    let scientificName: String
    let subtitle: String
    let avatarImageName: String
    let imageName: String
}

private struct FindDetailComment: Identifiable {
    let id: String
    let author: String
    let timestamp: String
    let body: String
    let avatarImageName: String
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

private struct ActivitySuggestionCard: View {
    let suggestion: FindDetailSuggestion

    var body: some View {
        ActivityHighlightedCardShell {
            VStack(alignment: .leading, spacing: 0) {
                ActivityCardHeader(
                    author: suggestion.author,
                    actionText: "suggested an ID",
                    timestamp: suggestion.timestamp,
                    avatarImageName: suggestion.avatarImageName,
                    actionTextStyle: .caption2
                )

                VStack(alignment: .leading, spacing: GaiaSpacing.cardInset) {
                    HStack(spacing: GaiaSpacing.md) {
                        GaiaAssetImage(name: suggestion.imageName, contentMode: .fill)
                            .frame(width: 104, height: 64)
                            .clipShape(RoundedRectangle(cornerRadius: GaiaRadius.sm, style: .continuous))

                        VStack(alignment: .leading, spacing: GaiaSpacing.sm) {
                            Text(suggestion.scientificName)
                                .gaiaFont(.title3)
                                .foregroundStyle(GaiaColor.olive)
                            Text(suggestion.subtitle)
                                .gaiaFont(.caption2Medium)
                                .foregroundStyle(GaiaColor.inkBlack300)
                        }

                        Spacer(minLength: 0)
                    }

                    HStack(spacing: GaiaSpacing.pillHorizontal) {
                        Spacer(minLength: 0)
                        ActivityOutlinedPill(title: "Agree")
                        ActivityOutlinedPill(title: "Comment")
                    }
                }
                .padding(GaiaSpacing.cardInset)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct ActivityCommentThread: View {
    let comments: [FindDetailComment]
    let showsReadMore: Bool
    let onReadMore: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: GaiaSpacing.md) {
            Rectangle()
                .fill(GaiaColor.broccoliBrown200)
                .frame(width: 0.5)

            VStack(alignment: .leading, spacing: GaiaSpacing.md) {
                ForEach(comments) { comment in
                    ActivityCommentCard(comment: comment)
                }
                if showsReadMore {
                    Button {
                        onReadMore()
                    } label: {
                        HStack {
                            Spacer()
                            Text("Read more")
                                .gaiaFont(.subheadline)
                                .foregroundStyle(GaiaColor.olive)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct ActivityCommentCard: View {
    let comment: FindDetailComment

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ActivityCardHeader(
                author: comment.author,
                actionText: "commented",
                timestamp: comment.timestamp,
                avatarImageName: comment.avatarImageName,
                actionTextStyle: .caption2
            )

            Text(comment.body)
                .gaiaFont(.subheadline)
                .foregroundStyle(GaiaColor.blackishGrey300)
                .padding(GaiaSpacing.cardInset)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(ActivityCardBackground(cornerRadius: GaiaRadius.lg))
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct ActivityCardHeader: View {
    let author: String
    let actionText: String
    let timestamp: String
    let avatarImageName: String
    let actionTextStyle: GaiaTextStyle

    private let avatarDimension: CGFloat = 48

    var body: some View {
        HStack(alignment: .center, spacing: GaiaSpacing.sm) {
            FindProfilePicture(size: .large, imageName: avatarImageName)

            HStack(alignment: .center, spacing: GaiaSpacing.sm) {
                HStack(alignment: .firstTextBaseline, spacing: GaiaSpacing.xs) {
                    Text(author)
                        .gaiaFont(.callout)
                        .foregroundStyle(GaiaColor.olive)
                        .lineLimit(1)

                    Text(actionText)
                        .gaiaFont(actionTextStyle)
                        .foregroundStyle(GaiaColor.broccoliBrown500)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Text(timestamp)
                    .gaiaFont(.caption)
                    .foregroundStyle(GaiaColor.inkBlack200)
                    .monospacedDigit()
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
                    .frame(
                        minWidth: 77,
                        maxWidth: 77,
                        minHeight: avatarDimension,
                        alignment: .center
                    )
                    .multilineTextAlignment(.trailing)
            }
        }
        .padding(GaiaSpacing.cardInset)
        .overlay(alignment: .bottom) {
            Divider()
                .overlay(GaiaColor.broccoliBrown200)
        }
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
                .foregroundStyle(GaiaColor.olive)
                .padding(.horizontal, GaiaSpacing.buttonHorizontalLarge)
                .frame(height: 34)
                .overlay(
                    Capsule()
                        .stroke(GaiaColor.olive, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

struct ActivityFooterBar: View {
    var body: some View {
        HStack(spacing: GaiaSpacing.cardInset) {
            ActivityPrimaryButton(title: "Suggest ID")
            ActivityPrimaryButton(title: "Comment")
        }
    }
}

private struct ActivityCardBackground: View {
    let cornerRadius: CGFloat

    var body: some View {
        let cardShape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

        cardShape
            .fill(GaiaColor.paperWhite50)
            .overlay {
                cardShape
                    .strokeBorder(GaiaColor.broccoliBrown200, lineWidth: 0.5)
            }
    }
}

private struct ActivityHighlightedCardShell<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .background(
                RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                    .fill(GaiaColor.paperWhite50)
            )
            .clipShape(RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous))
            .background(
                RoundedRectangle(cornerRadius: GaiaRadius.lg, style: .continuous)
                    .fill(GaiaColor.oliveGreen500)
            )
            .overlay(
                RoundedRectangle(cornerRadius: GaiaRadius.lg, style: .continuous)
                    .stroke(GaiaColor.broccoliBrown200, lineWidth: 0.5)
            )
            .clipShape(RoundedRectangle(cornerRadius: GaiaRadius.lg, style: .continuous))
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
