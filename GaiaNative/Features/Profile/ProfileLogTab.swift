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

    var body: some View {
        ScrollView(showsIndicators: false) {
            ProfileLogTab(content: contentStore.profileLog, presentation: .standalone)
                .padding(.horizontal, GaiaSpacing.md)
                .padding(.top, 8)
                .padding(.bottom, 120)
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
        _viewMode = State(initialValue: Self.launchViewMode ?? .list)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: GaiaSpacing.md) {
            if presentation == .standalone {
                Text("Log")
                    .font(GaiaTypography.title1Medium)
                    .foregroundStyle(GaiaColor.brandPrimary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, GaiaSpacing.xs)
            }

            ProfileLogSearchBar(text: $searchText)

            HStack(spacing: GaiaSpacing.sm) {
                ProfileLogViewToggle(selection: $viewMode)
                Spacer(minLength: 0)
                ProfileLogFilterButton()
            }

            Group {
                switch viewMode {
                case .list:
                    ProfileLogList(sections: filteredSections)
                case .grid:
                    ProfileLogGrid(items: filteredGridItems)
                case .map:
                    ProfileLogMap(content: content, observations: contentStore.observations)
                }
            }
            .padding(.top, GaiaSpacing.xs)
        }
    }

    private var filteredSections: [ProfileLogSection] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return content.listSections }

        let needle = query.lowercased()
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

    private var filteredGridItems: [ProfileLogGridItem] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return content.gridItems }

        let needle = query.lowercased()
        return content.gridItems.filter { $0.title.replacingOccurrences(of: "\n", with: " ").lowercased().contains(needle) }
    }

    private static var launchViewMode: ProfileLogViewMode? {
        let arguments = ProcessInfo.processInfo.arguments
        guard let flagIndex = arguments.firstIndex(of: "-gaiaLogView"),
              arguments.indices.contains(flagIndex + 1) else {
            return nil
        }

        return ProfileLogViewMode(rawValue: arguments[flagIndex + 1].lowercased())
    }
}

private struct ProfileLogSearchBar: View {
    @Binding var text: String
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 10) {
            GaiaIcon(kind: .search, size: 20, tint: GaiaColor.brandPrimary)
                .frame(width: 24, height: 24)

            TextField(
                "",
                text: $text,
                prompt: Text("Search species, location, notes...")
                    .font(GaiaTypography.subheadline)
                    .foregroundStyle(GaiaColor.textSecondary.opacity(0.55))
            )
            .font(GaiaTypography.subheadline)
            .foregroundStyle(GaiaColor.textPrimary)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .focused($isFocused)
        }
        .padding(.horizontal, 16)
        .frame(height: 48)
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

    var body: some View {
        HStack(spacing: 6) {
            ForEach(ProfileLogViewMode.allCases) { mode in
                Button {
                    selection = mode
                } label: {
                    ZStack {
                        if selection == mode {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(GaiaColor.brandPrimary)
                        }

                        icon(for: mode, selected: selection == mode)
                            .frame(width: 18, height: 18)
                    }
                    .frame(width: 40, height: 40)
                }
                .buttonStyle(GlassReactiveButtonStyle())
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(GaiaColor.oliveGreen100.opacity(0.55))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(GaiaColor.oliveGreen100, lineWidth: 0.5)
        )
        .shadow(color: GaiaShadow.navColor.opacity(0.16), radius: 12, x: 0, y: 4)
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
            ProfileLogMapGlyph()
                .stroke(tint, lineWidth: 1.5)
        }
    }
}

private struct ProfileLogFilterButton: View {
    var body: some View {
        Button(action: {}) {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(GaiaColor.brandPrimary)
                .frame(width: 48, height: 48)
                .overlay {
                    ProfileLogGlyphImage(path: "Icons/System/gear-20.png", tint: GaiaColor.paperWhite50)
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
        LazyVStack(alignment: .leading, spacing: GaiaSpacing.md) {
            ForEach(sections) { section in
                VStack(spacing: 0) {
                    HStack {
                        Text(section.title)
                            .font(GaiaTypography.captionMedium)
                            .foregroundStyle(GaiaColor.textPrimary)
                        Spacer()
                        Text(section.countLabel)
                            .font(GaiaTypography.caption)
                            .foregroundStyle(GaiaColor.blackishGrey200)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 11)
                    .frame(maxWidth: .infinity)
                    .background(GaiaColor.blackishGrey50)

                    ForEach(Array(section.entries.enumerated()), id: \.element.id) { index, entry in
                        VStack(spacing: 0) {
                            ProfileLogRow(entry: entry)

                            if index < section.entries.count - 1 {
                                Rectangle()
                                    .fill(GaiaColor.oliveGreen100)
                                    .frame(height: 1)
                            }
                        }
                    }
                }
            }
        }
    }
}

private struct ProfileLogRow: View {
    let entry: ProfileLogEntry

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            ProfileLogMedia(source: entry.imageSource)
                .frame(width: 56, height: 56)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(Color.white.opacity(0.32), lineWidth: 0.5)
                )
                .shadow(color: GaiaShadow.smallColor, radius: GaiaShadow.smallRadius, x: 0, y: GaiaShadow.smallYOffset)

            VStack(alignment: .leading, spacing: 4) {
                Text(entry.commonName)
                    .font(GaiaTypography.title2)
                    .foregroundStyle(GaiaColor.textPrimary)
                    .lineLimit(1)

                Text(entry.scientificName)
                    .font(GaiaTypography.subheadline)
                    .italic()
                    .foregroundStyle(GaiaColor.textSecondary)
                    .lineLimit(1)

                Text(entry.metaLabel)
                    .font(GaiaTypography.caption)
                    .foregroundStyle(GaiaColor.textSecondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            ProfileLogStatusPill(title: entry.statusLabel, kind: entry.statusKind)
        }
        .padding(.vertical, 18)
        .frame(maxWidth: .infinity, minHeight: 92, alignment: .leading)
    }
}

private struct ProfileLogStatusPill: View {
    let title: String
    let kind: ProfileLogStatusKind

