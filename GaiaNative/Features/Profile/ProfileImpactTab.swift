// figma: https://www.figma.com/design/4e4G3tnSR7AdPbf0jAYPP1/Gaia?node-id=1711-181330 (Profile Impact), 1711-182099 (Bio Calendar Full View), 1711-187857 (Profile Medals)
import SwiftUI

private struct ImpactGoal: Identifiable {
    let id: String
    let title: String
    let progressLabel: String
    let progress: CGFloat
    let accent: Color
    let trackColor: Color
    let titleColor: Color
    let pillFill: Color
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
    let badgeImageName: String
    let isEarned: Bool

    var titleColor: Color {
        isEarned ? GaiaColor.broccoliBrown400 : GaiaColor.blackishGrey200
    }

    var countFillColor: Color {
        isEarned ? GaiaColor.oliveGreen500 : GaiaColor.blackishGrey200
    }
}

private struct ImpactTreeRow: Identifiable {
    let id: String
    let title: String
    let count: Int
    let progress: CGFloat
    let titleWidth: CGFloat
}

struct ProfileImpactTab: View {
    let profile: ProfileSummary

    @EnvironmentObject private var contentStore: ContentStore
    @State private var showsExpandedMap = false
    @State private var showsMedalsDetail = false
    @State private var showsBioCalendarDetail = false

    private let warmCardShadow = Color(red: 128.0 / 255.0, green: 105.0 / 255.0, blue: 38.0 / 255.0).opacity(0.09)

    private let goals: [ImpactGoal] = [
        .init(
            id: "urban-fungi",
            title: "Urban Fungi Challenge",
            progressLabel: "2 of 5 finds",
            progress: 155.0 / 338.0,
            accent: GaiaColor.oliveGreen400,
            trackColor: GaiaColor.oliveGreen100,
            titleColor: GaiaColor.oliveGreen400,
            pillFill: GaiaColor.oliveGreen100,
            pillStroke: GaiaColor.borderStrong
        ),
        .init(
            id: "friendly-helper",
            title: "Friendly Helper",
            progressLabel: "2 of 5 finds",
            progress: 155.0 / 338.0,
            accent: GaiaColor.broccoliBrown400,
            trackColor: GaiaColor.broccoliBrown100,
            titleColor: GaiaColor.broccoliBrown400,
            pillFill: GaiaColor.broccoliBrown100,
            pillStroke: GaiaColor.broccoliBrown200
        )
    ]

