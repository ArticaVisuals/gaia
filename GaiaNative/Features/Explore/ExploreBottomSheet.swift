import SwiftUI
import UIKit

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
    private let sectionInset: CGFloat = 16

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
                    .fill(GaiaColor.greyMuted.opacity(0.25))
                    .frame(width: 88, height: 4)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 7)
                    .padding(.bottom, 8)

                VStack(alignment: .leading, spacing: 0) {
                    Text("Nearby")
                        .gaiaFont(.displayMedium)
                        .foregroundStyle(GaiaColor.olive)
                        .padding(.horizontal, sectionInset)
                        .padding(.top, 4)
                        .padding(.bottom, 8)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(ExploreSheetFilter.allCases) { filter in
                                Button {
                                    activeFilter = filter
                                } label: {
                                    GaiaPill(
                                        title: filter.title,
                                        style: filter == activeFilter ? .prominent : .soft
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, sectionInset)
                    }
                    .scrollClipDisabled()
                    .padding(.bottom, 12)
                }

                VStack(alignment: .leading, spacing: 0) {
                    ExploreSheetSectionHeader(title: "Projects", trailingText: "See all")
                        .padding(.horizontal, sectionInset)
                        .padding(.top, 2)
                        .padding(.bottom, 10)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(projects) { project in
                                ExploreSheetProjectCard(
                                    tag: project.tag,
                                    title: project.title,
                                    countLabel: project.countLabel,
                                    imageName: project.imageName,
                                    crop: project.crop
                                ) {
                                    onSelectProject(project.detailSelection)
                                }
                                .frame(width: ExploreSheetProjectCard.width)
                            }
                        }
                        .padding(.horizontal, sectionInset)
                        .padding(.bottom, GaiaSpacing.xl)
                    }
                    .scrollClipDisabled()
                }

                VStack(alignment: .leading, spacing: GaiaSpacing.md) {
                    HStack(alignment: .top) {
                        Text("Finds")
                            .gaiaFont(.title3)
                            .foregroundStyle(GaiaColor.inkBlack300)

                        Spacer(minLength: 12)

                        DraggableIconTabSwitch(
                            tabs: ExploreSheetViewMode.allCases,
                            selection: $viewMode,
                            accessibilityLabel: { $0.accessibilityLabel }
                        ) { mode, isSelected in
                            if let uiImage = AssetCatalog.uiImage(named: mode.iconPath) {
                                Image(uiImage: uiImage)
                                    .renderingMode(.template)
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundStyle(isSelected ? GaiaColor.paperWhite50 : GaiaColor.olive)
                                    .accessibilityHidden(true)
                            }
                        }
                    }
                    .padding(.horizontal, sectionInset)

                    if viewMode == .grid {
                        ExploreSheetFindGrid(finds: finds) { _ in
                            selectPrimarySpecies()
                        }
                        .padding(.horizontal, sectionInset)
                        .padding(.bottom, 32)
                    } else {
                        VStack(spacing: 8) {
                            ForEach(finds) { find in
                                ExploreSheetFindListRow(find: find) {
                                    selectPrimarySpecies()
                                }
                            }
                        }
                        .padding(.horizontal, sectionInset)
                        .padding(.bottom, 32)
                    }
                }
            }
            .padding(.bottom, 148)
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

private enum ExploreSheetViewMode: String, CaseIterable, Identifiable {
    case grid
    case list

    var id: String { rawValue }

    var iconPath: String {
        switch self {
        case .grid:
            return "Icons/System/grid-32.png"
        case .list:
            return "Icons/System/list-32.png"
        }
    }

    var accessibilityLabel: String {
        switch self {
        case .grid:
            return "Grid view"
        case .list:
            return "List view"
        }
    }
}

private struct ExploreSheetSectionHeader: View {
    let title: String
    let trailingText: String?

