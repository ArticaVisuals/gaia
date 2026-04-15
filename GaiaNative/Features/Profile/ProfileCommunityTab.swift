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

private struct CommunityHighlight: Identifiable {
    let id: String
    let title: String
    let subtitle: String
}

private struct CommunityMetric: Identifiable {
    let id: String
    let label: String
    let value: String
}

private struct ProfileCommunityProject: Identifiable {
    let selection: ProjectSelection
    let subtitle: String
    let location: String

    var id: String { selection.id }
}

struct ProfileCommunityTab: View {
    let posts: [CommunityPost]

    init(posts: [CommunityPost] = []) {
        self.posts = posts
    }

    @EnvironmentObject private var appState: AppState
    @State private var showsPeopleScreen = false

    private let projects: [ProfileCommunityProject] = [
        .init(
            selection: .init(
                id: "project-creek-1",
                title: "Creek Recovery",
                tag: "Wetland",
                countLabel: "12",
                imageName: "find-project-creek"
            ),
            subtitle: "2 days to go",
            location: "Arroyo Seco"
        ),
        .init(
            selection: .init(
                id: "project-creek-2",
                title: "Creek Recovery",
                tag: "Wetland",
                countLabel: "12",
                imageName: "find-project-creek"
            ),
            subtitle: "2 days to go",
            location: "Arroyo Seco"
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
            avatarImageName: "profile-avatar-lena",
            group: .suggested,
            followState: .follow
        ),
        .init(
            id: "noah-patel",
            name: "Noah Patel",
            subtitle: "Mutual",
            avatarImageName: "profile-avatar-noah",
            group: .suggested,
            followState: .follow
        )
    ]

    private let metrics: [CommunityMetric] = [
        .init(id: "following", label: "Following", value: "18"),
        .init(id: "friends", label: "Friends", value: "6"),
        .init(id: "projects", label: "Active Projects", value: "3")
    ]

