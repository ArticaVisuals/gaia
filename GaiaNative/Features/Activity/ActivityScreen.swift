// figma: https://www.figma.com/design/4e4G3tnSR7AdPbf0jAYPP1/Gaia?node-id=665-5519
import SwiftUI

struct ActivityScreen: View {
    @EnvironmentObject private var contentStore: ContentStore
    @State private var selectedFilter: ActivityFilter = .all

    var body: some View {
        VStack(spacing: 0) {
            ActivityHeader(selectedFilter: $selectedFilter)

            ScrollView(showsIndicators: false) {
                LazyVStack(alignment: .leading, spacing: GaiaSpacing.lg) {
                    ForEach(groupedEvents) { group in
                        ActivityDaySection(group: group)
                    }
                }
                .padding(.top, GaiaSpacing.lg)
                .padding(.bottom, 140)
            }
            .background(GaiaColor.paperWhite50)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(GaiaColor.paperWhite50.ignoresSafeArea())
    }

    private var filteredEvents: [ActivityEvent] {
        switch selectedFilter {
        case .all:
            return contentStore.activityEvents
        default:
            return contentStore.activityEvents.filter { event in
                (event.categoryIDs ?? []).contains(selectedFilter.categoryID)
            }
        }
    }

    private var groupedEvents: [ActivityEventGroup] {
        var groups: [ActivityEventGroup] = []

        for event in filteredEvents {
            let label = event.groupLabel ?? "Activity"
            if let index = groups.firstIndex(where: { $0.title == label }) {
                groups[index].events.append(event)
            } else {
                groups.append(ActivityEventGroup(title: label, events: [event]))
            }
        }

        return groups
    }
}

private enum ActivityFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case needsAttention = "Needs Attention"
    case idUpdates = "ID Updates"
    case comments = "Comments"

    var id: String { rawValue }

    var categoryID: String {
        switch self {
        case .all:
            return "all"
        case .needsAttention:
            return "needs-attention"
        case .idUpdates:
            return "id-updates"
        case .comments:
            return "comments"
        }
    }
}

private struct ActivityEventGroup: Identifiable {
    let title: String
    var events: [ActivityEvent]

    var id: String { title }
}

private struct ActivityHeader: View {
    @Binding var selectedFilter: ActivityFilter

    var body: some View {
        VStack(spacing: GaiaSpacing.sm) {
            Text("Activity")
                .font(GaiaTypography.title1Medium)
                .foregroundStyle(GaiaColor.oliveGreen500)
                .frame(maxWidth: .infinity)
                .frame(height: 48, alignment: .bottom)
                .padding(.top, 12)
                .padding(.horizontal, GaiaSpacing.md)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: GaiaSpacing.sm) {
                    ForEach(ActivityFilter.allCases) { filter in
                        Button {
                            selectedFilter = filter
                        } label: {
                            Text(filter.rawValue)
                                .font(GaiaTypography.footnote)
                                .foregroundStyle(filter == selectedFilter ? GaiaColor.paperWhite50 : GaiaColor.inkBlack300)
                                .padding(.horizontal, 10)
                                .frame(height: 28)
                                .background(
                                    Capsule()
                                        .fill(filter == selectedFilter ? GaiaColor.oliveGreen500 : GaiaColor.oliveGreen500.opacity(0.20))
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, GaiaSpacing.md)
            }
            .scrollIndicators(.hidden)
        }
        .padding(.bottom, GaiaSpacing.lg)
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

private struct ActivityDaySection: View {
    let group: ActivityEventGroup

    var body: some View {
        VStack(alignment: .leading, spacing: GaiaSpacing.sm) {
            Text(group.title)
                .font(GaiaTypography.subheadSerif)
                .foregroundStyle(GaiaColor.textSecondary)
                .padding(.horizontal, GaiaSpacing.md)

            VStack(spacing: 0) {
                ForEach(Array(group.events.enumerated()), id: \.element.id) { index, event in
                    ActivityFeedRow(event: event, showsDivider: index < group.events.count - 1)
                }
            }
        }
    }
}

private struct ActivityFeedRow: View {
    let event: ActivityEvent
    let showsDivider: Bool

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 14) {
                Circle()
                    .fill(GaiaColor.oliveGreen500.opacity(0.15))
                    .overlay(
                        Circle()
                            .stroke(GaiaColor.oliveGreen500.opacity(0.30), lineWidth: 1)
                    )
                    .frame(width: 32, height: 32)
                    .padding(.top, 2)

                VStack(alignment: .leading, spacing: GaiaSpacing.sm) {
                    VStack(alignment: .leading, spacing: GaiaSpacing.sm) {
                        HStack(alignment: .top, spacing: GaiaSpacing.sm) {
                            Text(event.title)
                                .font(GaiaTypography.subheadSerif)
                                .foregroundStyle(GaiaColor.textPrimary)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Text(event.timestampLabel)
                                .font(.custom("Neue Haas Unica W1G", size: 12))
                                .foregroundStyle(GaiaColor.textSecondary)
                                .fixedSize()
                        }

                        subtitleText
                    }

                    if let actionLabel = event.actionLabel {
                        Text(actionLabel)
                            .font(GaiaTypography.footnoteMedium)
                            .foregroundStyle(GaiaColor.grassGreen500)
                    }
                }
            }
            .padding(.horizontal, GaiaSpacing.md)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, minHeight: 100, alignment: .leading)

            if showsDivider {
                Rectangle()
                    .fill(GaiaColor.oliveGreen100)
                    .frame(height: 1)
                    .padding(.horizontal, GaiaSpacing.md)
            }
        }
    }

    private var subtitleText: Text {
        let fragments = event.subtitle.components(separatedBy: "**")

        return fragments.enumerated().reduce(Text("")) { partial, fragment in
            let isHighlight = fragment.offset.isMultiple(of: 2) == false
            let piece = Text(fragment.element)
                .font(isHighlight ? GaiaTypography.footnoteMedium : GaiaTypography.footnote)
                .foregroundStyle(isHighlight ? GaiaColor.vermillion300 : GaiaColor.textSecondary)

            return partial + piece
        }
    }
}
