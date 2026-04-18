// figma: https://www.figma.com/design/4e4G3tnSR7AdPbf0jAYPP1/Gaia?node-id=1609-176893 (Profile Community), 1711-180387 (People Screen), 1711-180594 (Community Profile Detail)
import SwiftUI

private enum ProfilePeopleGroup: String, CaseIterable, Identifiable {
    case mutuals
    case following
    case suggested

    var id: String { rawValue }

    var title: String {
        switch self {
        case .mutuals:
            return "Mutuals"
        case .following:
            return "Following"
        case .suggested:
            return "Suggested"
        }
    }

    var baselineCount: Int {
        switch self {
        case .mutuals:
            return 6
        case .following:
            return 12
        case .suggested:
            return 5
        }
    }
}

private struct ProfileCommunityPerson: Identifiable {
    let id: String
    let name: String
    let subtitle: String
    let avatarImageName: String
    var group: ProfilePeopleGroup
    var followState: FollowState

    enum FollowState {
        case mutual
        case following
        case follow
    }

    var searchableText: String {
        "\(name) \(subtitle)".lowercased()
    }
}

private struct ProfileCommunityProject: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let location: String
    let imageName: String
    let selection: ProjectSelection
}

struct ProfileCommunityTab: View {
    let posts: [CommunityPost]

    init(posts: [CommunityPost] = []) {
        self.posts = posts
    }

    @EnvironmentObject private var appState: AppState
    @State private var showsPeopleScreen = false
    @State private var showsMayaProfile = false

    private let projects: [ProfileCommunityProject] = [
        .init(
            id: "project-creek",
            title: "Creek Recovery",
            subtitle: "2 days to go",
            location: "Pasadena, CA",
            imageName: "find-project-creek",
            selection: .init(
                id: "project-creek",
                title: "Creek Recovery",
                tag: "Wetland",
                countLabel: "12",
                imageName: "find-project-creek"
            )
        ),
        .init(
            id: "project-pollinator",
            title: "Pollinator Corridor",
            subtitle: "4 days to go",
            location: "San Marino, CA",
            imageName: "find-project-pollinator",
            selection: .init(
                id: "project-pollinator",
                title: "Pollinator Corridor",
                tag: "Garden",
                countLabel: "12",
                imageName: "find-project-pollinator"
            )
        )
    ]

    private let people: [ProfileCommunityPerson] = [
        .init(
            id: "maya-chen",
            name: "Maya Chen",
            subtitle: "Pollinator Corridor (Member)",
            avatarImageName: "profile-avatar-maya",
            group: .following,
            followState: .following
        ),
        .init(
            id: "rafael-gomez",
            name: "Rafael Gomez",
            subtitle: "Creek Recovery: (Project Lead)",
            avatarImageName: "profile-avatar-noah",
            group: .following,
            followState: .follow
        ),
        .init(
            id: "noah-patel",
            name: "Noah Patel",
            subtitle: "Mutual",
            avatarImageName: "profile-avatar-noah",
            group: .mutuals,
            followState: .follow
        )
    ]

    private let metrics: [GaiaMetricCardItem] = [
        .init(id: "following", label: "Following", value: "18"),
        .init(id: "friends", label: "Friends", value: "6"),
        .init(id: "projects", label: "Active Projects", value: "3")
    ]

