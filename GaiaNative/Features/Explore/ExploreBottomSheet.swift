// figma: https://www.figma.com/design/4e4G3tnSR7AdPbf0jAYPP1/Gaia?node-id=1912-265748 (Map Half Fold)
// view mode toggle: https://www.figma.com/design/4e4G3tnSR7AdPbf0jAYPP1/Gaia?node-id=1711-179472
import SwiftUI

private enum ExploreBottomSheetLayout {
    static let contentHorizontalInset: CGFloat = 16
    static let dragIndicatorTopPadding: CGFloat = 7
    static let dragIndicatorBottomPadding: CGFloat = 8
    static let dragIndicatorWidth: CGFloat = 88
    static let dragIndicatorHeight: CGFloat = 4
    static let contentTopPadding: CGFloat = 24
    static let contentSectionSpacing: CGFloat = 32
    static let nearbySectionSpacing: CGFloat = 16
    static let filterChipSpacing: CGFloat = 8
    static let filterChipHeight: CGFloat = 34
    static let filterChipHorizontalPadding: CGFloat = 14
    static let projectsSectionSpacing: CGFloat = 12
    static let projectCardSpacing: CGFloat = 8
    static let projectCardWidth: CGFloat = 181
    static let projectCardHeight: CGFloat = 138
    static let projectCardInset: CGFloat = 12
    static let projectCardImageWidth: CGFloat = 157
    static let projectCardImageHeight: CGFloat = 57
    static let projectCardContentSpacing: CGFloat = 8
    static let projectCardTitleBlockSpacing: CGFloat = 6
    static let projectCardArrowGap: CGFloat = 17
    static let findsSectionSpacing: CGFloat = 16
    static let viewModeControlPadding: CGFloat = 4
    static let viewModeControlHeight: CGFloat = 48
    static let viewModeControlSpacing: CGFloat = 4
    static let viewModeButtonSize: CGFloat = 40
    static let viewModeIconSize: CGFloat = GaiaSpacing.iconMd
    static let findCardSpacing: CGFloat = 8
    static let findCardWidth: CGFloat = 180
    static let findCardHeight: CGFloat = 180.005
    static let findGridHeight: CGFloat = 556.0139770507812
    static let findCardCornerRadius: CGFloat = 12.203
    static let findCardBorderWidth: CGFloat = 0.763
    static let findCardTextHorizontalInset: CGFloat = 13
    static let findCardTextBottomInset: CGFloat = 15
    static let bottomContentInset: CGFloat = 120

    static let dragIndicatorColor = Color(
        .sRGB,
        red: 94 / 255,
        green: 98 / 255,
        blue: 98 / 255,
        opacity: 0.25
    )
}

struct ExploreBottomSheet: View {
    let species: [Species]
    let onSelectFind: (Species) -> Void
    let onSelectProject: (ProjectSelection) -> Void
    var allowsScroll: Bool = false
    var showsSurface: Bool = true
    var onPullDownCollapse: (() -> Void)? = nil

    @State private var activeFilter: ExploreSheetFilter = .trending
    @State private var viewMode: ExploreSheetViewMode = .grid
    @State private var scrollTopOffset: CGFloat = 0

