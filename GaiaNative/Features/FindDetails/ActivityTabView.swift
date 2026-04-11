import SwiftUI

struct ActivityTabView: View {
    let species: Species

    @State private var showsAllComments = false

    private let comments: [FindDetailComment] = [
        .init(
            id: "comment-1",
            author: "Maya Chen",
            timestamp: "4h ago",
            body: "Great find. Leaf margins and acorn shape strongly match Coast Live Oak.",
            avatarImageName: "find-avatar-alice"
        ),
        .init(
            id: "comment-2",
            author: "Maya Chen",
            timestamp: "4h ago",
            body: "Great find. Leaf margins and acorn shape strongly match Coast Live Oak.",
            avatarImageName: "find-avatar-alice"
        ),
        .init(
            id: "comment-3",
            author: "Maya Chen",
            timestamp: "4h ago",
            body: "Great find. Leaf margins and acorn shape strongly match Coast Live Oak.",
            avatarImageName: "find-avatar-alice"
        ),
        .init(
            id: "comment-4",
            author: "Maya Chen",
            timestamp: "6h ago",
            body: "Great find. Leaf margins and acorn shape strongly match Coast Live Oak.",
            avatarImageName: "find-avatar-alice"
        ),
        .init(
            id: "comment-5",
            author: "Maya Chen",
            timestamp: "Yesterday",
            body: "The acorn cap texture also lines up with Coast Live Oak.",
            avatarImageName: "find-avatar-alice"
        )
    ]

    private var visibleComments: [FindDetailComment] {
        showsAllComments ? comments : Array(comments.prefix(4))
    }

    private var showsReadMore: Bool {
        !showsAllComments && comments.count > visibleComments.count
    }

    private var suggestion: FindDetailSuggestion {
        FindDetailSuggestion(
            author: "Alice Edwards",
            timestamp: "2h ago",
            scientificName: species.scientificName,
            subtitle: "Original suggested ID",
            avatarImageName: "find-avatar-alice",
            imageName: "activity-suggestion-thumb"
        )
    }

    var body: some View {
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

            HStack(spacing: 12) {
                ActivityPrimaryButton(title: "Suggest ID")
                ActivityPrimaryButton(title: "Comment")
            }
        }
        .padding(.horizontal, 10)
        .padding(.top, GaiaSpacing.xs)
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
                .gaiaFont(.bodyMedium)
                .foregroundStyle(GaiaColor.paperWhite50)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(GaiaColor.olive, in: Capsule())
        }
        .buttonStyle(.plain)
    }
}

private struct ActivitySuggestionCard: View {
    let suggestion: FindDetailSuggestion

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ActivityCardHeader(
                author: suggestion.author,
                actionText: "suggested an ID",
                timestamp: suggestion.timestamp,
                avatarImageName: suggestion.avatarImageName
            )

            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 16) {
                    GaiaAssetImage(name: suggestion.imageName, contentMode: .fill)
                        .frame(width: 104, height: 64)
                        .clipShape(RoundedRectangle(cornerRadius: GaiaRadius.sm, style: .continuous))

                    VStack(alignment: .leading, spacing: 8) {
                        Text(suggestion.scientificName)
                            .gaiaFont(.title3)
                            .foregroundStyle(GaiaColor.olive)
                        Text(suggestion.subtitle)
                            .gaiaFont(.caption2Medium)
                            .foregroundStyle(GaiaColor.inkBlack300)
                    }

                    Spacer(minLength: 0)
                }

                HStack(spacing: 10) {
                    Spacer(minLength: 0)
                    ActivityOutlinedPill(title: "Agree")
                    ActivityOutlinedPill(title: "Comment")
                }
            }
            .padding(12)
        }
        .background(ActivityCardBackground(cornerRadius: GaiaRadius.lg))
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
                avatarImageName: comment.avatarImageName
            )

            Text(comment.body)
                .gaiaFont(.subheadline)
                .foregroundStyle(GaiaColor.blackishGrey300)
                .padding(12)
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

    private let avatarDimension: CGFloat = 48
    private let timestampWidth: CGFloat = 77

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            FindProfilePicture(size: .large, imageName: avatarImageName)

            HStack(alignment: .center, spacing: 8) {
                HStack(alignment: .bottom, spacing: 4) {
                    Text(author)
                        .gaiaFont(.subheadSerif)
                        .foregroundStyle(GaiaColor.olive)
                        .lineLimit(1)

                    Text(actionText)
                        .gaiaFont(.caption2Medium)
                        .foregroundStyle(GaiaColor.broccoliBrown500)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Text(timestamp)
                    .gaiaFont(.caption)
                    .foregroundStyle(GaiaColor.inkBlack200)
                    .monospacedDigit()
                    .lineLimit(1)
                    .frame(width: timestampWidth, height: avatarDimension, alignment: .topTrailing)
            }
            .frame(maxWidth: .infinity, minHeight: avatarDimension, alignment: .leading)
        }
        .padding(12)
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
                .padding(.horizontal, 14)
                .frame(height: 34)
                .overlay(
                    Capsule()
                        .stroke(GaiaColor.olive, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

private struct ActivityCardBackground: View {
    let cornerRadius: CGFloat

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(GaiaColor.paperWhite50)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(GaiaColor.broccoliBrown200, lineWidth: 0.5)
            )
            .shadow(color: GaiaShadow.cardColor, radius: GaiaShadow.cardRadius, x: 0, y: GaiaShadow.mdYOffset)
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
