// figma: https://www.figma.com/design/X0NcuRE0WKmsqR36cvlcij/Write-Test-Pro?node-id=16-2529 (Log Celebration), 16-2537 (Log Share)
import SwiftUI

struct ObserveShareScreen: View {
    let onBack: () -> Void
    let onDone: () -> Void

    @State private var mode: ObserveShareMode = .celebration
    @State private var selectedCardIndex = 0

    private let cards: [ObserveShareCardModel] = [
        .impact,
        .whyItMatters
    ]

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .top) {
                GaiaColor.surfacePrimary.ignoresSafeArea()

                switch mode {
                case .celebration:
                    ObserveCelebrationView {
                        HapticsService.selectionChanged()
                        withAnimation(GaiaMotion.softSpring) {
                            mode = .share
                        }
                    }
                    .padding(.top, max(proxy.safeAreaInsets.top + 32, 72))
                    .transition(.opacity)
                case .share:
                    ObserveSharePager(
                        cards: cards,
                        selectedCardIndex: $selectedCardIndex,
                        onSave: {
                            HapticsService.selectionChanged()
                        }
                    )
                    .padding(.top, max(proxy.safeAreaInsets.top + 56, 104))
                    .transition(.opacity)
                }

                HStack {
                    if mode == .celebration {
                        ToolbarGlassButton(icon: .back, accessibilityLabel: "Back") {
                            HapticsService.selectionChanged()
                            onBack()
                        }
                        Spacer()
                    } else {
                        Spacer()
                        ToolbarGlassButton(icon: .close, accessibilityLabel: "Close", action: onDone)
                    }
                }
                .padding(.horizontal, GaiaSpacing.md)
                .padding(.top, max(proxy.safeAreaInsets.top + 8, 16))
            }
        }
    }
}

private enum ObserveShareMode {
    case share
    case celebration
}

private struct ObserveShareCardModel: Identifiable {
    struct Metric: Identifiable {
        let id: String
        let value: String
        let label: String
        let usesBinocularsIcon: Bool
        let usesLogbookIcon: Bool
    }

    let id: String
    let title: String
    let imageName: String
    let subtitle: String
    let accent: Color
    let metrics: [Metric]

    static let impact = ObserveShareCardModel(
        id: "impact",
        title: "My Impact",
        imageName: "observe-share-impact",
        subtitle: "Chelonia mydas",
        accent: GaiaColor.paperWhite50,
        metrics: [
            .init(id: "finds", value: "127", label: "Total Finds", usesBinocularsIcon: true, usesLogbookIcon: false),
            .init(id: "streak", value: "6 days", label: "Current Streak", usesBinocularsIcon: false, usesLogbookIcon: false),
            .init(id: "rank", value: "Top 8%", label: "Regional Rank", usesBinocularsIcon: false, usesLogbookIcon: false),
            .init(id: "suggests", value: "56", label: "Total Suggests", usesBinocularsIcon: false, usesLogbookIcon: true)
        ]
    )

    static let whyItMatters = ObserveShareCardModel(
        id: "why",
        title: "Why It Matters",
        imageName: "observe-share-why-matters",
        subtitle: "",
        accent: GaiaColor.paperWhite50,
        metrics: []
    )
}

private struct ObserveSharePager: View {
    let cards: [ObserveShareCardModel]
    @Binding var selectedCardIndex: Int
    let onSave: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $selectedCardIndex) {
                ForEach(Array(cards.enumerated()), id: \.element.id) { index, card in
                    ObserveSharePageCard(card: card)
                        .frame(width: 312, height: 384)
                        .frame(maxWidth: .infinity)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 384)

            ObserveSharePageControl(
                selectedIndex: selectedCardIndex,
                count: cards.count
            )
            .padding(.top, 9)

            HStack(spacing: 13) {
                ObserveShareActionButton(icon: .share) {
                    HapticsService.selectionChanged()
                }
                ObserveShareActionButton(systemSymbol: "arrow.down") {
                    onSave()
                }
                ObserveShareActionButton(systemSymbol: "ellipsis") {
                    HapticsService.selectionChanged()
                }
            }
            .padding(.top, 48)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct ObserveSharePageCard: View {
    let card: ObserveShareCardModel

    private let shape = RoundedRectangle(cornerRadius: GaiaRadius.lg, style: .continuous)

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(card.title)
                .gaiaFont(.title1Medium)
                .foregroundStyle(GaiaColor.textPrimary)
                .frame(maxWidth: .infinity, alignment: .center)
                .multilineTextAlignment(.center)

            GaiaAssetImage(name: card.imageName, contentMode: .fill)
                .frame(height: 163)
                .clipShape(RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                        .stroke(GaiaColor.broccoliBrown200, lineWidth: 0.5)
                )

            if !card.subtitle.isEmpty {
                Text(card.subtitle)
                    .gaiaFont(.caption)
                    .foregroundStyle(GaiaColor.broccoliBrown500)
            }

            if card.metrics.isEmpty {
                ObserveWhyItMattersBody()
                    .gaiaFont(.subheadline)
                    .foregroundStyle(GaiaColor.broccoliBrown500)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Button(action: {}) {
                    Text("Learn More")
                        .gaiaFont(.body)
                        .foregroundStyle(GaiaColor.paperWhite50)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            Capsule(style: .continuous)
                                .fill(GaiaColor.oliveGreen500)
                        )
                }
                .buttonStyle(.plain)
            } else {
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: GaiaSpacing.sm),
                        GridItem(.flexible(), spacing: GaiaSpacing.sm)
                    ],
                    spacing: GaiaSpacing.sm
                ) {
                    ForEach(card.metrics) { metric in
                        ObserveShareMetricCard(metric: metric)
                    }
                }
            }
        }
        .padding(GaiaSpacing.md + 4)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(
            shape
                .fill(card.accent)
                .overlay(
                    shape.stroke(GaiaColor.broccoliBrown200, lineWidth: 0.5)
                )
                .shadow(color: GaiaShadow.storyColor, radius: GaiaShadow.storyRadius, x: 0, y: GaiaShadow.storyYOffset)
        )
    }
}

