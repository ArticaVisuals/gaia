import SwiftUI

private enum ObserveShareLayout {
    static let horizontalInset: CGFloat = GaiaSpacing.md
    static let topInset: CGFloat = 8
    static let toolbarToDeckSpacing: CGFloat = 76
    static let cardWidth: CGFloat = 315.134
    static let cardHeight: CGFloat = 376
    static let cardGap: CGFloat = 23
    static let cardInset: CGFloat = GaiaSpacing.lg
    static let illustrationHeight: CGFloat = 149.712
    static let illustrationBorderWidth: CGFloat = 1
    static let metricRowHeight: CGFloat = 52
    static let metricGap: CGFloat = GaiaSpacing.sm
    static let pageControlTopInset: CGFloat = 18
    static let pageDotSize: CGFloat = 8
    static let pageControlHorizontalInset: CGFloat = GaiaSpacing.lg
    static let actionButtonSize: CGFloat = 50
    static let actionButtonGap: CGFloat = 13
    static let actionBottomPadding: CGFloat = 108
    static let learnButtonHeight: CGFloat = 50
    static let cardCornerRadius: CGFloat = GaiaRadius.xl
    static let illustrationCornerRadius: CGFloat = GaiaRadius.md
}

private enum ObserveSharePage: String, CaseIterable, Identifiable {
    case impact
    case whyItMatters

    var id: String { rawValue }
}

struct ObserveShareScreen: View {
    @EnvironmentObject private var contentStore: ContentStore

    let onBack: () -> Void
    let onDone: () -> Void

    @State private var selectedPageID: ObserveSharePage.ID? = ObserveSharePage.impact.id

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .top) {
                GaiaColor.paperWhite50
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    HStack {
                        Spacer()
                        ToolbarGlassButton(icon: .close, accessibilityLabel: "Close", action: onDone)
                    }
                    .padding(.horizontal, ObserveShareLayout.horizontalInset)

                    Spacer(minLength: ObserveShareLayout.toolbarToDeckSpacing)

                    ObserveShareDeckSection(
                        selectedPageID: $selectedPageID,
                        scientificName: contentStore.primarySpecies.scientificName,
                        commonName: contentStore.primarySpecies.commonName,
                        totalFindsLabel: totalFindsLabel
                    )
                }
                .padding(.top, max(ObserveShareLayout.topInset, proxy.safeAreaInsets.top + ObserveShareLayout.topInset))

                ObserveShareActionRow(
                    shareMessage: shareMessage,
                    onBack: onBack,
                    onDone: onDone
                )
                .padding(.bottom, max(ObserveShareLayout.actionBottomPadding, proxy.safeAreaInsets.bottom + 74))
                .frame(maxHeight: .infinity, alignment: .bottom)
                .padding(.horizontal, ObserveShareLayout.horizontalInset)
            }
        }
    }

    private var totalFindsLabel: String {
        let parts = contentStore.profileLog.totalFindsLabel.split(separator: " ")
        if let first = parts.first, !first.isEmpty {
            return String(first)
        }
        return "127"
    }

    private var shareMessage: String {
        "I just logged \(contentStore.primarySpecies.commonName) on Gaia. Every sighting adds to the bigger ecological picture."
    }
}

private struct ObserveShareDeckSection: View {
    @Binding var selectedPageID: ObserveSharePage.ID?

    let scientificName: String
    let commonName: String
    let totalFindsLabel: String

