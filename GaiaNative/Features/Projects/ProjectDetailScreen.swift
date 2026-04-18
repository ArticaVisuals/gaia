import SwiftUI

private enum ProjectDetailLayout {
    static let screenWidth: CGFloat = 402
    static let pageInset = GaiaSpacing.md
    static let sectionSpacing = GaiaSpacing.xl
    static let sectionTopPadding = GaiaSpacing.lg
    static let actionStackSpacing = GaiaSpacing.lg
    static let actionRowSpacing = GaiaSpacing.sm
    static let heroHeight: CGFloat = 262
    static let heroTitleBottomInset: CGFloat = 15
    static let heroLocationSpacing = GaiaSpacing.xs
    static let heroOverlayStart: CGFloat = 0.34135
    static let toolbarHeight: CGFloat = 99
    static let toolbarTopPadding: CGFloat = GaiaSpacing.xl
    static let toolbarControlSpacing: CGFloat = 18
    static let primaryCardHeight: CGFloat = 128
    static let primaryCardDividerHeight: CGFloat = 80
    static let primaryMetricIconSize: CGFloat = 40
    static let primaryMetricRowHeight: CGFloat = 49
    static let primaryMetricValueWidth: CGFloat = 58
    static let primaryMetricValueHeight: CGFloat = 59
    static let recentCardSize: CGFloat = 180
    static let recentCardRadius: CGFloat = 12.203
    static let recentCardBorderWidth: CGFloat = 0.763
    static let recentCardTextWidth: CGFloat = 152.542
    static let recentCardTextLeading: CGFloat = 12.97
    static let recentCardTextBottom: CGFloat = 15.42
    static let recentCardShadowRadius: CGFloat = 30.508
    static let recentCardShadowYOffset: CGFloat = 6.102
    static let updateImageSize: CGFloat = 88.557
    static let observerAvatarSize = GaiaSpacing.iconXl
    static let observerAvatarOverlap = GaiaSpacing.md
    static let observerCardBorderWidth: CGFloat = 0.983
    static let footerBottomPadding = GaiaSpacing.xl
}

private enum ProjectImageFraming {
    case fill
    case custom(
        widthScale: CGFloat,
        heightScale: CGFloat,
        leftInsetFactor: CGFloat,
        topInsetFactor: CGFloat
    )
}

struct ProjectDetailScreen: View {
    let project: ProjectSelection?

    @EnvironmentObject private var appState: AppState

    private var content: ProjectDetailContent {
        .forProject(project)
    }

    var body: some View {
        GeometryReader { proxy in
            let contentWidth = min(proxy.size.width, ProjectDetailLayout.screenWidth)

            ZStack(alignment: .top) {
                GaiaColor.paperWhite50.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: ProjectDetailLayout.sectionSpacing) {
                        ProjectHeroSection(content: content)

                        ProjectActionsSection(content: content)
                            .padding(.horizontal, ProjectDetailLayout.pageInset)

                        ProjectRecentFindsSection(items: content.recentFinds)
                            .padding(.top, ProjectDetailLayout.sectionTopPadding)
                            .padding(.horizontal, ProjectDetailLayout.pageInset)

                        ProjectObserversSection(content: content)
                            .padding(.top, ProjectDetailLayout.sectionTopPadding)
                            .padding(.horizontal, ProjectDetailLayout.pageInset)

                        ProjectUpdatesSection(updates: content.updates)
                            .padding(.top, ProjectDetailLayout.sectionTopPadding)
                            .padding(.horizontal, ProjectDetailLayout.pageInset)
                    }
                    .frame(width: contentWidth, alignment: .leading)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, ProjectDetailLayout.footerBottomPadding)
                }

                ProjectDetailToolbar {
                    appState.closeProjectDetail()
                }
                .frame(width: contentWidth)
                .frame(maxWidth: .infinity)
            }
        }
        .statusBarHidden(true)
        .ignoresSafeArea(edges: .top)
    }
}

private struct ProjectDetailContent {
    struct Contributor: Identifiable {
        let id: String
        let imageName: String
        let framing: ProjectImageFraming
    }