    private let treeRows: [ImpactTreeRow] = [
        .init(id: "plants", title: "Plants", count: 28, progress: 99.333 / 123.495, titleWidth: 89.45),
        .init(id: "birds", title: "Birds", count: 15, progress: 76.96 / 123.495, titleWidth: 89.45),
        .init(id: "insects", title: "Insects", count: 12, progress: 58.168 / 123.495, titleWidth: 89.45),
        .init(id: "mammals", title: "Mammals", count: 5, progress: 40.27 / 123.495, titleWidth: 93.339),
        .init(id: "fungi", title: "Fungi", count: 3, progress: 27.742 / 123.495, titleWidth: 89.45)
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
            badgeImageName: "gaia-profile-impact-medal-plant",
            isEarned: true
        ),
        .init(
            id: "mammal",
            title: "Mammal",
            count: 10,
            badgeImageName: "gaia-profile-impact-medal-mammal",
            isEarned: true
        ),
        .init(
            id: "fungus",
            title: "Fungi",
            count: 4,
            badgeImageName: "gaia-profile-impact-medal-fungus",
            isEarned: true
        ),
        .init(
            id: "insect",
            title: "Insect",
            count: 3,
            badgeImageName: "gaia-profile-impact-medal-insect",
            isEarned: true
        ),
        .init(
            id: "reptile",
            title: "Reptile",
            count: 2,
            badgeImageName: "gaia-profile-impact-medal-reptile",
            isEarned: false
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


    var body: some View {
        VStack(alignment: .leading, spacing: GaiaSpacing.lg) {
            VStack(alignment: .leading, spacing: GaiaSpacing.md) {
                levelProgressCard
                monthlySummaryCard
                statsSection
            }

            VStack(alignment: .leading, spacing: GaiaSpacing.md) {
                goalsSection
                bioCalendarCard
                findMapSection
                treeOfLifeCard
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
        VStack(alignment: .leading, spacing: 19.489) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 11.255) {
                    Text("CURRENT LEVEL")
                        .font(.custom("NeueHaasUnica-Regular", size: 11))
                        .foregroundStyle(GaiaColor.oliveGreen100)

                    Text("3")
                        .font(.custom("NewSpirit-Regular", size: 45.019))
                        .tracking(-0.4689)
                        .foregroundStyle(GaiaColor.paperWhite50)
                }

                Spacer(minLength: 0)

                VStack(alignment: .trailing, spacing: 3.752) {
                    Text("NEXT")
                        .font(.custom("NeueHaasUnica-Regular", size: 11))
                        .foregroundStyle(GaiaColor.oliveGreen100)

                    Text("4")
                        .font(.custom("NewSpirit-Regular", size: 24))
                        .tracking(-0.2)
                        .foregroundStyle(GaiaColor.oliveGreen100)
                }
            }

            VStack(alignment: .leading, spacing: 11.255) {
                GeometryReader { proxy in
                    Capsule(style: .continuous)
                        .fill(GaiaColor.oliveGreen400)
                        .overlay(alignment: .leading) {
                            Capsule(style: .continuous)
                                .fill(GaiaColor.paperWhite50)
                                .frame(width: proxy.size.width * CGFloat(193.205 / 340.0))
                        }
                }
                .frame(height: 7.503)

                HStack(alignment: .center) {
                    Text("12 finds to level 4")
                        .font(.custom("NeueHaasUnica-Regular", size: 11))
                        .foregroundStyle(GaiaColor.oliveGreen100)

                    Spacer(minLength: 0)

                    Text("55% there")
                        .font(.custom("NeueHaasUnica-Regular", size: 11))
                        .foregroundStyle(GaiaColor.oliveGreen100)
                }
            }
        }
        .padding(15.006)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14.668, style: .continuous)
                .fill(GaiaColor.oliveGreen300)
                .overlay(
                    RoundedRectangle(cornerRadius: 14.668, style: .continuous)
                        .stroke(GaiaColor.oliveGreen200, lineWidth: 1)
                )
                .shadow(color: warmCardShadow, radius: 18.758, x: 0, y: 3.752)
        )
    }

    private var monthlySummaryCard: some View {
        HStack(alignment: .bottom, spacing: GaiaSpacing.md) {
            VStack(alignment: .leading, spacing: 10) {
                Text("MARCH 2026")
                    .gaiaFont(.caption)
                    .foregroundStyle(GaiaColor.broccoliBrown500)

                (
                    Text("You discovered ")
                    + Text("13 new species").foregroundStyle(GaiaColor.oliveGreen500)
                    + Text(" and made ")
                    + Text("4 contributions").foregroundStyle(GaiaColor.broccoliBrown500)
                    + Text(" this month.")
                )
                .gaiaFont(.title2)
                .foregroundStyle(GaiaColor.inkBlack300)
                .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)

            GaiaIcon(kind: .circleArrowRight, size: 32)
                .frame(width: 32, height: 32)
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
        )
    }

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Stats")
                .gaiaFont(.titleSans)
                .foregroundStyle(GaiaColor.inkBlack300)

            HStack(spacing: 0) {
                ForEach(Array(impactStats.enumerated()), id: \.element.id) { index, stat in
                    VStack(spacing: 12) {
                        Text(stat.title)
                            .gaiaFont(.caption2)
                            .foregroundStyle(GaiaColor.textSecondary)

                        Text(stat.value)
                            .font(.custom("NewSpirit-Medium", size: 32))
                            .tracking(-0.5)
                            .foregroundStyle(GaiaColor.oliveGreen400)
                            .lineLimit(1)
                            .minimumScaleFactor(0.85)
                    }
                    .frame(width: 89, alignment: .center)
                    .padding(.vertical, 8)

                    if index < impactStats.count - 1 {
                        Rectangle()
                            .fill(GaiaColor.border)
                            .frame(width: 0.5, height: 53)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, minHeight: 101, alignment: .center)
            .background(
                RoundedRectangle(cornerRadius: GaiaRadius.card, style: .continuous)
                    .fill(GaiaColor.paperWhite50)
                    .overlay(
                        RoundedRectangle(cornerRadius: GaiaRadius.card, style: .continuous)
                            .stroke(GaiaColor.border, lineWidth: 1)
                    )
            )
            .shadow(color: warmCardShadow, radius: 20, x: 0, y: 4)
        }
    }

    private var goalsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Goals")
                    .gaiaFont(.titleSans)
                    .foregroundStyle(GaiaColor.inkBlack300)
                Spacer(minLength: 0)
                Text("2 active")
                    .gaiaFont(.caption2)
                    .foregroundStyle(GaiaColor.oliveGreen400)
            }

            VStack(spacing: 12) {
                ForEach(goals) { goal in
                    goalCard(goal)
                }
            }
        }
    }

    private func goalCard(_ goal: ImpactGoal) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: GaiaSpacing.sm) {
                Text(goal.title)
                    .gaiaFont(.titleSans)
                    .foregroundStyle(goal.titleColor)
                    .frame(width: 133.652, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: 0)

                Text(goal.progressLabel)
                    .font(.custom("NeueHaasUnica-Regular", size: 11.72))
                    .foregroundStyle(goal.pillStroke)
                    .padding(.horizontal, 10.651)
                    .frame(height: 21.302)
                    .background(goal.pillFill, in: Capsule(style: .continuous))
                    .overlay(
                        Capsule(style: .continuous)
                            .stroke(goal.pillStroke, lineWidth: 0.533)
                    )
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule(style: .continuous)
                        .fill(goal.trackColor)
                    Capsule(style: .continuous)
                        .fill(goal.accent)
                        .frame(width: proxy.size.width * goal.progress)
                }
            }
            .frame(height: 6)
        }
        .padding(GaiaSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: GaiaRadius.card, style: .continuous)
                .fill(GaiaColor.paperWhite50)
                .overlay(
                    RoundedRectangle(cornerRadius: GaiaRadius.card, style: .continuous)
                        .stroke(GaiaColor.border, lineWidth: 0.976)
                )
        )
    }

    private var bioCalendarCard: some View {
        Button {
            showsBioCalendarDetail = true
        } label: {
            VStack(alignment: .leading, spacing: 20.003) {
                HStack(alignment: .bottom) {
                    Text("Bio Calendar")
                        .gaiaFont(.titleSans)
                        .foregroundStyle(GaiaColor.inkBlack300)
                    Spacer(minLength: 0)
                    Text("Last 60 days")
                        .gaiaFont(.caption2)
                        .foregroundStyle(GaiaColor.oliveGreen400)
                }

                GeometryReader { proxy in
                    let columnSpacing: CGFloat = 3.783868
                    let rowSpacing: CGFloat = 4.729836
                    let side = (proxy.size.width - (columnSpacing * 9)) / 10
                    let cellRadius: CGFloat = 3.784

                    LazyVGrid(
                        columns: Array(repeating: GridItem(.fixed(side), spacing: columnSpacing), count: 10),
                        alignment: .leading,
                        spacing: rowSpacing
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
                        HStack(spacing: 4.001) {
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
            .padding(16.003)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: GaiaRadius.card, style: .continuous)
                    .fill(GaiaColor.paperWhite50)
                    .overlay(
                        RoundedRectangle(cornerRadius: GaiaRadius.card, style: .continuous)
                            .stroke(GaiaColor.border, lineWidth: 0.976)
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private var treeOfLifeCard: some View {
        VStack(alignment: .leading, spacing: 21.477) {
            HStack(alignment: .bottom) {
                Text("Tree of Life")
                    .gaiaFont(.titleSans)
                    .foregroundStyle(GaiaColor.inkBlack300)
                Spacer(minLength: 0)
                Text("4 kingdoms")
                    .gaiaFont(.caption)
                    .foregroundStyle(GaiaColor.oliveGreen400)
            }

            VStack(alignment: .leading, spacing: 14.318) {
                treeAllRow
                VStack(alignment: .leading, spacing: 7.159) {
                    ForEach(treeRows) { row in
                        treeChildRow(row)
                    }
                }
            }
        }
        .padding(.horizontal, 19.446)
        .padding(.vertical, 23.335)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 15.557, style: .continuous)
                .fill(GaiaColor.paperWhite50)
                .overlay(
                    RoundedRectangle(cornerRadius: 15.557, style: .continuous)
                        .stroke(GaiaColor.broccoliBrown200, lineWidth: 0.972)
                )
        )
    }

    private var treeAllRow: some View {
        HStack(spacing: 17.898) {
            Text("All")
                .gaiaFont(.titleSans)
                .foregroundStyle(GaiaColor.oliveGreen500)
                .frame(width: 105.597, alignment: .leading)

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule(style: .continuous)
                        .fill(GaiaColor.oliveGreen100)
                    Capsule(style: .continuous)
                        .fill(GaiaColor.oliveGreen400)
                        .frame(width: proxy.size.width * CGFloat(93.0 / 141.392))
                }
            }
            .frame(width: 141.392, height: 5.369)

            Text("63")
                .gaiaFont(.titleSans)
                .foregroundStyle(GaiaColor.oliveGreen500)
                .frame(minWidth: 20, alignment: .trailing)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 7.159, style: .continuous)
                .fill(GaiaColor.oliveGreen50)
                .overlay(
                    RoundedRectangle(cornerRadius: 7.159, style: .continuous)
                        .stroke(GaiaColor.borderStrong, lineWidth: 0.895)
                )
        )
    }

    private func treeChildRow(_ row: ImpactTreeRow) -> some View {
        HStack(alignment: .center, spacing: 0) {
            TreeBranchConnector()
                .stroke(GaiaColor.broccoliBrown200, lineWidth: 0.447)
                .frame(width: 42.955, height: 42.955)

            HStack(spacing: 7.159) {
                Text(row.title)
                    .gaiaFont(.titleSans)
                    .foregroundStyle(GaiaColor.textSecondary)
                    .frame(width: row.titleWidth, alignment: .leading)

                ZStack(alignment: .leading) {
                    Capsule(style: .continuous)
                        .fill(GaiaColor.broccoliBrown100)
                    Capsule(style: .continuous)
                        .fill(GaiaColor.broccoliBrown500)
                        .frame(width: 123.495 * row.progress)
                }
                .frame(width: 123.495, height: 5.369)

                Text("\(row.count)")
                    .gaiaFont(.titleSans)
                    .foregroundStyle(GaiaColor.broccoliBrown500)
                    .frame(width: 23, alignment: .trailing)
            }
            .padding(.horizontal, 14.318)
            .padding(.top, 16)
            .padding(.bottom, 14.318)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(GaiaColor.paperWhite50)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(GaiaColor.broccoliBrown200, lineWidth: 0.447)
                    )
            )
        }
    }

    private var findMapSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Find Map")
                    .gaiaFont(.titleSans)
                    .foregroundStyle(GaiaColor.inkBlack300)

                Spacer(minLength: 0)

                Text(profileFindsLabel)
                    .gaiaFont(.caption2)
                    .foregroundStyle(GaiaColor.oliveGreen400)
            }

            ProfileHeatmapCard {
                showsExpandedMap = true
            }
        }
    }

    private var medalsSection: some View {
        VStack(alignment: .leading, spacing: GaiaSpacing.lg) {
            Text("Medals")
                .gaiaFont(.titleSans)
                .foregroundStyle(GaiaColor.inkBlack300)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: GaiaSpacing.space4) {
                    ForEach(medals) { medal in
                        medalSummaryItem(medal)
                    }
                }
            }

            HStack {
                Spacer(minLength: 0)

                Button {
                    showsMedalsDetail = true
                } label: {
                    Text("View all")
                        .gaiaFont(.caption2)
                        .foregroundStyle(GaiaColor.textSecondary)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func medalSummaryItem(_ medal: ImpactMedal) -> some View {
        VStack(spacing: GaiaSpacing.xs) {
            ZStack(alignment: .bottomTrailing) {
                MedalBadgeImage(
                    name: medal.badgeImageName,
                    width: 64,
                    height: 63.088,
                    fallbackTint: medal.titleColor
                )

                Text("\(medal.count)")
                    .gaiaFont(.captionMono)
                    .foregroundStyle(GaiaColor.paperWhite50)
                    .frame(width: 19, height: 18)
                    .background(medal.countFillColor, in: Capsule(style: .continuous))
                    .overlay(
                        Capsule(style: .continuous)
                            .stroke(GaiaColor.paperWhite50, lineWidth: 2)
                    )
            }
            .frame(width: 64, height: 63.088)

            Text(medal.title)
                .gaiaFont(.caption)
                .foregroundStyle(medal.titleColor)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
        }
        .frame(width: 64, alignment: .center)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(medal.title), \(medalCountLabel(for: medal.count))")
    }

    private func medalCountLabel(for count: Int) -> String {
        "\(count) \(count == 1 ? "find" : "finds")"
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
        RoundedRectangle(cornerRadius: 1.867, style: .continuous)
            .fill(calendarColor(for: level))
            .frame(width: 15, height: 15)
            .overlay(
                RoundedRectangle(cornerRadius: 1.867, style: .continuous)
                    .stroke(GaiaColor.paperWhite600, lineWidth: 0.247)
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
            )
    }
}

private struct TreeBranchConnector: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        // Vertical segment from top to mid
        let verticalX = rect.minX + 8
        path.move(to: CGPoint(x: verticalX, y: rect.minY))
        path.addLine(to: CGPoint(x: verticalX, y: rect.midY))
        // Horizontal segment from vertical into the card
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        return path
    }
}

