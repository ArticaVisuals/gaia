// figma: https://www.figma.com/design/4e4G3tnSR7AdPbf0jAYPP1/Gaia?node-id=793-16557
import SwiftUI

private struct ImpactGoal: Identifiable {
    let id: String
    let title: String
    let progressLabel: String
    let progress: CGFloat
    let accent: Color
    let titleColor: Color
    let pillStroke: Color
}

private struct ImpactMonthBar: Identifiable {
    let id: String
    let month: String
    let value: Int
    let fillRatio: CGFloat
}

private struct ImpactStatTile: Identifiable {
    let id: String
    let title: String
    let value: String
}

private struct ImpactMedal: Identifiable {
    let id: String
    let title: String
    let count: Int
    let icon: String
    let tint: Color
    let badgeImageName: String
}

private struct ImpactTreeSlice: Identifiable {
    let id: String
    let title: String
    let value: Double
    let color: Color
}

struct ProfileImpactTab: View {
    let profile: ProfileSummary

    @EnvironmentObject private var contentStore: ContentStore
    @State private var showsExpandedMap = false
    @State private var showsMedalsDetail = false
    @State private var showsBioCalendarDetail = false

    private let goals: [ImpactGoal] = [
        .init(
            id: "urban-fungi",
            title: "Urban Fungi\nChallenge",
            progressLabel: "2 of 5 finds",
            progress: 155 / 338,
            accent: GaiaColor.oliveGreen500,
            titleColor: GaiaColor.oliveGreen500,
            pillStroke: GaiaColor.oliveGreen500
        ),
        .init(
            id: "id-support",
            title: "ID Support Goal",
            progressLabel: "3 of 5 contributions",
            progress: 220 / 338,
            accent: GaiaColor.broccoliBrown500,
            titleColor: GaiaColor.broccoliBrown500,
            pillStroke: GaiaColor.broccoliBrown500
        )
    ]

    private let monthBars: [ImpactMonthBar] = [
        .init(id: "mar", month: "Mar", value: 23, fillRatio: 200 / 273),
        .init(id: "feb", month: "Feb", value: 19, fillRatio: 166 / 273),
        .init(id: "jan", month: "Jan", value: 15, fillRatio: 130 / 273),
        .init(id: "dec", month: "Dec", value: 22, fillRatio: 200 / 273),
        .init(id: "nov", month: "Nov", value: 28, fillRatio: 200 / 273),
        .init(id: "oct", month: "Oct", value: 20, fillRatio: 174 / 273)
    ]

    private let medals: [ImpactMedal] = [
        .init(
            id: "plant",
            title: "Plant",
            count: 12,
            icon: "leaf.fill",
            tint: GaiaColor.broccoliBrown400,
            badgeImageName: "gaia-profile-impact-medal-plant"
        ),
        .init(
            id: "mammal",
            title: "Mammal",
            count: 10,
            icon: "pawprint.fill",
            tint: GaiaColor.broccoliBrown400,
            badgeImageName: "gaia-profile-impact-medal-mammal"
        ),
        .init(
            id: "fungus",
            title: "Fungus",
            count: 4,
            icon: "tree.fill",
            tint: GaiaColor.broccoliBrown400,
            badgeImageName: "gaia-profile-impact-medal-fungus"
        ),
        .init(
            id: "insect",
            title: "Insect",
            count: 3,
            icon: "ladybug.fill",
            tint: GaiaColor.broccoliBrown400,
            badgeImageName: "gaia-profile-impact-medal-insect"
        ),
        .init(
            id: "reptile",
            title: "Reptile",
            count: 2,
            icon: "tortoise.fill",
            tint: GaiaColor.broccoliBrown400,
            badgeImageName: "gaia-profile-impact-medal-reptile"
        )
    ]

    private let calendarLevels: [Int] = [
        0, 2, 0, 0, 0, 4, 4, 0, 3, 0,
        0, 0, 4, 2, 4, 4, 0, 0, 0, 4,
        2, 0, 2, 0, 1, 1, 1, 3, 3, 0,
        2, 4, 2, 0, 1, 4, 1, 4, 3, 0,
        2, 3, 2, 0, 0, 4, 3, 0, 0, 0,
        2, 4, 0, 0, 0, 4, 4, 4, 0, 4
    ]

