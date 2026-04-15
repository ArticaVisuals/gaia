import SwiftUI
import UIKit

private enum ProjectDetailLayout {
    static let heroHeight: CGFloat = 262
    static let sectionSpacing = GaiaSpacing.lg
    static let sectionHeaderSpacing = GaiaSpacing.md
    static let actionRowSpacing = GaiaSpacing.cardInset
    static let actionSectionSpacing = GaiaSpacing.lg
    static let cardCornerRadius: CGFloat = 12.203
    static let heroCornerRadius = GaiaRadius.lg
    static let thumbnailCornerRadius: CGFloat = 12.203
    static let recentFindGridSpacing: CGFloat = 10
    static let recentFindBorderWidth: CGFloat = 0.763
    static let recentFindCardHeight: CGFloat = 180.005
    static let recentFindImageHeight: CGFloat = 88.557
    static let recentFindBlurRadius: CGFloat = 3.8
    static let recentFindShadowRadius: CGFloat = 6.102
    static let recentFindShadowYOffset: CGFloat = 4
    static let recentFindTitleInset: CGFloat = 13
    static let recentFindTitleBottomInset: CGFloat = 14
    static let updateThumbSize: CGFloat = 88.557
    static let updateCardHeight: CGFloat = 112.557
    static let observerRowSpacing = GaiaSpacing.pillHorizontal
    static let observerAvatarSize = GaiaSpacing.iconXl
    static let observerAvatarOverlap = GaiaSpacing.md
    static let founderAvatarScale: CGFloat = 2.18
    static let founderAvatarOffsetY: CGFloat = -14
}

struct ProjectDetailScreen: View {
    let project: ProjectSelection?

    @EnvironmentObject private var appState: AppState

    private var content: ProjectDetailContent {
        .forProject(project)
    }

    var body: some View {
        GeometryReader { proxy in
            let topInset = proxy.safeAreaInsets.top > 0 ? proxy.safeAreaInsets.top : windowSafeTopInset
            // Keep the hero under the glass toolbar while avoiding an overly tight top crop.
            let heroLift = max(topInset - GaiaSpacing.lg, 0)

            ZStack(alignment: .top) {
                GaiaColor.paperWhite50.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: ProjectDetailLayout.sectionSpacing) {
                        ProjectHeroSection(content: content)
                            .padding(.top, -heroLift)
                            .frame(maxWidth: .infinity)

                        VStack(alignment: .leading, spacing: ProjectDetailLayout.sectionSpacing) {
                            ProjectActionsSection(content: content)
                            ProjectRecentFindsSection(items: content.recentFinds, location: content.location)
                            ProjectObserversSection(content: content)
                            ProjectUpdatesSection(updates: content.updates)
                        }
                        .padding(.horizontal, GaiaSpacing.md)
                        .padding(.bottom, GaiaSpacing.xxxl)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                VStack {
                    HStack {
                        ToolbarGlassButton(icon: .back, accessibilityLabel: "Back") {
                            appState.closeProjectDetail()
                        }
                        Spacer()
                        ToolbarGlassPill(primaryAction: {}, secondaryAction: {})
                    }
                    .padding(.horizontal, GaiaSpacing.md)
                    .padding(.top, max(topInset + 8, 54))

                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
        }
        .ignoresSafeArea(edges: .top)
    }

    private var windowSafeTopInset: CGFloat {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)?
            .safeAreaInsets.top ?? 0
    }
}

private struct ProjectDetailContent {
    struct RecentFind: Identifiable {
        let id: String
        let title: String
        let imageName: String
    }

    struct UpdateItem: Identifiable {
        let id: String
        let title: String
        let subtitle: String
        let timeLabel: String
        let imageName: String
    }

    let id: String
    let title: String
    let location: String
    let heroImageName: String
    let founderImageName: String
    let observerImageNames: [String]
    let founderLabel: String
    let observersLabel: String
    let observersCount: String
    let findsLabel: String
    let findsCount: String
    let description: String
    let readMoreLabel: String
    let observersHeadline: String
    let observersSubtitle: String
    let recentFinds: [RecentFind]
    let updates: [UpdateItem]

