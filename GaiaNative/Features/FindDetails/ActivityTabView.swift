// figma: https://www.figma.com/design/4e4G3tnSR7AdPbf0jAYPP1/Gaia?node-id=870-15225
import SwiftUI

struct ActivityTabView: View {
    let species: Species

    private let comments: [FindDetailComment] = [
        .init(id: "comment-1", author: "Maya Chen", timestamp: "4h ago", body: "Great find. Leaf margins and acorn shape strongly match Coast Live Oak."),
        .init(id: "comment-2", author: "Maya Chen", timestamp: "6h ago", body: "Great find. Leaf margins and acorn shape strongly match Coast Live Oak.")
    ]

    private let leaderboardRows: [FindLeaderboardEntry] = [
        .init(rank: "1", name: "Oliver King", count: "12", isHighlighted: false),
        .init(rank: "2", name: "Maya Chen", count: "6", isHighlighted: false),
        .init(rank: "3", name: "Jules Kim", count: "3", isHighlighted: false),
        .init(rank: "12", name: "Alice Edwards", count: "1", isHighlighted: true)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                ActivityFilterPill(title: "Suggest ID")
                ActivityFilterPill(title: "Comment")
            }

            ActivitySuggestionCard(scientificName: species.scientificName)

            ActivityCommentThread(comments: comments)

            HStack {
                Spacer()
                Text("Read more")
                    .font(GaiaTypography.subheadline)
                    .foregroundStyle(GaiaColor.olive)
            }
            .padding(.horizontal, GaiaSpacing.xs)
            .padding(.leading, GaiaSpacing.md + 1)

            VStack(alignment: .leading, spacing: 12) {
                Text("Leaderboard")
                    .font(GaiaTypography.titleRegular)
                    .foregroundStyle(GaiaColor.olive)

                ActivityLeaderboardCard(rows: leaderboardRows)
            }
        }
        .padding(.horizontal, GaiaSpacing.md)
        .padding(.top, GaiaSpacing.xs)
    }
}

private struct FindDetailComment: Identifiable {
    let id: String
    let author: String
    let timestamp: String
    let body: String
}

private struct FindLeaderboardEntry: Identifiable {
    let rank: String
    let name: String
    let count: String
    let isHighlighted: Bool

    var id: String { rank + name }
}

private struct ActivityFilterPill: View {
    let title: String

    var body: some View {
        Button(action: {}) {
            Text(title)
                .font(GaiaTypography.body)
                .foregroundStyle(GaiaColor.paperWhite50)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(GaiaColor.olive, in: Capsule())
        }
        .buttonStyle(.plain)
        .shadow(color: GaiaShadow.mdColor.opacity(0.65), radius: 14, x: 0, y: 4)
    }
}

private struct ActivitySuggestionCard: View {
    let scientificName: String

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ActivityCardHeader(author: "Alice Edwards", actionText: "suggested an ID", timestamp: "2h ago")

            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 16) {
                    GaiaAssetImage(name: "activity-suggestion-thumb", contentMode: .fill)
                        .frame(width: 104, height: 64)
                        .clipShape(RoundedRectangle(cornerRadius: GaiaRadius.sm, style: .continuous))

                    VStack(alignment: .leading, spacing: 8) {
                        Text(scientificName)
                            .font(GaiaTypography.titleRegular)
                            .foregroundStyle(GaiaColor.olive)
                        Text("Original suggested ID")
                            .font(GaiaTypography.caption)
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
        .background(cardBackground)
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
            .fill(GaiaColor.paperWhite50)
            .overlay(
                RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                    .stroke(GaiaColor.broccoliBrown200, lineWidth: 0.5)
            )
            .shadow(color: GaiaShadow.mdColor, radius: GaiaShadow.mdRadius, x: 0, y: GaiaShadow.mdYOffset)
    }
}

private struct ActivityCommentCard: View {
    let comment: FindDetailComment

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ActivityCardHeader(author: comment.author, actionText: "commented", timestamp: comment.timestamp)

            Text(comment.body)
                .font(GaiaTypography.caption2)
                .foregroundStyle(GaiaColor.blackishGrey300)
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(
            RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                .fill(GaiaColor.paperWhite50)
                .overlay(
                    RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                        .stroke(GaiaColor.broccoliBrown200, lineWidth: 0.5)
                )
                .shadow(color: GaiaShadow.mdColor, radius: GaiaShadow.mdRadius, x: 0, y: GaiaShadow.mdYOffset)
        )
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct ActivityCommentThread: View {
    let comments: [FindDetailComment]

    var body: some View {
        HStack(alignment: .top, spacing: GaiaSpacing.md) {
            Rectangle()
                .fill(Color.black.opacity(0.1))
                .frame(width: 1)

            VStack(alignment: .leading, spacing: GaiaSpacing.sm) {
                ForEach(comments) { comment in
                    ActivityCommentCard(comment: comment)
                }
            }
        }
    }
}

private struct ActivityCardHeader: View {
    let author: String
    let actionText: String
    let timestamp: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            FindProfilePicture(size: .large)