    var body: some View {
        VStack(spacing: ObserveShareLayout.pageControlTopInset) {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(alignment: .top, spacing: ObserveShareLayout.cardGap) {
                    ObserveShareImpactCard(
                        scientificName: scientificName,
                        totalFindsLabel: totalFindsLabel
                    )
                    .id(ObserveSharePage.impact.id)

                    ObserveShareWhyItMattersCard(commonName: commonName)
                        .id(ObserveSharePage.whyItMatters.id)
                }
                .padding(.horizontal, ObserveShareLayout.horizontalInset)
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: $selectedPageID)
            .defaultScrollAnchor(.leading)
            .frame(height: ObserveShareLayout.cardHeight)

            ObserveSharePageControl(selectedPageID: $selectedPageID)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct ObserveShareImpactCard: View {
    let scientificName: String
    let totalFindsLabel: String

    var body: some View {
        ObserveShareCardShell {
            VStack(alignment: .leading, spacing: GaiaSpacing.md) {
                Text("My Impact")
                    .gaiaFont(.title1Medium)
                    .foregroundStyle(GaiaColor.inkBlack500)
                    .frame(maxWidth: .infinity, alignment: .center)

                VStack(alignment: .leading, spacing: GaiaSpacing.sm) {
                    ObserveShareIllustrationFrame {
                        GaiaAssetImage(name: "observe-share-impact", contentMode: .fit)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(.horizontal, GaiaSpacing.xs)
                            .padding(.top, GaiaSpacing.xs)
                    }

                    Text(scientificName)
                        .gaiaFont(.caption)
                        .foregroundStyle(GaiaColor.broccoliBrown500)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                VStack(spacing: ObserveShareLayout.metricGap) {
                    HStack(spacing: ObserveShareLayout.metricGap) {
                        ObserveShareMetricCard(
                            title: totalFindsLabel,
                            subtitle: "Total Finds",
                            icon: {
                                GaiaIcon(kind: .observe(selected: false), size: 24, tint: GaiaColor.inkBlack500)
                            }
                        )

                        ObserveShareMetricCard(
                            title: "6 days",
                            subtitle: "Current Streak"
                        )
                    }

                    HStack(spacing: ObserveShareLayout.metricGap) {
                        ObserveShareMetricCard(
                            title: "Top 8%",
                            subtitle: "Regional Rank"
                        )

                        ObserveShareMetricCard(
                            title: totalFindsLabel,
                            subtitle: "Total Contributions",
                            icon: {
                                GaiaIcon(kind: .log(selected: false), size: 24, tint: GaiaColor.inkBlack500)
                            }
                        )
                    }
                }
            }
        }
    }
}

private struct ObserveShareWhyItMattersCard: View {
    let commonName: String

    var body: some View {
        ObserveShareCardShell {
            VStack(alignment: .leading, spacing: GaiaSpacing.md) {
                VStack(alignment: .leading, spacing: GaiaSpacing.md) {
                    Text("Why It Matters")
                        .gaiaFont(.title1Medium)
                        .foregroundStyle(GaiaColor.inkBlack500)

                    VStack(alignment: .leading, spacing: 12) {
                        ObserveShareIllustrationFrame {
                            GaiaAssetImage(name: "observe-share-why-matters", contentMode: .fill)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }

                        Text("Your find of \(commonName) contributes to understanding urban canopy health in the San Gabriel Valley across 3 active datasets.")
                            .gaiaFont(.subheadline)
                            .foregroundStyle(GaiaColor.broccoliBrown500)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                Spacer(minLength: 0)

                Button(action: {}) {
                    Text("Learn More")
                        .gaiaFont(.bodyBold)
                        .foregroundStyle(GaiaColor.paperWhite50)
                        .frame(maxWidth: .infinity)
                        .frame(height: ObserveShareLayout.learnButtonHeight)
                        .background(
                            Capsule(style: .continuous)
                                .fill(GaiaColor.oliveGreen500)
                        )
                }
                .buttonStyle(.plain)
            }
            .frame(maxHeight: .infinity, alignment: .top)
        }
    }
}

private struct ObserveShareCardShell<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .padding(ObserveShareLayout.cardInset)
            .frame(width: ObserveShareLayout.cardWidth, height: ObserveShareLayout.cardHeight, alignment: .topLeading)
            .background(
                RoundedRectangle(cornerRadius: ObserveShareLayout.cardCornerRadius, style: .continuous)
                    .fill(GaiaColor.paperWhite50)
                    .overlay(
                        RoundedRectangle(cornerRadius: ObserveShareLayout.cardCornerRadius, style: .continuous)
                            .stroke(GaiaColor.broccoliBrown200, lineWidth: 1)
                    )
            )
    }
}

private struct ObserveShareIllustrationFrame<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    GaiaColor.siskin500.opacity(0.5),
                    GaiaColor.paperWhite50
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            content()
        }
        .frame(height: ObserveShareLayout.illustrationHeight)
        .clipShape(
            RoundedRectangle(
                cornerRadius: ObserveShareLayout.illustrationCornerRadius,
                style: .continuous
            )
        )
        .overlay(
            RoundedRectangle(
                cornerRadius: ObserveShareLayout.illustrationCornerRadius,
                style: .continuous
            )
            .stroke(GaiaColor.broccoliBrown200, lineWidth: ObserveShareLayout.illustrationBorderWidth)
        )
    }
}

private struct ObserveShareMetricCard<Icon: View>: View {
    let title: String
    let subtitle: String
    @ViewBuilder let icon: () -> Icon

