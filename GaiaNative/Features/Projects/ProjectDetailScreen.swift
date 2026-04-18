import SwiftUI
import UIKit

struct ProjectDetailScreen: View {
    let project: ProjectSelection?

    @EnvironmentObject private var appState: AppState

    private var content: ProjectDetailContent {
        .forProject(project)
    }

    var body: some View {
        GeometryReader { proxy in
            let safeAreaWidth = max(0, proxy.size.width - proxy.safeAreaInsets.leading - proxy.safeAreaInsets.trailing)
            let contentWidth = min(safeAreaWidth, UIScreen.main.bounds.width)
            let topInset = proxy.safeAreaInsets.top > 0 ? proxy.safeAreaInsets.top : windowSafeTopInset
            // Keep the hero under the glass toolbar while avoiding an overly tight top crop.
            let heroLift = max(topInset - GaiaSpacing.lg, 0)

            ZStack(alignment: .top) {
                GaiaColor.surfaceSheet.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: GaiaSpacing.xl) {
                        ProjectHeroSection(content: content)
                            .padding(.top, -heroLift)
                            .frame(maxWidth: .infinity)

                        VStack(alignment: .leading, spacing: GaiaSpacing.xl) {
                            ProjectActionsSection(content: content)
                            ProjectRecentFindsSection(items: content.recentFinds)
                            ProjectObserversSection(content: content)
                            ProjectUpdatesSection(updates: content.updates)
                        }
                        .padding(.horizontal, GaiaSpacing.md)
                    }
                    .padding(.bottom, GaiaSpacing.xxxl)
                    .frame(width: contentWidth, alignment: .leading)
                    .padding(.leading, proxy.safeAreaInsets.leading)
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
                .frame(width: contentWidth, alignment: .top)
                .frame(maxHeight: .infinity, alignment: .top)
                .padding(.leading, proxy.safeAreaInsets.leading)
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
        .init(id: "indian-cormorant", title: "Indian\nCormorant", imageName: "project-detail-recent-indian-cormorant"),
        .init(id: "european-roller", title: "European\nRoller", imageName: "project-detail-recent-european-roller"),
        .init(id: "bindweed-tribe", title: "Bindweed\nTribe", imageName: "project-detail-recent-bindweed-tribe"),
        .init(id: "emperor-gum-moth", title: "Emperor Gum\nMoth", imageName: "project-detail-recent-emperor-gum-moth"),
        .init(id: "garden-orbweaver", title: "Garden\nOrbweaver", imageName: "project-detail-recent-garden-orbweaver")
    ]

    private static let updates: [UpdateItem] = [
        .init(
            id: "weekend-goals",
            title: "Weekend find goals are live",
            subtitle: "Project organizers are focusing on milkweed and monkeyflower this week.",
            timeLabel: "2 days ago",
            imageName: "project-detail-update-highlight"
        ),
        .init(
            id: "spring-checkin",
            title: "Spring bloom check-in posted",
            subtitle: "See how recent finds are shaping the season so far.",
            timeLabel: "5 days ago",
            imageName: "project-detail-update-highlight"
        )
    ]

    private static let pollinator = ProjectDetailContent(
        id: "project-pollinator",
        title: "Pollinator Corridor",
        location: "Arroyo Seco",
        heroImageName: "project-detail-hero-pollinator",
        founderImageName: "find-avatar-alice",
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
        founderImageName: "find-avatar-alice",
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
                .frame(height: 262)
                .clipped()

            ProjectMediaImage(source: content.heroImageName, contentMode: .fill)
                .frame(maxWidth: .infinity)
                .frame(height: 262)
                .blur(radius: 11.55)
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
                colors: [Color.clear, Color.black.opacity(0.25)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(maxWidth: .infinity)
            .frame(height: 262)

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
            .padding(.bottom, GaiaSpacing.pillHorizontal)
        }
        .clipShape(
            UnevenRoundedRectangle(
                cornerRadii: .init(
                    topLeading: 0,
                    bottomLeading: GaiaRadius.md,
                    bottomTrailing: GaiaRadius.md,
                    topTrailing: 0
                ),
                style: .continuous
            )
        )
        .shadow(
            color: GaiaShadow.projectHeroColor,
            radius: GaiaShadow.projectHeroRadius,
            x: 0,
            y: GaiaShadow.projectHeroYOffset
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(content.title), \(content.location)")
    }
}

private struct ProjectActionsSection: View {
    let content: ProjectDetailContent

    var body: some View {
        VStack(spacing: GaiaSpacing.lg) {
            HStack(spacing: GaiaSpacing.sm) {
                ProjectActionButton(title: "Add Find", style: .filled, action: {})
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

private enum ProjectDetailLayout {
    static let cardHorizontalInset = GaiaSpacing.lg - GaiaSpacing.xs
    static let statsValueWidth: CGFloat = 58
    static let descriptionTextWidth: CGFloat = 305
    static let updateTitleWidth: CGFloat = 210
    static let updateTextWidth: CGFloat = 217
    static let statsDividerHorizontalInset: CGFloat = 7.5
    static let statsIconSize: CGFloat = 32
    static let statsIconSlotSize: CGFloat = 40
    static let statsValueSpacing: CGFloat = 2
    static let statsDividerHeight: CGFloat = 46
}

private struct ProjectResponsiveButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .brightness(configuration.isPressed ? -0.01 : 0)
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
            .animation(.interactiveSpring(response: 0.22, dampingFraction: 0.82), value: configuration.isPressed)
    }
}

private struct ProjectActionButton: View {
    let title: String
    let style: ProjectActionButtonStyle
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .gaiaFont(.bodyMedium)
                .foregroundStyle(style == .filled ? GaiaColor.paperWhite50 : GaiaColor.olive)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(backgroundView)
                .clipShape(Capsule(style: .continuous))
                .contentShape(Capsule(style: .continuous))
        }
        .buttonStyle(ProjectResponsiveButtonStyle())
    }

    @ViewBuilder
    private var backgroundView: some View {
        switch style {
        case .filled:
            Capsule(style: .continuous)
                .fill(GaiaColor.olive)
        case .outlined:
            Capsule(style: .continuous)
                .stroke(GaiaColor.olive, lineWidth: 1)
                .background(
                    Capsule(style: .continuous)
                        .fill(Color.clear)
                )
        }
    }
}

private struct ProjectStatsCard: View {
    let content: ProjectDetailContent

    var body: some View {
        HStack(spacing: 0) {
            founderColumn
                .frame(maxWidth: .infinity)

            divider

            metricColumn(
                label: content.observersLabel,
                icon: .profile(selected: false),
                value: content.observersCount
            )
            .frame(maxWidth: .infinity)

            divider

            metricColumn(
                label: content.findsLabel,
                icon: .observe(selected: false),
                value: content.findsCount
            )
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, ProjectDetailLayout.cardHorizontalInset)
        .padding(.vertical, GaiaSpacing.lg)
        .frame(height: 118)
        .background(
            RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                .fill(GaiaColor.paperWhite50)
                .overlay(
                    RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                        .stroke(GaiaColor.border, lineWidth: 1)
                )
        )
        .shadow(color: GaiaShadow.mdColor, radius: GaiaShadow.mdRadius, x: 0, y: GaiaShadow.mdYOffset)
    }

    private var founderColumn: some View {
        VStack(spacing: GaiaSpacing.md) {
            Text(content.founderLabel)
                .gaiaFont(.caption2Medium)
                .foregroundStyle(GaiaColor.olive)

            ProjectMediaImage(source: content.founderImageName, contentMode: .fill)
                .frame(width: 48, height: 48)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.black.opacity(0.1), lineWidth: 0.5)
                )
        }
        .frame(maxWidth: .infinity)
    }