    var body: some View {
        HStack(alignment: .center) {
            Text(title)
                .gaiaFont(.title3)
                .foregroundStyle(GaiaColor.inkBlack300)

            Spacer(minLength: 12)

            if let trailingText {
                Text(trailingText)
                    .gaiaFont(.caption2Medium)
                    .foregroundStyle(GaiaColor.olive)
            }
        }
    }
}

private struct ExploreSheetFindGrid: View {
    let finds: [ExploreSheetFind]
    let action: (ExploreSheetFind) -> Void

    var body: some View {
        GeometryReader { proxy in
            let spacing: CGFloat = 8
            let columnCount = 3
            let cardWidth = floor((proxy.size.width - (spacing * CGFloat(columnCount - 1))) / CGFloat(columnCount))
            let rows = CGFloat((finds.count + 2) / 3)
            let gridHeight = (rows * cardWidth) + (max(0, rows - 1) * spacing)
            let columns = Array(
                repeating: GridItem(.fixed(cardWidth), spacing: spacing, alignment: .top),
                count: columnCount
            )

            LazyVGrid(columns: columns, alignment: .leading, spacing: spacing) {
                ForEach(finds) { find in
                    ExploreSheetFindGridCard(find: find, sideLength: cardWidth) {
                        action(find)
                    }
                }
            }
            .frame(width: proxy.size.width, alignment: .leading)
            .frame(height: gridHeight, alignment: .top)
        }
        .frame(height: 328)
    }
}

private struct ExploreSheetFindGridCard: View {
    let find: ExploreSheetFind
    let sideLength: CGFloat
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .bottomLeading) {
                GaiaFindCardArtwork {
                    GaiaAssetImage(name: find.imageName)
                        .frame(width: sideLength, height: sideLength)
                        .clipped()
                }

                Text(find.title)
                    .gaiaFont(.bodySerifTight)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .padding(.horizontal, 8.5)
                    .padding(.bottom, 7.5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
            }
            .frame(width: sideLength, height: sideLength)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(GaiaColor.broccoliBrown200, lineWidth: 0.5)
            )
            .shadow(color: GaiaShadow.smallColor, radius: GaiaShadow.smallRadius, x: 0, y: GaiaShadow.smallYOffset)
            .contentShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .buttonStyle(.plain)
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
        .buttonStyle(.plain)
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

private struct ExploreSheetProjectCrop: Hashable {
    let scaleX: CGFloat
    let scaleY: CGFloat
    let left: CGFloat
    let top: CGFloat

    static let identity = Self(scaleX: 1, scaleY: 1, left: 0, top: 0)
}

private struct ExploreSheetProjectCard: View {
    static let height: CGFloat = 133
    static let width: CGFloat = 181