private struct ProfileMedalsDetailScreen: View {
    let onClose: () -> Void

    private let categoryBadges: [CategoryMedalBadge] = [
        .init(id: "fungus", title: "Fungus", findsText: "62 finds", imageName: "gaia-profile-medal-category-fungus"),
        .init(id: "fish", title: "Fish", findsText: "43 finds", imageName: "gaia-profile-medal-category-fish"),
        .init(id: "insect", title: "Insect", findsText: "98 finds", imageName: "gaia-profile-medal-category-insect"),
        .init(id: "mammal", title: "Mammal", findsText: "12 finds", imageName: "gaia-profile-medal-category-mammal"),
        .init(id: "mollusk", title: "Mollusk", findsText: "15 finds", imageName: "gaia-profile-medal-category-mollusk"),
        .init(id: "plant", title: "Plant", findsText: "45 finds", imageName: "gaia-profile-medal-category-plant"),
        .init(id: "bird", title: "Bird", findsText: "87 finds", imageName: "gaia-profile-medal-category-bird"),
        .init(id: "reptile", title: "Reptile", findsText: "13 finds", imageName: "gaia-profile-medal-category-reptile"),
        .init(id: "amphibian", title: "Amphibian", findsText: "65 finds", imageName: "gaia-profile-medal-category-amphibian")
    ]