    private let projects = ExploreSheetProject.sample
    private let finds = ExploreSheetFind.sample
    var body: some View {
        let topRadius: CGFloat = 48
        let sheetShape = UnevenRoundedRectangle(
            cornerRadii: .init(
                topLeading: topRadius,
                bottomLeading: 0,
                bottomTrailing: 0,
                topTrailing: topRadius
            ),
            style: .continuous
        )

        let content = ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                GeometryReader { proxy in
                    Color.clear
                        .preference(
                            key: ExploreSheetScrollTopPreferenceKey.self,
                            value: proxy.frame(in: .named("ExploreBottomSheetScroll")).minY
                        )
                }
                .frame(height: 0)

                Capsule()
                    .fill(ExploreBottomSheetLayout.dragIndicatorColor)
                    .frame(
                        width: ExploreBottomSheetLayout.dragIndicatorWidth,
                        height: ExploreBottomSheetLayout.dragIndicatorHeight
                    )
                    .frame(maxWidth: .infinity)
                    .padding(.top, ExploreBottomSheetLayout.dragIndicatorTopPadding)
                    .padding(.bottom, ExploreBottomSheetLayout.dragIndicatorBottomPadding)

                VStack(alignment: .leading, spacing: ExploreBottomSheetLayout.contentSectionSpacing) {
                    VStack(alignment: .leading, spacing: ExploreBottomSheetLayout.nearbySectionSpacing) {
                        Text("Nearby")
                            .gaiaFont(.displayMedium)
                            .foregroundStyle(GaiaColor.oliveGreen400)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: ExploreBottomSheetLayout.filterChipSpacing) {
                                ForEach(ExploreSheetFilter.allCases) { filter in
                                    ExploreSheetFilterChip(
                                        filter: filter,
                                        isActive: filter == activeFilter
                                    ) {
                                        activeFilter = filter
                                    }
                                }
                            }
                        }
                        .scrollClipDisabled()
                    }