    private let highlights: [CommunityHighlight] = [
        .init(
            id: "highlight-weekly",
            title: "5 followed observers contributed new finds this week",
            subtitle: "Most activity came from Pollinator Corridor and Creek Recovery"
        ),
        .init(
            id: "highlight-monthly",
            title: "You are among this month's most active contributors in Urban Fungi Watch",
            subtitle: "Based on finds added this month"
        )
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
            highlightsSection
        }
        .padding(.horizontal, GaiaSpacing.md)
        .fullScreenCover(isPresented: $showsPeopleScreen) {
            ProfilePeopleScreen {
                showsPeopleScreen = false
            }
        }
    }

    private var summarySection: some View {
        VStack(alignment: .leading, spacing: 0) {
            summaryCard
        }
        .padding(.top, 20)
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: GaiaSpacing.lg) {
            VStack(alignment: .leading, spacing: GaiaSpacing.sm) {
                Text("IDs confirmed")
                    .gaiaFont(.subheadline)
                    .foregroundStyle(GaiaColor.inkBlack300)

                Text("41")
                    .font(.custom("NewSpirit-Medium", size: 48))
                    .foregroundStyle(GaiaColor.oliveGreen500)
                    .tracking(-0.5)
                    .lineLimit(1)
            }

            HStack(alignment: .top, spacing: GaiaSpacing.lg) {
                ForEach(metrics) { metric in
                    metricColumn(metric)
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                .fill(GaiaColor.paperWhite50)
                .overlay(
                    RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                        .stroke(GaiaColor.broccoliBrown200, lineWidth: 0.5)
                )
                .shadow(color: GaiaShadow.mdColor, radius: GaiaShadow.mdRadius, x: 0, y: GaiaShadow.mdYOffset)
        )
    }

    private func metricColumn(_ metric: CommunityMetric) -> some View {
        VStack(alignment: .leading, spacing: GaiaSpacing.sm) {
            Text(metric.label)
                .gaiaFont(.footnote)
                .foregroundStyle(GaiaColor.textSecondary)
                .fixedSize(horizontal: true, vertical: false)

            Text(metric.value)
                .gaiaFont(.title1Medium)
                .foregroundStyle(GaiaColor.broccoliBrown500)
                .lineLimit(1)
        }
    }

    private var projectsSection: some View {
        VStack(alignment: .leading, spacing: GaiaSpacing.sm) {
            sectionHeader(title: "Projects", actionTitle: "See all")

            LazyVGrid(columns: projectColumns, spacing: GaiaSpacing.sm) {
                ForEach(projects, id: \.id) { project in
                    Button {
                        appState.openProjectDetail(project.selection)
                    } label: {
                        projectCard(project)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.top, GaiaSpacing.lg)
    }

    private func projectCard(_ project: ProfileCommunityProject) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            GaiaAssetImage(name: project.selection.imageName, contentMode: .fill)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .clipShape(RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                        .stroke(GaiaColor.broccoliBrown200, lineWidth: 0.5)
                )

            VStack(alignment: .leading, spacing: 3) {
                Text(project.selection.title)
                    .gaiaFont(.subheadline)
                    .foregroundStyle(GaiaColor.inkBlack500)
                    .lineLimit(1)

                Text(project.subtitle)
                    .gaiaFont(.footnote)
                    .foregroundStyle(GaiaColor.inkBlack200)
                    .lineLimit(1)

                HStack(spacing: 6) {
                    HStack(spacing: 0) {
                        GaiaIcon(kind: .pin, size: 11, tint: GaiaColor.broccoliBrown500)
                            .frame(width: 11, height: 13)

                        Text(project.location)
                            .gaiaFont(.footnote)
                            .foregroundStyle(GaiaColor.broccoliBrown500)
                            .lineLimit(1)
                    }

                    Spacer(minLength: 0)

                    GaiaIcon(kind: .circleArrowRight, size: 16)
                        .frame(width: 16, height: 16)
                }
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, minHeight: 129, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                .fill(GaiaColor.paperWhite50)
                .overlay(
                    RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                        .stroke(GaiaColor.broccoliBrown200, lineWidth: 0.5)
                )
                .shadow(color: GaiaShadow.smallColor, radius: GaiaShadow.smallRadius, x: 0, y: GaiaShadow.smallYOffset)
        )
        .contentShape(RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous))
    }

    private var peopleSection: some View {
        VStack(alignment: .leading, spacing: GaiaSpacing.sm) {
            sectionHeader(title: "People", actionTitle: "See all") {
                showsPeopleScreen = true
            }

            VStack(spacing: GaiaSpacing.sm) {
                ForEach(people.prefix(3)) { person in
                    ProfileCommunityPersonRow(person: person)
                }
            }
        }
        .padding(.top, GaiaSpacing.lg)
    }

    private var highlightsSection: some View {
        VStack(alignment: .leading, spacing: GaiaSpacing.sm) {
            sectionHeader(title: "Community Highlights")

            VStack(spacing: GaiaSpacing.sm) {
                ForEach(highlights) { highlight in
                    highlightCard(highlight)
                }
            }
        }
        .padding(.top, GaiaSpacing.lg)
    }

    private func highlightCard(_ highlight: CommunityHighlight) -> some View {
        HStack(alignment: .top, spacing: GaiaSpacing.sm) {
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(GaiaColor.oliveGreen500)
                .frame(width: 8, height: 20)
                .padding(.top, 1)

            VStack(alignment: .leading, spacing: GaiaSpacing.sm) {
                Text(highlight.title)
                    .gaiaFont(.subheadlineMedium)
                    .foregroundStyle(GaiaColor.inkBlack500)
                    .fixedSize(horizontal: false, vertical: true)

                Text(highlight.subtitle)
                    .gaiaFont(.footnote)
                    .foregroundStyle(GaiaColor.inkBlack300)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                .fill(GaiaColor.oliveGreen50)
        )
    }

    private func sectionHeader(title: String, actionTitle: String? = nil, action: (() -> Void)? = nil) -> some View {
        HStack(alignment: .bottom, spacing: GaiaSpacing.sm) {
            Text(title)
                .gaiaFont(.title2)
                .foregroundStyle(GaiaColor.inkBlack300)

            Spacer(minLength: 0)

            if let actionTitle {
                if let action {
                    Button(action: action) {
                        Text(actionTitle)
                            .gaiaFont(.caption2)
                            .foregroundStyle(GaiaColor.inkBlack300)
                    }
                    .buttonStyle(.plain)
                } else {
                    Text(actionTitle)
                        .gaiaFont(.caption2)
                        .foregroundStyle(GaiaColor.inkBlack300)
                }
            }
        }
    }
}

private struct ProfileCommunityPersonRow: View {
    let person: ProfileCommunityPerson
    var onToggleFollow: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: GaiaSpacing.sm) {
            avatar

            VStack(alignment: .leading, spacing: GaiaSpacing.sm) {
                Text(person.name)
                    .gaiaFont(.subheadSerif)
                    .foregroundStyle(GaiaColor.inkBlack500)
                    .lineLimit(1)

                Text(person.subtitle)
                    .gaiaFont(.footnote)
                    .foregroundStyle(GaiaColor.oliveGreen500)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)

            followButtonContent
        }
        .padding(.horizontal, GaiaSpacing.sm + GaiaSpacing.xs)
        .padding(.vertical, GaiaSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                .fill(GaiaColor.paperWhite50)
                .overlay(
                    RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                        .stroke(GaiaColor.broccoliBrown200, lineWidth: 0.5)
                )
                .shadow(color: GaiaShadow.smallColor, radius: GaiaShadow.smallRadius, x: 0, y: GaiaShadow.smallYOffset)
        )
    }

    private var avatar: some View {
        GaiaAssetImage(name: person.avatarImageName, contentMode: .fill)
            .frame(width: 44, height: 44)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(GaiaColor.oliveGreen100, lineWidth: 0.688)
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
            Text("Following")
                .gaiaFont(.subheadline)
                .foregroundStyle(GaiaColor.oliveGreen500)
                .padding(.horizontal, 10)
                .frame(height: 28)
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(GaiaColor.oliveGreen500, lineWidth: 1)
                )
        case .follow:
            Text("Follow")
                .gaiaFont(.footnote)
                .foregroundStyle(GaiaColor.paperWhite50)
                .padding(.horizontal, 10)
                .frame(height: 28)
                .background(GaiaColor.oliveGreen500, in: Capsule())
        case .mutual:
            Text("Mutual")
                .gaiaFont(.footnote)
                .foregroundStyle(GaiaColor.paperWhite50)
                .padding(.horizontal, 10)
                .frame(height: 28)
                .background(GaiaColor.broccoliBrown500, in: Capsule())
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
                prompt: Text("Look up a species by name")
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
                if person.id == "maya-chen" {
                    Button {
                        showsMayaProfile = true
                    } label: {
                        ProfileCommunityPersonRow(person: person) {
                            toggleFollow(for: person.id)
                        }
                    }
                    .buttonStyle(.plain)
                } else {
                    ProfileCommunityPersonRow(person: person) {
                        toggleFollow(for: person.id)
                    }
                }
            }

            if group == .mutuals, selectedFilter == .all, trimmedSearchText.isEmpty {
                Button {
                    selectedFilter = .mutuals
                } label: {
                    Text("See all")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(GaiaColor.oliveGreen500)
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
    case suggested

    var id: String { title }

    var title: String {
        switch self {
        case .all:
            return "All"
        case .mutuals:
            return "Mutuals"
        case .following:
            return "Following"
        case .suggested:
            return "Suggested"
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
        case .suggested:
            return .suggested
        }
    }
}

private struct MayaProfileDetailScreen: View {
    let onClose: () -> Void

    @EnvironmentObject private var contentStore: ContentStore
    @State private var showsExpandedMap = false

    private let projects: [MayaProfileProject] = [
        .init(id: "maya-project-1", title: "Creek Recovery", tag: "Wetland", countLabel: "12", imageName: "find-project-creek"),
        .init(id: "maya-project-2", title: "Creek Recovery", tag: "Wetland", countLabel: "12", imageName: "find-project-creek")
    ]

    private let recentFinds: [MayaRecentFind] = [
        .init(id: "cacti", title: "Cacti", imageName: "project-detail-recent-cacti"),
        .init(id: "indian-cormorant", title: "Indian\nCormorant", imageName: "project-detail-recent-indian-cormorant"),
        .init(id: "european-roller", title: "European\nRoller", imageName: "project-detail-recent-european-roller"),
        .init(id: "bindweed-tribe", title: "Bindweed\nTribe", imageName: "project-detail-recent-bindweed-tribe"),
        .init(id: "emperor-gum-moth", title: "Emperor Gum\nMoth", imageName: "project-detail-recent-emperor-gum-moth"),
        .init(id: "garden-orbweaver", title: "Garden\nOrbweaver", imageName: "project-detail-recent-garden-orbweaver")
    ]

    var body: some View {
        GeometryReader { proxy in
            let topInset = proxy.safeAreaInsets.top > 0 ? proxy.safeAreaInsets.top : windowSafeTopInset
            let horizontalContentPadding = GaiaSpacing.md * 2
            let usableContentWidth = max(proxy.size.width - horizontalContentPadding, 0)
            let projectCardWidth = min(max(floor((usableContentWidth - GaiaSpacing.sm) / 2), 0), 181)
            let recentFindCardWidth = min(max(floor((usableContentWidth - (GaiaSpacing.sm * 2)) / 3), 0), 118)

            ZStack(alignment: .top) {
                GaiaColor.paperWhite50.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: GaiaSpacing.lg) {
                        profileHeader
                        sharedContextCard
                        projectsSection(cardWidth: projectCardWidth)
                        recentFindsSection(cardWidth: recentFindCardWidth)
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
                        .overlay(
                            Capsule(style: .continuous)
                                .stroke(GaiaColor.oliveGreen500, lineWidth: 1)
                        )
                }

                // Stats row
                HStack(spacing: 26) {
                    statColumn(label: "Finds", value: "127")
                    statColumn(label: "Level", value: "14")
                    statColumn(label: "Suggests", value: "56")
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, GaiaSpacing.md)
        }
        .padding(.bottom, 36)
        .frame(maxWidth: .infinity)
    }

    private var sharedContextCard: some View {
        VStack(alignment: .leading, spacing: GaiaSpacing.md) {
            Text("YOU AND MAYA")
                .gaiaFont(.caption)
                .foregroundStyle(GaiaColor.oliveGreen500)

            HStack(spacing: GaiaSpacing.md) {
                VStack(alignment: .leading, spacing: GaiaSpacing.xxs) {
                    Text("2")
                        .gaiaFont(.title2Medium)
                        .foregroundStyle(GaiaColor.inkBlack500)
                    Text("shared projects")
                        .gaiaFont(.footnote)
                        .foregroundStyle(GaiaColor.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                VStack(alignment: .leading, spacing: GaiaSpacing.xxs) {
                    Text("14")
                        .gaiaFont(.title2Medium)
                        .foregroundStyle(GaiaColor.inkBlack500)
                    Text("species in common")
                        .gaiaFont(.footnote)
                        .foregroundStyle(GaiaColor.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            Text("Frequently identifies your finds")
                .gaiaFont(.subheadline)
                .foregroundStyle(GaiaColor.vermillion500)
        }
        .padding(GaiaSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                .fill(GaiaColor.oliveGreen50)
                .overlay(
                    RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                        .stroke(GaiaColor.oliveGreen500, lineWidth: 0.5)
                )
        )
        .padding(.horizontal, GaiaSpacing.md)
    }

    private func projectsSection(cardWidth: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: GaiaSpacing.sm) {
            Text("Projects")
                .gaiaFont(.title2)
                .foregroundStyle(GaiaColor.inkBlack300)

            HStack(spacing: GaiaSpacing.sm) {
                ForEach(projects) { project in
                    mayaProjectCard(project, cardWidth: cardWidth)
                }
            }

            Button(action: {}) {
                Text("View All")
                    .gaiaFont(.bodySerif)
                    .foregroundStyle(GaiaColor.oliveGreen500)
                    .padding(.horizontal, 14)
                    .frame(height: 34)
                    .overlay(
                        Capsule(style: .continuous)
                            .stroke(GaiaColor.oliveGreen500, lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, GaiaSpacing.md)
    }

    private func recentFindsSection(cardWidth: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: GaiaSpacing.sm) {
            HStack(alignment: .bottom, spacing: GaiaSpacing.sm) {
                Text("Recent Finds")
                    .gaiaFont(.title2)
                    .foregroundStyle(GaiaColor.inkBlack300)

                Spacer(minLength: 0)

                Text("See all")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(GaiaColor.oliveGreen500)
            }

            let columns: [GridItem] = Array(repeating: GridItem(.fixed(cardWidth), spacing: GaiaSpacing.sm), count: 3)

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
                    .gaiaFont(.subheadSerif)
                    .foregroundStyle(GaiaColor.inkBlack300)

                Spacer(minLength: 0)

                Text("5 finds")
                    .gaiaFont(.caption2)
                    .foregroundStyle(GaiaColor.inkBlack300)
            }

            VStack(spacing: 0) {
                ZStack(alignment: .topTrailing) {
                    GaiaAssetImage(name: "gaia-profile-impact-map-preview", contentMode: .fill)
                        .frame(height: 214)
                        .frame(maxWidth: .infinity)
                        .clipped()

                    GlassCircleButton(size: 44) {
                        showsExpandedMap = true
                    } label: {
                        GaiaIcon(kind: .expand, size: 24, tint: GaiaColor.inkBlack900)
                    }
                    .padding(GaiaSpacing.md)
                    .accessibilityLabel("Expand map")
                }

                HStack {
                    Text("127 finds")
                        .gaiaFont(.caption2Medium)
                        .foregroundStyle(GaiaColor.broccoliBrown500)
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, GaiaSpacing.md)
                .frame(height: 41)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(GaiaColor.surfaceCard)
            }
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                    .stroke(GaiaColor.border, lineWidth: 0.5)
            )
            .shadow(color: GaiaShadow.mdColor, radius: GaiaShadow.mdRadius, x: 0, y: GaiaShadow.mdYOffset)
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

    private func statColumn(label: String, value: String) -> some View {
        VStack(spacing: GaiaSpacing.sm) {
            Text(label)
                .gaiaFont(.footnote)
                .foregroundStyle(GaiaColor.textSecondary)

            Text(value)
                .gaiaFont(.title1Medium)
                .foregroundStyle(GaiaColor.inkBlack500)
        }
        .frame(width: 60)
    }

    private func mayaProjectCard(_ project: MayaProfileProject, cardWidth: CGFloat) -> some View {
        let cardHeight = cardWidth * (133.0 / 181.0)

        return ZStack(alignment: .topLeading) {
            GaiaAssetImage(name: project.imageName, contentMode: .fill)
                .frame(width: cardWidth, height: cardHeight)

            GaiaAssetImage(name: project.imageName, contentMode: .fill)
                .frame(width: cardWidth, height: cardHeight)
                .blur(radius: 1.4)
                .mask(
                    LinearGradient(
                        stops: [
                            .init(color: .clear, location: 0.417),
                            .init(color: .black, location: 1)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            LinearGradient(
                stops: [
                    .init(color: Color(red: 70 / 255, green: 76 / 255, blue: 19 / 255, opacity: 0), location: 0.417),
                    .init(color: Color(red: 41 / 255, green: 76 / 255, blue: 19 / 255, opacity: 0.85), location: 1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 0) {
                Text(project.tag)
                    .gaiaFont(.caption)
                    .foregroundStyle(GaiaColor.paperWhite50)
                    .padding(.horizontal, 10)
                    .frame(height: 20)
                    .background(Color.black.opacity(0.5), in: Capsule())
                    .overlay(
                        Capsule()
                            .stroke(GaiaColor.blackishGrey200, lineWidth: 0.5)
                    )
                    .padding(12)

                Spacer(minLength: 0)

                VStack(alignment: .leading, spacing: GaiaSpacing.xs) {
                    Text(project.title)
                        .gaiaFont(.subheadSerif)
                        .foregroundStyle(GaiaColor.paperWhite50)
                        .lineLimit(1)

                    HStack(spacing: GaiaSpacing.xxs) {
                        GaiaIcon(kind: .observe(selected: true), size: 14, tint: GaiaColor.paperWhite50)
                            .frame(width: 14, height: 10)

                        Text(project.countLabel)
                            .font(.custom("Neue Haas Unica W1G", size: 10))
                            .foregroundStyle(GaiaColor.paperWhite50)
                    }
                }
                .padding(12)
            }
        }
        .frame(width: cardWidth, height: cardHeight)
        .clipShape(RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                .stroke(GaiaColor.blackishGrey200, lineWidth: 0.5)
        )
        .shadow(color: GaiaShadow.smallColor, radius: GaiaShadow.smallRadius, x: 0, y: GaiaShadow.smallYOffset)
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
                    .gaiaFont(.bodySerif)
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
}

private struct MayaProfileProject: Identifiable {
    let id: String
    let title: String
    let tag: String
    let countLabel: String
    let imageName: String
}

private struct MayaRecentFind: Identifiable {
    let id: String
    let title: String
    let imageName: String
}
