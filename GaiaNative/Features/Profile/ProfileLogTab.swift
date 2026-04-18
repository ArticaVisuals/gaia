// figma: https://www.figma.com/design/4e4G3tnSR7AdPbf0jAYPP1/Gaia?node-id=995-15341 (Log List), 875-22720 (Log Grid), 982-5804 (Log Top Bar)
import SwiftUI

private enum ProfileLogViewMode: String, CaseIterable, Identifiable {
    case grid
    case list
    case map

    var id: String { rawValue }

    var accessibilityLabel: String {
        switch self {
        case .grid:
            return "Grid view"
        case .list:
            return "List view"
        case .map:
            return "Map view"
        }
    }
}

enum ProfileLogPresentation {
    case standalone
    case embedded
}

struct LogScreen: View {
    @EnvironmentObject private var contentStore: ContentStore
    @State private var searchText = ""
    @State private var viewMode: ProfileLogViewMode = profileLogLaunchViewMode() ?? .list
    @State private var showsSearchBar = false
    private let bottomContentInset = GaiaSpacing.sm

    var body: some View {
        VStack(spacing: 0) {
            ProfileLogHeader(
                presentation: .standalone,
                searchText: $searchText,
                viewMode: $viewMode,
                showsSearchBar: $showsSearchBar
            )
            .zIndex(1)

            ScrollView(showsIndicators: false) {
                ProfileLogBody(
                    content: contentStore.profileLog,
                    observations: contentStore.observations,
                    searchText: searchText,
                    viewMode: viewMode
                )
                .padding(.bottom, bottomContentInset)
            }
        }
        .background(GaiaColor.paperWhite50)
        .ignoresSafeArea(edges: .bottom)
    }
}

struct ProfileLogTab: View {
    let content: ProfileLogContent
    let presentation: ProfileLogPresentation

    @EnvironmentObject private var contentStore: ContentStore

    @State private var searchText = ""
    @State private var viewMode: ProfileLogViewMode
    @State private var showsSearchBar: Bool

    init(content: ProfileLogContent, presentation: ProfileLogPresentation = .standalone) {
        self.content = content
        self.presentation = presentation
        _viewMode = State(initialValue: profileLogLaunchViewMode() ?? .list)
        _showsSearchBar = State(initialValue: presentation != .standalone)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: GaiaSpacing.md) {
            ProfileLogHeader(
                presentation: presentation,
                searchText: $searchText,
                viewMode: $viewMode,
                showsSearchBar: $showsSearchBar
            )

            ProfileLogBody(
                content: content,
                observations: contentStore.observations,
                searchText: searchText,
                viewMode: viewMode
            )
        }
        .background(GaiaColor.paperWhite50)
    }
}

private struct ProfileLogHeader: View {
    let presentation: ProfileLogPresentation
    @Binding var searchText: String
    @Binding var viewMode: ProfileLogViewMode
    @Binding var showsSearchBar: Bool

    var body: some View {
        Group {
            if presentation == .standalone {
                standaloneHeader
            } else {
                embeddedHeader
            }
        }
    }

