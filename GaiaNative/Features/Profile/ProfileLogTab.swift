// figma: https://www.figma.com/design/4e4G3tnSR7AdPbf0jAYPP1/Gaia?node-id=875-22224 (Grid), 875-23464 (Log List), 875-23090 (Log Top Bar)
import SwiftUI

private enum ProfileLogViewMode: String, CaseIterable, Identifiable {
    case grid
    case list
    case map

    var id: String { rawValue }
}

enum ProfileLogPresentation {
    case standalone
    case embedded
}

struct LogScreen: View {
    @EnvironmentObject private var contentStore: ContentStore
    @State private var searchText = ""
    @State private var viewMode: ProfileLogViewMode = profileLogLaunchViewMode() ?? .list

    var body: some View {
        ScrollView(showsIndicators: false) {
            ProfileLogBody(
                content: contentStore.profileLog,
                observations: contentStore.observations,
                searchText: searchText,
                viewMode: viewMode
            )
            .padding(.bottom, GaiaSpacing.xxl)
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            ProfileLogHeader(
                presentation: .standalone,
                searchText: $searchText,
                viewMode: $viewMode
            )
            .background(GaiaColor.paperWhite50)
        }
        .background(GaiaColor.paperWhite50)
    }
}

struct ProfileLogTab: View {
    let content: ProfileLogContent
    let presentation: ProfileLogPresentation

    @EnvironmentObject private var contentStore: ContentStore

    @State private var searchText = ""
    @State private var viewMode: ProfileLogViewMode

    init(content: ProfileLogContent, presentation: ProfileLogPresentation = .standalone) {
        self.content = content
        self.presentation = presentation
        _viewMode = State(initialValue: profileLogLaunchViewMode() ?? .list)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: GaiaSpacing.md) {
            ProfileLogHeader(
                presentation: presentation,
                searchText: $searchText,
                viewMode: $viewMode
            )

            ProfileLogBody(
                content: content,
                observations: contentStore.observations,
                searchText: searchText,
                viewMode: viewMode
            )
        }
    }
}

private struct ProfileLogHeader: View {
    let presentation: ProfileLogPresentation
    @Binding var searchText: String
    @Binding var viewMode: ProfileLogViewMode

    var body: some View {
        Group {
            switch presentation {
            case .standalone:
                ProfileLogStandaloneHeader(viewMode: $viewMode)
            case .embedded:
                VStack(alignment: .leading, spacing: GaiaSpacing.md) {
                    ProfileLogSearchBar(text: $searchText)

                    HStack(spacing: GaiaSpacing.sm) {
                        ProfileLogViewToggle(selection: $viewMode)
                        Spacer(minLength: 0)
                        ProfileLogFilterButton()
                    }
                }
            }
        }
    }
}

private struct ProfileLogStandaloneHeader: View {
    @Binding var viewMode: ProfileLogViewMode

    var body: some View {
        VStack(spacing: GaiaSpacing.sm) {
            HStack {
                ProfileLogTopActionButton(accessibilityLabel: "Search log") {
                    GaiaIcon(kind: .search, size: 20, tint: GaiaColor.brandPrimary)
                }

                Spacer(minLength: 0)

                Text("Log")
                    .gaiaFont(.title1Medium)
                    .foregroundStyle(GaiaColor.brandPrimary)

                Spacer(minLength: 0)

                ProfileLogTopActionButton(accessibilityLabel: "Filter log") {
                    ProfileLogGlyphImage(path: "Icons/System/filter-32.png", tint: GaiaColor.brandPrimary)
                        .frame(width: 20, height: 20)
                }
            }
            .frame(height: 48)
            .padding(.horizontal, GaiaSpacing.md)
            .padding(.top, GaiaSpacing.sm)

            ProfileLogViewToggle(selection: $viewMode)
        }
        .padding(.bottom, GaiaSpacing.md)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(GaiaColor.border)
                .frame(height: 0.5)
        }
    }
}

private struct ProfileLogTopActionButton<Label: View>: View {
    let accessibilityLabel: String
    var size: CGFloat = 44
    @ViewBuilder let label: () -> Label