    private var divider: some View {
        Rectangle()
            .fill(GaiaColor.border)
            .frame(width: 1, height: ProjectDetailLayout.statsDividerHeight)
            .padding(.horizontal, ProjectDetailLayout.statsDividerHorizontalInset)
    }

    private func metricColumn(
        label: String,
        icon: GaiaIconKind,
        value: String
    ) -> some View {
        VStack(spacing: GaiaSpacing.md) {
            Text(label)
                .gaiaFont(.caption2Medium)
                .foregroundStyle(GaiaColor.olive)

            HStack(spacing: ProjectDetailLayout.statsValueSpacing) {
                GaiaIcon(kind: icon, size: ProjectDetailLayout.statsIconSize, tint: GaiaColor.olive)
                    .frame(width: ProjectDetailLayout.statsIconSlotSize, height: ProjectDetailLayout.statsIconSlotSize)

                Text(value)
                    .gaiaFont(.statValue)
                    .foregroundStyle(GaiaColor.olive)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .fixedSize(horizontal: true, vertical: false)
                    .frame(minWidth: ProjectDetailLayout.statsValueWidth, alignment: .leading)
                    .frame(height: 59, alignment: .leading)
            }
            .frame(height: 49)
        }
    }
}

private struct ProjectDescriptionCard: View {
    let content: ProjectDetailContent

