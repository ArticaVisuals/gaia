import SwiftUI

struct SwipeableStoryDeck: View {
    let story: StoryCard
    let availableWidth: CGFloat

    @State private var activeIndex = 0
    @State private var dragOffset: CGSize = .zero
    @State private var frontThrowOffset: CGSize = .zero
    @State private var isThrowing = false
    @State private var isAnimatingAdvance = false

    private let throwDistance: CGFloat = 75
    private let throwMagnitude: CGFloat = 1000
    private let throwDuration: Double = 0.36
    private let baseCardSize = StoryLearningCardMetrics.cardSize

    private var pages: [StoryDeckPage] {
        story.pages.isEmpty ? PreviewStories.keystone.pages : story.pages
    }

    private var deckScale: CGFloat {
        min(1, max(0.86, availableWidth / 364))
    }

    private var layout: StoryDeckLayout {
        StoryDeckLayout(scale: deckScale)
    }

    private var frontIndex: Int { activeIndex }
    private var midIndex: Int { activeIndex + 1 }
    private var backIndex: Int { activeIndex + 2 }

    private var activeDrag: CGSize {
        isThrowing ? frontThrowOffset : dragOffset
    }

    private var promotionProgress: CGFloat {
        let distance = hypot(activeDrag.width, activeDrag.height)
        return min(distance / (throwDistance * 1.6), 1)
    }

    private var frontRotation: Double {
        max(-20, min(20, activeDrag.width * 0.06))
    }

    private var pageControlSpacing: CGFloat {
        StoryLearningCardMetrics.pageControlSpacing * deckScale
    }

    private var pageDotSize: CGFloat {
        StoryLearningCardMetrics.pageDotSize * deckScale
    }

