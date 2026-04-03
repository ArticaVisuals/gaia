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

struct ProfileCommunityTab: View {
    let posts: [CommunityPost]

    init(posts: [CommunityPost] = []) {
        self.posts = posts
    }

    @EnvironmentObject private var appState: AppState
    @State private var showsPeopleScreen = false

    private let projects: [ProjectSelection] = [
        .init(
            id: "project-creek-1",
            title: "Creek Recovery",
            tag: "Wetland",
            countLabel: "12",
            imageName: "find-project-creek"
        ),
        .init(
            id: "project-creek-2",
            title: "Creek Recovery",
            tag: "Wetland",
            countLabel: "12",
            imageName: "find-project-creek"
        )
    ]

    private let people: [ProfileCommunityPerson] = [
        .init(
            id: "maya-chen",
            name: "Maya Chen",
            subtitle: "Pollinator Corridor (Member)",
            avatarImageName: "find-avatar-alice",
            group: .following,
            followState: .following
        ),
        .init(
            id: "rafael-gomez",
            name: "Rafael Gomez",
            subtitle: "Creek Recovery: (Project Lead)",
            avatarImageName: "find-avatar-alice",
            group: .suggested,
            followState: .follow
        ),
        .init(
            id: "noah-patel",
            name: "Noah Patel",
            subtitle: "Mutual",
            avatarImageName: "find-avatar-alice",
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

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            summarySection
            projectsSection
            peopleSection
            highlightsSection
        }
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
        .padding(.horizontal, GaiaSpacing.md)
        .padding(.top, 20)
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: GaiaSpacing.lg) {
            VStack(alignment: .leading, spacing: GaiaSpacing.sm) {
                Text("IDs confirmed")
                    .font(GaiaTypography.subheadline)
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
                .font(GaiaTypography.footnote)
                .foregroundStyle(GaiaColor.textSecondary)
                .tracking(-0.08)
                .fixedSize(horizontal: true, vertical: false)

            Text(metric.value)
                .font(GaiaTypography.title1Medium)
                .foregroundStyle(GaiaColor.broccoliBrown500)
                .tracking(-0.3)
                .lineLimit(1)
        }
    }

    private var projectsSection: some View {
        VStack(alignment: .leading, spacing: GaiaSpacing.sm) {
            sectionHeader(title: "Projects", actionTitle: "See all")

            HStack(spacing: GaiaSpacing.sm) {
                ForEach(projects, id: \.id) { project in
                    Button {
                        appState.openProjectDetail(project)
                    } label: {
                        projectCard(project)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.horizontal, GaiaSpacing.md)
        .padding(.top, GaiaSpacing.lg)
    }

    private func projectCard(_ project: ProjectSelection) -> some View {
        ZStack(alignment: .topLeading) {
            GaiaAssetImage(name: project.imageName, contentMode: .fill)
                .frame(width: 181, height: 133)
                .blur(radius: 1.4)
                .overlay {
                    LinearGradient(
                        stops: [
                            .init(color: Color(red: 70 / 255, green: 76 / 255, blue: 19 / 255, opacity: 0), location: 0.417),
                            .init(color: Color(red: 41 / 255, green: 76 / 255, blue: 19 / 255, opacity: 0.85), location: 1)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }

            VStack(alignment: .leading, spacing: 0) {
                Text(project.tag)
                    .font(GaiaTypography.caption)
                    .foregroundStyle(GaiaColor.paperWhite50)
                    .tracking(0.25)
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
                        .font(GaiaTypography.subheadSerif)
                        .foregroundStyle(GaiaColor.paperWhite50)
                        .lineLimit(1)

                    HStack(spacing: GaiaSpacing.xxs) {
                        GaiaIcon(kind: .observe(selected: true), size: 14, tint: GaiaColor.paperWhite50)
                            .frame(width: 14, height: 10)

                        Text(project.countLabel)
                            .font(.custom("Neue Haas Unica W1G", size: 10))
                            .foregroundStyle(GaiaColor.paperWhite50)
                            .tracking(0.25)
                    }
                }
                .padding(12)
            }
        }
        .frame(width: 181, height: 133)
        .clipShape(RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                .stroke(GaiaColor.blackishGrey200, lineWidth: 0.5)
        )
        .shadow(color: GaiaShadow.darkColor, radius: GaiaShadow.smallRadius, x: 0, y: GaiaShadow.smallYOffset)
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
        .padding(.horizontal, GaiaSpacing.md)
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
        .padding(.horizontal, GaiaSpacing.md)
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
                    .font(GaiaTypography.subheadlineMedium)
                    .foregroundStyle(GaiaColor.inkBlack500)
                    .fixedSize(horizontal: false, vertical: true)

                Text(highlight.subtitle)
                    .font(GaiaTypography.footnote)
                    .foregroundStyle(GaiaColor.inkBlack300)
                    .tracking(-0.08)
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
                .font(GaiaTypography.title2)
                .foregroundStyle(GaiaColor.inkBlack300)

            Spacer(minLength: 0)

            if let actionTitle {
                if let action {
                    Button(action: action) {
                        Text(actionTitle)
                            .font(GaiaTypography.caption2)
                            .foregroundStyle(GaiaColor.inkBlack300)
                    }
                    .buttonStyle(.plain)
                } else {
                    Text(actionTitle)
                        .font(GaiaTypography.caption2)
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
                    .font(GaiaTypography.subheadSerif)
                    .foregroundStyle(GaiaColor.inkBlack500)

                Text(person.subtitle)
                    .font(GaiaTypography.footnote)
                    .foregroundStyle(GaiaColor.oliveGreen500)
                    .tracking(-0.08)
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
                .font(GaiaTypography.subheadline)
                .foregroundStyle(GaiaColor.oliveGreen500)
                .padding(.horizontal, 10)
                .frame(height: 28)
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(GaiaColor.oliveGreen500, lineWidth: 1)
                )
        case .follow:
            Text("Follow")
                .font(GaiaTypography.footnote)
                .foregroundStyle(GaiaColor.paperWhite50)
                .padding(.horizontal, 10)
                .frame(height: 28)
                .background(GaiaColor.oliveGreen500, in: Capsule())
        case .mutual:
            Text("Mutual")
                .font(GaiaTypography.footnote)
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
    @FocusState private var isSearchFieldFocused: Bool

    var body: some View {
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
        .background(GaiaColor.surfacePrimary.ignoresSafeArea())
        .safeAreaInset(edge: .top, spacing: 0) {
            topChrome
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
                    .font(GaiaTypography.title1Medium)
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
            .font(GaiaTypography.subheadline)
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
                            .font(GaiaTypography.footnote)
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
                .font(GaiaTypography.caption2)
                .foregroundStyle(GaiaColor.textSecondary)
                .padding(.top, GaiaSpacing.md)
                .padding(.bottom, GaiaSpacing.xs)

            ForEach(people) { person in
                ProfileCommunityPersonRow(person: person) {
                    toggleFollow(for: person.id)
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
