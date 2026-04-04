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
        VStack(spacing: 0) {
            ProfileLogHeader(
                presentation: .standalone,
                searchText: $searchText,
                viewMode: $viewMode
            )
            .padding(.horizontal, GaiaSpacing.md)
            .padding(.top, 12)
            .padding(.bottom, 12)
            .background(GaiaColor.surfacePrimary)
            .zIndex(1)

            ScrollView(showsIndicators: false) {
                ProfileLogBody(
                    content: contentStore.profileLog,
                    observations: contentStore.observations,
                    searchText: searchText,
                    viewMode: viewMode
                )
                .padding(.bottom, 156)
            }
        }
        .background(GaiaColor.surfacePrimary)
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
        VStack(alignment: .leading, spacing: GaiaSpacing.md) {
            if presentation == .standalone {
                Text("Log")
                    .gaiaFont(.title1Medium)
                    .foregroundStyle(GaiaColor.brandPrimary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, GaiaSpacing.sm)
            }

            ProfileLogSearchBar(text: $searchText)

            HStack(spacing: GaiaSpacing.sm) {
                ProfileLogViewToggle(selection: $viewMode)
                Spacer(minLength: 0)
                ProfileLogFilterButton()
            }
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
                    .padding(.horizontal, GaiaSpacing.md)
            case .map:
                ProfileLogMap(content: content, observations: observations)
                    .padding(.horizontal, GaiaSpacing.md)
            }
        }
        .padding(.top, GaiaSpacing.xs)
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
        HStack(spacing: 4) {
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
        .padding(.horizontal, 8)
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
                ProfileLogDayBar(title: section.title, countLabel: section.countLabel)

                ForEach(Array(section.entries.enumerated()), id: \.element.id) { _, entry in
                    ProfileLogRow(entry: entry)

                    Rectangle()
                        .fill(GaiaColor.border)
                        .frame(height: 1)
                }
            }
        }
    }
}

private struct ProfileLogDayBar: View {
    let title: String
    let countLabel: String

    var body: some View {
        HStack(spacing: 10) {
            Text(title)
                .gaiaFont(.footnoteMedium)
                .foregroundStyle(GaiaColor.textPrimary)

            Text(countLabel)
                .gaiaFont(.caption)
                .foregroundStyle(GaiaColor.blackishGrey200)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: 33)
        .background(GaiaColor.paperWhite500)
        .overlay(alignment: .top) {
            Rectangle().fill(GaiaColor.border).frame(height: 1)
        }
        .overlay(alignment: .bottom) {
            Rectangle().fill(GaiaColor.border).frame(height: 1)
        }
    }
}

private struct ProfileLogRow: View {
    let entry: ProfileLogEntry

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            HStack(alignment: .center, spacing: 14) {
                ProfileLogMedia(source: entry.imageSource)
                    .frame(width: 76, height: 76)
                    .clipShape(RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous))

                VStack(alignment: .leading, spacing: GaiaSpacing.md) {
                    VStack(alignment: .leading, spacing: GaiaSpacing.sm) {
                        Text(entry.commonName)
                            .gaiaFont(.title3)
                            .foregroundStyle(GaiaColor.textPrimary)
                            .lineLimit(1)
                            .truncationMode(.tail)

                        Text(entry.scientificName)
                            .gaiaFont(.footnote)
                            .italic()
                            .foregroundStyle(GaiaColor.broccoliBrown500)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }

                    Text(entry.metaLabel)
                        .gaiaFont(.caption)
                        .foregroundStyle(GaiaColor.blackishGrey300)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .layoutPriority(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            ProfileLogStatusPill(title: entry.statusLabel, kind: entry.statusKind)
                .padding(.top, 1)
        }
        .padding(.horizontal, GaiaSpacing.md)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, minHeight: 104, alignment: .leading)
        .background(GaiaColor.paperWhite50)
    }
}

private struct ProfileLogStatusPill: View {
    let title: String
    let kind: ProfileLogStatusKind

    var body: some View {
        Text(title)
            .gaiaFont(.footnote)
            .foregroundStyle(foreground)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
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
        switch kind {
        case .researchGrade:
            return GaiaColor.oliveGreen100
        case .needsID:
            return GaiaColor.broccoliBrown100
        case .draft:
            return GaiaColor.blackishGrey50
        }
    }

    private var stroke: Color {
        switch kind {
        case .researchGrade:
            return GaiaColor.brandPrimary
        case .needsID:
            return GaiaColor.broccoliBrown500
        case .draft:
            return GaiaColor.blackishGrey200
        }
    }

    private var foreground: Color {
        switch kind {
        case .researchGrade:
            return GaiaColor.brandPrimary
        case .needsID:
            return GaiaColor.broccoliBrown500
        case .draft:
            return GaiaColor.textSecondary
        }
    }
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
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .truncationMode(.tail)
                    .padding(.horizontal, 9)
                    .padding(.bottom, 8)
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
        .shadow(color: Color(red: 128 / 255, green: 105 / 255, blue: 38 / 255).opacity(0.09), radius: 10, x: 0, y: 4)
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