    private var standaloneHeader: some View {
        VStack(spacing: GaiaSpacing.md) {
            ZStack {
                Text("Log")
                    .gaiaFont(.title1Medium)
                    .foregroundStyle(GaiaColor.brandPrimary)

                HStack {
                    ProfileLogToolbarIconButton(accessibilityLabel: "Open search", action: revealSearchBar) {
                        GaiaIcon(kind: .search, size: 20, tint: GaiaColor.brandPrimary)
                            .accessibilityHidden(true)
                    }

                    Spacer(minLength: 0)

                    ProfileLogToolbarIconButton(accessibilityLabel: "Filter observations", action: {}) {
                        ProfileLogGlyphImage(path: "Icons/System/filter-32.png", tint: GaiaColor.brandPrimary)
                            .frame(width: 20, height: 20)
                            .accessibilityHidden(true)
                    }
                }
            }
            .frame(height: 40)

            if isSearchBarVisible {
                ProfileLogSearchBar(text: $searchText)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }

            DraggableIconTabSwitch(
                tabs: ProfileLogViewMode.allCases,
                selection: $viewMode,
                accessibilityLabel: { $0.accessibilityLabel }
            ) { mode, selected in
                icon(for: mode, selected: selected)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, GaiaSpacing.md)
        .padding(.top, GaiaSpacing.cardInset)
        .padding(.bottom, GaiaSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(GaiaColor.paperWhite50)
        .overlay(alignment: .bottom) {
            ProfileLogHairline()
        }
        .shadow(color: GaiaShadow.mdColor, radius: GaiaShadow.mdRadius, x: 0, y: GaiaShadow.mdYOffset)
        .animation(GaiaMotion.quickEase, value: isSearchBarVisible)
    }

    private var embeddedHeader: some View {
        VStack(alignment: .leading, spacing: GaiaSpacing.md) {
            ProfileLogSearchBar(text: $searchText)

            HStack(spacing: GaiaSpacing.sm) {
                DraggableIconTabSwitch(
                    tabs: ProfileLogViewMode.allCases,
                    selection: $viewMode,
                    accessibilityLabel: { $0.accessibilityLabel }
                ) { mode, selected in
                    icon(for: mode, selected: selected)
                }
                Spacer(minLength: 0)
                ProfileLogFilterButton()
            }
        }
    }

    private var isSearchBarVisible: Bool {
        showsSearchBar || !searchText.isEmpty
    }

    private func revealSearchBar() {
        guard !showsSearchBar else { return }
        HapticsService.selectionChanged()
        withAnimation(GaiaMotion.quickEase) {
            showsSearchBar = true
        }
    }

    @ViewBuilder
    private func icon(for mode: ProfileLogViewMode, selected: Bool) -> some View {
        let tint = selected ? GaiaColor.paperWhite50 : GaiaColor.brandPrimary
        switch mode {
        case .grid:
            ProfileLogGlyphImage(path: "Icons/System/grid-32.png", tint: tint)
        case .list:
            ProfileLogGlyphImage(path: "Icons/System/list-32.png", tint: tint)
        case .map:
            ProfileLogGlyphImage(path: "Icons/System/map-32.png", tint: tint)
        }
    }
}

private struct ProfileLogBody: View {
    let content: ProfileLogContent
    let observations: [Observation]
    let searchText: String
    let viewMode: ProfileLogViewMode

    var body: some View {
        Group {
            switch viewMode {
            case .list:
                ProfileLogList(sections: filteredSections)
            case .grid:
                ProfileLogGrid(items: filteredGridItems)
                    .padding(.top, GaiaSpacing.md)
                    .padding(.horizontal, GaiaSpacing.md)
            case .map:
                ProfileLogMap(content: content, observations: observations)
                    .padding(.horizontal, GaiaSpacing.md)
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }

    private var filteredSections: [ProfileLogSection] {
        profileLogFilteredSections(content: content, query: searchText)
    }

    private var filteredGridItems: [ProfileLogGridItem] {
        profileLogFilteredGridItems(content: content, query: searchText)
    }
}

private func profileLogLaunchViewMode() -> ProfileLogViewMode? {
    let arguments = ProcessInfo.processInfo.arguments
    guard let flagIndex = arguments.firstIndex(of: "-gaiaLogView"),
          arguments.indices.contains(flagIndex + 1) else {
        return nil
    }

    return ProfileLogViewMode(rawValue: arguments[flagIndex + 1].lowercased())
}

private func profileLogFilteredSections(content: ProfileLogContent, query: String) -> [ProfileLogSection] {
    let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else { return content.listSections }

    let needle = trimmed.lowercased()
    return content.listSections.compactMap { section in
        let entries = section.entries.filter { entry in
            [
                entry.commonName,
                entry.scientificName,
                entry.metaLabel,
                entry.statusLabel
            ]
            .joined(separator: " ")
            .lowercased()
            .contains(needle)
        }

        guard !entries.isEmpty else { return nil }
        return ProfileLogSection(
            id: section.id,
            title: section.title,
            countLabel: entries.count == 1 ? "1 find" : "\(entries.count) finds",
            entries: entries
        )
    }
}

private func profileLogFilteredGridItems(content: ProfileLogContent, query: String) -> [ProfileLogGridItem] {
    let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else { return content.gridItems }

    let needle = trimmed.lowercased()
    return content.gridItems.filter {
        $0.displayTitle.lowercased().contains(needle)
    }
}

private struct ProfileLogSearchBar: View {
    @Binding var text: String
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: GaiaSpacing.xs) {
            GaiaIcon(kind: .search, size: 20, tint: GaiaColor.textSecondary.opacity(0.55))
                .frame(width: 26, height: 26)

            TextField(
                "",
                text: $text,
                prompt: Text("Search species, location, notes...")
                    .font(GaiaTypography.subheadline)
                    .foregroundStyle(GaiaColor.textSecondary.opacity(0.55))
            )
            .gaiaFont(.subheadline)
            .foregroundStyle(GaiaColor.textPrimary)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .focused($isFocused)

            GaiaIcon(kind: .microphone, size: 20, tint: GaiaColor.textSecondary.opacity(0.55))
                .frame(width: 32, height: 32)
        }
        .padding(.horizontal, GaiaSpacing.sm)
        .frame(height: 40)
        .background(
            Capsule(style: .continuous)
                .fill(GaiaColor.paperWhite50)
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(GaiaColor.blackishGrey200, lineWidth: 0.5)
                )
        )
        .contentShape(Capsule())
        .onTapGesture {
            isFocused = true
        }
    }
}

private struct ProfileLogToolbarIconButton<Content: View>: View {
    let accessibilityLabel: String
    let action: () -> Void
    @ViewBuilder let content: () -> Content