    static func forProject(_ selection: ProjectSelection?) -> ProjectDetailContent {
        let selected = selection ?? .init(
            id: "project-pollinator",
            title: "Pollinator Corridor",
            tag: "Garden",
            countLabel: "9",
            imageName: "find-project-pollinator"
        )

        switch selected.id {
        case "project-creek":
            return .creek
        case "project-pollinator":
            return .pollinator
        default:
            return .pollinator
        }
    }

    private static let recentFinds: [RecentFind] = [
        .init(id: "cacti", title: "Cacti", imageName: "project-detail-recent-cacti"),
        .init(id: "indian-cormorant", title: "Indian Cormorant", imageName: "project-detail-recent-indian-cormorant"),
        .init(id: "european-roller", title: "European Roller", imageName: "project-detail-recent-european-roller"),
        .init(id: "bindweed-tribe", title: "Bindweed Tribe", imageName: "project-detail-recent-bindweed-tribe"),
        .init(id: "emperor-gum-moth", title: "Emperor Gum Moth", imageName: "project-detail-recent-emperor-gum-moth"),
        .init(id: "garden-orbweaver", title: "Garden Orbweaver", imageName: "project-detail-recent-garden-orbweaver")
    ]

    private static let updates: [UpdateItem] = [
        .init(
            id: "weekend-goals",
            title: "Weekend find goals are live",
            subtitle: "Project organizers are focusing on milkweed and monkeyflower this week.",
            timeLabel: "2 days ago",
            imageName: "project-detail-update-weekend-goals"
        ),
        .init(
            id: "spring-checkin",
            title: "Spring bloom check-in posted",
            subtitle: "See how recent finds are shaping the season so far.",
            timeLabel: "5 days ago",
            imageName: "project-detail-update-spring-bloom"
        )
    ]

    private static let observerImageNames = [
        "project-detail-contributor-1",
        "project-detail-contributor-2",
        "project-detail-contributor-3",
        "project-detail-contributor-4",
        "project-detail-contributor-5",
        "project-detail-contributor-6"
    ]

    private static let pollinator = ProjectDetailContent(
        id: "project-pollinator",
        title: "Pollinator Corridor",
        location: "Arroyo Seco",
        heroImageName: "project-detail-hero-pollinator",
        founderImageName: "project-detail-founder-alice-edwards",
        observerImageNames: observerImageNames,
        founderLabel: "Founder",
        observersLabel: "Observers",
        observersCount: "24",
        findsLabel: "Finds",
        findsCount: "156",
        description: "Map wildflower species along the Arroyo Seco to support native pollinator recovery.",
        readMoreLabel: "Read More",
        observersHeadline: "24 people contributing",
        observersSubtitle: "Led by Alice Edwards and 2 coordinators",
        recentFinds: recentFinds,
        updates: updates
    )

    private static let creek = ProjectDetailContent(
        id: "project-creek",
        title: "Creek Recovery",
        location: "Arroyo Seco",
        heroImageName: "find-project-creek",
        founderImageName: "project-detail-founder-alice-edwards",
        observerImageNames: observerImageNames,
        founderLabel: "Founder",
        observersLabel: "Observers",
        observersCount: "24",
        findsLabel: "Finds",
        findsCount: "156",
        description: "Map habitat restoration finds along the Arroyo Seco and track recovery progress over time.",
        readMoreLabel: "Read More",
        observersHeadline: "24 people contributing",
        observersSubtitle: "Led by Alice Edwards and 2 coordinators",
        recentFinds: recentFinds,
        updates: updates
    )
}

private struct ProjectHeroSection: View {
    let content: ProjectDetailContent

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            ProjectMediaImage(source: content.heroImageName, contentMode: .fill)
                .frame(maxWidth: .infinity)
                .frame(height: ProjectDetailLayout.heroHeight)
                .clipped()

