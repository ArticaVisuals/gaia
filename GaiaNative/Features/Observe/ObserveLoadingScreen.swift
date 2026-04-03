import SwiftUI

private enum ObserveLoadingLayout {
    static let stackWidth: CGFloat = 283
    static let stackHeight: CGFloat = 181
    static let cardWidth: CGFloat = 267
    static let cardHeight: CGFloat = 163
    static let cardInsetCompensation: CGFloat = 8
    static let cardCornerRadius: CGFloat = 7
    static let cardBorderWidth: CGFloat = 1

    static let contentSpacing: CGFloat = 27
    static let dotsSpacing: CGFloat = 8
    static let dotSize: CGFloat = 10
    static let dotPulseDuration: Double = 1.2
    static let dotScaleMin: CGFloat = 0.8
    static let dotOpacityMin: CGFloat = 0.3

    static let shuffleAnimation = Animation.timingCurve(0.32, 0.72, 0, 1, duration: 0.45)
    static let shuffleIntervalNanoseconds: UInt64 = 500_000_000
    static let completionDelayNanoseconds: UInt64 = 2_000_000_000
    static let rotationJitterRange = -1.5...1.5
    static let blurredCardImageBlur: CGFloat = 0.5
    static let blurredCardOverlayOpacity: Double = 0.2
}

private struct ObserveLoadingSlot {
    let rotation: Double
    let zIndex: Double
    let isBlurred: Bool
    let offset: CGSize

    static let all: [ObserveLoadingSlot] = [
        ObserveLoadingSlot(rotation: -3.3, zIndex: 3, isBlurred: false, offset: .zero),
        ObserveLoadingSlot(rotation: 3.5, zIndex: 2, isBlurred: true, offset: .zero),
        ObserveLoadingSlot(rotation: 0, zIndex: 1, isBlurred: true, offset: CGSize(width: 5, height: 3))
    ]
}

private struct ObserveLoadingCardState: Identifiable {
    let id: String
    let assetName: String
    var slotIndex: Int
    var jitter: Double

    static let initial: [ObserveLoadingCardState] = [
        ObserveLoadingCardState(id: "front", assetName: "observe-loading-front", slotIndex: 0, jitter: 0),
        ObserveLoadingCardState(id: "middle", assetName: "observe-loading-middle", slotIndex: 1, jitter: 0),
        ObserveLoadingCardState(id: "back", assetName: "observe-loading-back", slotIndex: 2, jitter: 0)
    ]
}

struct ObserveLoadingScreen: View {
    let onComplete: () -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var didSchedule = false
    @State private var cards = ObserveLoadingCardState.initial
    @State private var shouldAnimateDots = false
    @State private var shuffleTask: Task<Void, Never>?
    @State private var completionTask: Task<Void, Never>?

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [GaiaColor.paperWhite100, GaiaColor.oliveGreen200],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: ObserveLoadingLayout.contentSpacing) {
                ObserveLoadingCardStack(cards: cards)
                    .frame(width: ObserveLoadingLayout.stackWidth, height: ObserveLoadingLayout.stackHeight)

                ObserveLoadingDots(isAnimating: shouldAnimateDots)

                Text("Identifying Species...")
                    .font(GaiaTypography.title)
                    .foregroundStyle(GaiaColor.oliveGreen500)
                    .multilineTextAlignment(.center)
            }
        }
        .onAppear(perform: startLoadingSequence)
        .onDisappear(perform: cancelScheduledTasks)
    }

    private func startLoadingSequence() {
        guard !didSchedule else { return }
        didSchedule = true
        cards = ObserveLoadingCardState.initial
        shouldAnimateDots = !reduceMotion

        if !reduceMotion {
            startShuffleAnimation()
        }

        completionTask = Task {
            try? await Task.sleep(nanoseconds: ObserveLoadingLayout.completionDelayNanoseconds)
            guard !Task.isCancelled else { return }
            await MainActor.run {
                onComplete()
            }
        }
    }

    private func startShuffleAnimation() {
        shuffleTask?.cancel()
        shuffleTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: ObserveLoadingLayout.shuffleIntervalNanoseconds)
                guard !Task.isCancelled else { return }

                await MainActor.run {
                    withAnimation(ObserveLoadingLayout.shuffleAnimation) {
                        for index in cards.indices {
                            cards[index].slotIndex = (cards[index].slotIndex + 1) % ObserveLoadingSlot.all.count
                            cards[index].jitter = Double.random(in: ObserveLoadingLayout.rotationJitterRange)
                        }
                    }
                }
            }
        }
    }

    private func cancelScheduledTasks() {
        shuffleTask?.cancel()
        shuffleTask = nil

        completionTask?.cancel()
        completionTask = nil

        shouldAnimateDots = false
        didSchedule = false
    }
}

private struct ObserveLoadingCardStack: View {
    let cards: [ObserveLoadingCardState]

    var body: some View {
        ZStack {
            ForEach(cards) { card in
                let slot = ObserveLoadingSlot.all[card.slotIndex]

                ObserveLoadingCard(
                    assetName: card.assetName,
                    isBlurred: slot.isBlurred
                )
                .rotationEffect(.degrees(slot.rotation + card.jitter))
                .offset(slot.offset)
                .zIndex(slot.zIndex)
            }
        }
    }
}

private struct ObserveLoadingCard: View {
    let assetName: String
    let isBlurred: Bool

    var body: some View {
        ZStack {
            GaiaAssetImage(name: assetName)
                .frame(
                    width: ObserveLoadingLayout.cardWidth + ObserveLoadingLayout.cardInsetCompensation,
                    height: ObserveLoadingLayout.cardHeight + ObserveLoadingLayout.cardInsetCompensation
                )
                .blur(radius: isBlurred ? ObserveLoadingLayout.blurredCardImageBlur : 0)
        }
        .frame(width: ObserveLoadingLayout.cardWidth, height: ObserveLoadingLayout.cardHeight)
        .clipShape(RoundedRectangle(cornerRadius: ObserveLoadingLayout.cardCornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: ObserveLoadingLayout.cardCornerRadius, style: .continuous)
                .stroke(GaiaColor.broccoliBrown200, lineWidth: ObserveLoadingLayout.cardBorderWidth)
        )
        .overlay(
            RoundedRectangle(cornerRadius: ObserveLoadingLayout.cardCornerRadius, style: .continuous)
                .fill(
                    GaiaColor.broccoliBrown200.opacity(
                        isBlurred ? ObserveLoadingLayout.blurredCardOverlayOpacity : 0
                    )
                )
        )
        .shadow(color: GaiaShadow.smallColor, radius: 14, x: 0, y: 9)
    }
}

private struct ObserveLoadingDots: View {
    let isAnimating: Bool

    var body: some View {
        HStack(spacing: ObserveLoadingLayout.dotsSpacing) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(GaiaColor.oliveGreen500)
                    .frame(width: ObserveLoadingLayout.dotSize, height: ObserveLoadingLayout.dotSize)
                    .scaleEffect(isAnimating ? 1 : ObserveLoadingLayout.dotScaleMin)
                    .opacity(isAnimating ? 1 : ObserveLoadingLayout.dotOpacityMin)
                    .animation(
                        .easeInOut(duration: ObserveLoadingLayout.dotPulseDuration)
                            .repeatForever()
                            .delay(Double(index) * 0.2),
                        value: isAnimating
                    )
            }
        }
        .accessibilityHidden(true)
    }
}