    private let badgeColumns: [GridItem] = Array(
        repeating: GridItem(.fixed(118), spacing: GaiaSpacing.sm),
        count: 3
    )

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: GaiaSpacing.lg) {
                medalSection(title: "Recently Earned") {
                    recentlyEarnedCard
                }
                medalSection(title: "Category") {
                    LazyVGrid(columns: badgeColumns, alignment: .leading, spacing: GaiaSpacing.sm) {
                        ForEach(categoryBadges) { badge in
                            categoryBadgeCard(badge)
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
                Text("Mammal Scout")
                    .gaiaFont(.title1)
                    .foregroundStyle(GaiaColor.blackishGrey500)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Text("Logged 10+ mammal species in your region")
                    .gaiaFont(.caption)
                    .foregroundStyle(GaiaColor.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(GaiaSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                .fill(GaiaColor.paperWhite50)
                .overlay(
                    RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                        .stroke(GaiaColor.border, lineWidth: 0.5)
                )
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
                MedalBadgeImage(
                    name: badge.imageName,
                    width: 82.98,
                    height: 82.98,
                    fallbackTint: GaiaColor.broccoliBrown400
                )

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

private struct MedalBadgeImage: View {
    let name: String
    let width: CGFloat
    let height: CGFloat
    var fallbackTint: Color

    var body: some View {
        GaiaAssetImage(name: name, contentMode: .fit, fallbackTint: fallbackTint)
            .frame(width: width, height: height)
            .accessibilityHidden(true)
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

struct ProfileHeatmapCard: View {
    let action: () -> Void

    var body: some View {
        GeometryReader { proxy in
            let scale = proxy.size.width / ProfileHeatmapLayout.baseSize.width

            ZStack(alignment: .topLeading) {
                Color.clear

                Image("gaia-profile-impact-map-preview")
                    .resizable()
                    .interpolation(.high)
                    .frame(
                        width: proxy.size.width * 1.0348,
                        height: proxy.size.height * 1.1963
                    )
                    .offset(
                        x: proxy.size.width * -0.0183,
                        y: proxy.size.height * -0.0981
                    )
                    .accessibilityHidden(true)

                ForEach(ProfileHeatmapLayout.largePins) { pin in
                    ProfileHeatmapPinBubble(
                        diameter: pin.size * scale,
                        strokeWidth: nil,
                        shadows: ProfileHeatmapLayout.largeShadows.scaled(by: scale)
                    )
                    .position(
                        x: proxy.size.width * (pin.leftPercent / 100) + (pin.size * scale * 0.5),
                        y: proxy.size.height * (pin.topPercent / 100) + (pin.size * scale * 0.5)
                    )
                }

                ForEach(ProfileHeatmapLayout.smallPins) { pin in
                    ProfileHeatmapPinBubble(
                        diameter: pin.size * scale,
                        strokeWidth: ProfileHeatmapLayout.smallPinStrokeWidth * scale,
                        shadows: ProfileHeatmapLayout.smallShadows.scaled(by: scale)
                    )
                    .position(
                        x: proxy.size.width * (pin.leftPercent / 100) + (pin.size * scale * 0.5),
                        y: proxy.size.height * (pin.topPercent / 100) + (pin.size * scale * 0.5)
                    )
                }

                ForEach(ProfileHeatmapLayout.pinPairs) { pair in
                    ProfileHeatmapPinBubble(
                        diameter: pair.backDiameter * scale,
                        strokeWidth: ProfileHeatmapLayout.smallPinStrokeWidth * scale,
                        shadows: ProfileHeatmapLayout.smallShadows.scaled(by: scale)
                    )
                    .position(
                        x: proxy.size.width * (pair.leftPercent / 100) + ((pair.backOffset.width + (pair.backDiameter * 0.5)) * scale),
                        y: proxy.size.height * (pair.topPercent / 100) + ((pair.backOffset.height + (pair.backDiameter * 0.5)) * scale)
                    )

                    ProfileHeatmapPinBubble(
                        diameter: pair.frontDiameter * scale,
                        strokeWidth: ProfileHeatmapLayout.smallPinStrokeWidth * scale,
                        shadows: []
                    )
                    .position(
                        x: proxy.size.width * (pair.leftPercent / 100) + (pair.frontDiameter * scale * 0.5),
                        y: proxy.size.height * (pair.topPercent / 100) + (pair.frontDiameter * scale * 0.5)
                    )
                }

                ProfileHeatmapPinBubble(
                    diameter: ProfileHeatmapLayout.selectedPin.diameter * scale,
                    strokeWidth: ProfileHeatmapLayout.selectedPinStrokeWidth * scale,
                    shadows: []
                )
                .position(
                    x: (ProfileHeatmapLayout.selectedPin.origin.x + (ProfileHeatmapLayout.selectedPin.diameter * 0.5)) * scale,
                    y: (ProfileHeatmapLayout.selectedPin.origin.y + (ProfileHeatmapLayout.selectedPin.diameter * 0.5)) * scale
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(GaiaColor.paperWhite50)
            .overlay(alignment: .topTrailing) {
                GlassCircleButton(size: ProfileHeatmapLayout.buttonSize * scale, action: action) {
                    ProfileHeatmapExpandIcon(size: ProfileHeatmapLayout.iconSize * scale)
                }
                .padding(ProfileHeatmapLayout.buttonPadding * scale)
                .accessibilityLabel("Expand map")
            }
        }
        .aspectRatio(ProfileHeatmapLayout.baseSize.width / ProfileHeatmapLayout.baseSize.height, contentMode: .fit)
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: GaiaRadius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: GaiaRadius.card, style: .continuous)
                .stroke(GaiaColor.border, lineWidth: 1)
        )
    }
}

private struct ProfileHeatmapExpandIcon: View {
    let size: CGFloat

    var body: some View {
        GeometryReader { proxy in
            let scale = proxy.size.width / ProfileHeatmapLayout.iconSize
            let slotSide = proxy.size.width * 0.6326
            let slotInset = proxy.size.width * 0.3674

            ZStack {
                Image("gaia-profile-impact-expand-a-24")
                    .resizable()
                    .renderingMode(.original)
                    .interpolation(.high)
                    .frame(
                        width: ProfileHeatmapLayout.expandVectorSize.width * scale,
                        height: ProfileHeatmapLayout.expandVectorSize.height * scale
                    )
                    .rotationEffect(.degrees(-135))
                    .position(x: slotSide * 0.5, y: slotInset + (slotSide * 0.5))

                Image("gaia-profile-impact-expand-b-24")
                    .resizable()
                    .renderingMode(.original)
                    .interpolation(.high)
                    .frame(
                        width: ProfileHeatmapLayout.expandVectorSize.width * scale,
                        height: ProfileHeatmapLayout.expandVectorSize.height * scale
                    )
                    .rotationEffect(.degrees(45))
                    .position(x: slotInset + (slotSide * 0.5), y: slotSide * 0.5)
            }
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}

private struct ProfileHeatmapPinBubble: View {
    let diameter: CGFloat
    let strokeWidth: CGFloat?
    let shadows: [ProfileHeatmapShadow]

    var body: some View {
        shadows.reduce(AnyView(baseCircle)) { partial, shadow in
            AnyView(
                partial.shadow(
                    color: shadow.color,
                    radius: shadow.blur,
                    x: shadow.x,
                    y: shadow.y
                )
            )
        }
        .frame(width: diameter, height: diameter)
        .accessibilityHidden(true)
    }

    private var baseCircle: some View {
        Circle()
            .fill(ProfileHeatmapLayout.pinGradient)
            .overlay {
                if let strokeWidth {
                    Circle()
                        .stroke(Color.white.opacity(0.5), lineWidth: strokeWidth)
                }
            }
    }
}

private struct ProfileHeatmapPinPlacement: Identifiable {
    let id: String
    let topPercent: CGFloat
    let leftPercent: CGFloat
    let size: CGFloat
}

private struct ProfileHeatmapPinPairPlacement: Identifiable {
    let id: String
    let topPercent: CGFloat
    let leftPercent: CGFloat
    let frontDiameter: CGFloat
    let backDiameter: CGFloat
    let backOffset: CGSize
}

private struct ProfileHeatmapAbsolutePinPlacement {
    let origin: CGPoint
    let diameter: CGFloat
}

private struct ProfileHeatmapShadow {
    let x: CGFloat
    let y: CGFloat
    let blur: CGFloat
    let color: Color
}

private extension Array where Element == ProfileHeatmapShadow {
    func scaled(by scale: CGFloat) -> [ProfileHeatmapShadow] {
        map {
            ProfileHeatmapShadow(
                x: $0.x * scale,
                y: $0.y * scale,
                blur: $0.blur * scale,
                color: $0.color
            )
        }
    }
}

private enum ProfileHeatmapLayout {
    static let baseSize = CGSize(width: 370, height: 214.00001525878906)
    static let buttonSize: CGFloat = 40.001
    static let buttonPadding: CGFloat = 11.222
    static let iconSize: CGFloat = 26.667
    static let expandVectorSize = CGSize(width: 11.7018, height: 12.1555)
    static let smallPinStrokeWidth: CGFloat = 0.49277
    static let selectedPinStrokeWidth: CGFloat = 0.492755
    static let selectedPin = ProfileHeatmapAbsolutePinPlacement(
        origin: CGPoint(x: 71, y: 61),
        diameter: 12.2137
    )

    static let pinGradient = LinearGradient(
        colors: [
            Color(.sRGB, red: 123.0 / 255.0, green: 179.0 / 255.0, blue: 105.0 / 255.0),
            Color(.sRGB, red: 110.0 / 255.0, green: 145.0 / 255.0, blue: 82.0 / 255.0)
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    static let largeShadows: [ProfileHeatmapShadow] = [
        .init(x: 8.354, y: 17.672, blur: 5.462, color: Color(.sRGB, red: 116.0 / 255.0, green: 161.0 / 255.0, blue: 93.0 / 255.0, opacity: 0.01)),
        .init(x: 5.462, y: 11.246, blur: 5.141, color: Color(.sRGB, red: 116.0 / 255.0, green: 161.0 / 255.0, blue: 93.0 / 255.0, opacity: 0.08)),
        .init(x: 3.213, y: 6.426, blur: 4.177, color: Color(.sRGB, red: 116.0 / 255.0, green: 161.0 / 255.0, blue: 93.0 / 255.0, opacity: 0.28)),
        .init(x: 1.285, y: 2.892, blur: 3.213, color: Color(.sRGB, red: 116.0 / 255.0, green: 161.0 / 255.0, blue: 93.0 / 255.0, opacity: 0.48)),
        .init(x: 0.321, y: 0.643, blur: 1.607, color: Color(.sRGB, red: 116.0 / 255.0, green: 161.0 / 255.0, blue: 93.0 / 255.0, opacity: 0.55))
    ]

    static let smallShadows: [ProfileHeatmapShadow] = [
        .init(x: 4.962, y: 10.497, blur: 3.245, color: Color(.sRGB, red: 116.0 / 255.0, green: 161.0 / 255.0, blue: 93.0 / 255.0, opacity: 0.01)),
        .init(x: 3.245, y: 6.68, blur: 3.054, color: Color(.sRGB, red: 116.0 / 255.0, green: 161.0 / 255.0, blue: 93.0 / 255.0, opacity: 0.08)),
        .init(x: 1.909, y: 3.817, blur: 2.481, color: Color(.sRGB, red: 116.0 / 255.0, green: 161.0 / 255.0, blue: 93.0 / 255.0, opacity: 0.28)),
        .init(x: 0.763, y: 1.718, blur: 1.909, color: Color(.sRGB, red: 116.0 / 255.0, green: 161.0 / 255.0, blue: 93.0 / 255.0, opacity: 0.48)),
        .init(x: 0.191, y: 0.382, blur: 0.954, color: Color(.sRGB, red: 116.0 / 255.0, green: 161.0 / 255.0, blue: 93.0 / 255.0, opacity: 0.55))
    ]

    static let largePins: [ProfileHeatmapPinPlacement] = [
        .init(id: "86016", topPercent: 56.44, leftPercent: 59.37, size: 22.001),
        .init(id: "86018", topPercent: 47.56, leftPercent: 57.74, size: 22.001),
        .init(id: "86020", topPercent: 48.97, leftPercent: 63.69, size: 22.001),
        .init(id: "86022", topPercent: 35.41, leftPercent: 64.23, size: 22.001)
    ]

    static let smallPins: [ProfileHeatmapPinPlacement] = [
        .init(id: "86024", topPercent: 20.92, leftPercent: 35.43, size: 13.068),
        .init(id: "86026", topPercent: 25.05, leftPercent: 33.13, size: 13.068),
        .init(id: "86028", topPercent: 25.05, leftPercent: 30.24, size: 13.068),
        .init(id: "86030", topPercent: 24.05, leftPercent: 27.64, size: 13.068),
        .init(id: "86032", topPercent: 30.04, leftPercent: 27.35, size: 13.068),
        .init(id: "86034", topPercent: 33.54, leftPercent: 24.46, size: 13.068),
        .init(id: "86036", topPercent: 38.54, leftPercent: 30.53, size: 13.068),
        .init(id: "86038", topPercent: 25.28, leftPercent: 38.45, size: 13.068),
        .init(id: "86040", topPercent: 29.54, leftPercent: 40.36, size: 13.068),
        .init(id: "86042", topPercent: 29.65, leftPercent: 35.93, size: 13.068),
        .init(id: "86044", topPercent: 31.54, leftPercent: 35.93, size: 13.068),
        .init(id: "86046", topPercent: 32.13, leftPercent: 31.89, size: 13.068),
        .init(id: "86048", topPercent: 26.55, leftPercent: 24.17, size: 13.068),
        .init(id: "86050", topPercent: 24.55, leftPercent: 20.41, size: 13.068),
        .init(id: "86052", topPercent: 35.04, leftPercent: 27.35, size: 13.068),
        .init(id: "86054", topPercent: 28.63, leftPercent: 28.71, size: 13.068),
        .init(id: "86056", topPercent: 32.63, leftPercent: 34.49, size: 13.068),
        .init(id: "86058", topPercent: 32.63, leftPercent: 38.24, size: 13.068),
        .init(id: "86066", topPercent: 37.41, leftPercent: 38.81, size: 13.068),
        .init(id: "86068", topPercent: 41.54, leftPercent: 36.51, size: 13.068),
        .init(id: "86070", topPercent: 41.77, leftPercent: 41.83, size: 13.068),
        .init(id: "86072", topPercent: 46.03, leftPercent: 43.74, size: 13.068),
        .init(id: "86074", topPercent: 46.13, leftPercent: 39.31, size: 13.068),
        .init(id: "86076", topPercent: 48.62, leftPercent: 35.27, size: 13.068),
        .init(id: "86078", topPercent: 49.12, leftPercent: 37.87, size: 13.068),
        .init(id: "86080", topPercent: 49.12, leftPercent: 41.62, size: 13.068),
        .init(id: "86082", topPercent: 58.35, leftPercent: 43.85, size: 13.068),
        .init(id: "86084", topPercent: 60.09, leftPercent: 47.38, size: 13.068),
        .init(id: "86086", topPercent: 63.58, leftPercent: 45.87, size: 13.068),
        .init(id: "86088", topPercent: 63.58, leftPercent: 49.4, size: 13.068),
        .init(id: "86090", topPercent: 65.33, leftPercent: 47.38, size: 13.068),
        .init(id: "86092", topPercent: 66.2, leftPercent: 51.42, size: 13.068),
        .init(id: "86094", topPercent: 68.82, leftPercent: 54.95, size: 13.068),
        .init(id: "86096", topPercent: 70.56, leftPercent: 49.4, size: 13.068),
        .init(id: "86098", topPercent: 74.05, leftPercent: 52.93, size: 13.068),
        .init(id: "86100", topPercent: 76.67, leftPercent: 54.95, size: 13.068),
        .init(id: "86102", topPercent: 78.41, leftPercent: 51.93, size: 13.068),
        .init(id: "86104", topPercent: 81.03, leftPercent: 56.97, size: 13.068),
        .init(id: "86106", topPercent: 82.78, leftPercent: 54.45, size: 13.068),
        .init(id: "86108", topPercent: 82.78, leftPercent: 58.99, size: 13.068),
        .init(id: "86110", topPercent: 86.01, leftPercent: 59.05, size: 13.068),
        .init(id: "86112", topPercent: 90.0, leftPercent: 53.76, size: 13.068),
        .init(id: "86115", topPercent: 32.98, leftPercent: 45.53, size: 13.068),
        .init(id: "86117", topPercent: 47.0, leftPercent: 50.94, size: 13.068)
    ]

    static let pinPairs: [ProfileHeatmapPinPairPlacement] = [
        .init(
            id: "86059",
            topPercent: 36.63,
            leftPercent: 35.93,
            frontDiameter: 13.061,
            backDiameter: 13.068,
            backOffset: CGSize(width: 12.5, height: 35.28)
        ),
        .init(
            id: "86062",
            topPercent: 36.63,
            leftPercent: 40.47,
            frontDiameter: 13.061,
            backDiameter: 13.068,
            backOffset: CGSize(width: 12.5, height: 35.28)
        )
    ]
}
