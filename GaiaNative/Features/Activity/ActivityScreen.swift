// figma: https://www.figma.com/design/4e4G3tnSR7AdPbf0jAYPP1/Gaia?node-id=979-5252
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

private struct ActivityDaySection: View {
    let group: ActivityEventGroup

    var body: some View {
        VStack(alignment: .leading, spacing: GaiaSpacing.sm) {
            Text(group.title)
                .gaiaFont(.subheadSerif)
                .foregroundStyle(GaiaColor.textSecondary)
                .padding(.horizontal, GaiaSpacing.md)

            VStack(spacing: 0) {
                ForEach(Array(group.events.enumerated()), id: \.element.id) { index, event in
                    ActivityNotificationItem(
                        event: event,
                        showsDivider: index < group.events.count - 1
                    )
                }
            }
        }
    }
}