            ProjectMediaImage(source: content.heroImageName, contentMode: .fill)
                .frame(maxWidth: .infinity)
                .frame(height: ProjectDetailLayout.heroHeight)
                .blur(radius: 9.5)
                .mask(
                    LinearGradient(
                        stops: [
                            .init(color: .clear, location: 0.0),
                            .init(color: .clear, location: 0.4),
                            .init(color: .black.opacity(0.7), location: 0.72),
                            .init(color: .black, location: 1.0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            LinearGradient(
                colors: [Color.clear, Color.black.opacity(0.22)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(maxWidth: .infinity)
            .frame(height: ProjectDetailLayout.heroHeight)

            VStack(alignment: .leading, spacing: GaiaSpacing.sm) {
                Text(content.title)
                    .gaiaFont(.displayMedium)
                    .foregroundStyle(GaiaColor.paperWhite50)
                    .lineLimit(2)

                HStack(spacing: 0) {
                    ProjectLocationPinIcon()
                    Text(content.location)
                        .gaiaFont(.subheadline)
                        .foregroundStyle(GaiaColor.paperWhite50)
                        .lineLimit(1)
                }
            }
            .padding(.leading, GaiaSpacing.detailInset)
            .padding(.bottom, GaiaSpacing.detailInset)
        }
        .clipShape(
            UnevenRoundedRectangle(
                cornerRadii: .init(
                    topLeading: 0,
                    bottomLeading: ProjectDetailLayout.heroCornerRadius,
                    bottomTrailing: ProjectDetailLayout.heroCornerRadius,
                    topTrailing: 0
                ),
                style: .continuous
            )
        )
        .shadow(
            color: GaiaColor.blackishGrey300.opacity(0.45),
            radius: 16.2,
            x: 0,
            y: 4
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(content.title), \(content.location)")
    }
}

private struct ProjectActionsSection: View {
    let content: ProjectDetailContent
    @EnvironmentObject private var appState: AppState

    var body: some View {
        VStack(spacing: ProjectDetailLayout.actionSectionSpacing) {
            HStack(spacing: ProjectDetailLayout.actionRowSpacing) {
                ProjectActionButton(title: "Add Find", style: .filled) {
                    appState.closeProjectDetail()
                    appState.select(section: .observe)
                }
                ProjectActionStatusPill(title: "Joined")
            }

            ProjectStatsCard(content: content)
            ProjectDescriptionCard(content: content)
        }
    }
}

private enum ProjectActionButtonStyle {
    case filled
    case outlined
}

private struct ProjectActionButton: View {
    let title: String
    let style: ProjectActionButtonStyle
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .gaiaFont(.subheadline)
                .foregroundStyle(style == .filled ? GaiaColor.paperWhite50 : GaiaColor.oliveGreen500)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
        }
        .buttonStyle(.plain)
        .background(backgroundView)
        .clipShape(Capsule(style: .continuous))
        .contentShape(Capsule(style: .continuous))
    }

    @ViewBuilder
    private var backgroundView: some View {
        switch style {
        case .filled:
            Capsule(style: .continuous)
                .fill(GaiaColor.oliveGreen300)
        case .outlined:
            Capsule(style: .continuous)
                .stroke(GaiaColor.oliveGreen200, lineWidth: 1)
                .background(
                    Capsule(style: .continuous)
                        .fill(Color.clear)
                )
        }
    }
}

private struct ProjectActionStatusPill: View {
    let title: String

    var body: some View {
        Text(title)
            .gaiaFont(.subheadline)
            .foregroundStyle(GaiaColor.oliveGreen500)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                Capsule(style: .continuous)
                    .stroke(GaiaColor.oliveGreen200, lineWidth: 1)
            )
            .accessibilityLabel(title)
    }
}

private struct ProjectStatsCard: View {
    let content: ProjectDetailContent

    var body: some View {
        HStack(spacing: 0) {
            founderColumn
            divider
            metricColumn(
                label: content.observersLabel,
                icon: .profile(selected: false),
                value: content.observersCount,
                iconTextOverlap: 11
            )
            divider
            metricColumn(
                label: content.findsLabel,
                icon: .observe(selected: false),
                value: content.findsCount,
                iconTextOverlap: 6
            )
        }
        .padding(.horizontal, GaiaSpacing.cardContentInsetWide)
        .padding(.vertical, GaiaSpacing.lg)
        .frame(height: 128)
        .background(
            RoundedRectangle(cornerRadius: ProjectDetailLayout.cardCornerRadius, style: .continuous)
                .fill(GaiaColor.paperWhite50)
                .overlay(
                    RoundedRectangle(cornerRadius: ProjectDetailLayout.cardCornerRadius, style: .continuous)
                        .stroke(GaiaColor.border, lineWidth: ProjectDetailLayout.recentFindBorderWidth)
                )
        )
    }

    private var founderColumn: some View {
        VStack(spacing: GaiaSpacing.inset12) {
            Text(content.founderLabel)
                .gaiaFont(.caption2)
                .foregroundStyle(GaiaColor.oliveGreen300)

            ProjectCroppedCircleImage(
                source: content.founderImageName,
                size: 48,
                scale: ProjectDetailLayout.founderAvatarScale,
                offsetY: ProjectDetailLayout.founderAvatarOffsetY
            )
        }
        .frame(maxWidth: .infinity)
    }

    private var divider: some View {
        Rectangle()
            .fill(GaiaColor.border)
            .frame(width: 0.5)
            .frame(maxHeight: .infinity)
    }

    private func metricColumn(
        label: String,
        icon: GaiaIconKind,
        value: String,
        iconTextOverlap: CGFloat
    ) -> some View {
        VStack(spacing: GaiaSpacing.inset12) {
            Text(label)
                .gaiaFont(.caption2)
                .foregroundStyle(GaiaColor.oliveGreen300)

            HStack(spacing: -iconTextOverlap) {
                GaiaIcon(kind: icon, size: 40, tint: GaiaColor.oliveGreen400)
                    .frame(width: 40, height: 40)

                Text(value)
                    .gaiaFont(.displayMedium)
                    .foregroundStyle(GaiaColor.oliveGreen400)
                    .frame(width: 58, height: 59, alignment: .leading)
            }
            .frame(height: 49)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct ProjectDescriptionCard: View {
    let content: ProjectDetailContent

    var body: some View {
        VStack(alignment: .leading, spacing: GaiaSpacing.md) {
            Text(content.description)
                .gaiaFont(.subheadline)
                .foregroundStyle(GaiaColor.paperWhite50)
                .frame(maxWidth: 305, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)

            Button(action: {}) {
                Text(content.readMoreLabel)
                    .gaiaFont(.subheadline)
                    .foregroundStyle(GaiaColor.olive)
                    .padding(.horizontal, GaiaSpacing.buttonHorizontalLarge)
                    .frame(height: 34)
                    .background(
                        Capsule(style: .continuous)
                            .fill(GaiaColor.paperWhite50)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, GaiaSpacing.lg - 4)
        .padding(.vertical, GaiaSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: ProjectDetailLayout.cardCornerRadius, style: .continuous)
                .fill(GaiaColor.oliveGreen300)
                .overlay(
                    RoundedRectangle(cornerRadius: ProjectDetailLayout.cardCornerRadius, style: .continuous)
                        .stroke(Color.black.opacity(0.1), lineWidth: 0.5)
                )
        )
    }
}

private struct ProjectSectionHeader: View {
    let title: String
    let actionTitle: String

    var body: some View {
        HStack(alignment: .bottom, spacing: GaiaSpacing.sm) {
            Text(title)
                .gaiaFont(.titleSans)
                .foregroundStyle(GaiaColor.inkBlack300)

            Spacer(minLength: 0)

            Button(action: {}) {
                Text(actionTitle)
                    .gaiaFont(.caption2)
                    .foregroundStyle(GaiaColor.olive)
            }
            .buttonStyle(.plain)
        }
    }
}

private struct ProjectRecentFindsSection: View {
    let items: [ProjectDetailContent.RecentFind]
    let location: String

    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: ProjectDetailLayout.recentFindGridSpacing),
        GridItem(.flexible(), spacing: ProjectDetailLayout.recentFindGridSpacing)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: ProjectDetailLayout.sectionHeaderSpacing) {
            ProjectSectionHeader(title: "Recent Finds", actionTitle: "See all")

            LazyVGrid(columns: columns, alignment: .leading, spacing: ProjectDetailLayout.recentFindGridSpacing) {
                ForEach(items) { item in
                    ProjectRecentFindCard(item: item, location: location) {
                        // TODO: Wire project recent find navigation.
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

private struct ProjectRecentFindCard: View {
    let item: ProjectDetailContent.RecentFind
    let location: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 0) {
                ProjectMediaImage(source: item.imageName, contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .frame(height: ProjectDetailLayout.recentFindImageHeight)
                    .clipped()

                VStack(alignment: .leading, spacing: GaiaSpacing.xs) {
                    Text(item.title)
                        .gaiaFont(.titleSans)
                        .foregroundStyle(GaiaColor.textPrimary)
                        .lineLimit(2)

                    Text("Recent find")
                        .gaiaFont(.caption2)
                        .foregroundStyle(GaiaColor.oliveGreen500)

                    HStack(spacing: GaiaSpacing.xs) {
                        GaiaIcon(kind: .pin, size: 16, tint: GaiaColor.oliveGreen500)
                            .frame(width: 16, height: 16)

                        Text(location)
                            .gaiaFont(.caption2)
                            .foregroundStyle(GaiaColor.inkBlack300)
                            .lineLimit(1)
                    }
                }
                .padding(.horizontal, GaiaSpacing.cardInset)
                .padding(.top, GaiaSpacing.sm)
                .padding(.bottom, GaiaSpacing.cardInset)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
            .frame(maxWidth: .infinity)
            .frame(height: ProjectDetailLayout.recentFindCardHeight)
            .clipShape(RoundedRectangle(cornerRadius: ProjectDetailLayout.thumbnailCornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: ProjectDetailLayout.thumbnailCornerRadius, style: .continuous)
                    .stroke(GaiaColor.border, lineWidth: ProjectDetailLayout.recentFindBorderWidth)
            )
            .shadow(
                color: GaiaShadow.smallColor,
                radius: ProjectDetailLayout.recentFindShadowRadius,
                x: 0,
                y: ProjectDetailLayout.recentFindShadowYOffset
            )
        }
        .buttonStyle(GaiaPressableCardStyle())
    }
}

private struct ProjectObserversSection: View {
    let content: ProjectDetailContent

    var body: some View {
        VStack(alignment: .leading, spacing: ProjectDetailLayout.sectionHeaderSpacing) {
            ProjectSectionHeader(title: "Observers", actionTitle: "See all")

            VStack(alignment: .leading, spacing: ProjectDetailLayout.observerRowSpacing) {
                HStack(spacing: -ProjectDetailLayout.observerAvatarOverlap) {
                    ForEach(content.observerImageNames, id: \.self) { imageName in
                        ProjectMediaImage(source: imageName, contentMode: .fill)
                            .frame(
                                width: ProjectDetailLayout.observerAvatarSize,
                                height: ProjectDetailLayout.observerAvatarSize
                            )
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(GaiaColor.paperWhite50, lineWidth: 2)
                            )
                    }

                    Text("+18")
                        .gaiaFont(.caption)
                        .foregroundStyle(GaiaColor.olive)
                        .frame(width: 40, height: 40)
                        .background(Circle().fill(GaiaColor.oliveGreen100))
                        .overlay(
                            Circle()
                                .stroke(GaiaColor.paperWhite50, lineWidth: 2)
                        )
                }

                VStack(alignment: .leading, spacing: ProjectDetailLayout.observerRowSpacing) {
                    Text(content.observersHeadline)
                        .gaiaFont(.titleSans)
                        .foregroundStyle(GaiaColor.oliveGreen500)

                    Text(content.observersSubtitle)
                        .gaiaFont(.footnote)
                        .foregroundStyle(GaiaColor.textSecondary)
                }
            }
            .padding(GaiaSpacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: ProjectDetailLayout.cardCornerRadius, style: .continuous)
                    .fill(GaiaColor.paperWhite50)
                    .overlay(
                        RoundedRectangle(cornerRadius: ProjectDetailLayout.cardCornerRadius, style: .continuous)
                            .stroke(GaiaColor.border, lineWidth: ProjectDetailLayout.recentFindBorderWidth)
                    )
            )
        }
    }
}

private struct ProjectUpdatesSection: View {
    let updates: [ProjectDetailContent.UpdateItem]

    var body: some View {
        VStack(alignment: .leading, spacing: GaiaSpacing.inset12) {
            ProjectSectionHeader(title: "Updates", actionTitle: "See all")

            ForEach(updates) { update in
                ProjectUpdateCard(update: update)
            }
        }
    }
}

private struct ProjectUpdateCard: View {
    let update: ProjectDetailContent.UpdateItem

    var body: some View {
        HStack(spacing: GaiaSpacing.md) {
            ProjectMediaImage(source: update.imageName, contentMode: .fill)
                .frame(width: ProjectDetailLayout.updateThumbSize, height: ProjectDetailLayout.updateThumbSize)
                .clipShape(RoundedRectangle(cornerRadius: ProjectDetailLayout.thumbnailCornerRadius, style: .continuous))

            VStack(alignment: .leading, spacing: GaiaSpacing.inset12) {
                VStack(alignment: .leading, spacing: GaiaSpacing.sm) {
                    Text(update.title)
                        .gaiaFont(.body)
                        .foregroundStyle(GaiaColor.textPrimary)
                        .lineLimit(1)

                    Text(update.subtitle)
                        .gaiaFont(.caption2)
                        .foregroundStyle(GaiaColor.inkBlack300)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Text(update.timeLabel)
                    .gaiaFont(.caption)
                    .foregroundStyle(GaiaColor.olive)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(GaiaSpacing.inset12)
        .frame(maxWidth: .infinity, minHeight: ProjectDetailLayout.updateCardHeight, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: ProjectDetailLayout.cardCornerRadius, style: .continuous)
                .fill(GaiaColor.paperWhite50)
                .overlay(
                    RoundedRectangle(cornerRadius: ProjectDetailLayout.cardCornerRadius, style: .continuous)
                        .stroke(GaiaColor.borderStrong, lineWidth: ProjectDetailLayout.recentFindBorderWidth)
                )
        )
    }
}

private struct ProjectLocationPinIcon: View {
    var body: some View {
        GaiaIcon(kind: .pin, size: 20, tint: GaiaColor.paperWhite50)
            .frame(width: 17, height: 20)
    }
}

private struct ProjectCroppedCircleImage: View {
    let source: String
    let size: CGFloat
    var scale: CGFloat = 1
    var offsetY: CGFloat = 0

    var body: some View {
        ZStack {
            ProjectMediaImage(source: source, contentMode: .fill)
                .frame(width: size, height: size)
                .scaleEffect(scale)
                .offset(y: offsetY)
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(
            Circle()
                .stroke(Color.black.opacity(0.1), lineWidth: 0.5)
        )
    }
}

private struct ProjectMediaImage: View {
    let source: String
    var contentMode: ContentMode = .fill

    var body: some View {
        if let url = URL(string: source), source.hasPrefix("http") {
            AsyncImage(url: url, transaction: .init(animation: .easeInOut(duration: 0.2))) { phase in
                switch phase {
                case let .success(image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: contentMode)
                default:
                    placeholder
                }
            }
        } else {
            GaiaAssetImage(name: source, contentMode: contentMode)
        }
    }

    private var placeholder: some View {
        LinearGradient(
            colors: [GaiaColor.oliveGreen100, GaiaColor.paperWhite50],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