    var body: some View {
        Text(title)
            .font(GaiaTypography.footnote)
            .foregroundStyle(foreground)
            .padding(.horizontal, 12)
            .frame(height: 30)
            .background(
                Capsule()
                    .fill(fill)
                    .overlay(
                        Capsule()
                            .stroke(stroke, lineWidth: 1)
                    )
            )
            .fixedSize()
    }

    private var fill: Color {
        switch kind {
        case .researchGrade:
            return GaiaColor.oliveGreen50
        case .needsID:
            return GaiaColor.broccoliBrown50
        case .draft:
            return GaiaColor.blackishGrey50
        }
    }

    private var stroke: Color {
        switch kind {
        case .researchGrade:
            return GaiaColor.oliveGreen200
        case .needsID:
            return GaiaColor.broccoliBrown200
        case .draft:
            return GaiaColor.blackishGrey100
        }
    }

    private var foreground: Color {
        switch kind {
        case .researchGrade:
            return GaiaColor.brandPrimary
        case .needsID:
            return GaiaColor.brandSecondary
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

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .bottomLeading) {
                ProfileLogMedia(source: item.imageSource)
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .clipped()
                    .overlay(
                        LinearGradient(
                            colors: [
                                Color.black.opacity(0.02),
                                Color.black.opacity(0.10),
                                Color.black.opacity(0.55)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                Text(item.title)
                    .font(GaiaTypography.subheadSerif)
                    .foregroundStyle(GaiaColor.paperWhite50)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .padding(10)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .background(GaiaColor.surfaceCard)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(GaiaColor.borderStrong, lineWidth: 0.5)
        )
        .shadow(color: GaiaShadow.smallColor, radius: GaiaShadow.smallRadius, x: 0, y: GaiaShadow.smallYOffset)
        .contentShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

private struct ProfileLogMap: View {
    let content: ProfileLogContent
    let observations: [Observation]

    var body: some View {
        VStack(alignment: .leading, spacing: GaiaSpacing.sm) {
            Text(content.totalFindsLabel)
                .font(GaiaTypography.subheadSerif)
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

private struct ProfileLogMapGlyph: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: rect.minX + rect.width * 0.30, y: rect.minY + rect.height * 0.16))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.08, y: rect.minY + rect.height * 0.30))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.08, y: rect.minY + rect.height * 0.90))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.30, y: rect.minY + rect.height * 0.76))

        path.move(to: CGPoint(x: rect.minX + rect.width * 0.30, y: rect.minY + rect.height * 0.16))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.58, y: rect.minY + rect.height * 0.30))

        path.move(to: CGPoint(x: rect.minX + rect.width * 0.30, y: rect.minY + rect.height * 0.16))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.30, y: rect.minY + rect.height * 0.76))

        path.move(to: CGPoint(x: rect.minX + rect.width * 0.58, y: rect.minY + rect.height * 0.30))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.92, y: rect.minY + rect.height * 0.16))

        path.move(to: CGPoint(x: rect.minX + rect.width * 0.58, y: rect.minY + rect.height * 0.30))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.58, y: rect.minY + rect.height * 0.90))

        path.move(to: CGPoint(x: rect.minX + rect.width * 0.92, y: rect.minY + rect.height * 0.16))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.92, y: rect.minY + rect.height * 0.76))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.58, y: rect.minY + rect.height * 0.90))

        path.move(to: CGPoint(x: rect.minX + rect.width * 0.30, y: rect.minY + rect.height * 0.76))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.58, y: rect.minY + rect.height * 0.90))

        return path
    }
}