    var body: some View {
        VStack(spacing: pageControlSpacing) {
            deckArea
                .frame(width: layout.stackWidth, height: layout.stackHeight)

            if activeIndex < pages.count {
                HStack(spacing: GaiaSpacing.sm * deckScale) {
                    ForEach(pages.indices, id: \.self) { index in
                        Circle()
                            .fill(index == activeIndex ? StoryDeckVisualStyle.brandPrimary : StoryDeckVisualStyle.inactivePageDot)
                            .frame(width: pageDotSize, height: pageDotSize)
                    }
                }
                .animation(.spring(response: 0.36, dampingFraction: 0.85), value: activeIndex)
            } else {
                VStack(spacing: GaiaSpacing.buttonHorizontalLarge) {
                    Text("You've read\nevery card.")
                        .gaiaFont(.title1Medium)
                        .foregroundStyle(StoryDeckVisualStyle.brandPrimary)
                        .multilineTextAlignment(.center)

                    Text("The Coast Live Oak thanks you.")
                        .font(GaiaTypography.footnote)
                        .tracking(GaiaTextStyle.caption.tracking)
                        .foregroundStyle(GaiaColor.blackishGrey500)
                        .multilineTextAlignment(.center)

                    Button("Read Again") {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.84)) {
                            activeIndex = 0
                        }
                    }
                    .font(GaiaTypography.footnoteMedium)
                    .foregroundStyle(GaiaColor.paperWhite50)
                    .padding(.horizontal, GaiaSpacing.xl)
                    .frame(height: 44)
                    .background(StoryDeckVisualStyle.brandPrimary)
                    .clipShape(.capsule)
                }
                .padding(.top, GaiaSpacing.xl)
            }
        }
        .onAppear(perform: reset)
        .onChange(of: story.id, initial: false) { _, _ in
            reset()
        }
    }

    private var deckArea: some View {
        ZStack(alignment: .topLeading) {
            if activeIndex >= pages.count {
                Color.clear
            } else {
                if backIndex < pages.count {
                    cardSlot(for: pages[backIndex], position: .back)
                }

                if midIndex < pages.count {
                    cardSlot(for: pages[midIndex], position: .mid)
                }

                if frontIndex < pages.count {
                    cardSlot(for: pages[frontIndex], position: .front)
                        .gesture(dragGesture)
                }
            }
        }
    }

    @ViewBuilder
    private func cardSlot(for page: StoryDeckPage, position: StoryDeckPosition) -> some View {
        let transform = layout.transform(for: position, progress: promotionProgress)
        let isFront = position == .front
        let blurAmount = layout.blur(for: position) * (1 - promotionProgress)
        let tintOpacity = layout.tintOpacity(for: position) * (1 - promotionProgress)

        StoryLearningCard(page: page, scale: deckScale)
            .frame(width: baseCardSize.width * deckScale, height: baseCardSize.height * deckScale)
            .blur(radius: blurAmount)
            .overlay {
                if position != .front {
                    RoundedRectangle(cornerRadius: GaiaRadius.lg * deckScale, style: .continuous)
                        .fill(GaiaColor.broccoliBrown200.opacity(tintOpacity))
                }
            }
            .scaleEffect(transform.scale, anchor: .topLeading)
            .offset(x: transform.x + (isFront ? activeDrag.width : 0), y: transform.y + (isFront ? activeDrag.height : 0))
            .rotationEffect(.degrees(isFront ? frontRotation : 0), anchor: .topLeading)
            .animation(isFront ? nil : .spring(response: 0.38, dampingFraction: 0.88), value: promotionProgress)
            .allowsHitTesting(isFront && !isAnimatingAdvance)
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 4, coordinateSpace: .local)
            .onChanged { value in
                guard !isAnimatingAdvance else { return }
                dragOffset = value.translation
            }
            .onEnded { value in
                guard !isAnimatingAdvance else { return }

                let translation = value.translation
                let predicted = value.predictedEndTranslation
                let translationDistance = hypot(translation.width, translation.height)
                let predictedDistance = hypot(predicted.width, predicted.height)

                if max(translationDistance, predictedDistance) > throwDistance {
                    throwFrontCard(using: predictedDistance > translationDistance ? predicted : translation)
                } else {
                    withAnimation(.spring(response: 0.42, dampingFraction: 0.76)) {
                        dragOffset = .zero
                        frontThrowOffset = .zero
                    }
                }
            }
    }

    private func throwFrontCard(using translation: CGSize) {
        let distance = max(1, hypot(translation.width, translation.height))
        let direction = CGSize(width: translation.width / distance, height: translation.height / distance)

        isAnimatingAdvance = true
        isThrowing = true

        withAnimation(.timingCurve(0.22, 0, 0.5, 1, duration: throwDuration)) {
            frontThrowOffset = CGSize(
                width: dragOffset.width + direction.width * throwMagnitude,
                height: dragOffset.height + direction.height * throwMagnitude
            )
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + throwDuration) {
            activeIndex += 1
            resetDrag()
            isAnimatingAdvance = false
        }
    }

    private func reset() {
        activeIndex = 0
        resetDrag()
    }

    private func resetDrag() {
        dragOffset = .zero
        frontThrowOffset = .zero
        isThrowing = false
    }
}

private struct StoryLearningCard: View {
    let page: StoryDeckPage
    let scale: CGFloat

    private var bodyLineSpacing: CGFloat {
        GaiaTextStyle.bodySerifTight.lineSpacing * scale
    }

    private var titleLineSpacing: CGFloat {
        (GaiaTextStyle.displayMedium.lineSpacing - StoryLearningCardMetrics.titleLineHeightTightening) * scale
    }

    var body: some View {
        VStack(alignment: .leading, spacing: StoryLearningCardMetrics.sectionSpacing * scale) {
            Text(page.title)
                .font(GaiaTypography.displayMedium)
                .tracking(GaiaTextStyle.displayMedium.tracking * scale)
                .foregroundStyle(GaiaColor.broccoliBrown500)
                .lineSpacing(titleLineSpacing)
                .lineLimit(2, reservesSpace: true)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: StoryLearningCardMetrics.imageCopySpacing * scale) {
                ZStack {
                    Color.white

                    GaiaAssetImage(name: page.imageAssetName, contentMode: .fill)
                        .frame(
                            width: StoryLearningCardMetrics.imageCropSize.width * scale,
                            height: StoryLearningCardMetrics.imageCropSize.height * scale
                        )
                }
                .frame(maxWidth: .infinity)
                .frame(height: StoryLearningCardMetrics.imageFrameHeight * scale)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: GaiaRadius.md * scale, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: GaiaRadius.md * scale, style: .continuous)
                        .stroke(GaiaColor.broccoliBrown200, lineWidth: max(0.5, scale))
                )