    let tag: String
    let title: String
    let countLabel: String
    let imageName: String
    var crop: ExploreSheetProjectCrop = .identity
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topLeading) {
                GeometryReader { proxy in
                    let imageWidth = proxy.size.width * crop.scaleX
                    let imageHeight = proxy.size.height * crop.scaleY
                    let imageOffsetX = -(proxy.size.width * crop.left)
                    let imageOffsetY = -(proxy.size.height * crop.top)

                    ZStack {
                        GaiaAssetImage(name: imageName, contentMode: .fill)
                            .frame(width: imageWidth, height: imageHeight)
                            .offset(x: imageOffsetX, y: imageOffsetY)

                        GaiaAssetImage(name: imageName, contentMode: .fill)
                            .frame(width: imageWidth, height: imageHeight)
                            .offset(x: imageOffsetX, y: imageOffsetY)
                            .blur(radius: 1.4)
                            .mask(
                                LinearGradient(
                                    stops: [
                                        .init(color: .clear, location: 0.417),
                                        .init(color: .black, location: 1)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )

                        LinearGradient(
                            stops: [
                                .init(color: GaiaColor.projectCardOverlay.opacity(0), location: 0.417),
                                .init(color: GaiaColor.projectCardOverlay.opacity(0.85), location: 1)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    }
                }
                .clipped()

                VStack(alignment: .leading, spacing: 0) {
                    Text(tag)
                        .gaiaFont(.caption)
                        .foregroundStyle(GaiaColor.paperWhite50)
                        .padding(.horizontal, GaiaSpacing.pillHorizontal)
                        .frame(height: 20)
                        .background(Color.black.opacity(0.5), in: Capsule())
                        .overlay(
                            Capsule(style: .continuous)
                                .stroke(GaiaColor.blackishGrey200, lineWidth: 0.5)
                        )
                        .padding(GaiaSpacing.cardInset)

                    Spacer(minLength: 0)

                    VStack(alignment: .leading, spacing: GaiaSpacing.xs) {
                        Text(title)
                            .gaiaFont(.calloutTight)
                            .foregroundStyle(GaiaColor.paperWhite50)
                            .lineLimit(2)
                            .minimumScaleFactor(0.9)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        HStack(spacing: GaiaSpacing.xxs) {
                            ExploreSheetProjectCardBinocularsIcon()

                            Text(countLabel)
                                .gaiaFont(.micro)
                                .foregroundStyle(GaiaColor.paperWhite50)
                                .lineLimit(1)
                        }
                    }
                    .padding(GaiaSpacing.cardInset)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: Self.height)
            .background(GaiaColor.blackishGrey50)
            .clipShape(RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                    .stroke(GaiaColor.blackishGrey200, lineWidth: 0.5)
            )
            .shadow(color: GaiaShadow.cardColor, radius: GaiaShadow.cardRadius, x: 0, y: GaiaShadow.mdYOffset)
            .contentShape(RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(title), \(tag) project, \(countLabel) finds")
        .accessibilityHint("Opens the project details page")
    }
}

private struct ExploreSheetProjectCardBinocularsIcon: View {
    var body: some View {
        Group {
            if let image = AssetCatalog.uiImage(named: "Icons/System/binoculars-20.png") {
                Image(uiImage: image)
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(GaiaColor.paperWhite50)
            } else {
                GaiaIcon(kind: .observe(selected: false), size: 14, tint: GaiaColor.paperWhite50)
            }
        }
        .frame(width: 14, height: 10)
    }
}

private struct ExploreSheetProject: Identifiable {
    let id: String
    let title: String
    let tag: String
    let imageName: String
    let countLabel: String
    var crop: ExploreSheetProjectCrop = .identity

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
        .init(
            id: "project-creek",
            title: "Creek Recovery",
            tag: "Wetland",
            imageName: "find-project-creek",
            countLabel: "12",
            crop: .init(scaleX: 1.1289, scaleY: 1.0264, left: 0.105, top: 0.019)
        ),
        .init(
            id: "project-pollinator",
            title: "Pollinator Corridor",
            tag: "Garden",
            imageName: "find-project-pollinator",
            countLabel: "12",
            crop: .init(scaleX: 1.2061, scaleY: 1.0966, left: 0.2044, top: 0.0228)
        ),
        .init(id: "project-sea", title: "Sea Creatures", tag: "Ocean", imageName: "coast-live-oak-gallery-4", countLabel: "12")
    ]
}

private struct ExploreSheetFind: Identifiable {
    let id: String
    let title: String
    let imageName: String

    static let sample: [ExploreSheetFind] = [
        .init(id: "find-coast-live-oak", title: "Coast Live Oak", imageName: "coast-live-oak-hero"),
        .init(id: "find-indian-cormorant", title: "Indian Cormorant", imageName: "coast-live-oak-gallery-1"),
        .init(id: "find-european-roller", title: "European Roller", imageName: "coast-live-oak-gallery-2"),
        .init(id: "find-bindweed-tribe", title: "Bindweed Tribe", imageName: "coast-live-oak-gallery-3"),
        .init(id: "find-emperor-gum-moth", title: "Emperor Gum Moth", imageName: "coast-live-oak-gallery-4"),
        .init(id: "find-garden-orbweaver", title: "Garden Orbweaver", imageName: "observe-photo-square")
    ]
}