    var body: some View {
        Button(action: {}) {
            label()
                .frame(width: size, height: size)
                .contentShape(Rectangle())
        }
        .buttonStyle(GlassReactiveButtonStyle())
        .accessibilityLabel(accessibilityLabel)
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
                    .padding(.horizontal, GaiaSpacing.md)
            case .map:
                ProfileLogMap(content: content, observations: observations)
                    .padding(.horizontal, GaiaSpacing.md)
            }
        }
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
        $0.title.replacingOccurrences(of: "\n", with: " ").lowercased().contains(needle)
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
        .background(GaiaMaterialBackground(cornerRadius: GaiaRadius.full))
        .clipShape(Capsule())
        .contentShape(Capsule())
        .shadow(color: GaiaShadow.navColor.opacity(0.28), radius: 16, x: 0, y: 6)
        .onTapGesture {
            isFocused = true
        }
    }
}

private struct ProfileLogViewToggle: View {
    @Binding var selection: ProfileLogViewMode
    @State private var dragOffset: CGFloat?

    private let buttonSize: CGFloat = 40
    private let gap: CGFloat = 4
    private let pad: CGFloat = 4
    private let buttonRadius: CGFloat = GaiaRadius.sm
    private var containerRadius: CGFloat { GaiaRadius.md }
    private var step: CGFloat { buttonSize + gap }
    private var modes: [ProfileLogViewMode] { ProfileLogViewMode.allCases }

    var body: some View {
        let selectedIdx = modes.firstIndex(of: selection) ?? 0
        let indicatorX = dragOffset ?? (CGFloat(selectedIdx) * step)

        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: buttonRadius, style: .continuous)
                .fill(GaiaColor.brandPrimary)
                .frame(width: buttonSize, height: buttonSize)
                .offset(x: indicatorX)

            HStack(spacing: gap) {
                ForEach(modes) { mode in
                    Button { select(mode) } label: {
                        icon(for: mode, selected: selection == mode)
                            .frame(width: 22, height: 22)
                            .frame(width: buttonSize, height: buttonSize)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(GlassReactiveButtonStyle())
                }
            }
        }
        .padding(pad)
        .background(
            RoundedRectangle(cornerRadius: containerRadius, style: .continuous)
                .fill(GaiaColor.oliveGreen100)
        )
        .contentShape(Rectangle())
        .highPriorityGesture(modeDragGesture)
        .animation(
            dragOffset == nil
                ? GaiaMotion.spring
                : .interactiveSpring(response: 0.18, dampingFraction: 0.86),
            value: indicatorX
        )
    }

    private func select(_ mode: ProfileLogViewMode) {
        guard selection != mode else { return }
        HapticsService.selectionChanged()
        withAnimation(GaiaMotion.spring) {
            selection = mode
        }
    }

    private var modeDragGesture: some Gesture {
        DragGesture(minimumDistance: 4, coordinateSpace: .local)
            .onChanged { value in
                let x = value.location.x - pad
                dragOffset = max(0, min(x - buttonSize / 2, step * CGFloat(modes.count - 1)))

                let idx = min(max(Int(x / step), 0), modes.count - 1)
                let mode = modes[idx]
                if selection != mode {
                    HapticsService.selectionChanged()
                    selection = mode
                }
            }
            .onEnded { _ in
                dragOffset = nil
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

private struct ProfileLogFilterButton: View {
    var body: some View {
        Button(action: {}) {
            RoundedRectangle(cornerRadius: GaiaRadius.sm, style: .continuous)
                .fill(GaiaColor.brandPrimary)
                .frame(width: 44, height: 44)
                .overlay {
                    ProfileLogGlyphImage(path: "Icons/System/filter-32.png", tint: GaiaColor.paperWhite50)
                        .frame(width: 20, height: 20)
                }
        }
        .buttonStyle(GlassReactiveButtonStyle())
        .shadow(color: GaiaShadow.navColor.opacity(0.18), radius: 12, x: 0, y: 4)
    }
}

private struct ProfileLogList: View {
    let sections: [ProfileLogSection]

    var body: some View {
        LazyVStack(alignment: .leading, spacing: -0.5) {
            ForEach(sections) { section in
                ProfileLogDayBar(title: section.title, countLabel: section.countLabel)

                ForEach(section.entries) { entry in
                    ProfileLogRow(entry: entry)
                }
            }
        }
    }
}

private struct ProfileLogDayBar: View {
    let title: String
    let countLabel: String

    var body: some View {
        HStack(alignment: .lastTextBaseline, spacing: 10) {
            Text(title)
                .gaiaFont(.title1Medium)
                .foregroundStyle(GaiaColor.inkBlack300)

            Text(countLabel)
                .gaiaFont(.caption2)
                .foregroundStyle(GaiaColor.brandPrimary)
        }
        .padding(.horizontal, GaiaSpacing.md)
        .padding(.top, GaiaSpacing.lg)
        .padding(.bottom, GaiaSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 68, alignment: .bottomLeading)
        .background(GaiaColor.paperWhite50)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(GaiaColor.border)
                .frame(height: 0.5)
        }
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(GaiaColor.border)
                .frame(height: 0.5)
        }
    }
}