                Text(page.body)
                    .font(GaiaTypography.bodySerif)
                    .foregroundStyle(GaiaColor.blackishGrey500)
                    .lineSpacing(bodyLineSpacing)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(GaiaSpacing.md * scale)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(GaiaColor.paperWhite50)
        .clipShape(RoundedRectangle(cornerRadius: GaiaRadius.lg * scale, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: GaiaRadius.lg * scale, style: .continuous)
                .stroke(GaiaColor.broccoliBrown200, lineWidth: max(0.75, scale))
        )
        .shadow(color: GaiaShadow.lgColor, radius: 40 * scale, x: 0, y: 8 * scale)
    }
}

private enum StoryDeckPosition {
    case front
    case mid
    case back
}

private struct StoryDeckLayout {
    let scale: CGFloat

    var stackWidth: CGFloat { StoryLearningCardMetrics.stackSize.width * scale }
    var stackHeight: CGFloat { StoryLearningCardMetrics.stackSize.height * scale }

    func transform(for position: StoryDeckPosition, progress: CGFloat) -> StoryDeckTransform {
        switch position {
        case .front:
            return transformedPosition(x: 0, y: 41, scale: 1)
        case .mid:
            return interpolatedTransform(
                from: transformedPosition(x: 14.72, y: 19.16, scale: 303.559 / 333),
                to: transformedPosition(x: 0, y: 41, scale: 1),
                progress: progress
            )
        case .back:
            return interpolatedTransform(
                from: transformedPosition(x: 31.05, y: 0, scale: 270.902 / 333),
                to: transformedPosition(x: 14.72, y: 19.16, scale: 303.559 / 333),
                progress: progress
            )
        }
    }

    func blur(for position: StoryDeckPosition) -> CGFloat {
        switch position {
        case .front:
            return 0
        case .mid:
            return 1 * scale
        case .back:
            return 2.5 * scale
        }
    }

    func tintOpacity(for position: StoryDeckPosition) -> Double {
        switch position {
        case .front:
            return 0
        case .mid:
            return 0.08
        case .back:
            return 0.14
        }
    }

    private func transformedPosition(x: CGFloat, y: CGFloat, scale positionScale: CGFloat) -> StoryDeckTransform {
        StoryDeckTransform(x: x * scale, y: y * scale, scale: positionScale)
    }

    private func interpolatedTransform(from: StoryDeckTransform, to: StoryDeckTransform, progress: CGFloat) -> StoryDeckTransform {
        StoryDeckTransform(
            x: interpolate(from.x, to.x, progress),
            y: interpolate(from.y, to.y, progress),
            scale: interpolate(from.scale, to.scale, progress)
        )
    }

    private func interpolate(_ start: CGFloat, _ end: CGFloat, _ progress: CGFloat) -> CGFloat {
        start + ((end - start) * progress)
    }
}

private struct StoryDeckTransform {
    let x: CGFloat
    let y: CGFloat
    let scale: CGFloat
}

private enum StoryLearningCardMetrics {
    static let cardSize = CGSize(width: 333, height: 431)
    static let stackSize = CGSize(width: 364, height: 472)
    static let pageControlSpacing: CGFloat = 20
    static let pageDotSize: CGFloat = 8
    static let sectionSpacing: CGFloat = 48
    static let imageCopySpacing: CGFloat = 12
    static let imageFrameHeight: CGFloat = 183
    static let imageCropSize = CGSize(width: 342, height: 192)
    static let titleLineHeightTightening: CGFloat = 0.64
}
