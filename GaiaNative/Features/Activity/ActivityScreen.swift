// figma: https://www.figma.com/design/4e4G3tnSR7AdPbf0jAYPP1/Gaia?node-id=995-15449
import SwiftUI

struct ActivityScreen: View {
    @EnvironmentObject private var contentStore: ContentStore
    @State private var selectedFilter: ActivityFilter = .all

    var body: some View {
        VStack(spacing: 0) {
            ActivityTopBar(
                title: "Activity",
                filters: ActivityFilter.allCases.map(\.rawValue),
                selectedFilter: selectedFilter.rawValue
            ) { selected in
                guard let filter = ActivityFilter(rawValue: selected) else { return }
                selectedFilter = filter
            }

            ScrollView(showsIndicators: false) {
                LazyVStack(alignment: .leading, spacing: 0) {
                    if groupedEvents.isEmpty {
                        ActivityEmptyState(filter: selectedFilter)
                            .padding(.horizontal, GaiaSpacing.md)
                            .padding(.top, GaiaSpacing.lg)
                    } else {
                        ForEach(groupedEvents) { group in
                            ActivityDaySection(group: group)
                        }
                    }
                }
                .padding(.bottom, GaiaSpacing.sm)
            }
            .background(GaiaColor.paperWhite50)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(GaiaColor.paperWhite50.ignoresSafeArea())
        .ignoresSafeArea(edges: .bottom)
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

struct ActivityHairline: View {
    var color: Color = GaiaColor.border
    @Environment(\.displayScale) private var displayScale

    var body: some View {
        Rectangle()
            .fill(color)
            .frame(height: 1 / max(displayScale, 1))
            .accessibilityHidden(true)
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

private struct ActivityDaySection: View {
    let group: ActivityEventGroup

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(group.title)
                .gaiaFont(.title1Medium)
                .foregroundStyle(GaiaColor.inkBlack300)
                .padding(.top, GaiaSpacing.lg)
                .padding(.bottom, GaiaSpacing.cardInset)
                .padding(.horizontal, GaiaSpacing.md)

            VStack(spacing: 0) {
                ActivitySectionDivider()

                ForEach(group.events) { event in
                    ActivityNotificationItem(event: event)
                    ActivitySectionDivider()
                }
            }
        }
    }
}

private struct ActivitySectionDivider: View {
    var body: some View {
        ActivityHairline()
    }
}

private struct ActivityEmptyState: View {
    let filter: ActivityFilter

    var body: some View {
        VStack(alignment: .leading, spacing: GaiaSpacing.sm) {
            Text("No activity yet")
                .gaiaFont(.title3)
                .foregroundStyle(GaiaColor.textPrimary)

            Text("There isn’t any activity in \(filter.rawValue.lowercased()) right now.")
                .gaiaFont(.footnote)
                .foregroundStyle(GaiaColor.textSecondary)
        }
        .padding(GaiaSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: GaiaRadius.card, style: .continuous)
                .fill(GaiaColor.surfaceCard)
                .overlay(
                    RoundedRectangle(cornerRadius: GaiaRadius.card, style: .continuous)
                        .stroke(GaiaColor.border, lineWidth: 0.5)
                )
        )
    }
}