    var body: some View {
        Button(action: action) {
            content()
                .frame(width: 20, height: 20)
                .frame(width: 40, height: 40)
                .contentShape(Rectangle())
        }
        .buttonStyle(GlassReactiveButtonStyle())
        .accessibilityLabel(accessibilityLabel)
    }
}

private struct ProfileLogFilterButton: View {
    var body: some View {
        Button(action: {}) {
            RoundedRectangle(cornerRadius: GaiaRadius.sm, style: .continuous)
                .fill(GaiaColor.brandPrimary)
                .frame(width: 48, height: 48)
                .overlay {
                    ProfileLogGlyphImage(path: "Icons/System/filter-32.png", tint: GaiaColor.paperWhite50)
                        .frame(width: 33, height: 35)
                }
        }
        .buttonStyle(GlassReactiveButtonStyle())
        .shadow(color: GaiaShadow.navColor.opacity(0.18), radius: 12, x: 0, y: 4)
    }
}

private struct ProfileLogList: View {
    let sections: [ProfileLogSection]

    var body: some View {
        LazyVStack(alignment: .leading, spacing: 0) {
            ForEach(sections) { section in
                GaiaDayDivider(title: section.title, detail: section.countLabel)

                ForEach(Array(section.entries.enumerated()), id: \.element.id) { _, entry in
                    ProfileLogRow(entry: entry)

                    ProfileLogHairline()
                }
            }
        }
    }
}

private struct ProfileLogRow: View {
    let entry: ProfileLogEntry
    private let rowVerticalPadding = GaiaSpacing.sm + GaiaSpacing.xs + GaiaSpacing.xxs

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            HStack(alignment: .center, spacing: 14) {
                ProfileLogMedia(source: entry.imageSource)
                    .frame(width: 76, height: 76)
                    .clipShape(RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous))

                VStack(alignment: .leading, spacing: GaiaSpacing.cardInset) {
                    VStack(alignment: .leading, spacing: GaiaSpacing.sm) {
                        Text(entry.commonName)
                            .gaiaFont(.title3Medium)
                            .foregroundStyle(GaiaColor.textPrimary)
                            .lineLimit(2)
                            .truncationMode(.tail)
                            .fixedSize(horizontal: false, vertical: true)

                        Text(entry.scientificName)
                            .gaiaFont(.footnote)
                            .italic()
                            .foregroundStyle(GaiaColor.broccoliBrown500)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }

                    Text(entry.metaLabel)
                        .gaiaFont(.caption2)
                        .foregroundStyle(GaiaColor.blackishGrey200)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .layoutPriority(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            GaiaStatusPill(title: entry.statusLabel, variant: entry.statusKind.pillVariant)
        }
        .padding(.horizontal, GaiaSpacing.md)
        .padding(.vertical, rowVerticalPadding)
        .frame(maxWidth: .infinity, minHeight: 104, alignment: .leading)
        .background(GaiaColor.paperWhite50)
    }
}

private struct ProfileLogGrid: View {
    let items: [ProfileLogGridItem]