                    VStack(alignment: .leading, spacing: ExploreBottomSheetLayout.contentSectionSpacing) {
                        VStack(alignment: .leading, spacing: ExploreBottomSheetLayout.projectsSectionSpacing) {
                            ExploreSheetSectionHeader(title: "Projects", trailingText: nil)

                            HStack(spacing: ExploreBottomSheetLayout.projectCardSpacing) {
                                ForEach(projects.prefix(2)) { project in
                                    ExploreSheetProjectCard(project: project) {
                                        onSelectProject(project.detailSelection)
                                    }
                                }
                            }

                            HStack {
                                Spacer()
                                Text("View all")
                                    .gaiaFont(.caption2)
                                    .foregroundStyle(GaiaColor.textSecondary)
                            }
                        }

                        VStack(alignment: .leading, spacing: ExploreBottomSheetLayout.findsSectionSpacing) {
                            ExploreSheetSectionHeader(title: "Finds", trailingText: nil)

                            ExploreSheetViewModeControl(viewMode: $viewMode)

                            if viewMode == .grid {
                                ExploreSheetFindGrid(finds: finds) { _ in
                                    selectPrimarySpecies()
                                }
                            } else {
                                VStack(spacing: ExploreBottomSheetLayout.findCardSpacing) {
                                    ForEach(finds) { find in
                                        ExploreSheetFindListRow(find: find) {
                                            selectPrimarySpecies()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.top, ExploreBottomSheetLayout.contentTopPadding)
                .padding(.horizontal, ExploreBottomSheetLayout.contentHorizontalInset)
            }
            .padding(.bottom, ExploreBottomSheetLayout.bottomContentInset)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .coordinateSpace(name: "ExploreBottomSheetScroll")
        .scrollDisabled(!allowsScroll)
        .onPreferenceChange(ExploreSheetScrollTopPreferenceKey.self) { newValue in
            scrollTopOffset = newValue
        }
        .simultaneousGesture(contentCollapseGesture)

        if showsSurface {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .background(sheetShape.fill(GaiaColor.surfaceSheet))
                .overlay(
                    sheetShape
                        .stroke(GaiaColor.borderStrong, lineWidth: 0.5)
                )
                .clipShape(sheetShape)
                .shadow(color: GaiaShadow.mediumColor, radius: 24, x: 0, y: -4)
        } else {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .clipShape(sheetShape)
        }
    }

    private func selectPrimarySpecies() {
        onSelectFind(species.first ?? PreviewSpecies.coastLiveOak)
    }

    private var contentCollapseGesture: some Gesture {
        DragGesture(minimumDistance: 12, coordinateSpace: .local)
            .onEnded { value in
                guard allowsScroll, canCollapseFromContent(value) else { return }
                onPullDownCollapse?()
            }
    }

    private func canCollapseFromContent(_ value: DragGesture.Value) -> Bool {
        guard scrollTopOffset >= -2 else { return false }

        let verticalTravel = value.translation.height
        let horizontalTravel = abs(value.translation.width)
        let predictedVerticalTravel = value.predictedEndTranslation.height
        let extraMomentum = predictedVerticalTravel - verticalTravel

        guard verticalTravel > 22 else { return false }
        guard verticalTravel > horizontalTravel * 1.15 else { return false }

        return predictedVerticalTravel > 150 || extraMomentum > 70
    }
}

private struct ExploreSheetScrollTopPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

private enum ExploreSheetFilter: String, CaseIterable, Identifiable {
    case trending = "Trending"
    case needsID = "Needs ID"
    case friends = "Friends"

    var id: String { rawValue }
    var title: String { rawValue }
}

private enum ExploreSheetViewMode: CaseIterable, Identifiable {
    case grid
    case list

    var id: Self { self }

    var icon: GaiaIconKind {
        switch self {
        case .grid:
            .grid
        case .list:
            .list
        }
    }

    var accessibilityLabel: String {
        switch self {
        case .grid:
            "Grid view"
        case .list:
            "List view"
        }
    }
}

private struct ExploreSheetSectionHeader: View {
    let title: String
    let trailingText: String?

    var body: some View {
        HStack(alignment: .center) {
            Text(title)
                .gaiaFont(.titleSans)
                .foregroundStyle(GaiaColor.textSecondary)

            Spacer(minLength: 12)

            if let trailingText {
                Text(trailingText)
                    .gaiaFont(.caption2)
                    .foregroundStyle(GaiaColor.textSecondary)
            }
        }
    }
}

private struct ExploreSheetFilterChip: View {
    let filter: ExploreSheetFilter
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(filter.title)
                .gaiaFont(.subheadline)
                .foregroundStyle(isActive ? GaiaColor.paperWhite50 : GaiaColor.textDisabled)
                .padding(.horizontal, ExploreBottomSheetLayout.filterChipHorizontalPadding)
                .frame(height: ExploreBottomSheetLayout.filterChipHeight)
                .background(
                    Capsule()
                        .fill(isActive ? GaiaColor.oliveGreen400 : GaiaColor.surfaceControlSubtle)
                )
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

private struct ExploreSheetViewModeControl: View {
    @Binding var viewMode: ExploreSheetViewMode

    private var modes: [ExploreSheetViewMode] { ExploreSheetViewMode.allCases }
    private var controlWidth: CGFloat {
        let modeCount = CGFloat(modes.count)
        let totalSpacing = CGFloat(max(modes.count - 1, 0)) * ExploreBottomSheetLayout.viewModeControlSpacing
        return (modeCount * ExploreBottomSheetLayout.viewModeButtonSize)
            + totalSpacing
            + (ExploreBottomSheetLayout.viewModeControlPadding * 2)
    }
    private var segmentStep: CGFloat {
        ExploreBottomSheetLayout.viewModeButtonSize + ExploreBottomSheetLayout.viewModeControlSpacing
    }
    private var selectedIndex: Int {
        modes.firstIndex(of: viewMode) ?? 0
    }

    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                .fill(GaiaColor.surfaceControlSubtle)

            RoundedRectangle(cornerRadius: GaiaRadius.sm, style: .continuous)
                .fill(GaiaColor.oliveGreen400)
                .frame(
                    width: ExploreBottomSheetLayout.viewModeButtonSize,
                    height: ExploreBottomSheetLayout.viewModeButtonSize
                )
                .offset(
                    x: ExploreBottomSheetLayout.viewModeControlPadding + (CGFloat(selectedIndex) * segmentStep)
                )

            HStack(spacing: ExploreBottomSheetLayout.viewModeControlSpacing) {
                ForEach(modes) { mode in
                    ExploreSheetViewToggleButton(
                        mode: mode,
                        isActive: viewMode == mode
                    ) {
                        select(mode)
                    }
                }
            }
            .padding(ExploreBottomSheetLayout.viewModeControlPadding)
        }
        .frame(
            width: controlWidth,
            height: ExploreBottomSheetLayout.viewModeControlHeight,
            alignment: .leading
        )
        .contentShape(RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous))
        .animation(GaiaMotion.spring, value: viewMode)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Find view mode")
        .accessibilityHint("Switches between grid and list results")
    }

    private func select(_ mode: ExploreSheetViewMode) {
        guard viewMode != mode else { return }
        HapticsService.selectionChanged()
        withAnimation(GaiaMotion.spring) {
            viewMode = mode
        }
    }
}

private struct ExploreSheetViewToggleButton: View {
    let mode: ExploreSheetViewMode
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            GaiaIcon(
                kind: mode.icon,
                size: ExploreBottomSheetLayout.viewModeIconSize,
                tint: isActive ? GaiaColor.paperWhite50 : GaiaColor.textDisabled
            )
            .frame(
                width: ExploreBottomSheetLayout.viewModeButtonSize,
                height: ExploreBottomSheetLayout.viewModeButtonSize
            )
            .contentShape(RoundedRectangle(cornerRadius: GaiaRadius.sm, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(mode.accessibilityLabel)
        .accessibilityAddTraits(isActive ? [.isSelected] : [])
    }
}

private struct ExploreSheetProjectCard: View {
    let project: ExploreSheetProject
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            GaiaProjectSummaryCard(
                title: project.title,
                subtitle: project.subtitle,
                location: project.location,
                imageName: project.imageName,
                width: ExploreBottomSheetLayout.projectCardWidth
            )
        }
        .buttonStyle(GaiaPressableCardStyle())
        .accessibilityLabel("\(project.title), \(project.location)")
        .accessibilityHint("Opens the project details page")
    }
}

