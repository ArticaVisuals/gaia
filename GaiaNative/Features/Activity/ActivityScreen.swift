// figma: https://www.figma.com/design/4e4G3tnSR7AdPbf0jAYPP1/Gaia?node-id=1462-125362
import SwiftUI

struct ActivityScreen: View {
    @EnvironmentObject private var contentStore: ContentStore
    @State private var selectedFilter: ActivityFilter = .all
    private let bottomContentInset = GaiaSpacing.step120 + GaiaSpacing.md + GaiaSpacing.xs

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
                    } else {
                        ForEach(groupedEvents) { group in
                            ActivityDaySection(group: group)
                        }
                    }
                }
                .padding(.bottom, bottomContentInset)
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
    case needsID = "Needs ID"
    case verified = "Verified"
    case comments = "Comments"

    var id: String { rawValue }

    var categoryID: String {
        switch self {
        case .all:
            return "all"
        case .needsID:
            return "needs-id"
        case .verified:
            return "verified"
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
    private let dividerHeight = 1 / UIScreen.main.scale

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(group.title)
                .gaiaFont(.title1Medium)
                .foregroundStyle(GaiaColor.inkBlack300)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, GaiaSpacing.md)
                .padding(.top, GaiaSpacing.lg)
                .padding(.bottom, GaiaSpacing.space4)

            Rectangle()
                .fill(GaiaColor.broccoliBrown200)
                .frame(height: dividerHeight)

            ForEach(group.events) { event in
                ActivityNotificationItem(event: event)

                Rectangle()
                    .fill(GaiaColor.broccoliBrown200)
                    .frame(height: dividerHeight)
            }
        }
    }
}

private struct ActivityEmptyState: View {
    let filter: ActivityFilter

    var body: some View {
        VStack(alignment: .leading, spacing: GaiaSpacing.sm) {
            Text(emptyTitle)
                .gaiaFont(.title3Medium)
                .foregroundStyle(GaiaColor.inkBlack300)

            Text(emptyMessage)
                .gaiaFont(.subheadline)
                .foregroundStyle(GaiaColor.blackishGrey500)
        }
        .padding(.horizontal, GaiaSpacing.md)
        .padding(.top, GaiaSpacing.xl)
        .padding(.bottom, GaiaSpacing.xxxl)
    }

    private var emptyTitle: String {
        switch filter {
        case .comments:
            return "No comments yet"
        case .needsID:
            return "Nothing needs review"
        case .verified:
            return "No verified updates yet"
        case .all:
            return "No activity yet"
        }
    }

    private var emptyMessage: String {
        switch filter {
        case .comments:
            return "Comments from the community will appear here."
        case .needsID:
            return "Items waiting on more detail or identification will show up here."
        case .verified:
            return "Verified finds and community confirmations will appear here."
        case .all:
            return "New finds, community updates, and reminders will appear here as they happen."
        }
    }
}