    init(title: String, subtitle: String, @ViewBuilder icon: @escaping () -> Icon = { EmptyView() }) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
    }

    var body: some View {
        VStack(alignment: .leading, spacing: GaiaSpacing.xs) {
            HStack(spacing: GaiaSpacing.xs) {
                icon()

                Text(title)
                    .gaiaFont(.title3Medium)
                    .foregroundStyle(GaiaColor.inkBlack500)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Text(subtitle)
                .gaiaFont(.caption2)
                .foregroundStyle(GaiaColor.broccoliBrown500)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .padding(GaiaSpacing.sm)
        .frame(maxWidth: .infinity, minHeight: ObserveShareLayout.metricRowHeight, alignment: .bottomLeading)
        .background(
            RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                .fill(GaiaColor.paperWhite50)
                .overlay(
                    RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                        .stroke(GaiaColor.broccoliBrown200, lineWidth: 1)
                )
        )
    }
}

private struct ObserveSharePageControl: View {
    @Binding var selectedPageID: ObserveSharePage.ID?

    var body: some View {
        HStack(spacing: GaiaSpacing.sm) {
            ForEach(ObserveSharePage.allCases) { page in
                Button {
                    withAnimation(.easeInOut(duration: 0.24)) {
                        selectedPageID = page.id
                    }
                } label: {
                    Circle()
                        .fill(page.id == currentPageID ? GaiaColor.inkBlack500 : Color.black.opacity(0.22))
                        .frame(
                            width: ObserveShareLayout.pageDotSize,
                            height: ObserveShareLayout.pageDotSize
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel(page == .impact ? "Show My Impact card" : "Show Why It Matters card")
            }
        }
        .padding(.horizontal, ObserveShareLayout.pageControlHorizontalInset)
        .padding(.vertical, GaiaSpacing.xs)
        .background(
            Color.clear
                .background(GaiaMaterial.overlay, in: Capsule(style: .continuous))
                .overlay(
                    Capsule(style: .continuous)
                        .fill(Color.white.opacity(0.12))
                )
        )
    }

    private var currentPageID: ObserveSharePage.ID {
        selectedPageID ?? ObserveSharePage.impact.id
    }
}

private struct ObserveShareActionRow: View {
    let shareMessage: String
    let onBack: () -> Void
    let onDone: () -> Void

    var body: some View {
        HStack(spacing: ObserveShareLayout.actionButtonGap) {
            ShareLink(item: shareMessage) {
                ObserveShareActionCircle {
                    GaiaIcon(kind: .share, size: 32, tint: GaiaColor.inkBlack500)
                        .offset(y: -1)
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Share")

            Button(action: {}) {
                ObserveShareActionCircle {
                    ObserveShareSaveIcon()
                        .offset(y: -1)
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Save")

            Menu {
                Button("Back to previous step", action: onBack)
                Button("Return to Explore", action: onDone)
            } label: {
                ObserveShareActionCircle {
                    ObserveShareEllipsesIcon()
                }
            }
            .accessibilityLabel("More options")
        }
    }
}

private struct ObserveShareActionCircle<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        ZStack {
            Circle()
                .fill(GaiaColor.paperWhite50)
                .overlay(
                    Circle()
                        .stroke(GaiaColor.broccoliBrown200, lineWidth: 1)
                )

            content()
        }
        .frame(
            width: ObserveShareLayout.actionButtonSize,
            height: ObserveShareLayout.actionButtonSize
        )
        .contentShape(Circle())
    }
}

private struct ObserveShareSaveIcon: View {
    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height

            let leftFrame = CGRect(
                x: width * 0.4771,
                y: height * 0.2041,
                width: width * 0.2227,
                height: height * 0.5150
            )
            let rightFrame = CGRect(
                x: width * 0.3002,
                y: height * 0.2041,
                width: width * 0.2227,
                height: height * 0.5150
            )
            let baseFrame = CGRect(
                x: width * 0.1563,
                y: height * 0.6306,
                width: width * 0.6875,
                height: height * 0.1964
            )

            ZStack {
                ObserveShareSaveArrowLeftShape()
                    .fill(GaiaColor.inkBlack500)
                    .frame(width: leftFrame.width, height: leftFrame.height)
                    .position(x: leftFrame.midX, y: leftFrame.midY)

                ObserveShareSaveArrowRightShape()
                    .fill(GaiaColor.inkBlack500)
                    .frame(width: rightFrame.width, height: rightFrame.height)
                    .position(x: rightFrame.midX, y: rightFrame.midY)

                ObserveShareSaveBaseShape()
                    .fill(GaiaColor.inkBlack500)
                    .frame(width: baseFrame.width, height: baseFrame.height)
                    .position(x: baseFrame.midX, y: baseFrame.midY)
            }
        }
        .frame(width: 32, height: 32)
        .accessibilityHidden(true)
    }
}

private struct ObserveShareSaveArrowLeftShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let sx = rect.width / 7.1255
        let sy = rect.height / 16.4001

        func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: rect.minX + (x * sx), y: rect.minY + (y * sy))
        }

        path.move(to: point(0, 0.732422))
        path.addCurve(to: point(0.732422, 0), control1: point(0, 0.32771), control2: point(0.32771, 0))
        path.addCurve(to: point(1.46484, 0.732422), control1: point(1.13713, 0), control2: point(1.46484, 0.32771))
        path.addLine(to: point(1.46484, 13.918))
        path.addLine(to: point(5.87402, 9.50879))
        path.addCurve(to: point(6.91113, 9.50879), control1: point(6.1602, 9.22261), control2: point(6.62496, 9.22261))
        path.addCurve(to: point(6.91113, 10.5449), control1: point(7.19707, 9.79482), control2: point(7.19684, 10.2587))
        path.addLine(to: point(1.27441, 16.1816))
        path.addCurve(to: point(0.433594, 16.332), control1: point(1.02256, 16.4335), control2: point(0.675993, 16.4439))
        path.addCurve(to: point(0, 15.6533), control1: point(0.205066, 16.2265), control2: point(0, 15.9824))
        path.addLine(to: point(0, 0.732422))
        path.closeSubpath()
        return path
    }
}

private struct ObserveShareSaveArrowRightShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let sx = rect.width / 7.12552
        let sy = rect.height / 16.4001

        func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: rect.minX + (x * sx), y: rect.minY + (y * sy))
        }

        path.move(to: point(7.12552, 15.6533))
        path.addCurve(to: point(6.69193, 16.332), control1: point(7.12552, 15.9824), control2: point(6.92042, 16.2265))
        path.addCurve(to: point(5.85111, 16.1816), control1: point(6.44955, 16.4439), control2: point(6.10297, 16.4335))
        path.addLine(to: point(0.214387, 10.5449))
        path.addCurve(to: point(0.214387, 9.50879), control1: point(-0.0713455, 10.2587), control2: point(-0.0715791, 9.79483))
        path.addCurve(to: point(1.2515, 9.50879), control1: point(0.500561, 9.22261), control2: point(0.965322, 9.22261))
        path.addLine(to: point(5.66068, 13.918))
        path.addLine(to: point(5.66068, 0.732422))
        path.addCurve(to: point(6.3931, 0), control1: point(5.66068, 0.32771), control2: point(5.98839, 0))
        path.addCurve(to: point(7.12552, 0.732422), control1: point(6.79779, 0.0000213991), control2: point(7.12552, 0.327723))
        path.addLine(to: point(7.12552, 15.6533))
        path.closeSubpath()
        return path
    }
}

private struct ObserveShareSaveBaseShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let sx = rect.width / 22
        let sy = rect.height / 6.28516

        func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: rect.minX + (x * sx), y: rect.minY + (y * sy))
        }

        path.move(to: point(0, 4.06641))
        path.addLine(to: point(0, 0.732422))
        path.addCurve(to: point(0.732422, 0), control1: point(0, 0.32771), control2: point(0.32771, 0))
        path.addCurve(to: point(1.46484, 0.732422), control1: point(1.13713, 0), control2: point(1.46484, 0.32771))
        path.addLine(to: point(1.46484, 4.06641))
        path.addCurve(to: point(2.21875, 4.82031), control1: point(1.46484, 4.48243), control2: point(1.80273, 4.82031))
        path.addLine(to: point(19.7803, 4.82031))
        path.addCurve(to: point(20.5342, 4.06641), control1: point(20.1963, 4.82031), control2: point(20.5342, 4.48243))
        path.addLine(to: point(20.5342, 0.732422))
        path.addCurve(to: point(21.2666, 0), control1: point(20.5342, 0.327786), control2: point(20.862, 0.0001227))
        path.addCurve(to: point(22, 0.732422), control1: point(21.6713, 0), control2: point(22, 0.32771))
        path.addLine(to: point(22, 4.06641))
        path.addCurve(to: point(19.7803, 6.28516), control1: point(22, 5.29185), control2: point(21.0057, 6.28516))
        path.addLine(to: point(2.21875, 6.28516))
        path.addCurve(to: point(0, 4.06641), control1: point(0.993306, 6.28516), control2: point(0, 5.29185))
        path.closeSubpath()
        return path
    }
}

private struct ObserveShareEllipsesIcon: View {
    var body: some View {
        HStack(spacing: 3.37) {
            ForEach(0..<3, id: \.self) { _ in
                Circle()
                    .fill(GaiaColor.inkBlack500)
                    .frame(width: 3.611, height: 3.611)
            }
        }
        .frame(width: 32, height: 32)
        .accessibilityHidden(true)
    }
}