    private let columns = Array(
        repeating: GridItem(.flexible(minimum: 0), spacing: GaiaSpacing.sm, alignment: .top),
        count: 3
    )

    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: GaiaSpacing.sm) {
            ForEach(items) { item in
                ProfileLogGridCard(item: item)
            }
        }
    }
}

private struct ProfileLogGridCard: View {
    let item: ProfileLogGridItem

    private let cardRadius: CGFloat = GaiaRadius.md

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .bottomLeading) {
                GaiaFindCardArtwork {
                    ProfileLogMedia(source: item.imageSource)
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .clipped()
                }

                Text(item.displayTitle)
                    .gaiaFont(.calloutTight)
                    .foregroundStyle(GaiaColor.paperWhite50)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .truncationMode(.tail)
                    .padding(.horizontal, 8.5)
                    .padding(.bottom, 11.5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .background(GaiaColor.surfaceCard)
        .clipShape(RoundedRectangle(cornerRadius: cardRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: cardRadius, style: .continuous)
                .stroke(GaiaColor.border, lineWidth: 0.5)
        )
        .shadow(color: GaiaShadow.smallColor, radius: GaiaShadow.smallRadius, x: 0, y: GaiaShadow.smallYOffset)
        .contentShape(RoundedRectangle(cornerRadius: cardRadius, style: .continuous))
    }
}

private struct ProfileLogMap: View {
    let content: ProfileLogContent
    let observations: [Observation]

    var body: some View {
        VStack(alignment: .leading, spacing: GaiaSpacing.sm) {
            Text(content.totalFindsLabel)
                .gaiaFont(.subheadSerif)
                .foregroundStyle(GaiaColor.textPrimary)

            ExploreMapView(
                observations: observations,
                recenterRequestID: nil,
                showsMarkers: true,
                initialZoomOverride: 11.8
            )
            .frame(height: 320)
            .clipShape(RoundedRectangle(cornerRadius: GaiaRadius.card, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: GaiaRadius.card, style: .continuous)
                    .stroke(GaiaColor.borderStrong, lineWidth: 0.5)
            )
            .shadow(color: GaiaShadow.mdColor, radius: GaiaShadow.mdRadius, x: 0, y: GaiaShadow.mdYOffset)
        }
    }
}

private struct ProfileLogMedia: View {
    let source: String

    var body: some View {
        if let url = URL(string: source), source.hasPrefix("http") {
            AsyncImage(url: url, transaction: .init(animation: .easeInOut(duration: 0.2))) { phase in
                switch phase {
                case let .success(image):
                    image
                        .resizable()
                        .scaledToFill()
                default:
                    placeholder
                }
            }
        } else {
            GaiaAssetImage(name: source, contentMode: .fill)
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

private struct ProfileLogGlyphImage: View {
    let path: String
    let tint: Color

    var body: some View {
        Group {
            if let uiImage = AssetCatalog.uiImage(named: path) {
                Image(uiImage: uiImage)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(tint)
            }
        }
    }
}

private struct ProfileLogHairline: View {
    var color: Color = GaiaColor.border
    @Environment(\.displayScale) private var displayScale

    var body: some View {
        Rectangle()
            .fill(color)
            .frame(height: 1 / max(displayScale, 1))
            .accessibilityHidden(true)
    }
}

private extension ProfileLogStatusKind {
    var pillVariant: GaiaStatusPillVariant {
        switch self {
        case .researchGrade:
            return .research
        case .casualGrade:
            return .casual
        case .ungraded:
            return .ungraded
        case .needsID:
            return .needsID
        case .draft:
            return .draft
        }
    }
}

private extension ProfileLogGridItem {
    var displayTitle: String {
        title.profileLogInlineText
    }
}

private extension String {
    var profileLogInlineText: String {
        components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }
}