    struct RecentFind: Identifiable {
        let id: String
        let title: String
        let imageName: String
        let framing: ProjectImageFraming
    }

    struct UpdateItem: Identifiable {
        let id: String
        let title: String
        let subtitle: String
        let timeLabel: String
        let imageName: String
        let framing: ProjectImageFraming
    }

    let id: String
    let title: String
    let location: String
    let heroImageName: String
    let heroFraming: ProjectImageFraming
    let founder: Contributor
    let contributors: [Contributor]
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
        let selected = selection ?? ProjectSelection(
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

    private static let founder = Contributor(
        id: "alice-edwards",
        imageName: "project-detail-founder-alice-edwards",
        framing: .custom(
            widthScale: 4.0841,
            heightScale: 7.2574,
            leftInsetFactor: -1.7655,
            topInsetFactor: -0.9164
        )
    )

    private static let contributors: [Contributor] = [
        .init(
            id: "contributor-1",
            imageName: "project-detail-contributor-1",
            framing: .custom(
                widthScale: 3.0565,
                heightScale: 2.0355,
                leftInsetFactor: -1.4116,
                topInsetFactor: -0.5516
            )
        ),
        .init(
            id: "contributor-2",
            imageName: "project-detail-contributor-2",
            framing: .custom(
                widthScale: 1.7725,
                heightScale: 2.6588,
                leftInsetFactor: -0.2873,
                topInsetFactor: -0.6140
            )
        ),
        .init(
            id: "contributor-3",
            imageName: "project-detail-contributor-3",
            framing: .custom(
                widthScale: 5.0969,
                heightScale: 7.6453,
                leftInsetFactor: -2.5367,
                topInsetFactor: -2.2577
            )
        ),
        .init(
            id: "contributor-4",
            imageName: "project-detail-contributor-4",
            framing: .custom(
                widthScale: 1.7369,
                heightScale: 2.5508,
                leftInsetFactor: -0.2548,
                topInsetFactor: -0.3747
            )
        ),
        .init(
            id: "contributor-5",
            imageName: "project-detail-contributor-5",
            framing: .custom(
                widthScale: 1.3706,
                heightScale: 1.8275,
                leftInsetFactor: -0.0651,
                topInsetFactor: -0.1799
            )
        ),
        .init(
            id: "contributor-6",
            imageName: "project-detail-contributor-6",
            framing: .custom(
                widthScale: 1.8441,
                heightScale: 2.7605,
                leftInsetFactor: -0.6926,
                topInsetFactor: -0.5130
            )
        )
    ]

    private static let recentFinds: [RecentFind] = [
        .init(
            id: "cacti",
            title: "Cacti",
            imageName: "project-detail-recent-cacti",
            framing: .fill
        ),
        .init(
            id: "indian-cormorant",
            title: "Indian\nCormorant",
            imageName: "project-detail-recent-indian-cormorant",
            framing: .custom(
                widthScale: 1,
                heightScale: 1.3333,
                leftInsetFactor: 0,
                topInsetFactor: -0.2948
            )
        ),
        .init(
            id: "european-roller",
            title: "European Roller",
            imageName: "project-detail-recent-european-roller",
            framing: .fill
        ),
        .init(
            id: "bindweed-tribe",
            title: "Bindweed Tribe",
            imageName: "project-detail-recent-bindweed-tribe",
            framing: .fill
        ),
        .init(
            id: "emperor-gum-moth",
            title: "Emperor Gum Moth",
            imageName: "project-detail-recent-emperor-gum-moth",
            framing: .fill
        ),
        .init(
            id: "garden-orbweaver",
            title: "Garden\nOrbweaver",
            imageName: "project-detail-recent-garden-orbweaver",
            framing: .fill
        )
    ]

    private static let updates: [UpdateItem] = [
        .init(
            id: "weekend-goals",
            title: "Weekend find goals are live",
            subtitle: "Project organizers are focusing on milkweed and monkeyflower this week.",
            timeLabel: "2 days ago",
            imageName: "project-detail-update-weekend-goals",
            framing: .custom(
                widthScale: 1.5,
                heightScale: 1,
                leftInsetFactor: -0.3694,
                topInsetFactor: 0
            )
        ),
        .init(
            id: "spring-checkin",
            title: "Spring bloom check-in posted",
            subtitle: "See how recent finds are shaping the season so far.",
            timeLabel: "5 days ago",
            imageName: "project-detail-update-spring-bloom",
            framing: .custom(
                widthScale: 1.5,
                heightScale: 1,
                leftInsetFactor: -0.3694,
                topInsetFactor: 0
            )
        )
    ]

    private static let pollinator = ProjectDetailContent(
        id: "project-pollinator",
        title: "Pollinator Corridor",
        location: "Arroyo Seco",
        heroImageName: "project-detail-hero-pollinator",
        heroFraming: .fill,
        founder: founder,
        contributors: contributors,
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
        heroFraming: .fill,
        founder: founder,
        contributors: contributors,
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

private struct ProjectDetailToolbar: View {
    let onBack: () -> Void

    var body: some View {
        toolbarBody
            .frame(height: ProjectDetailLayout.toolbarHeight, alignment: .top)
            .padding(.horizontal, ProjectDetailLayout.pageInset)
            .padding(.top, ProjectDetailLayout.toolbarTopPadding)
    }

    @ViewBuilder
    private var toolbarBody: some View {
        toolbarContent
    }

    private var toolbarContent: some View {
        HStack {
            ToolbarGlassButton(
                icon: .back,
                accessibilityLabel: "Back",
                action: onBack
            )

            Spacer(minLength: 0)

            ToolbarGlassPill(primaryAction: {}, secondaryAction: {})
        }
    }
}

private struct ProjectHeroSection: View {
    let content: ProjectDetailContent

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            ProjectMediaImage(source: content.heroImageName, framing: content.heroFraming)
                .frame(maxWidth: .infinity)
                .frame(height: ProjectDetailLayout.heroHeight)

            LinearGradient(
                stops: [
                    .init(color: .clear, location: ProjectDetailLayout.heroOverlayStart),
                    .init(color: .black.opacity(0.65), location: 1)
                ],
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

                HStack(spacing: ProjectDetailLayout.heroLocationSpacing) {
                    ProjectLocationPinIcon()
                    Text(content.location)
                        .gaiaFont(.subheadline)
                        .foregroundStyle(GaiaColor.paperWhite50)
                        .lineLimit(1)
                }
            }
            .padding(.leading, GaiaSpacing.detailInset)
            .padding(.bottom, ProjectDetailLayout.heroTitleBottomInset)
        }
        .clipShape(
            UnevenRoundedRectangle(
                cornerRadii: .init(
                    topLeading: 0,
                    bottomLeading: GaiaRadius.lg,
                    bottomTrailing: GaiaRadius.lg,
                    topTrailing: 0
                ),
                style: .continuous
            )
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(content.title), \(content.location)")
    }
}

private struct ProjectActionsSection: View {
    let content: ProjectDetailContent

    @EnvironmentObject private var appState: AppState

    var body: some View {
        VStack(spacing: ProjectDetailLayout.actionStackSpacing) {
            HStack(spacing: ProjectDetailLayout.actionRowSpacing) {
                ProjectActionButton(
                    title: "Contribute",
                    style: .filled,
                    action: {
                        appState.closeProjectDetail()
                        appState.select(section: .observe)
                    }
                )

                ProjectActionButton(title: "Joined", style: .outlined, action: {})
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
                .gaiaFont(.titleSans)
                .foregroundStyle(textColor)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(backgroundView)
                .clipShape(Capsule(style: .continuous))
                .contentShape(Capsule(style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var textColor: Color {
        switch style {
        case .filled:
            return GaiaColor.paperWhite50
        case .outlined:
            return GaiaColor.oliveGreen400
        }
    }

    @ViewBuilder
    private var backgroundView: some View {
        switch style {
        case .filled:
            Capsule(style: .continuous)
                .fill(GaiaColor.oliveGreen400)
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(GaiaColor.oliveGreen200, lineWidth: 1)
                )
        case .outlined:
            Capsule(style: .continuous)
                .fill(Color.clear)
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(GaiaColor.oliveGreen400, lineWidth: 1)
                )
        }
    }
}

private struct ProjectStatsCard: View {
    let content: ProjectDetailContent

    var body: some View {
        HStack(spacing: 0) {
            ProjectStatsFounderColumn(
                label: content.founderLabel,
                founder: content.founder
            )

            divider

            ProjectStatsMetricColumn(
                label: content.observersLabel,
                icon: .profile(selected: false),
                value: content.observersCount,
                overlap: 11
            )

            divider

            ProjectStatsMetricColumn(
                label: content.findsLabel,
                icon: .observe(selected: false),
                value: content.findsCount,
                overlap: 6
            )
        }
        .padding(.horizontal, GaiaSpacing.cardContentInsetWide)
        .padding(.vertical, GaiaSpacing.lg)
        .frame(maxWidth: .infinity)
        .frame(height: ProjectDetailLayout.primaryCardHeight)
        .background(
            RoundedRectangle(cornerRadius: GaiaRadius.lg, style: .continuous)
                .fill(GaiaColor.paperWhite50)
                .overlay(
                    RoundedRectangle(cornerRadius: GaiaRadius.lg, style: .continuous)
                        .stroke(GaiaColor.border, lineWidth: 1)
                )
        )
    }

    private var divider: some View {
        Rectangle()
            .fill(GaiaColor.border)
            .frame(width: 1, height: ProjectDetailLayout.primaryCardDividerHeight)
            .frame(maxHeight: .infinity)
    }
}

private struct ProjectStatsFounderColumn: View {
    let label: String
    let founder: ProjectDetailContent.Contributor

    var body: some View {
        VStack(spacing: GaiaSpacing.inset12) {
            Text(label)
                .gaiaFont(.caption2)
                .foregroundStyle(GaiaColor.oliveGreen300)

            ProjectMediaImage(source: founder.imageName, framing: founder.framing)
                .frame(width: 48, height: 48)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.black.opacity(0.1), lineWidth: 0.5)
                )
        }
        .frame(maxWidth: .infinity)
    }
}

private struct ProjectStatsMetricColumn: View {
    let label: String
    let icon: GaiaIconKind
    let value: String
    let overlap: CGFloat

    var body: some View {
        VStack(spacing: GaiaSpacing.inset12) {
            Text(label)
                .gaiaFont(.caption2)
                .foregroundStyle(GaiaColor.oliveGreen300)

            HStack(spacing: -overlap) {
                GaiaIcon(
                    kind: icon,
                    size: ProjectDetailLayout.primaryMetricIconSize,
                    tint: GaiaColor.oliveGreen400
                )
                .frame(
                    width: ProjectDetailLayout.primaryMetricIconSize,
                    height: ProjectDetailLayout.primaryMetricIconSize
                )

                Text(value)
                    .gaiaFont(.displayMedium)
                    .foregroundStyle(GaiaColor.oliveGreen400)
                    .frame(
                        width: ProjectDetailLayout.primaryMetricValueWidth,
                        height: ProjectDetailLayout.primaryMetricValueHeight,
                        alignment: .center
                    )
                    .multilineTextAlignment(.center)
            }
            .frame(
                width: ProjectDetailLayout.primaryMetricIconSize + ProjectDetailLayout.primaryMetricValueWidth - overlap,
                height: ProjectDetailLayout.primaryMetricRowHeight
            )
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
                .frame(width: 305, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)

            Button(action: {}) {
                Text(content.readMoreLabel)
                    .gaiaFont(.subheadline)
                    .foregroundStyle(GaiaColor.oliveGreen500)
                    .padding(.horizontal, GaiaSpacing.buttonHorizontalLarge)
                    .frame(height: 34)
                    .background(
                        Capsule(style: .continuous)
                            .fill(GaiaColor.paperWhite50)
                            .overlay(
                                Capsule(style: .continuous)
                                    .stroke(GaiaColor.oliveGreen200, lineWidth: 1)
                            )
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, GaiaSpacing.cardContentInsetWide)
        .padding(.vertical, GaiaSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(minHeight: ProjectDetailLayout.primaryCardHeight, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: GaiaRadius.lg, style: .continuous)
                .fill(GaiaColor.oliveGreen300)
                .overlay(
                    RoundedRectangle(cornerRadius: GaiaRadius.lg, style: .continuous)
                        .stroke(Color.black.opacity(0.1), lineWidth: 0.5)
                )
        )
    }
}

private struct ProjectSectionHeader: View {
    let title: String

    var body: some View {
        Text(title)
            .gaiaFont(.titleSans)
            .foregroundStyle(GaiaColor.inkBlack300)
    }
}

private struct ProjectSectionFooterButton: View {
    let title: String

    var body: some View {
        Button(action: {}) {
            Text(title)
                .gaiaFont(.caption2)
                .foregroundStyle(GaiaColor.textSecondary)
        }
        .buttonStyle(.plain)
    }
}

private struct ProjectRecentFindsSection: View {
    let items: [ProjectDetailContent.RecentFind]

    private let columns: [GridItem] = [
        GridItem(.fixed(ProjectDetailLayout.recentCardSize), spacing: GaiaSpacing.sm),
        GridItem(.fixed(ProjectDetailLayout.recentCardSize), spacing: GaiaSpacing.sm)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: GaiaSpacing.md) {
            ProjectSectionHeader(title: "Recent Finds")

            LazyVGrid(columns: columns, alignment: .leading, spacing: GaiaSpacing.sm) {
                ForEach(items) { item in
                    ProjectRecentFindCard(item: item)
                }
            }

            HStack {
                Spacer(minLength: 0)
                ProjectSectionFooterButton(title: "View all")
            }
        }
    }
}

private struct ProjectRecentFindCard: View {
    let item: ProjectDetailContent.RecentFind

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            ProjectMediaImage(source: item.imageName, framing: item.framing)
                .frame(width: ProjectDetailLayout.recentCardSize, height: ProjectDetailLayout.recentCardSize)

            LinearGradient(
                stops: [
                    .init(color: .clear, location: 0.53889),
                    .init(color: .black.opacity(0.4), location: 1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            Text(item.title)
                .gaiaFont(.titleSans)
                .foregroundStyle(GaiaColor.paperWhite50)
                .frame(width: ProjectDetailLayout.recentCardTextWidth, alignment: .leading)
                .padding(.leading, ProjectDetailLayout.recentCardTextLeading)
                .padding(.bottom, ProjectDetailLayout.recentCardTextBottom)
                .shadow(
                    color: GaiaColor.broccoliBrown500.opacity(0.24),
                    radius: 61.017,
                    x: 0,
                    y: 12.203
                )
        }
        .frame(width: ProjectDetailLayout.recentCardSize, height: ProjectDetailLayout.recentCardSize)
        .clipShape(RoundedRectangle(cornerRadius: ProjectDetailLayout.recentCardRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: ProjectDetailLayout.recentCardRadius, style: .continuous)
                .stroke(GaiaColor.blackishGrey200, lineWidth: ProjectDetailLayout.recentCardBorderWidth)
        )
        .shadow(
            color: GaiaShadow.smallColor,
            radius: ProjectDetailLayout.recentCardShadowRadius,
            x: 0,
            y: ProjectDetailLayout.recentCardShadowYOffset
        )
    }
}

private struct ProjectObserversSection: View {
    let content: ProjectDetailContent

    var body: some View {
        VStack(alignment: .leading, spacing: GaiaSpacing.md) {
            ProjectSectionHeader(title: "Observers")

            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: -ProjectDetailLayout.observerAvatarOverlap) {
                    ForEach(content.contributors) { contributor in
                        ProjectMediaImage(source: contributor.imageName, framing: contributor.framing)
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
                        .foregroundStyle(GaiaColor.oliveGreen500)
                        .frame(width: 40, height: 40)
                        .background(
                            Circle()
                                .fill(GaiaColor.oliveGreen100)
                        )
                        .overlay(
                            Circle()
                                .stroke(GaiaColor.paperWhite50, lineWidth: 2)
                        )
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text(content.observersHeadline)
                        .gaiaFont(.titleSans)
                        .foregroundStyle(GaiaColor.oliveGreen500)

                    Text(content.observersSubtitle)
                        .gaiaFont(.footnote)
                        .foregroundStyle(GaiaColor.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(GaiaSpacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: GaiaRadius.lg, style: .continuous)
                    .fill(GaiaColor.paperWhite50)
                    .overlay(
                        RoundedRectangle(cornerRadius: GaiaRadius.lg, style: .continuous)
                            .stroke(GaiaColor.border, lineWidth: ProjectDetailLayout.observerCardBorderWidth)
                    )
            )

            HStack {
                Spacer(minLength: 0)
                ProjectSectionFooterButton(title: "View all")
            }
        }
    }
}

private struct ProjectUpdatesSection: View {
    let updates: [ProjectDetailContent.UpdateItem]

    var body: some View {
        VStack(alignment: .leading, spacing: GaiaSpacing.inset12) {
            ProjectSectionHeader(title: "Updates")

            ForEach(updates) { update in
                ProjectUpdateCard(update: update)
            }

            HStack {
                Spacer(minLength: 0)
                ProjectSectionFooterButton(title: "View all")
            }
        }
    }
}

private struct ProjectUpdateCard: View {
    let update: ProjectDetailContent.UpdateItem

    var body: some View {
        HStack(spacing: GaiaSpacing.md) {
            ProjectMediaImage(source: update.imageName, framing: update.framing)
                .frame(width: ProjectDetailLayout.updateImageSize, height: ProjectDetailLayout.updateImageSize)
                .clipShape(RoundedRectangle(cornerRadius: GaiaRadius.thumbnail, style: .continuous))

            VStack(alignment: .leading, spacing: GaiaSpacing.inset12) {
                VStack(alignment: .leading, spacing: GaiaSpacing.sm) {
                    Text(update.title)
                        .gaiaFont(.body)
                        .foregroundStyle(GaiaColor.textPrimary)
                        .frame(width: 210, alignment: .leading)
                        .lineLimit(1)

                    Text(update.subtitle)
                        .gaiaFont(.caption2)
                        .foregroundStyle(GaiaColor.inkBlack300)
                        .frame(width: 217, alignment: .leading)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Text(update.timeLabel)
                    .gaiaFont(.caption)
                    .foregroundStyle(GaiaColor.oliveGreen500)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(GaiaSpacing.inset12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: GaiaRadius.lg, style: .continuous)
                .fill(GaiaColor.paperWhite50)
                .overlay(
                    RoundedRectangle(cornerRadius: GaiaRadius.lg, style: .continuous)
                        .stroke(GaiaColor.borderStrong, lineWidth: 1)
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

private struct ProjectMediaImage: View {
    let source: String
    var framing: ProjectImageFraming = .fill

    var body: some View {
        GeometryReader { proxy in
            if let url = URL(string: source), source.hasPrefix("http") {
                AsyncImage(url: url, transaction: .init(animation: .easeInOut(duration: 0.2))) { phase in
                    switch phase {
                    case let .success(image):
                        framed(image.resizable(), in: proxy.size)
                    default:
                        placeholder
                    }
                }
            } else {
                framed(
                    GaiaAssetImage(name: source, contentMode: .fill),
                    in: proxy.size
                )
            }
        }
        .clipped()
    }

    @ViewBuilder
    private func framed<Content: View>(_ content: Content, in size: CGSize) -> some View {
        switch framing {
        case .fill:
            content
                .frame(width: size.width, height: size.height)
        case let .custom(widthScale, heightScale, leftInsetFactor, topInsetFactor):
            let imageWidth = size.width * widthScale
            let imageHeight = size.height * heightScale

            ZStack(alignment: .topLeading) {
                content
                    .frame(width: imageWidth, height: imageHeight)
                    .offset(
                        x: leftInsetFactor * size.width,
                        y: topInsetFactor * size.height
                    )
            }
            .frame(width: size.width, height: size.height, alignment: .topLeading)
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