    var body: some View {
        VStack(alignment: .leading, spacing: GaiaSpacing.md) {
            Text(content.description)
                .gaiaFont(.subheadline)
                .foregroundStyle(GaiaColor.textInverseSecondary)
                .frame(maxWidth: ProjectDetailLayout.descriptionTextWidth, alignment: .leading)
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
            .buttonStyle(ProjectResponsiveButtonStyle())
        }
        .padding(.horizontal, ProjectDetailLayout.cardHorizontalInset)
        .padding(.vertical, GaiaSpacing.lg)
        .frame(maxWidth: .infinity, minHeight: 128, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                .fill(GaiaColor.olive)
                .overlay(
                    RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
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
                .gaiaFont(.title3)
                .foregroundStyle(GaiaColor.inkBlack300)

            Spacer(minLength: 0)

            Button(action: {}) {
                Text(actionTitle)
                    .gaiaFont(.subheadline)
                    .foregroundStyle(GaiaColor.olive)
            }
            .buttonStyle(ProjectResponsiveButtonStyle())
        }
    }
}

private struct ProjectRecentFindsSection: View {
    let items: [ProjectDetailContent.RecentFind]

    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: GaiaSpacing.sm),
        GridItem(.flexible(), spacing: GaiaSpacing.sm),
        GridItem(.flexible(), spacing: GaiaSpacing.sm)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: GaiaSpacing.md) {
            ProjectSectionHeader(title: "Recent Finds", actionTitle: "See all")

            LazyVGrid(columns: columns, alignment: .leading, spacing: GaiaSpacing.sm) {
                ForEach(items) { item in
                    ProjectRecentFindCard(item: item)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

private struct ProjectRecentFindCard: View {
    let item: ProjectDetailContent.RecentFind

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .bottomLeading) {
                GaiaFindCardArtwork {
                    ProjectMediaImage(source: item.imageName, contentMode: .fill)
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .clipped()
                }

                Text(item.title)
                    .gaiaFont(.callout)
                    .foregroundStyle(GaiaColor.paperWhite50)
                    .lineLimit(2)
                    .frame(width: max(proxy.size.width - 16, 0), alignment: .leading)
                    .padding(.leading, GaiaSpacing.sm)
                    .padding(.bottom, GaiaSpacing.sm)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                .stroke(GaiaColor.blackishGrey200, lineWidth: 0.5)
        )
        .shadow(color: GaiaShadow.smallColor, radius: GaiaShadow.smallRadius, x: 0, y: GaiaShadow.smallYOffset)
    }
}

private struct ProjectObserversSection: View {
    let content: ProjectDetailContent

    var body: some View {
        VStack(alignment: .leading, spacing: GaiaSpacing.md) {
            ProjectSectionHeader(title: "Observers", actionTitle: "See all")

            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: -16) {
                    ForEach(0..<6, id: \.self) { _ in
                        ProjectMediaImage(source: content.founderImageName, contentMode: .fill)
                            .frame(width: 40, height: 40)
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
                .padding(.trailing, GaiaSpacing.md)

                VStack(alignment: .leading, spacing: 10) {
                    Text(content.observersHeadline)
                        .gaiaFont(.subheadSerif)
                        .foregroundStyle(GaiaColor.olive)

                    Text(content.observersSubtitle)
                        .gaiaFont(.footnote)
                        .foregroundStyle(GaiaColor.textSecondary)
                }
            }
            .padding(GaiaSpacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                    .fill(GaiaColor.paperWhite50)
                    .overlay(
                        RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                            .stroke(GaiaColor.border, lineWidth: 1)
                    )
            )
        }
    }
}

private struct ProjectUpdatesSection: View {
    let updates: [ProjectDetailContent.UpdateItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
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
                .frame(width: 104, height: 84)
                .clipShape(RoundedRectangle(cornerRadius: GaiaRadius.sm, style: .continuous))

            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: GaiaSpacing.sm) {
                    Text(update.title)
                        .gaiaFont(.subheadSerif)
                        .foregroundStyle(GaiaColor.textPrimary)
                        .lineLimit(1)
                        .frame(maxWidth: ProjectDetailLayout.updateTitleWidth, alignment: .leading)

                    Text(update.subtitle)
                        .gaiaFont(.caption2)
                        .foregroundStyle(GaiaColor.inkBlack300)
                        .lineLimit(2)
                        .frame(maxWidth: ProjectDetailLayout.updateTextWidth, alignment: .leading)
                }

                Text(update.timeLabel)
                    .gaiaFont(.caption)
                    .foregroundStyle(GaiaColor.olive)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, GaiaSpacing.sm + 4)
        .padding(.vertical, GaiaSpacing.sm + 4)
        .frame(maxWidth: .infinity, minHeight: 108, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                .fill(GaiaColor.paperWhite50)
                .overlay(
                    RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                        .stroke(GaiaColor.border, lineWidth: 1)
                )
        )
        .shadow(color: GaiaShadow.mdColor, radius: GaiaShadow.mdRadius, x: 0, y: GaiaShadow.mdYOffset)
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