private struct ExploreSheetFindGrid: View {
    let finds: [ExploreSheetFind]
    let action: (ExploreSheetFind) -> Void

    var body: some View {
        let columns = [
            GridItem(.fixed(ExploreBottomSheetLayout.findCardWidth), spacing: ExploreBottomSheetLayout.findCardSpacing, alignment: .top),
            GridItem(.fixed(ExploreBottomSheetLayout.findCardWidth), spacing: ExploreBottomSheetLayout.findCardSpacing, alignment: .top)
        ]

        LazyVGrid(columns: columns, alignment: .leading, spacing: ExploreBottomSheetLayout.findCardSpacing) {
            ForEach(finds) { find in
                ExploreSheetFindGridCard(find: find) {
                    action(find)
                }
            }
        }
        .frame(height: ExploreBottomSheetLayout.findGridHeight, alignment: .top)
    }
}

private struct ExploreSheetFindGridCard: View {
    let find: ExploreSheetFind
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .bottomLeading) {
                GaiaAssetImage(name: find.imageName)
                    .frame(width: ExploreBottomSheetLayout.findCardWidth, height: ExploreBottomSheetLayout.findCardHeight)
                    .clipped()

                LinearGradient(
                    stops: [
                        .init(color: .clear, location: 0.54),
                        .init(color: Color.black.opacity(0.4), location: 1)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                Text(find.title)
                    .gaiaFont(.titleSans)
                    .foregroundStyle(GaiaColor.paperWhite50)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .shadow(color: GaiaColor.broccoliBrown500.opacity(0.24), radius: 12, x: 0, y: 6)
                    .padding(.horizontal, ExploreBottomSheetLayout.findCardTextHorizontalInset)
                    .padding(.bottom, ExploreBottomSheetLayout.findCardTextBottomInset)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
            }
            .frame(width: ExploreBottomSheetLayout.findCardWidth, height: ExploreBottomSheetLayout.findCardHeight)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: ExploreBottomSheetLayout.findCardCornerRadius,
                    style: .continuous
                )
            )
            .overlay(
                RoundedRectangle(
                    cornerRadius: ExploreBottomSheetLayout.findCardCornerRadius,
                    style: .continuous
                )
                .stroke(GaiaColor.blackishGrey200, lineWidth: ExploreBottomSheetLayout.findCardBorderWidth)
            )
            .shadow(color: GaiaShadow.smallColor, radius: 15.254, x: 0, y: 6.102)
            .contentShape(
                RoundedRectangle(
                    cornerRadius: ExploreBottomSheetLayout.findCardCornerRadius,
                    style: .continuous
                )
            )
        }
        .buttonStyle(GaiaPressableCardStyle())
    }
}