private struct ObserveShareMetricCard: View {
    let metric: ObserveShareCardModel.Metric

    var body: some View {
        VStack(alignment: .leading, spacing: GaiaSpacing.xxs) {
            HStack(spacing: GaiaSpacing.xxs) {
                if metric.usesBinocularsIcon {
                    GaiaIcon(kind: .binoculars, size: 16, tint: GaiaColor.oliveGreen500)
                        .frame(width: 16, height: 16)
                } else if metric.usesLogbookIcon {
                    Image(systemName: "book.closed")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(GaiaColor.oliveGreen500)
                        .frame(width: 16, height: 16)
                }

                Text(metric.value)
                    .gaiaFont(.titleSans)
                    .foregroundStyle(GaiaColor.oliveGreen500)
            }

            Text(metric.label)
                .gaiaFont(.caption)
                .foregroundStyle(GaiaColor.broccoliBrown500)
                .lineLimit(1)
        }
        .padding(.horizontal, GaiaSpacing.md - 2)
        .padding(.vertical, GaiaSpacing.sm + 2)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                .fill(GaiaColor.paperWhite50)
                .overlay(
                    RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                        .stroke(GaiaColor.broccoliBrown200, lineWidth: 0.5)
                )
        )
    }
}

private struct ObserveSharePageControl: View {
    let selectedIndex: Int
    let count: Int

    var body: some View {
        HStack(spacing: GaiaSpacing.md - 2) {
            ForEach(0..<count, id: \.self) { index in
                Circle()
                    .fill(index == selectedIndex ? GaiaColor.oliveGreen500 : GaiaColor.oliveGreen200)
                    .frame(width: 8, height: 8)
            }
        }
        .frame(width: 72, height: 8)
        .accessibilityHidden(true)
    }
}

private struct ObserveShareActionButton: View {
    let icon: GaiaIconKind?
    let systemSymbol: String?
    let action: () -> Void

    init(icon: GaiaIconKind? = nil, systemSymbol: String? = nil, action: @escaping () -> Void) {
        self.icon = icon
        self.systemSymbol = systemSymbol
        self.action = action
    }

    var body: some View {
        Button {
            action()
        } label: {
            ZStack {
                Circle()
                    .fill(GaiaColor.oliveGreen400)
                    .overlay(
                        Circle()
                            .stroke(GaiaColor.oliveGreen200, lineWidth: 1)
                    )

                if let icon {
                    GaiaIcon(kind: icon, size: 24, tint: GaiaColor.paperWhite50)
                        .frame(width: 24, height: 24)
                } else if let systemSymbol {
                    Image(systemName: systemSymbol)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(GaiaColor.paperWhite50)
                }
            }
            .frame(width: 52, height: 52)
            .shadow(color: GaiaShadow.storyColor, radius: 12, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}

private struct ObserveCelebrationView: View {
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Text("Nice Find!")
                .font(.custom("NewSpirit-Medium", size: 64))
                .tracking(-0.92)
                .lineSpacing(6.4)
                .foregroundStyle(GaiaColor.textPrimary)
                .frame(maxWidth: .infinity, alignment: .center)
                .multilineTextAlignment(.center)

            VStack(alignment: .leading, spacing: 16) {
                Text("Chelonia\nmydas")
                    .gaiaFont(.displayMedium)
                    .foregroundStyle(GaiaColor.broccoliBrown500)

                GaiaAssetImage(name: "observe-celebration-photo", contentMode: .fill)
                    .frame(height: 195)
                    .clipShape(RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                            .stroke(GaiaColor.broccoliBrown200, lineWidth: 0.5)
                    )
            }
            .padding(24)
            .frame(width: 312)
            .background(
                RoundedRectangle(cornerRadius: GaiaRadius.lg, style: .continuous)
                    .fill(GaiaColor.paperWhite50)
                    .overlay(
                        RoundedRectangle(cornerRadius: GaiaRadius.lg, style: .continuous)
                            .stroke(GaiaColor.broccoliBrown200, lineWidth: 0.5)
                    )
                    .shadow(color: GaiaShadow.greenGlow, radius: 40, x: 0, y: 8)
            )
            .padding(.top, 32)

            Text("Every sighting adds clarity\nto the bigger picture.")
                .font(.custom("NewSpirit-Regular", size: 20))
                .lineSpacing(6)
                .foregroundStyle(GaiaColor.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.top, 32)

            Spacer(minLength: 0)

            Button(action: onContinue) {
                Text("Add to Collection")
                    .gaiaFont(.body)
                    .foregroundStyle(GaiaColor.paperWhite50)
                    .padding(.horizontal, 28)
                    .frame(height: 50)
                    .background(
                        Capsule(style: .continuous)
                            .fill(GaiaColor.oliveGreen500)
                    )
            }
            .buttonStyle(.plain)
            .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, GaiaSpacing.md + 4)
    }
}

private struct ObserveWhyItMattersBody: View {
    var body: some View {
        (
            Text("Your find of ")
            + Text("Green Sea Turtles ").foregroundStyle(GaiaColor.oliveGreen500)
            + Text("supports in understanding subtropical health in the Hawaiian North Shore across 3 active datasets.")
        )
        .fixedSize(horizontal: false, vertical: true)
    }
}