    private let projectColumns: [GridItem] = [
        GridItem(.flexible(minimum: 0), spacing: GaiaSpacing.sm),
        GridItem(.flexible(minimum: 0), spacing: GaiaSpacing.sm)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            summarySection
            projectsSection
            peopleSection
        }
        .padding(.horizontal, GaiaSpacing.md)
        .fullScreenCover(isPresented: $showsPeopleScreen) {
            ProfilePeopleScreen {
                showsPeopleScreen = false
            }
        }
        .fullScreenCover(isPresented: $showsMayaProfile) {
            MayaProfileDetailScreen {
                showsMayaProfile = false
            }
        }
    }

    private var summarySection: some View {
        VStack(alignment: .leading, spacing: 0) {
            summaryCard
        }
        .padding(.top, GaiaSpacing.md)
    }

    private var summaryCard: some View {
        GaiaMetricsCard(items: metrics)
    }

    private var projectsSection: some View {
        VStack(alignment: .leading, spacing: GaiaSpacing.sm) {
            sectionHeader(title: "Projects")

            LazyVGrid(columns: projectColumns, spacing: GaiaSpacing.sm) {
                ForEach(projects, id: \.id) { project in
                    Button {
                        appState.openProjectDetail(project.selection)
                    } label: {
                        GaiaProjectSummaryCard(
                            title: project.title,
                            subtitle: project.subtitle,
                            location: project.location,
                            imageName: project.imageName
                        )
                    }
                    .buttonStyle(GaiaPressableCardStyle())
                }
            }

            HStack {
                Spacer(minLength: 0)

                Text("View all")
                    .gaiaFont(.caption2)
                    .foregroundStyle(GaiaColor.textSecondary)
            }
        }
        .padding(.top, GaiaSpacing.lg)
    }

    private var peopleSection: some View {
        VStack(alignment: .leading, spacing: GaiaSpacing.sm) {
            sectionHeader(title: "People")

            VStack(spacing: GaiaSpacing.sm) {
                ForEach(people.prefix(3)) { person in
                    if person.id == "maya-chen" {
                        ProfileCommunityPersonRow(
                            person: person,
                            onProfileTap: { showsMayaProfile = true }
                        )
                    } else {
                        ProfileCommunityPersonRow(person: person)
                    }
                }
            }

            Button {
                showsPeopleScreen = true
            } label: {
                Text("View all")
                    .gaiaFont(.caption2)
                    .foregroundStyle(GaiaColor.textSecondary)
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.top, GaiaSpacing.lg)
    }

    private func sectionHeader(title: String, actionTitle: String? = nil, action: (() -> Void)? = nil) -> some View {
        HStack(alignment: .bottom, spacing: GaiaSpacing.sm) {
            Text(title)
                .gaiaFont(.titleSans)
                .foregroundStyle(GaiaColor.textSecondary)

            Spacer(minLength: 0)

            if let actionTitle {
                if let action {
                    Button(action: action) {
                        Text(actionTitle)
                            .gaiaFont(.caption2)
                            .foregroundStyle(GaiaColor.textSecondary)
                    }
                    .buttonStyle(.plain)
                } else {
                    Text(actionTitle)
                        .gaiaFont(.caption2)
                        .foregroundStyle(GaiaColor.textSecondary)
                }
            }
        }
    }

    private func communityPillLabel(_ title: String, style: CommunityPillStyle) -> some View {
        Text(title)
            .gaiaFont(.subheadline)
            .foregroundStyle(style.foregroundColor)
            .padding(.horizontal, 14)
            .frame(height: 34)
            .background(style.backgroundColor, in: Capsule())
            .overlay {
                if let borderColor = style.borderColor {
                    Capsule(style: .continuous)
                        .stroke(borderColor, lineWidth: 1)
                }
            }
    }

    private func profileArrowButton(size: CGFloat = 20) -> some View {
        let iconSize: CGFloat = size > 20 ? 18 : 16

        return ZStack {
            Circle()
                .fill(GaiaColor.paperWhite50)
                .overlay(
                    Circle()
                        .stroke(GaiaColor.oliveGreen500, lineWidth: 1)
                )

            GaiaIcon(kind: .circleArrowRight, size: iconSize, tint: GaiaColor.oliveGreen500)
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}

private struct ProfileCommunityPersonRow: View {
    let person: ProfileCommunityPerson
    var onToggleFollow: (() -> Void)? = nil
    var onProfileTap: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: GaiaSpacing.sm) {
            profileContent
            followButtonContent
        }
        .padding(.horizontal, GaiaSpacing.sm + GaiaSpacing.xs)
        .padding(.vertical, GaiaSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: GaiaRadius.card, style: .continuous)
                .fill(GaiaColor.paperWhite50)
                .overlay(
                    RoundedRectangle(cornerRadius: GaiaRadius.card, style: .continuous)
                        .stroke(borderColor, lineWidth: 0.5)
                )
        )
    }

    @ViewBuilder
    private var profileContent: some View {
        if let onProfileTap {
            Button(action: onProfileTap) {
                profileSummary
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(person.name)
            .accessibilityValue(person.subtitle)
            .accessibilityHint("Open profile details")
        } else {
            profileSummary
        }
    }

    private var profileSummary: some View {
        HStack(spacing: GaiaSpacing.sm) {
            avatar

            VStack(alignment: .leading, spacing: GaiaSpacing.sm) {
                Text(person.name)
                    .gaiaFont(.titleSans)
                    .foregroundStyle(GaiaColor.textPrimary)
                    .lineLimit(1)

                Text(person.subtitle)
                    .gaiaFont(.footnote)
                    .foregroundStyle(GaiaColor.oliveGreen500)
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var avatar: some View {
        GaiaAssetImage(name: person.avatarImageName, contentMode: .fill)
            .frame(width: 48, height: 48)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(GaiaColor.oliveGreen100, lineWidth: 0.5)
            )
            .accessibilityHidden(true)
    }

    @ViewBuilder
    private var followButtonContent: some View {
        if isFollowToggleEnabled {
            Button(action: onToggleFollow ?? {}) {
                followPill
            }
            .buttonStyle(.plain)
            .accessibilityLabel(person.followState == .following ? "Unfollow \(person.name)" : "Follow \(person.name)")
        } else {
            followPill
        }
    }

    private var isFollowToggleEnabled: Bool {
        onToggleFollow != nil && person.followState != .mutual
    }

    @ViewBuilder
    private var followPill: some View {
        switch person.followState {
        case .following:
            communityPillLabel("Following", style: .primary)
        case .follow:
            communityPillLabel("Follow", style: .secondary)
        case .mutual:
            communityPillLabel("Mutual", style: .mutual)
        }
    }

    private func communityPillLabel(_ title: String, style: CommunityPillStyle) -> some View {
        Text(title)
            .gaiaFont(.subheadline)
            .foregroundStyle(style.foregroundColor)
            .padding(.horizontal, 14)
            .frame(height: 34)
            .background(style.backgroundColor, in: Capsule())
            .overlay {
                if let borderColor = style.borderColor {
                    Capsule(style: .continuous)
                        .stroke(borderColor, lineWidth: 1)
                }
            }
    }

    private var borderColor: Color {
        switch person.followState {
        case .mutual:
            return GaiaColor.borderStrong
        case .following, .follow:
            return GaiaColor.textInverseSecondary
        }
    }
}

private enum CommunityPillStyle: Equatable {
    case primary
    case secondary
    case mutual

    var foregroundColor: Color {
        switch self {
        case .primary, .mutual:
            return GaiaColor.paperWhite50
        case .secondary:
            return GaiaColor.oliveGreen500
        }
    }

    var backgroundColor: Color {
        switch self {
        case .primary:
            return GaiaColor.oliveGreen500
        case .secondary:
            return GaiaColor.paperWhite50
        case .mutual:
            return GaiaColor.oliveGreen400
        }
    }

    var borderColor: Color? {
        switch self {
        case .secondary:
            return GaiaColor.oliveGreen500
        case .primary, .mutual:
            return nil
        }
    }
}

private struct ProfilePeopleScreen: View {
    let onClose: () -> Void
    @State private var people = Self.initialPeople
    @State private var selectedFilter: ProfilePeopleFilter = .all
    @State private var searchText = ""
    @State private var showsMayaProfile = false
    @FocusState private var isSearchFieldFocused: Bool

    var body: some View {
        GeometryReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: GaiaSpacing.lg) {
                    ForEach(visibleGroups) { group in
                        let matchingPeople = peopleForGroup(group)
                        if !matchingPeople.isEmpty {
                            groupSection(group: group, people: matchingPeople)
                        }
                    }
                }
                .padding(.horizontal, GaiaSpacing.md)
                .padding(.top, GaiaSpacing.lg)
                .padding(.bottom, GaiaSpacing.xxxl)
            }
            .background(GaiaColor.paperWhite50)
            .overlay(alignment: .top) {
                GaiaColor.paperWhite50
                    .frame(height: proxy.safeAreaInsets.top)
                    .ignoresSafeArea(edges: .top)
                    .allowsHitTesting(false)
            }
            .safeAreaInset(edge: .top, spacing: 0) {
                topChrome
            }
            .fullScreenCover(isPresented: $showsMayaProfile) {
                MayaProfileDetailScreen {
                    showsMayaProfile = false
                }
            }
        }
    }

    private var topChrome: some View {
        VStack(spacing: GaiaSpacing.md) {
            HStack {
                ToolbarGlassButton(icon: .back, accessibilityLabel: "Back") {
                    onClose()
                }

                Spacer(minLength: 0)

                Text("People")
                    .gaiaFont(.title1Medium)
                    .foregroundStyle(GaiaColor.oliveGreen500)

                Spacer(minLength: 0)

                Color.clear
                    .frame(width: 48, height: 48)
            }
            .padding(.horizontal, GaiaSpacing.md)
            .padding(.top, GaiaSpacing.xs)

            VStack(alignment: .leading, spacing: GaiaSpacing.md) {
                searchBar
                filterChips
            }
            .padding(.horizontal, GaiaSpacing.md)
        }
        .padding(.bottom, GaiaSpacing.md)
        .frame(maxWidth: .infinity)
        .background(
            GaiaColor.paperWhite50
                .ignoresSafeArea(edges: .top)
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .fill(GaiaColor.broccoliBrown200)
                        .frame(height: 0.5)
                }
                .shadow(color: GaiaShadow.mdColor, radius: GaiaShadow.mdRadius, x: 0, y: GaiaShadow.mdYOffset)
        )
    }

    private var searchBar: some View {
        HStack(spacing: GaiaSpacing.xs) {
            GaiaIcon(kind: .search, size: 20, tint: GaiaColor.blackishGrey200)
                .frame(width: 26, height: 26)

            TextField(
                "",
                text: $searchText,
                prompt: Text("Search by name")
                    .font(GaiaTypography.subheadline)
                    .foregroundStyle(GaiaColor.blackishGrey500.opacity(0.5))
            )
            .gaiaFont(.subheadline)
            .foregroundStyle(GaiaColor.inkBlack500)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .submitLabel(.search)
            .focused($isSearchFieldFocused)

            GaiaIcon(kind: .microphone, size: 32, tint: GaiaColor.blackishGrey200)
                .frame(width: 32, height: 32)
        }
        .padding(.leading, GaiaSpacing.sm)
        .padding(.trailing, GaiaSpacing.xs)
        .frame(height: 40)
        .background(
            Capsule(style: .continuous)
                .fill(.white)
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(GaiaColor.blackishGrey200, lineWidth: 0.5)
                )
        )
    }

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: GaiaSpacing.sm) {
                ForEach(ProfilePeopleFilter.allCases) { filter in
                    Button {
                        guard selectedFilter != filter else { return }
                        HapticsService.selectionChanged()
                        selectedFilter = filter
                    } label: {
                        Text(filter.title)
                            .gaiaFont(.footnote)
                            .foregroundStyle(selectedFilter == filter ? GaiaColor.paperWhite50 : GaiaColor.inkBlack300)
                            .padding(.horizontal, 10)
                            .frame(height: 28)
                            .background {
                                if selectedFilter == filter {
                                    Capsule(style: .continuous)
                                        .fill(GaiaColor.oliveGreen500)
                                } else {
                                    Capsule(style: .continuous)
                                        .fill(GaiaColor.oliveGreen500.opacity(0.20))
                                }
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    @ViewBuilder
    private func groupSection(group: ProfilePeopleGroup, people: [ProfileCommunityPerson]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("\(group.title.uppercased()) · \(displayCount(for: group, matchingCount: people.count))")
                .gaiaFont(.caption2)
                .foregroundStyle(GaiaColor.textSecondary)
                .padding(.top, GaiaSpacing.md)
                .padding(.bottom, GaiaSpacing.xs)

            ForEach(people) { person in
                ProfileCommunityPersonRow(
                    person: person,
                    onToggleFollow: { toggleFollow(for: person.id) },
                    onProfileTap: person.id == "maya-chen"
                        ? { showsMayaProfile = true }
                        : nil
                )
            }

            if group == .mutuals, selectedFilter == .all, trimmedSearchText.isEmpty {
                Button {
                    selectedFilter = .mutuals
                } label: {
                    Text("View all")
                        .gaiaFont(.caption2)
                        .foregroundStyle(GaiaColor.textSecondary)
                }
                .buttonStyle(.plain)
                .padding(.top, GaiaSpacing.xs)
            }
        }
    }

    private var visibleGroups: [ProfilePeopleGroup] {
        if let scopedGroup = selectedFilter.group {
            return [scopedGroup]
        }
        return ProfilePeopleGroup.allCases
    }

    private func peopleForGroup(_ group: ProfilePeopleGroup) -> [ProfileCommunityPerson] {
        searchedPeople.filter { $0.group == group }
    }

    private var searchedPeople: [ProfileCommunityPerson] {
        guard !trimmedSearchText.isEmpty else {
            return people
        }
        return people.filter { $0.searchableText.contains(trimmedSearchText) }
    }

    private var trimmedSearchText: String {
        searchText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
    }

    private func displayCount(for group: ProfilePeopleGroup, matchingCount: Int) -> Int {
        trimmedSearchText.isEmpty ? group.baselineCount : matchingCount
    }

    private func toggleFollow(for personID: String) {
        guard let index = people.firstIndex(where: { $0.id == personID }) else { return }

        switch people[index].followState {
        case .mutual:
            return
        case .following:
            people[index].followState = .follow
            people[index].group = .suggested
        case .follow:
            people[index].followState = .following
            people[index].group = .following
        }
    }

    private static let initialPeople: [ProfileCommunityPerson] = [
        .init(
            id: "noah-patel",
            name: "Noah Patel",
            subtitle: "Urban Fungi Watch (Member)",
            avatarImageName: "profile-avatar-noah",
            group: .mutuals,
            followState: .mutual
        ),
        .init(
            id: "maya-chen",
            name: "Maya Chen",
            subtitle: "Pollinator Corridor (Member)",
            avatarImageName: "profile-avatar-maya",
            group: .mutuals,
            followState: .mutual
        ),
        .init(
            id: "lena-ortiz",
            name: "Lena Ortiz",
            subtitle: "8 shared species",
            avatarImageName: "profile-avatar-lena",
            group: .mutuals,
            followState: .mutual
        ),
        .init(
            id: "rafael-gomez",
            name: "Rafael Gomez",
            subtitle: "Creek Recovery (Project Coor.)",
            avatarImageName: "profile-avatar-noah",
            group: .following,
            followState: .following
        ),
        .init(
            id: "ava-kim",
            name: "Ava Kim",
            subtitle: "42 finds this season",
            avatarImageName: "profile-avatar-noah",
            group: .following,
            followState: .following
        ),
        .init(
            id: "james-whitfield",
            name: "James Whitfield",
            subtitle: "Descanso Gardens (Botanist)",
            avatarImageName: "profile-avatar-noah",
            group: .following,
            followState: .following
        ),
        .init(
            id: "sofia-reyes",
            name: "Sofia Reyes",
            subtitle: "18 finds this month",
            avatarImageName: "profile-avatar-noah",
            group: .suggested,
            followState: .follow
        ),
        .init(
            id: "daniel-kwon",
            name: "Daniel Kwon",
            subtitle: "3 mutuals follow them",
            avatarImageName: "profile-avatar-noah",
            group: .suggested,
            followState: .follow
        )
    ]
}

private enum ProfilePeopleFilter: CaseIterable, Identifiable {
    case all
    case mutuals
    case following

    var id: String { title }

    var title: String {
        switch self {
        case .all:
            return "All"
        case .mutuals:
            return "Mutuals"
        case .following:
            return "Following"
        }
    }

    var group: ProfilePeopleGroup? {
        switch self {
        case .all:
            return nil
        case .mutuals:
            return .mutuals
        case .following:
            return .following
        }
    }
}

private struct MayaProfileDetailScreen: View {
    let onClose: () -> Void

    @EnvironmentObject private var contentStore: ContentStore
    @State private var showsExpandedMap = false

    private let projects: [MayaProfileProject] = [
        .init(id: "maya-project-1", title: "Creek Recovery", subtitle: "2 days to go", location: "Pasadena, CA", imageName: "find-project-creek"),
        .init(id: "maya-project-2", title: "Pollinator Corridor", subtitle: "4 days to go", location: "San Marino, CA", imageName: "find-project-pollinator")
    ]

    private let recentFinds: [MayaRecentFind] = [
        .init(id: "cacti", title: "Cacti", imageName: "project-detail-recent-cacti"),
        .init(id: "indian-cormorant", title: "Indian\nCormorant", imageName: "project-detail-recent-indian-cormorant"),
        .init(id: "european-roller", title: "European\nRoller", imageName: "project-detail-recent-european-roller"),
        .init(id: "bindweed-tribe", title: "Bindweed\nTribe", imageName: "project-detail-recent-bindweed-tribe"),
        .init(id: "emperor-gum-moth", title: "Emperor Gum\nMoth", imageName: "project-detail-recent-emperor-gum-moth"),
        .init(id: "garden-orbweaver", title: "Garden\nOrbweaver", imageName: "project-detail-recent-garden-orbweaver")
    ]

    private let highlights: [GaiaMetricCardItem] = [
        .init(id: "finds", label: "Finds", value: "127"),
        .init(id: "level", label: "Level", value: "14"),
        .init(id: "suggests", label: "Suggests", value: "56")
    ]

    var body: some View {
        GeometryReader { proxy in
            let topInset = proxy.safeAreaInsets.top > 0 ? proxy.safeAreaInsets.top : windowSafeTopInset
            let horizontalContentPadding = GaiaSpacing.md * 2
            let usableContentWidth = max(proxy.size.width - horizontalContentPadding, 0)
            let projectCardWidth = min(max(floor((usableContentWidth - GaiaSpacing.sm) / 2), 0), 181)
            let recentFindCardWidth = min(max(floor((usableContentWidth - GaiaSpacing.sm) / 2), 0), 181)

            ZStack(alignment: .top) {
                GaiaColor.paperWhite50.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: GaiaSpacing.lg) {
                        profileHeader
                        sharedContextCard
                        projectsSection(cardWidth: projectCardWidth)
                        findsSection(cardWidth: recentFindCardWidth)
                        findMapSection
                    }
                    .padding(.bottom, GaiaSpacing.xxxl)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                topToolbar(topInset: topInset)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .ignoresSafeArea(edges: .top)
        .fullScreenCover(isPresented: $showsExpandedMap) {
            ImpactMapExpandedScreen(observations: contentStore.observations) {
                showsExpandedMap = false
            }
        }
    }

    private var windowSafeTopInset: CGFloat {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)?
            .safeAreaInsets.top ?? 0
    }

    private var profileHeader: some View {
        VStack(alignment: .center, spacing: 0) {
            // Hero image — negative bottom padding creates the avatar overlap
            GaiaAssetImage(name: "project-detail-hero-pollinator", contentMode: .fill)
                .frame(height: 161)
                .frame(maxWidth: .infinity)
                .clipped()
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
                .padding(.bottom, -36)

            // Badge container
            VStack(spacing: GaiaSpacing.lg) {
                // Profile badge
                VStack(spacing: GaiaSpacing.md) {
                    // Profile image container (Figma: 150px wide)
                    VStack(spacing: GaiaSpacing.sm) {
                        GaiaAssetImage(name: "profile-avatar-maya", contentMode: .fill)
                            .frame(width: 72, height: 72)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(GaiaColor.oliveGreen100, lineWidth: 1.125)
                            )

                        VStack(spacing: GaiaSpacing.xs) {
                            Text("Maya Chen")
                                .gaiaFont(.title1Medium)
                                .foregroundStyle(GaiaColor.oliveGreen500)
                                .multilineTextAlignment(.center)

                            Text("Pasadena, CA")
                                .gaiaFont(.subheadline)
                                .foregroundStyle(GaiaColor.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(width: 150)
                    }

                    Text("Following")
                        .gaiaFont(.subheadline)
                        .foregroundStyle(GaiaColor.oliveGreen500)
                        .padding(.horizontal, 14)
                        .frame(height: 34)
                        .background(GaiaColor.paperWhite50, in: Capsule(style: .continuous))
                        .overlay(
                            Capsule(style: .continuous)
                                .stroke(GaiaColor.oliveGreen500, lineWidth: 1)
                        )
                }

                GaiaMetricsCard(items: highlights)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, GaiaSpacing.md)
        }
        .padding(.bottom, 36)
        .frame(maxWidth: .infinity)
    }

    private var sharedContextCard: some View {
        HStack(alignment: .center, spacing: GaiaSpacing.md) {
            VStack(alignment: .leading, spacing: 6) {
                Text("YOU AND MAYA")
                    .gaiaFont(.caption2)
                    .foregroundStyle(GaiaColor.oliveGreen500)

                Text("You have 2 shared projects and made 14 species in common.")
                    .gaiaFont(.titleSans)
                    .foregroundStyle(GaiaColor.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)

            profileArrowButton(size: 24)
        }
        .padding(GaiaSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: GaiaRadius.card, style: .continuous)
                .fill(GaiaColor.paperWhite50)
                .overlay(
                    RoundedRectangle(cornerRadius: GaiaRadius.card, style: .continuous)
                        .stroke(GaiaColor.border, lineWidth: 0.5)
                )
        )
        .padding(.horizontal, GaiaSpacing.md)
    }

    private func projectsSection(cardWidth: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: GaiaSpacing.sm) {
            Text("Projects")
                .gaiaFont(.titleSans)
                .foregroundStyle(GaiaColor.textSecondary)

            HStack(spacing: GaiaSpacing.sm) {
                ForEach(projects) { project in
                    mayaProjectCard(project, cardWidth: cardWidth)
                }
            }

            Button(action: {}) {
                Text("View all")
                    .gaiaFont(.caption2)
                    .foregroundStyle(GaiaColor.textSecondary)
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.horizontal, GaiaSpacing.md)
    }

    private func findsSection(cardWidth: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: GaiaSpacing.sm) {
            Text("Finds")
                .gaiaFont(.titleSans)
                .foregroundStyle(GaiaColor.textSecondary)

            HStack(spacing: 4) {
                findViewModeButton(kind: .grid, isSelected: true)
                findViewModeButton(kind: .list, isSelected: false)
            }
            .padding(4)
            .background(
                RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                    .fill(GaiaColor.textDisabled.opacity(0.20))
            )

            let columns: [GridItem] = [
                GridItem(.fixed(cardWidth), spacing: GaiaSpacing.sm),
                GridItem(.fixed(cardWidth), spacing: GaiaSpacing.sm)
            ]

            LazyVGrid(columns: columns, alignment: .leading, spacing: GaiaSpacing.sm) {
                ForEach(recentFinds) { find in
                    mayaRecentFindCard(find, sideLength: cardWidth) {
                        // TODO: Wire profile recent find navigation.
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, GaiaSpacing.md)
    }

    private var findMapSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Find Map")
                    .gaiaFont(.titleSans)
                    .foregroundStyle(GaiaColor.textSecondary)

                Spacer(minLength: 0)

                Text("127 finds")
                    .gaiaFont(.caption2)
                    .foregroundStyle(GaiaColor.textSecondary)
            }

            ProfileHeatmapCard {
                showsExpandedMap = true
            }
        }
        .padding(.horizontal, GaiaSpacing.md)
    }

    private func topToolbar(topInset: CGFloat) -> some View {
        VStack(spacing: 0) {
            HStack {
                ToolbarGlassButton(icon: .back, accessibilityLabel: "Back", action: onClose)

                Spacer(minLength: 0)

                GlassCircleButton(size: 48, action: {}) {
                    GaiaIcon(kind: .share, size: 32, tint: GaiaColor.inkBlack900)
                }
                .accessibilityLabel("Share")
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, GaiaSpacing.md)
            .padding(.top, max(topInset + 8, 54))

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private func mayaProjectCard(_ project: MayaProfileProject, cardWidth: CGFloat) -> some View {
        GaiaProjectSummaryCard(
            title: project.title,
            subtitle: project.subtitle,
            location: project.location,
            imageName: project.imageName,
            width: cardWidth
        )
    }

    private func mayaRecentFindCard(_ item: MayaRecentFind, sideLength: CGFloat, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            ZStack(alignment: .bottomLeading) {
                GaiaAssetImage(name: item.imageName, contentMode: .fill)
                    .frame(width: sideLength, height: sideLength)

                LinearGradient(
                    stops: [
                        .init(color: Color.black.opacity(0), location: 0),
                        .init(color: Color.black.opacity(0.56), location: 1)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                Text(item.title)
                    .gaiaFont(.title3)
                    .foregroundStyle(GaiaColor.paperWhite50)
                    .lineLimit(2)
                    .frame(width: max(sideLength - (GaiaSpacing.sm * 2), 0), alignment: .leading)
                    .padding(.leading, GaiaSpacing.sm)
                    .padding(.bottom, 8)
            }
            .frame(width: sideLength, height: sideLength)
            .clipShape(RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                    .stroke(GaiaColor.broccoliBrown200, lineWidth: 0.5)
            )
        }
        .buttonStyle(GaiaPressableCardStyle())
    }

    private func findViewModeButton(kind: GaiaIconKind, isSelected: Bool) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: GaiaRadius.sm, style: .continuous)
                .fill(isSelected ? GaiaColor.oliveGreen400 : GaiaColor.textDisabled.opacity(0.20))
                .frame(width: 40, height: 40)

            GaiaIcon(kind: kind, size: 20, tint: isSelected ? GaiaColor.paperWhite50 : GaiaColor.textDisabled)
        }
        .frame(width: 40, height: 40)
    }

    private func profileArrowButton(size: CGFloat = 20) -> some View {
        let iconSize: CGFloat = size > 20 ? 18 : 16

        return ZStack {
            Circle()
                .fill(GaiaColor.paperWhite50)
                .overlay(
                    Circle()
                        .stroke(GaiaColor.oliveGreen500, lineWidth: 1)
                )

            GaiaIcon(kind: .circleArrowRight, size: iconSize, tint: GaiaColor.oliveGreen500)
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}

private struct MayaProfileProject: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let location: String
    let imageName: String
}

private struct MayaRecentFind: Identifiable {
    let id: String
    let title: String
    let imageName: String
}
