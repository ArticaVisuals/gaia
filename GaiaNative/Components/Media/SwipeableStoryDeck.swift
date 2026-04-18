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
    private let baseCardSize = CGSize(width: 328, height: 432)
    private let designWidth: CGFloat = 353

    private var pages: [StoryDeckPage] {
        story.pages.isEmpty ? PreviewStories.keystone.pages : story.pages
    }

    private var deckScale: CGFloat {
        min(1, max(0.86, availableWidth / designWidth))
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

    var body: some View {
        VStack(spacing: 20 * deckScale) {
            deckArea
                .frame(width: layout.stackWidth, height: layout.stackHeight)

            if activeIndex < pages.count {
                HStack(spacing: 8 * deckScale) {
                    ForEach(pages.indices, id: \.self) { index in
                        Circle()
                            .fill(index == activeIndex ? GaiaColor.oliveGreen500 : GaiaColor.oliveGreen200)
                            .frame(width: 8 * deckScale, height: 8 * deckScale)
                    }
                }
                .padding(.horizontal, 24 * deckScale)
                .background(.ultraThinMaterial, in: Capsule(style: .continuous))
                .animation(.spring(response: 0.36, dampingFraction: 0.85), value: activeIndex)
            } else {
                VStack(spacing: 14) {
                    Text("🌿")
                        .font(.system(size: 44))
                        .accessibilityHidden(true)

                    Text("You've read\nevery card.")
                        .font(.custom("NewSpirit-Medium", size: 30))
                        .foregroundStyle(GaiaColor.oliveGreen500)
                        .multilineTextAlignment(.center)

                    Text("The Coast Live Oak thanks you.")
                        .font(.custom("Neue Haas Unica W1G", size: 14))
                        .tracking(0.4)
                        .foregroundStyle(GaiaColor.blackishGrey500)
                        .multilineTextAlignment(.center)

                    Button("Read Again") {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.84)) {
                            activeIndex = 0
                        }
                    }
                    .font(.custom("Neue Haas Unica W1G", size: 14))
                    .foregroundStyle(GaiaColor.paperWhite50)
                    .padding(.horizontal, 32)
                    .frame(height: 44)
                    .background(GaiaColor.oliveGreen500)
                    .clipShape(.capsule)
                }
                .padding(.top, 32)
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
                    RoundedRectangle(cornerRadius: GaiaRadius.card * deckScale, style: .continuous)
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

    private var titleFontSize: CGFloat { 31.806 * scale }
    private var bodyFontSize: CGFloat { 14.909 * scale }
    private var cardCornerRadius: CGFloat { GaiaRadius.xl * scale }

    var body: some View {
        VStack(alignment: .leading, spacing: 32 * scale) {
            Text(page.title)
                .font(.custom("NewSpirit-Medium", size: titleFontSize))
                .tracking(-0.5 * scale)
                .lineSpacing(StoryLearningCardTheme.titleLineSpacing * scale)
                .foregroundStyle(GaiaColor.broccoliBrown500)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: 20 * scale) {
                StoryDeckMediaImage(source: page.imageAssetName)
                    .frame(height: 181.893 * scale)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 8 * scale, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8 * scale, style: .continuous)
                            .stroke(StoryLearningCardTheme.borderColor, lineWidth: max(0.7, 1 * scale))
                    )

                Text(page.body)
                    .font(.custom("Neue Haas Unica W1G", size: bodyFontSize))
                    .foregroundStyle(GaiaColor.inkBlack300)
                    .lineSpacing(StoryLearningCardTheme.bodyLineSpacing * scale)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16 * scale)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(GaiaColor.paperWhite50)
        .clipShape(RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous)
                .stroke(StoryLearningCardTheme.borderColor, lineWidth: max(0.7, 1 * scale))
        )
        .shadow(color: StoryLearningCardTheme.shadowColor, radius: 32.542 * scale, x: 0, y: 6.508 * scale)
    }
}

private struct StoryDeckMediaImage: View {
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
            colors: [GaiaColor.asparagusGreen50, GaiaColor.paperWhite50],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

private enum StoryLearningCardTheme {
    static let borderColor = GaiaColor.broccoliBrown200
    static let shadowColor = Color(red: 155.0 / 255.0, green: 133.0 / 255.0, blue: 107.0 / 255.0).opacity(0.24)
    static let titleLineSpacing: CGFloat = -8.68
    static let bodyLineSpacing: CGFloat = -3.07
}

private enum StoryDeckPosition {
    case front
    case mid
    case back
}

private struct StoryDeckLayout {
    let scale: CGFloat

    var stackWidth: CGFloat { 328 * scale }
    var stackHeight: CGFloat { 473 * scale }

    func transform(for position: StoryDeckPosition, progress: CGFloat) -> StoryDeckTransform {
        switch position {
        case .front:
            return transformedPosition(x: 0, y: 41, scale: 1)
        case .mid:
            return interpolatedTransform(
                from: transformedPosition(x: 15.779, y: 19.163, scale: 300.0 / 328.0),
                to: transformedPosition(x: 0, y: 41, scale: 1),
                progress: progress
            )
        case .back:
            return interpolatedTransform(
                from: transformedPosition(x: 31.049, y: 0, scale: 270.912 / 328.0),
                to: transformedPosition(x: 15.779, y: 19.163, scale: 300.0 / 328.0),
                progress: progress
            )
        }
    }

    func blur(for position: StoryDeckPosition) -> CGFloat {
        switch position {
        case .front:
            return 0
        case .mid:
            return 1.0 * scale
        case .back:
            return 2.5 * scale
        }
    }

    func tintOpacity(for position: StoryDeckPosition) -> Double {
        switch position {
        case .front:
            return 0
        case .mid:
            return 0.12
        case .back:
            return 0.20
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