private struct ExploreSheetFindListRow: View {
    let find: ExploreSheetFind
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                GaiaAssetImage(name: find.imageName)
                    .frame(width: 88, height: 88)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                Text(find.title)
                    .gaiaFont(.title3)
                    .foregroundStyle(GaiaColor.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                ExploreSheetTemplateIcon(
                    path: "Icons/System/chevron-20.png",
                    tint: UIColor(GaiaColor.greyMuted),
                    size: CGSize(width: 12, height: 12)
                )
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(GaiaColor.surfaceCard)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(GaiaColor.broccoliBrown100, lineWidth: 0.5)
            )
        }
        .buttonStyle(GaiaPressableCardStyle())
    }
}

private struct ExploreSheetTemplateIcon: View {
    let path: String
    let tint: UIColor
    let size: CGSize

    var body: some View {
        Group {
            if let uiImage = AssetCatalog.uiImage(named: path) {
                Image(uiImage: uiImage)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(Color(uiColor: tint))
            }
        }
        .frame(width: size.width, height: size.height)
    }
}

private struct ExploreSheetProject: Identifiable {
    let id: String
    let title: String
    let tag: String
    let subtitle: String
    let location: String
    let imageName: String
    let countLabel: String

    var detailSelection: ProjectSelection {
        ProjectSelection(
            id: id,
            title: title,
            tag: tag,
            countLabel: countLabel,
            imageName: imageName
        )
    }

    static let sample: [ExploreSheetProject] = [
        .init(id: "project-creek", title: "Creek Recovery", tag: "Wetland", subtitle: "2 days to go", location: "Pasadena, CA", imageName: "find-project-creek", countLabel: "12"),
        .init(id: "project-pollinator", title: "Pollinator Corridor", tag: "Garden", subtitle: "4 days to go", location: "San Marino, CA", imageName: "find-project-pollinator", countLabel: "12"),
        .init(id: "project-sea", title: "Sea Creatures", tag: "Ocean", subtitle: "Ends tomorrow", location: "Malibu, CA", imageName: "coast-live-oak-gallery-4", countLabel: "12")
    ]
}

private struct ExploreSheetFind: Identifiable {
    let id: String
    let title: String
    let imageName: String

    static let sample: [ExploreSheetFind] = [
        .init(id: "find-bindweed-tribe", title: "Bindweed Tribe", imageName: "coast-live-oak-gallery-3"),
        .init(id: "find-emperor-gum-moth", title: "Emperor Gum Moth", imageName: "coast-live-oak-gallery-4"),
        .init(id: "find-garden-orbweaver", title: "Garden Orbweaver", imageName: "observe-photo-square"),
        .init(id: "find-coast-live-oak", title: "Coast Live Oak", imageName: "coast-live-oak-hero"),
        .init(id: "find-indian-cormorant", title: "Indian Cormorant", imageName: "coast-live-oak-gallery-1"),
        .init(id: "find-european-roller", title: "European Roller", imageName: "coast-live-oak-gallery-2")
    ]
}