            HStack(alignment: .top, spacing: 8) {
                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text(author)
                        .font(GaiaTypography.subheadSerif)
                        .foregroundStyle(GaiaColor.olive)
                        .lineLimit(1)
                    Text(actionText)
                        .font(GaiaTypography.caption2)
                        .foregroundStyle(GaiaColor.broccoliBrown500)
                        .lineLimit(1)
                }
                Spacer(minLength: 0)
                Text(timestamp)
                    .font(GaiaTypography.caption)
                    .foregroundStyle(GaiaColor.inkBlack200)
                    .tracking(0.25)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .overlay(alignment: .bottom) {
            Divider()
                .background(GaiaColor.broccoliBrown200)
        }
    }
}

private struct ActivityOutlinedPill: View {
    let title: String

    var body: some View {
        Button(action: {}) {
            Text(title)
                .font(GaiaTypography.subheadline)
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

private struct ActivityLeaderboardCard: View {
    let rows: [FindLeaderboardEntry]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(rows) { row in
                ActivityLeaderboardRow(entry: row)
            }

            HStack(spacing: 0) {
                Text("Show more")
                    .font(GaiaTypography.callout)
                    .foregroundStyle(GaiaColor.olive)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
            }
            .frame(maxWidth: .infinity)
        }
        .background(
            RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                .fill(GaiaColor.paperWhite50)
                .overlay(
                    RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                        .stroke(GaiaColor.broccoliBrown200, lineWidth: 0.5)
                )
                .shadow(color: GaiaShadow.mdColor, radius: GaiaShadow.mdRadius, x: 0, y: GaiaShadow.mdYOffset)
        )
        .clipShape(RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous))
    }
}

private struct ActivityLeaderboardRow: View {
    let entry: FindLeaderboardEntry

    var body: some View {
        HStack(spacing: 0) {
            HStack(spacing: 16) {
                Text(entry.rank)
                    .font(GaiaTypography.callout)
                    .foregroundStyle(rankColor)
                    .monospacedDigit()
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
                    .frame(width: 24, alignment: .leading)

                HStack(spacing: 8) {
                    FindProfilePicture(size: .small)
                    Text(entry.name)
                        .font(GaiaTypography.subheadSerif)
                        .foregroundStyle(rankColor)
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 0)

            HStack(spacing: 4) {
                Text(entry.count)
                    .font(GaiaTypography.subheadSerif)
                    .foregroundStyle(rankColor)
                    .monospacedDigit()
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
                ActivityBinocularsIcon(tint: entry.isHighlighted ? GaiaColor.paperWhite50 : GaiaColor.olive)
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 56)
        .background(entry.isHighlighted ? GaiaColor.olive : GaiaColor.paperWhite50)
        .overlay(alignment: .top) {
            if !entry.isHighlighted {
                Rectangle()
                    .fill(GaiaColor.oliveGreen50)
                    .frame(height: 1)
            }
        }
    }

    private var rankColor: Color {
        entry.isHighlighted ? GaiaColor.paperWhite50 : GaiaColor.olive
    }
}

// figma component: Profile Pictures (32/48) — node 870:13598 and 870:13596
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
        let dimension = size.dimension

        ZStack {
            Circle()
                .fill(GaiaColor.blackishGrey100)

            GaiaAssetImage(name: imageName, contentMode: .fill)
                .frame(width: dimension * 3.1506, height: dimension * 2.0982)
                .offset(x: -dimension * 1.6501, y: -dimension * 0.2343)
        }
        .frame(width: dimension, height: dimension)
        .clipShape(Circle())
        .overlay(Circle().stroke(Color.black.opacity(0.1), lineWidth: size.borderWidth))
    }
}

private struct ActivityBinocularsIcon: View {
    let tint: Color

    var body: some View {
        Group {
            if let image = AssetCatalog.uiImage(named: "Icons/System/binoculars-20.png") {
                Image(uiImage: image)
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(tint)
            } else {
                GaiaIcon(kind: .observe(selected: false), size: 14)
                    .foregroundStyle(tint)
            }
        }
        .frame(width: 14, height: 10)
    }
}
