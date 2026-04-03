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
            let topInset = proxy.safeAreaInsets.top > 0 ? proxy.safeAreaInsets.top : windowSafeTopInset
            // Keep the hero under the glass toolbar while matching the Figma vertical rhythm.
            let heroLift = max(topInset - GaiaSpacing.md, 0)

            ZStack(alignment: .top) {
                GaiaColor.surfacePrimary.ignoresSafeArea()

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
        founderImageName: "project-detail-profile-stack",
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
        founderImageName: "project-detail-profile-stack",
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
                    .font(GaiaTypography.displayMedium)
                    .foregroundStyle(GaiaColor.paperWhite50)
                    .tracking(-0.5)
                    .lineLimit(2)

                HStack(spacing: 0) {
                    ProjectLocationPinIcon()
                    Text(content.location)
                        .font(GaiaTypography.subheadline)
                        .foregroundStyle(GaiaColor.paperWhite50)
                        .lineLimit(1)
                }
            }
            .padding(.leading, 15)
            .padding(.bottom, 10)
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
            color: Color(red: 115 / 255, green: 115 / 255, blue: 100 / 255).opacity(0.5),
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

private struct ProjectActionButton: View {
    let title: String
    let style: ProjectActionButtonStyle
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(GaiaTypography.body)
                .foregroundStyle(style == .filled ? GaiaColor.paperWhite50 : GaiaColor.olive)
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
        .padding(.horizontal, GaiaSpacing.lg - 4)
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
                .font(GaiaTypography.caption2)
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
            .frame(width: 1, height: 69)
    }

    private func metricColumn(
        label: String,
        icon: GaiaIconKind,
        value: String,
        iconTextOverlap: CGFloat
    ) -> some View {
        VStack(spacing: GaiaSpacing.md) {
            Text(label)
                .font(GaiaTypography.caption2)
                .foregroundStyle(GaiaColor.olive)

            HStack(spacing: -iconTextOverlap) {
                GaiaIcon(kind: icon, size: 40, tint: GaiaColor.olive)
                    .frame(width: 40, height: 40)

                Text(value)
                    .font(.custom("NewSpirit-Medium", size: 30.471))
                    .foregroundStyle(GaiaColor.olive)
                    .tracking(-0.272)
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
                .font(GaiaTypography.subheadline)
                .foregroundStyle(GaiaColor.textInverseSecondary)
                .lineSpacing(0)
                .frame(maxWidth: 305, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)

            Button(action: {}) {
                Text(content.readMoreLabel)
                    .font(GaiaTypography.subheadline)
                    .foregroundStyle(GaiaColor.olive)
                    .padding(.horizontal, 14)
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
                .font(GaiaTypography.titleRegular)
                .foregroundStyle(GaiaColor.inkBlack300)

            Spacer(minLength: 0)

            Button(action: {}) {
                Text(actionTitle)
                    .font(GaiaTypography.subheadline)
                    .foregroundStyle(GaiaColor.olive)
            }
            .buttonStyle(.plain)
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
                ProjectMediaImage(source: item.imageName, contentMode: .fill)
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .clipped()
                    .blur(radius: 2.3)

                LinearGradient(
                    colors: [Color.clear, Color.black.opacity(0.56)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(width: proxy.size.width, height: proxy.size.height)

                Text(item.title)
                    .font(GaiaTypography.bodySerif)
                    .foregroundStyle(GaiaColor.paperWhite50)
                    .lineSpacing(0)
                    .lineLimit(2)
                    .frame(width: max(proxy.size.width - 16, 0), alignment: .leading)
                    .padding(.leading, GaiaSpacing.sm)
                    .padding(.bottom, 8)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                .stroke(GaiaColor.border, lineWidth: 1)
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
                        .font(GaiaTypography.caption)
                        .foregroundStyle(GaiaColor.olive)
                        .tracking(0.25)
                        .frame(width: 40, height: 40)
                        .background(Circle().fill(GaiaColor.oliveGreen100))
                        .overlay(
                            Circle()
                                .stroke(GaiaColor.paperWhite50, lineWidth: 2)
                        )
                }

                VStack(alignment: .leading, spacing: 1) {
                    Text(content.observersHeadline)
                        .font(GaiaTypography.subheadSerif)
                        .foregroundStyle(GaiaColor.olive)

                    Text(content.observersSubtitle)
                        .font(GaiaTypography.footnote)
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

            VStack(alignment: .leading, spacing: GaiaSpacing.md) {
                VStack(alignment: .leading, spacing: GaiaSpacing.sm) {
                    Text(update.title)
                        .font(GaiaTypography.subheadSerif)
                        .foregroundStyle(GaiaColor.textPrimary)
                        .lineLimit(1)

                    Text(update.subtitle)
                        .font(GaiaTypography.caption2)
                        .foregroundStyle(GaiaColor.inkBlack300)
                        .lineLimit(2)
                }

                Text(update.timeLabel)
                    .font(GaiaTypography.caption)
                    .foregroundStyle(GaiaColor.olive)
                    .tracking(0.25)
                    .lineLimit(1)
            }

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