    private let treeSlices: [ImpactTreeSlice] = [
        .init(id: "mammal", title: "Mammal", value: 22, color: GaiaColor.vermillion500),
        .init(id: "insect", title: "Insect", value: 16, color: GaiaColor.indigoBlue500),
        .init(id: "reptile", title: "Reptile", value: 5, color: GaiaColor.siskin500),
        .init(id: "plant", title: "Plant", value: 20, color: GaiaColor.grassGreen500)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: GaiaSpacing.md) {
            VStack(alignment: .leading, spacing: GaiaSpacing.md) {
                levelProgressCard
                monthlySummaryCard
                statsSection
            }

            VStack(alignment: .leading, spacing: GaiaSpacing.md) {
                goalsSection
                bioCalendarCard
                treeOfLifeCard
                findMapSection
                medalsSection
            }
        }
        .padding(.horizontal, GaiaSpacing.md)
        .fullScreenCover(isPresented: $showsExpandedMap) {
            ImpactMapExpandedScreen(observations: contentStore.observations) {
                showsExpandedMap = false
            }
        }
        .fullScreenCover(isPresented: $showsMedalsDetail) {
            ProfileMedalsDetailScreen {
                showsMedalsDetail = false
            }
        }
        .fullScreenCover(isPresented: $showsBioCalendarDetail) {
            ProfileBioCalendarScreen {
                showsBioCalendarDetail = false
            }
        }
    }

    private var levelProgressCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("CURRENT LEVEL")
                        .gaiaFont(.caption2)
                        .foregroundStyle(GaiaColor.paperWhite200)

                    Text("3")
                        .font(.custom("NewSpirit-Medium", size: 48))
                        .tracking(-0.5)
                        .foregroundStyle(GaiaColor.paperWhite50)
                }

                Spacer(minLength: 0)

                VStack(alignment: .trailing, spacing: 6) {
                    Text("NEXT")
                        .gaiaFont(.caption2)
                        .foregroundStyle(GaiaColor.paperWhite200)

                    Text("4")
                        .gaiaFont(.title2Medium)
                        .foregroundStyle(GaiaColor.paperWhite200)
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                GeometryReader { proxy in
                    Capsule(style: .continuous)
                        .fill(GaiaColor.paperWhite50.opacity(0.28))
                        .overlay(alignment: .leading) {
                            Capsule(style: .continuous)
                                .fill(GaiaColor.paperWhite50)
                                .frame(width: proxy.size.width * 0.65)
                        }
                }
                .frame(height: 6)

                HStack(alignment: .center) {
                    Text("12 finds to level 4")
                        .gaiaFont(.caption2)
                        .foregroundStyle(GaiaColor.paperWhite200)

                    Spacer(minLength: 0)

                    Text("65% there")
                        .font(.custom("Neue Haas Unica W1G", size: 11))
                        .foregroundStyle(GaiaColor.paperWhite200)
                        .padding(.horizontal, 10)
                        .frame(height: 22)
                        .background(GaiaColor.paperWhite50.opacity(0.16), in: Capsule(style: .continuous))
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                .fill(GaiaColor.oliveGreen400)
                .overlay(
                    RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                        .stroke(GaiaColor.oliveGreen200, lineWidth: 0.5)
                )
                .shadow(color: GaiaShadow.mdColor, radius: GaiaShadow.mdRadius, x: 0, y: GaiaShadow.mdYOffset)
        )
    }

    private var monthlySummaryCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("MARCH 2026")
                .gaiaFont(.caption)
                .foregroundStyle(GaiaColor.broccoliBrown500)

            (
                Text("You discovered ")
                + Text("3 new species").foregroundStyle(GaiaColor.oliveGreen500)
                + Text(" and made ")
                + Text("4 contributions").foregroundStyle(GaiaColor.broccoliBrown500)
                + Text(" this month.")
            )
            .gaiaFont(.title2)
            .foregroundStyle(GaiaColor.inkBlack300)
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: GaiaRadius.card, style: .continuous)
                .fill(GaiaColor.paperWhite50)
                .overlay(
                    RoundedRectangle(cornerRadius: GaiaRadius.card, style: .continuous)
                        .stroke(GaiaColor.broccoliBrown200, lineWidth: 0.5)
                )
                .shadow(color: GaiaShadow.mdColor, radius: GaiaShadow.mdRadius, x: 0, y: GaiaShadow.mdYOffset)
        )
    }

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Stats")
                .gaiaFont(.subheadSerif)
                .foregroundStyle(GaiaColor.inkBlack300)

            HStack(spacing: 0) {
                ForEach(Array(impactStats.enumerated()), id: \.element.id) { index, stat in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(stat.title)
                            .gaiaFont(.caption2)
                            .foregroundStyle(GaiaColor.broccoliBrown500)

                        Text(stat.value)
                            .font(.custom("NewSpirit-Medium", size: 40))
                            .tracking(-0.5)
                            .foregroundStyle(GaiaColor.oliveGreen500)
                            .lineLimit(1)
                            .minimumScaleFactor(0.85)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)

                    if index < impactStats.count - 1 {
                        Rectangle()
                            .fill(GaiaColor.border)
                            .frame(width: 0.5, height: 52)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: GaiaRadius.card, style: .continuous)
                    .fill(GaiaColor.paperWhite50)
                    .overlay(
                        RoundedRectangle(cornerRadius: GaiaRadius.card, style: .continuous)
                            .stroke(GaiaColor.border, lineWidth: 0.5)
                    )
                    .shadow(color: GaiaShadow.mdColor, radius: GaiaShadow.mdRadius, x: 0, y: GaiaShadow.mdYOffset)
            )
        }
    }

    private var goalsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Goals")
                    .gaiaFont(.title2)
                    .foregroundStyle(GaiaColor.inkBlack300)
                Spacer(minLength: 0)
                Text("2 active")
                    .gaiaFont(.caption2)
                    .foregroundStyle(GaiaColor.inkBlack300)
            }

            VStack(spacing: 12) {
                ForEach(goals) { goal in
                    goalCard(goal)
                }
            }
        }
    }

    private func goalCard(_ goal: ImpactGoal) -> some View {
        GaiaDataCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: GaiaSpacing.sm) {
                    Text(goal.title)
                        .gaiaFont(.title3)
                        .foregroundStyle(goal.titleColor)
                        .lineLimit(2)
                        .minimumScaleFactor(0.9)

                    Spacer(minLength: 0)

                    Text(goal.progressLabel)
                        .gaiaFont(.caption)
                        .foregroundStyle(goal.pillStroke)
                        .padding(.horizontal, 10)
                        .frame(height: 24)
                        .overlay(
                            Capsule(style: .continuous)
                                .stroke(goal.pillStroke, lineWidth: 0.5)
                        )
                }

                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        Capsule(style: .continuous)
                            .fill(GaiaColor.blackishGrey50)
                        Capsule(style: .continuous)
                            .fill(goal.accent)
                            .frame(width: proxy.size.width * goal.progress)
                    }
                }
                .frame(height: 6)
            }
        }
    }

    private var bioCalendarCard: some View {
        Button {
            showsBioCalendarDetail = true
        } label: {
            profileSoftCard {
                VStack(alignment: .leading, spacing: 20) {
                    HStack(alignment: .bottom) {
                        Text("Bio Calendar")
                            .gaiaFont(.title2)
                            .foregroundStyle(GaiaColor.inkBlack300)
                        Spacer(minLength: 0)
                        Text("Last 60 days")
                            .gaiaFont(.caption2)
                            .foregroundStyle(GaiaColor.inkBlack300)
                    }

                    GeometryReader { proxy in
                        let spacing: CGFloat = 4
                        let side = (proxy.size.width - (spacing * 9)) / 10
                        let cellRadius: CGFloat = 3

                        LazyVGrid(
                            columns: Array(repeating: GridItem(.fixed(side), spacing: spacing), count: 10),
                            alignment: .leading,
                            spacing: spacing
                        ) {
                            ForEach(Array(calendarLevels.enumerated()), id: \.offset) { _, level in
                                RoundedRectangle(cornerRadius: cellRadius, style: .continuous)
                                    .fill(calendarColor(for: level))
                                    .frame(width: side, height: side)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: cellRadius, style: .continuous)
                                            .stroke(GaiaColor.border, lineWidth: 0.5)
                                    )
                            }
                        }
                    }
                    .frame(height: 206)

                    HStack {
                        Text("41 active days")
                            .gaiaFont(.caption2)
                            .foregroundStyle(GaiaColor.oliveGreen500)

                        Spacer(minLength: 0)

                        HStack(spacing: GaiaSpacing.sm) {
                            Text("1")
                                .gaiaFont(.caption)
                                .foregroundStyle(GaiaColor.inkBlack300)
                            HStack(spacing: 4) {
                                legendSwatch(level: 0)
                                legendSwatch(level: 1)
                                legendSwatch(level: 2)
                                legendSwatch(level: 4)
                            }
                            Text("4+")
                                .gaiaFont(.caption)
                                .foregroundStyle(GaiaColor.inkBlack300)
                        }
                    }
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var treeOfLifeCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .bottom) {
                Text("Tree of Life")
                    .gaiaFont(.title2)
                    .foregroundStyle(GaiaColor.inkBlack300)
                Spacer(minLength: 0)
                Text("4 kingdoms")
                    .gaiaFont(.caption2)
                    .foregroundStyle(GaiaColor.inkBlack300)
            }

            HStack(spacing: GaiaSpacing.xl) {
                treeOfLifeChart
                VStack(alignment: .leading, spacing: GaiaSpacing.sm) {
                    ForEach(treeSlices) { slice in
                        HStack(spacing: GaiaSpacing.xs + GaiaSpacing.xxs) {
                            RoundedRectangle(cornerRadius: GaiaRadius.sm, style: .continuous)
                                .fill(slice.color)
                                .frame(width: 14, height: 14)
                            Text(slice.title)
                                .gaiaFont(.caption2)
                                .foregroundStyle(GaiaColor.inkBlack300)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.horizontal, GaiaSpacing.xs)
        }
        .padding(.horizontal, GaiaSpacing.md)
        .padding(.top, GaiaSpacing.md)
        .padding(.bottom, GaiaSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: GaiaRadius.card, style: .continuous)
                .fill(GaiaColor.paperWhite50)
                .overlay(
                    RoundedRectangle(cornerRadius: GaiaRadius.card, style: .continuous)
                        .stroke(GaiaColor.broccoliBrown200, lineWidth: 0.5)
                )
                .shadow(color: GaiaShadow.smallColor, radius: GaiaShadow.smallRadius, x: 0, y: GaiaShadow.smallYOffset)
        )
    }

    private var treeOfLifeChart: some View {
        return ZStack {
            Image("gaia-profile-impact-tree-insect")
                .resizable()
                .renderingMode(.original)
                .scaledToFit()
                .frame(width: 108.11, height: 56.27)
                .rotationEffect(.degrees(-157.04))
                .position(x: 82.54, y: 46.99)

            Image("gaia-profile-impact-tree-mammal")
                .resizable()
                .renderingMode(.original)
                .scaledToFit()
                .frame(width: 59.23, height: 56.27)
                .position(x: 100.26, y: 101.91)

            Image("gaia-profile-impact-tree-reptile")
                .resizable()
                .renderingMode(.original)
                .scaledToFit()
                .frame(width: 76.01, height: 16.48)
                .rotationEffect(.degrees(72.95))
                .position(x: 28.21, y: 89.56)

            Image("gaia-profile-impact-tree-plant")
                .resizable()
                .renderingMode(.original)
                .scaledToFit()
                .frame(width: 20.49, height: 13.07)
                .rotationEffect(.degrees(47.98))
                .position(x: 58.97, y: 126.73)

            Circle()
                .fill(GaiaColor.surfaceCard)
                .frame(width: 74, height: 74)

                VStack(spacing: 0) {
                    Text("63")
                        .gaiaFont(.displayMedium)
                        .foregroundStyle(GaiaColor.inkBlack500)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                Text("species")
                    .gaiaFont(.caption)
                    .foregroundStyle(GaiaColor.inkBlack300)
                    .offset(y: -2)
            }
        }
        .frame(width: 147, height: 147)
        .clipped()
    }

    private var findMapSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Find Map")
                    .gaiaFont(.title2)
                    .foregroundStyle(GaiaColor.inkBlack300)
                Spacer(minLength: 0)
                Text(profileFindsLabel)
                    .gaiaFont(.caption2)
                    .foregroundStyle(GaiaColor.inkBlack300)
            }

            ZStack(alignment: .topTrailing) {
                GaiaAssetImage(name: "gaia-profile-impact-map-preview", contentMode: .fill)
                    .frame(height: 214)
                    .frame(maxWidth: .infinity)
                    .clipped()

                GlassCircleButton(size: 44, action: {
                    showsExpandedMap = true
                }) {
                    ProfileImpactExpandIcon()
                }
                .padding(GaiaSpacing.md)
            }
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                    .stroke(GaiaColor.border, lineWidth: 0.5)
            )
            .shadow(color: GaiaShadow.smallColor, radius: GaiaShadow.smallRadius, x: 0, y: GaiaShadow.smallYOffset)
        }
    }

    private var medalsSection: some View {
        VStack(alignment: .leading, spacing: GaiaSpacing.sm) {
            HStack {
                Text("Medals")
                    .gaiaFont(.title2)
                    .foregroundStyle(GaiaColor.inkBlack300)

                Spacer(minLength: 0)

                Button {
                    showsMedalsDetail = true
                } label: {
                    Text("View all")
                        .gaiaFont(.caption2)
                        .foregroundStyle(GaiaColor.inkBlack200)
                }
                .buttonStyle(.plain)
            }

            HStack(spacing: 0) {
                ForEach(Array(medals.enumerated()), id: \.element.id) { index, medal in
                    if index > 0 {
                        Spacer(minLength: 0)
                    }
                    medalBadge(medal)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    private func medalBadge(_ medal: ImpactMedal) -> some View {
        VStack(spacing: GaiaSpacing.xs) {
            ZStack(alignment: .bottomTrailing) {
                GaiaAssetImage(name: medal.badgeImageName, contentMode: .fit)
                    .frame(width: 59.81, height: 58.96)

                Text("\(medal.count)")
                    .gaiaFont(.micro)
                    .foregroundStyle(GaiaColor.paperWhite50)
                    .frame(width: 16.45, height: 16.45)
                    .background(Circle().fill(GaiaColor.oliveGreen500))
                    .overlay(
                        Circle()
                            .stroke(GaiaColor.paperWhite200, lineWidth: 2)
                    )
                    .offset(x: 2, y: 2)
            }
            .frame(width: 59.81, height: 58.96)

            Text(medal.title)
                .gaiaFont(.micro)
                .foregroundStyle(
                    medal.id == "plant"
                        ? GaiaColor.broccoliBrown500
                        : GaiaColor.broccoliBrown200
                )
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(width: 59.81)
    }

    private var monthToMonthCard: some View {
        profileSoftCard {
            VStack(alignment: .leading, spacing: GaiaSpacing.md) {
                Text("Month-to-Month")
                    .gaiaFont(.subheadSerif)
                    .foregroundStyle(GaiaColor.inkBlack300)

                VStack(spacing: GaiaSpacing.xs + GaiaSpacing.xxs) {
                    ForEach(monthBars) { bar in
                        HStack(spacing: 12) {
                            Text(bar.month)
                                .gaiaFont(.footnote)
                                .foregroundStyle(GaiaColor.inkBlack300)
                                .frame(width: 34, alignment: .leading)

                            GeometryReader { proxy in
                                ZStack(alignment: .leading) {
                                    Capsule(style: .continuous)
                                        .fill(GaiaColor.oliveGreen100)
                                    Capsule(style: .continuous)
                                        .fill(GaiaColor.oliveGreen400)
                                        .frame(width: proxy.size.width * bar.fillRatio)
                                }
                            }
                            .frame(height: 14)

                            Text("\(bar.value)")
                                .gaiaFont(.footnote)
                                .foregroundStyle(GaiaColor.inkBlack300)
                                .frame(width: 22, alignment: .trailing)
                        }
                        .frame(height: 20)
                    }
                }
            }
        }
    }

    private var streakCard: some View {
        profileSoftCard {
            VStack(alignment: .leading, spacing: GaiaSpacing.md) {
                VStack(alignment: .leading, spacing: GaiaSpacing.sm) {
                    HStack(alignment: .firstTextBaseline) {
                        Text("Current Streak")
                            .gaiaFont(.subheadline)
                            .foregroundStyle(GaiaColor.inkBlack300)
                        Spacer(minLength: 0)
                        Text("4 days")
                            .gaiaFont(.title2Medium)
                            .foregroundStyle(GaiaColor.oliveGreen500)
                    }

                    HStack(alignment: .firstTextBaseline) {
                        Text("Longest Streak")
                            .gaiaFont(.subheadline)
                            .foregroundStyle(GaiaColor.inkBlack300)
                        Spacer(minLength: 0)
                        Text("12 days")
                            .gaiaFont(.subheadSerif)
                            .foregroundStyle(GaiaColor.blackishGrey300)
                    }
                }

                Text("▲ 18% more active than last month")
                    .gaiaFont(.footnoteMedium)
                    .foregroundStyle(GaiaColor.oliveGreen500)
            }
        }
    }

    private var patternInsightCard: some View {
        profileSoftCard {
            VStack(alignment: .leading, spacing: GaiaSpacing.sm) {
                Text("PATTERN INSIGHT")
                    .gaiaFont(.captionMedium)
                    .foregroundStyle(GaiaColor.oliveGreen500)

                Text("You observe most on Saturdays and Sundays, usually between 8–11am. Your most productive month was November with 28 finds.")
                    .gaiaFont(.footnote)
                    .foregroundStyle(GaiaColor.inkBlack500)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var profileFindsLabel: String {
        let parts = profile.impactSummary.split(separator: " ")
        if parts.count >= 2, Int(parts[0]) != nil {
            return "\(parts[0]) \(parts[1])"
        }
        return "127 finds"
    }

    private var impactStats: [ImpactStatTile] {
        [
            .init(id: "species", title: "Species", value: "63"),
            .init(id: "ids-labeled", title: "IDs Labeled", value: "23"),
            .init(id: "projects", title: "Projects", value: "4")
        ]
    }

    private func legendSwatch(level: Int) -> some View {
        RoundedRectangle(cornerRadius: GaiaRadius.sm, style: .continuous)
            .fill(calendarColor(for: level))
            .frame(width: 15, height: 15)
            .overlay(
                RoundedRectangle(cornerRadius: GaiaRadius.sm, style: .continuous)
                    .stroke(GaiaColor.paperWhite600, lineWidth: 0.25)
            )
    }

    private func calendarColor(for level: Int) -> Color {
        switch level {
        case 4:
            return GaiaColor.oliveGreen500
        case 3:
            return GaiaColor.oliveGreen300
        case 2:
            return GaiaColor.oliveGreen200
        case 1:
            return GaiaColor.oliveGreen100
        default:
            return GaiaColor.oliveGreen50
        }
    }

    @ViewBuilder
    private func profileSoftCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(.horizontal, GaiaSpacing.md)
            .padding(.vertical, GaiaSpacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: GaiaRadius.card, style: .continuous)
                    .fill(GaiaColor.paperWhite50)
                    .overlay(
                    RoundedRectangle(cornerRadius: GaiaRadius.card, style: .continuous)
                        .stroke(GaiaColor.border, lineWidth: 0.5)
                    )
                    .shadow(color: GaiaShadow.smColor, radius: GaiaShadow.smRadius, x: 0, y: GaiaShadow.smYOffset)
            )
    }
}

private struct ProfileImpactExpandIcon: View {
    var body: some View {
        GeometryReader { proxy in
            let canvas = min(proxy.size.width, proxy.size.height)
            let slot = canvas * (1 - 0.3674)
            let arrowWidth = canvas * (20.359 / 24)
            let arrowHeight = canvas * (21.148 / 24)

            ZStack {
                Image("gaia-profile-impact-expand-a-24")
                    .resizable()
                    .renderingMode(.original)
                    .scaledToFit()
                    .frame(width: arrowWidth, height: arrowHeight)
                    .rotationEffect(.degrees(-135))
                    .frame(width: slot, height: slot)
                    .position(x: slot * 0.5, y: canvas - (slot * 0.5))

                Image("gaia-profile-impact-expand-b-24")
                    .resizable()
                    .renderingMode(.original)
                    .scaledToFit()
                    .frame(width: arrowWidth, height: arrowHeight)
                    .rotationEffect(.degrees(45))
                    .frame(width: slot, height: slot)
                    .position(x: canvas - (slot * 0.5), y: slot * 0.5)
            }
            .frame(width: canvas, height: canvas)
        }
        .frame(width: 24, height: 24)
        .accessibilityHidden(true)
    }
}

private struct ProfileMedalsDetailScreen: View {
    let onClose: () -> Void

    private let categoryBadges: [CategoryMedalBadge] = [
        .init(id: "fungus", title: "Fungus", findsText: "10 finds", imageName: "gaia-profile-medal-category-fungus"),
        .init(id: "fish", title: "Fish", findsText: "10 finds", imageName: "gaia-profile-medal-category-fish"),
        .init(id: "insect", title: "Insect", findsText: "10 finds", imageName: "gaia-profile-medal-category-insect"),
        .init(id: "mammal", title: "Mammal", findsText: "10 finds", imageName: "gaia-profile-medal-category-mammal"),
        .init(id: "mollusk", title: "Mollusk", findsText: "10 finds", imageName: "gaia-profile-medal-category-mollusk"),
        .init(id: "plant", title: "Plant", findsText: "10 finds", imageName: "gaia-profile-medal-category-plant"),
        .init(id: "bird", title: "Bird", findsText: "10 finds", imageName: "gaia-profile-medal-category-bird"),
        .init(id: "reptile", title: "Reptile", findsText: "10 finds", imageName: "gaia-profile-medal-category-reptile"),
        .init(id: "amphibian", title: "Amphibian", findsText: "10 finds", imageName: "gaia-profile-medal-category-amphibian")
    ]

    private let regionalBadges: [RegionalMedalBadge] = [
        .init(id: "alpine-observer", title: "Alpine\nObserver", isEarned: true),
        .init(id: "night-watcher", title: "Night\nWatcher", isEarned: true),
        .init(id: "coastal-sentinel-earned", title: "Coastal\nSentinel", isEarned: true),
        .init(id: "coastal-sentinel-locked-a", title: "Coastal\nSentinel", isEarned: false),
        .init(id: "coastal-sentinel-locked-b", title: "Coastal\nSentinel", isEarned: false),
        .init(id: "coastal-sentinel-locked-c", title: "Coastal\nSentinel", isEarned: false)
    ]

    private let badgeColumns: [GridItem] = Array(
        repeating: GridItem(.fixed(118), spacing: GaiaSpacing.sm),
        count: 3
    )

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: GaiaSpacing.lg) {
                recentlyEarnedCard
                medalSection(title: "Category") {
                    LazyVGrid(columns: badgeColumns, alignment: .leading, spacing: GaiaSpacing.sm) {
                        ForEach(categoryBadges) { badge in
                            categoryBadgeCard(badge)
                        }
                    }
                }
                medalSection(title: "Regional") {
                    LazyVGrid(columns: badgeColumns, alignment: .leading, spacing: GaiaSpacing.sm) {
                        ForEach(regionalBadges) { badge in
                            regionalBadgeCard(badge)
                        }
                    }
                }
            }
            .padding(.horizontal, GaiaSpacing.md)
            .padding(.top, GaiaSpacing.lg)
            .padding(.bottom, 48)
        }
        .background(GaiaColor.paperWhite50.ignoresSafeArea())
        .safeAreaInset(edge: .top, spacing: 0) {
            VStack(spacing: 0) {
                HStack(alignment: .center) {
                    ToolbarGlassButton(icon: .back, accessibilityLabel: "Back") {
                        onClose()
                    }

                    Spacer(minLength: 0)

                    Text("Medals")
                        .gaiaFont(.title1Medium)
                        .foregroundStyle(GaiaColor.oliveGreen500)

                    Spacer(minLength: 0)

                    Color.clear
                        .frame(width: 48, height: 48)
                }
                .padding(.horizontal, GaiaSpacing.md)
                .padding(.top, 8)
                .padding(.bottom, GaiaSpacing.md)

                Text("8 earned")
                    .gaiaFont(.subheadSerif)
                    .foregroundStyle(GaiaColor.blackishGrey500)
                    .padding(.bottom, GaiaSpacing.md)
            }
            .frame(maxWidth: .infinity)
            .background(GaiaColor.paperWhite50)
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(GaiaColor.broccoliBrown200)
                    .frame(height: 0.5)
            }
            .shadow(color: GaiaShadow.mdColor, radius: GaiaShadow.mdRadius, x: 0, y: GaiaShadow.mdYOffset)
        }
    }

    private var recentlyEarnedCard: some View {
        HStack(spacing: GaiaSpacing.md) {
            Image("gaia-profile-medal-featured-circle")
                .resizable()
                .renderingMode(.original)
                .scaledToFit()
                .frame(width: 64, height: 64)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: GaiaSpacing.sm) {
                Text("RECENTLY EARNED")
                    .gaiaFont(.caption)
                    .foregroundStyle(GaiaColor.oliveGreen200)

                VStack(alignment: .leading, spacing: GaiaSpacing.xs) {
                    Text("Mammal Scout")
                        .gaiaFont(.title1Medium)
                        .foregroundStyle(GaiaColor.paperWhite50)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)

                    VStack(alignment: .leading, spacing: GaiaSpacing.sm) {
                        Text("Earned March 22, 2026")
                            .gaiaFont(.caption)
                            .foregroundStyle(GaiaColor.textInverseSecondary)

                        Text("Logged 10+ mammal species in your region")
                            .gaiaFont(.caption)
                            .foregroundStyle(GaiaColor.textInverseSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .padding(GaiaSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                .fill(GaiaColor.oliveGreen500)
                .shadow(color: GaiaShadow.smallColor, radius: GaiaShadow.smallRadius, x: 0, y: GaiaShadow.smallYOffset)
        )
    }

    @ViewBuilder
    private func medalSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: GaiaSpacing.md) {
            Text(title)
                .gaiaFont(.title2)
                .foregroundStyle(GaiaColor.inkBlack300)

            content()
        }
    }

    private func categoryBadgeCard(_ badge: CategoryMedalBadge) -> some View {
        badgeCardContainer {
            VStack(spacing: GaiaSpacing.xs) {
                Image(badge.imageName)
                    .resizable()
                    .renderingMode(.original)
                    .scaledToFit()
                    .frame(width: 82.98, height: 82.98)
                    .accessibilityHidden(true)

                Text(badge.title)
                    .gaiaFont(.bodySerif)
                    .foregroundStyle(GaiaColor.broccoliBrown500)
                    .multilineTextAlignment(.center)

                Text(badge.findsText)
                    .gaiaFont(.caption)
                    .foregroundStyle(GaiaColor.blackishGrey200)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private func regionalBadgeCard(_ badge: RegionalMedalBadge) -> some View {
        badgeCardContainer {
            VStack(spacing: GaiaSpacing.xs) {
                if badge.isEarned {
                    Circle()
                        .stroke(GaiaColor.broccoliBrown500, lineWidth: 5)
                        .frame(width: 83, height: 83)
                } else {
                    Circle()
                        .fill(GaiaColor.blackishGrey200)
                        .frame(width: 83, height: 83)
                }

                Text(badge.title)
                    .gaiaFont(.bodySerif)
                    .foregroundStyle(
                        badge.isEarned
                            ? GaiaColor.broccoliBrown500
                            : GaiaColor.blackishGrey200
                    )
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private func badgeCardContainer<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(.horizontal, GaiaSpacing.md)
            .padding(.vertical, GaiaSpacing.md)
            .frame(width: 118, alignment: .center)
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
}

struct ProfileBioCalendarScreen: View {
    let onClose: () -> Void

    @State private var selectedFilter: BioCalendarFilter = .all

    private let monthBars: [ImpactMonthBar] = [
        .init(id: "mar", month: "Mar", value: 23, fillRatio: 200 / 273),
        .init(id: "feb", month: "Feb", value: 19, fillRatio: 166 / 273),
        .init(id: "jan", month: "Jan", value: 15, fillRatio: 130 / 273),
        .init(id: "dec", month: "Dec", value: 22, fillRatio: 200 / 273),
        .init(id: "nov", month: "Nov", value: 28, fillRatio: 200 / 273),
        .init(id: "oct", month: "Oct", value: 20, fillRatio: 174 / 273)
    ]

    private let calendarWeeks: [[BioCalendarDay?]] = [
        [nil, nil, nil, nil, nil, nil, .init(day: 1, dots: 2)],
        [
            .init(day: 2, dots: 2),
            .init(day: 3, dots: 1),
            .init(day: 4, dots: 0),
            .init(day: 5, dots: 0),
            .init(day: 6, dots: 1),
            .init(day: 7, dots: 2),
            .init(day: 8, dots: 2)
        ],
        [
            .init(day: 9, dots: 0),
            .init(day: 10, dots: 0),
            .init(day: 11, dots: 0),
            .init(day: 12, dots: 2),
            .init(day: 13, dots: 0),
            .init(day: 14, dots: 1),
            .init(day: 15, dots: 2)
        ],
        [
            .init(day: 16, dots: 0),
            .init(day: 17, dots: 0),
            .init(day: 18, dots: 0),
            .init(day: 19, dots: 0),
            .init(day: 20, dots: 0),
            .init(day: 21, dots: 2),
            .init(day: 22, dots: 2)
        ],
        [
            .init(day: 23, dots: 0),
            .init(day: 24, dots: 0),
            .init(day: 25, dots: 0),
            .init(day: 26, dots: 0),
            .init(day: 27, dots: 0),
            .init(day: 28, dots: 1),
            .init(day: 29, dots: 2)
        ],
        [
            .init(day: 30, dots: 0),
            .init(day: 31, dots: 0),
            nil, nil, nil, nil, nil
        ]
    ]

    private let weekDayLabels: [String] = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    private let cellSize: CGFloat = 44.194
    private let cellSpacing: CGFloat = 4

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: GaiaSpacing.md) {
                statsDetailsCard
                calendarCard
                monthToMonthCard
                streakCard
                monthlySummaryDetailCard
            }
            .padding(.horizontal, GaiaSpacing.md)
            .padding(.top, GaiaSpacing.lg)
            .padding(.bottom, 56)
        }
        .background(GaiaColor.paperWhite50.ignoresSafeArea())
        .safeAreaInset(edge: .top, spacing: 0) {
            VStack(spacing: GaiaSpacing.md) {
                HStack(alignment: .center) {
                    ToolbarGlassButton(icon: .back, accessibilityLabel: "Back", action: onClose)

                    Spacer(minLength: 0)

                    Text("Bio Calendar")
                        .gaiaFont(.title1Medium)
                        .foregroundStyle(GaiaColor.oliveGreen500)

                    Spacer(minLength: 0)

                    Color.clear
                        .frame(width: 48, height: 48)
                }

                HStack(spacing: GaiaSpacing.sm) {
                    ForEach(BioCalendarFilter.allCases) { filter in
                        Button {
                            selectedFilter = filter
                        } label: {
                            Text(filter.rawValue)
                                .gaiaFont(.footnote)
                                .foregroundStyle(
                                    selectedFilter == filter
                                        ? GaiaColor.paperWhite50
                                        : GaiaColor.inkBlack300
                                )
                                .padding(.horizontal, 10)
                                .frame(height: 28)
                                .background(
                                    Capsule(style: .continuous)
                                        .fill(
                                            selectedFilter == filter
                                                ? GaiaColor.oliveGreen500
                                                : GaiaColor.blackishGrey200.opacity(0.20)
                                        )
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, GaiaSpacing.md)
            .padding(.top, 8)
            .padding(.bottom, GaiaSpacing.lg)
            .frame(maxWidth: .infinity)
            .background(GaiaColor.paperWhite50)
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(GaiaColor.border)
                    .frame(height: 0.5)
            }
            .shadow(color: GaiaShadow.mdColor.opacity(0.9), radius: 20, x: 0, y: 4)
        }
    }

    private var statsDetailsCard: some View {
        HStack(alignment: .center) {
            detailMetric(title: "Finds", value: "159")

            verticalDivider

            detailMetric(title: "Active days", value: "41")

            verticalDivider

            detailMetric(title: "Projects", value: "4")
        }
        .padding(.horizontal, GaiaSpacing.md)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: GaiaRadius.lg, style: .continuous)
                .fill(GaiaColor.paperWhite50)
                .overlay(
                    RoundedRectangle(cornerRadius: GaiaRadius.lg, style: .continuous)
                        .stroke(GaiaColor.border, lineWidth: 0.5)
                )
        )
    }

    private var calendarCard: some View {
        VStack(alignment: .leading, spacing: GaiaSpacing.lg) {
            HStack {
                Text("May 2026")
                    .gaiaFont(.titleSans)
                    .foregroundStyle(GaiaColor.inkBlack300)

                Spacer(minLength: 0)

                HStack(spacing: GaiaSpacing.sm) {
                    monthArrowButton(rotation: .degrees(180))
                    monthArrowButton(rotation: .degrees(0))
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: cellSpacing) {
                    ForEach(weekDayLabels, id: \.self) { label in
                        Text(label)
                            .gaiaFont(.caption2)
                            .foregroundStyle(GaiaColor.inkBlack300)
                            .frame(width: cellSize, height: 16)
                    }
                }

                Rectangle()
                    .fill(GaiaColor.border)
                    .frame(height: 0.5)

                VStack(spacing: cellSpacing) {
                    ForEach(Array(calendarWeeks.enumerated()), id: \.offset) { _, week in
                        HStack(spacing: cellSpacing) {
                            ForEach(Array(week.enumerated()), id: \.offset) { _, day in
                                calendarDayCell(day)
                            }
                        }
                    }
                }
            }
        }
        .padding(.horizontal, GaiaSpacing.md)
        .padding(.vertical, GaiaSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: GaiaRadius.lg, style: .continuous)
                .fill(GaiaColor.paperWhite50)
                .overlay(
                    RoundedRectangle(cornerRadius: GaiaRadius.lg, style: .continuous)
                        .stroke(GaiaColor.border, lineWidth: 0.5)
                )
        )
    }

    private var monthToMonthCard: some View {
        softAnalyticsCard {
            VStack(alignment: .leading, spacing: GaiaSpacing.md) {
                Text("Monthly Breakdown")
                    .gaiaFont(.titleSans)
                    .foregroundStyle(GaiaColor.inkBlack300)

                VStack(spacing: GaiaSpacing.xs + GaiaSpacing.xxs) {
                    ForEach(monthBars) { bar in
                        HStack(spacing: 12) {
                            Text(bar.month)
                                .gaiaFont(.footnote)
                                .foregroundStyle(GaiaColor.inkBlack300)
                                .frame(width: 34, alignment: .leading)

                            GeometryReader { proxy in
                                ZStack(alignment: .leading) {
                                    Capsule(style: .continuous)
                                        .fill(GaiaColor.oliveGreen100)
                                    Capsule(style: .continuous)
                                        .fill(GaiaColor.oliveGreen400)
                                        .frame(width: proxy.size.width * bar.fillRatio)
                                }
                            }
                            .frame(height: 14)

                            Text("\(bar.value)")
                                .gaiaFont(.footnote)
                                .foregroundStyle(GaiaColor.inkBlack300)
                                .frame(width: 22, alignment: .trailing)
                        }
                        .frame(height: 20)
                    }
                }
            }
        }
    }

    private var streakCard: some View {
        softAnalyticsCard {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .firstTextBaseline) {
                        Text("Current Streak")
                            .gaiaFont(.titleSans)
                            .foregroundStyle(GaiaColor.inkBlack300)

                        Spacer(minLength: 0)

                        Text("4 days")
                            .gaiaFont(.displayMedium)
                            .foregroundStyle(GaiaColor.oliveGreen500)
                    }

                    HStack(alignment: .firstTextBaseline) {
                        Text("Longest Streak")
                            .gaiaFont(.subheadline)
                            .foregroundStyle(GaiaColor.inkBlack300)

                        Spacer(minLength: 0)

                        Text("12 days")
                            .gaiaFont(.titleSans)
                            .foregroundStyle(GaiaColor.oliveGreen500)
                    }
                }

                Text("18% more active than last month")
                    .gaiaFont(.caption2)
                    .foregroundStyle(GaiaColor.oliveGreen500)
            }
        }
    }

    private var monthlySummaryDetailCard: some View {
        softAnalyticsCard {
            VStack(alignment: .leading, spacing: 10) {
                Text("Monthly Summary")
                    .gaiaFont(.titleSans)
                    .foregroundStyle(GaiaColor.inkBlack300)

                (
                    Text("You logged ")
                    + Text("159 finds").foregroundStyle(GaiaColor.oliveGreen500)
                    + Text(" across ")
                    + Text("41 active days").foregroundStyle(GaiaColor.broccoliBrown500)
                    + Text(" in ")
                    + Text("4 projects").foregroundStyle(GaiaColor.oliveGreen500)
                    + Text(" this month.")
                )
                .gaiaFont(.title2)
                .foregroundStyle(GaiaColor.inkBlack300)
                .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func detailMetric(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: GaiaSpacing.sm) {
            Text(title)
                .gaiaFont(.caption2)
                .foregroundStyle(GaiaColor.blackishGrey200)

            Text(value)
                .gaiaFont(.displayMedium)
                .foregroundStyle(GaiaColor.oliveGreen500)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var verticalDivider: some View {
        Rectangle()
            .fill(GaiaColor.border)
            .frame(width: 1, height: 56)
    }

    private func monthArrowButton(rotation: Angle) -> some View {
        Button(action: {}) {
            Image("gaia-icon-chevron-20")
                .resizable()
                .renderingMode(.template)
                .scaledToFit()
                .foregroundStyle(GaiaColor.inkBlack300)
                .frame(width: 20, height: 20)
                .rotationEffect(rotation)
                .frame(width: 28, height: 28)
                .background(
                    Circle()
                        .fill(GaiaColor.paperWhite50)
                )
                .overlay(
                    Circle()
                        .stroke(GaiaColor.border, lineWidth: 0.5)
                )
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func calendarDayCell(_ day: BioCalendarDay?) -> some View {
        if let day {
            VStack(spacing: 2) {
                Text("\(day.day)")
                    .gaiaFont(.titleSans)
                    .foregroundStyle(day.dots > 0 ? GaiaColor.oliveGreen400 : GaiaColor.blackishGrey200)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                HStack(spacing: 2) {
                    ForEach(0..<day.dots, id: \.self) { _ in
                        Circle()
                            .fill(GaiaColor.oliveGreen400)
                            .frame(width: 4, height: 4)
                    }
                }
                .frame(height: 4)
            }
            .frame(width: cellSize, height: cellSize)
        } else {
            Color.clear
                .frame(width: cellSize, height: cellSize)
        }
    }

    @ViewBuilder
    private func softAnalyticsCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(.horizontal, GaiaSpacing.md)
            .padding(.vertical, GaiaSpacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: GaiaRadius.lg, style: .continuous)
                    .fill(GaiaColor.paperWhite50)
                    .overlay(
                        RoundedRectangle(cornerRadius: GaiaRadius.lg, style: .continuous)
                            .stroke(GaiaColor.border, lineWidth: 0.5)
                    )
            )
    }
}

private enum BioCalendarFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case mutuals = "Mutuals"
    case following = "Following"

    var id: String { rawValue }
}

private struct BioCalendarDay {
    let day: Int
    let dots: Int
}

private struct CategoryMedalBadge: Identifiable {
    let id: String
    let title: String
    let findsText: String
    let imageName: String
}

private struct RegionalMedalBadge: Identifiable {
    let id: String
    let title: String
    let isEarned: Bool
}