private struct ProfileLogRow: View {
    let entry: ProfileLogEntry

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ProfileLogMedia(source: entry.imageSource)
                .frame(width: 76, height: 76)
                .clipShape(RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous))

            VStack(alignment: .leading, spacing: GaiaSpacing.cardInset) {
                VStack(alignment: .leading, spacing: GaiaSpacing.sm) {
                    Text(entry.commonName)
                        .gaiaFont(.titleSans)
                        .foregroundStyle(GaiaColor.textPrimary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
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

            ProfileLogStatusPill(title: entry.statusLabel, kind: entry.statusKind)
                .padding(.top, GaiaSpacing.xxs / 2)
        }
        .padding(.horizontal, GaiaSpacing.md)
        .padding(.vertical, GaiaSpacing.buttonHorizontalLarge)
        .frame(maxWidth: .infinity, minHeight: 104, alignment: .leading)
        .background(GaiaColor.paperWhite50)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(GaiaColor.border)
                .frame(height: 0.5)
        }
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(GaiaColor.border)
                .frame(height: 0.5)
        }
    }
}

private struct ProfileLogStatusPill: View {
    let title: String
    let kind: ProfileLogStatusKind

    var body: some View {
        Text(title)
            .gaiaFont(.footnote)
            .foregroundStyle(foreground)
            .padding(.horizontal, GaiaSpacing.pillHorizontal)
            .padding(.vertical, GaiaSpacing.xs)
            .frame(height: 28)
            .background(
                Capsule()
                    .fill(fill)
                    .overlay(
                        Capsule()
                            .stroke(stroke, lineWidth: 0.5)
                    )
            )
            .fixedSize()
    }

    private var fill: Color {
        switch appearance {
        case .researchGrade:
            return GaiaColor.oliveGreen100
        case .casualGrade, .ungraded:
            return GaiaColor.paperWhite50
        case .needsID:
            return GaiaColor.broccoliBrown100
        case .draft:
            return GaiaColor.blackishGrey50
        }
    }

    private var stroke: Color {
        switch appearance {
        case .researchGrade:
            return GaiaColor.brandPrimary
        case .casualGrade:
            return GaiaColor.oliveGreen200
        case .ungraded:
            return GaiaColor.blackishGrey200
        case .needsID:
            return GaiaColor.broccoliBrown500
        case .draft:
            return GaiaColor.blackishGrey200
        }
    }

    private var foreground: Color {
        switch appearance {
        case .researchGrade, .casualGrade:
            return GaiaColor.brandPrimary
        case .ungraded:
            return GaiaColor.blackishGrey200
        case .needsID:
            return GaiaColor.broccoliBrown500
        case .draft:
            return GaiaColor.textSecondary
        }
    }

    private var appearance: ProfileLogStatusAppearance {
        switch title.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
        case "research grade":
            return .researchGrade
        case "casual grade":
            return .casualGrade
        case "ungraded":
            return .ungraded
        default:
            switch kind {
            case .researchGrade:
                return .researchGrade
            case .needsID:
                return .needsID
            case .draft:
                return .draft
            }
        }
    }
}

private enum ProfileLogStatusAppearance {
    case researchGrade
    case casualGrade
    case ungraded
    case needsID
    case draft
}

private struct ProfileLogGrid: View {
    let items: [ProfileLogGridItem]

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 3)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
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
                ProfileLogMedia(source: item.imageSource)
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .clipped()

                ProfileLogMedia(source: item.imageSource)
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .clipped()
                    .blur(radius: 3.7)
                    .mask(
                        LinearGradient(
                            stops: [
                                .init(color: .clear, location: 0),
                                .init(color: .clear, location: 0.22),
                                .init(color: .black.opacity(0.58), location: 0.72),
                                .init(color: .black, location: 1)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                LinearGradient(
                    colors: [
                        Color.black.opacity(0),
                        Color.black.opacity(0.56)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                Text(item.title)
                    .gaiaFont(.bodySerif)
                    .foregroundStyle(GaiaColor.paperWhite50)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .truncationMode(.tail)
                    .padding(.horizontal, GaiaSpacing.pillHorizontal - (GaiaSpacing.xxs / 2))
                    .padding(.bottom, GaiaSpacing.sm)
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
        .shadow(color: GaiaShadow.smallColor, radius: 10, x: 0, y: 4)
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
