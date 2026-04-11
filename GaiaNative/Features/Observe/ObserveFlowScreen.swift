import SwiftUI

struct ObserveFlowScreen: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel = ObserveViewModel()

    var body: some View {
        if #available(iOS 18.0, *) {
            flowContent
                .toolbarVisibility(.hidden, for: .tabBar)
        } else {
            flowContent
        }
    }

    private var flowContent: some View {
        Group {
            switch viewModel.step {
            case .camera:
                ObserveCameraScreen(
                    onClose: { appState.select(section: .explore) },
                    onShutter: { viewModel.step = .loading },
                    onPhotoImport: { viewModel.step = .loading },
                    onAudioSend: { clipURL in
                        viewModel.submitAudioObservation(url: clipURL)
                    }
                )
            case .loading:
                ObserveLoadingScreen {
                    viewModel.step = .details
                }
            case .details:
                ObserveDetailsScreen(
                    onBack: { viewModel.step = .camera },
                    onContinue: { viewModel.step = .celebration }
                )
            case .celebration:
                ObserveCelebrationScreen(
                    onContinue: { viewModel.step = .share }
                )
            case .share:
                ObserveShareScreen(
                    onBack: { viewModel.step = .celebration },
                    onDone: { appState.select(section: .explore) }
                )
            }
        }
        .animation(GaiaMotion.softSpring, value: viewModel.step)
    }
}

private enum ObserveCelebrationLayout {
    static let horizontalInset: CGFloat = 43
    static let contentWidth: CGFloat = 315.134
    static let photoHeight: CGFloat = 195
    static let photoCornerRadius: CGFloat = 13.929
    static let photoBorderWidth: CGFloat = 0.871
    static let buttonHeight: CGFloat = 50
}

private struct ObserveCelebrationScreen: View {
    @EnvironmentObject private var contentStore: ContentStore

    let onContinue: () -> Void

    @State private var animateIn = false

    var body: some View {
        GeometryReader { proxy in
            let bottomInset = proxy.safeAreaInsets.bottom
            let bottomBarHeight = GaiaSpacing.md + ObserveCelebrationLayout.buttonHeight + max(GaiaSpacing.md, bottomInset)
            let availableWidth = max(0, proxy.size.width - (ObserveCelebrationLayout.horizontalInset * 2))
            let contentWidth = min(ObserveCelebrationLayout.contentWidth, availableWidth)

            ZStack(alignment: .bottom) {
                GaiaColor.paperWhite50
                    .ignoresSafeArea()

                ObserveCelebrationBackgroundWash()
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer(minLength: 0)

                    VStack(spacing: GaiaSpacing.xl) {
                        Text("Nice Find!")
                            .gaiaFont(.heroMedium)
                            .foregroundStyle(GaiaColor.inkBlack500)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .opacity(animateIn ? 1 : 0)
                            .scaleEffect(animateIn ? 1 : 0.9)
                            .offset(y: animateIn ? 0 : 30)
                            .animation(GaiaMotion.spring.delay(0.2), value: animateIn)

                        ObserveCelebrationSpeciesCard(
                            scientificName: formattedScientificName,
                            photoAssetName: "observe-photo-highlight"
                        )
                        .opacity(animateIn ? 1 : 0)
                        .offset(y: animateIn ? 0 : 40)
                        .animation(GaiaMotion.spring.delay(0.45), value: animateIn)

                        Text("Every sighting adds clarity to the bigger picture.")
                            .gaiaFont(.title3)
                            .foregroundStyle(GaiaColor.inkBlack500)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 275)
                            .opacity(animateIn ? 1 : 0)
                            .offset(y: animateIn ? 0 : 15)
                            .animation(.easeInOut(duration: 0.6).delay(0.7), value: animateIn)
                    }
                    .frame(width: contentWidth)

                    Spacer(minLength: 0)
                }
                .padding(.bottom, bottomBarHeight)

                ObserveCelebrationBottomBar(
                    bottomInset: bottomInset,
                    animateIn: animateIn,
                    action: onContinue
                )
            }
            .onAppear {
                animateIn = true
            }
        }
    }

    private var formattedScientificName: String {
        let words = contentStore.primarySpecies.scientificName.split(separator: " ")

        guard let firstWord = words.first else {
            return contentStore.primarySpecies.scientificName
        }

        let remainingWords = words.dropFirst().joined(separator: " ")
        guard !remainingWords.isEmpty else {
            return String(firstWord)
        }

        return "\(firstWord)\n\(remainingWords)"
    }
}

private struct ObserveCelebrationBackgroundWash: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            GaiaColor.oliveGreen400.opacity(0.14),
                            GaiaColor.oliveGreen400.opacity(0)
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 180
                    )
                )
                .frame(width: 360, height: 360)
                .offset(x: -166, y: -228)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            GaiaColor.oliveGreen400.opacity(0.12),
                            GaiaColor.oliveGreen400.opacity(0)
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 200
                    )
                )
                .frame(width: 400, height: 400)
                .offset(x: 160, y: 260)
        }
    }
}

private struct ObserveCelebrationSpeciesCard: View {
    let scientificName: String
    let photoAssetName: String

    var body: some View {
        VStack(alignment: .leading, spacing: GaiaSpacing.md) {
            Text(scientificName)
                .gaiaFont(.displayMedium)
                .foregroundStyle(GaiaColor.broccoliBrown500)
                .fixedSize(horizontal: false, vertical: true)

            GaiaAssetImage(name: photoAssetName)
                .frame(maxWidth: .infinity)
                .frame(height: ObserveCelebrationLayout.photoHeight)
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: ObserveCelebrationLayout.photoCornerRadius,
                        style: .continuous
                    )
                )
                .overlay(
                    RoundedRectangle(
                        cornerRadius: ObserveCelebrationLayout.photoCornerRadius,
                        style: .continuous
                    )
                    .stroke(GaiaColor.broccoliBrown200, lineWidth: ObserveCelebrationLayout.photoBorderWidth)
                )
        }
        .padding(GaiaSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: GaiaRadius.xl, style: .continuous)
                .fill(GaiaColor.neutralWhite)
                .shadow(color: GaiaColor.grassGreen500.opacity(0.23), radius: 24, x: 5, y: 10)
                .shadow(color: GaiaColor.grassGreen500.opacity(0.20), radius: 44, x: 19, y: 39)
                .shadow(color: GaiaColor.grassGreen500.opacity(0.12), radius: 59, x: 44, y: 89)
        )
        .overlay(
            RoundedRectangle(cornerRadius: GaiaRadius.xl, style: .continuous)
                .stroke(GaiaColor.broccoliBrown200, lineWidth: 1)
        )
    }
}

private struct ObserveCelebrationBottomBar: View {
    let bottomInset: CGFloat
    let animateIn: Bool
    let action: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Button(action: action) {
                Text("Add to Collection")
                    .gaiaFont(.bodyBold)
                    .foregroundStyle(GaiaColor.paperWhite50)
                    .frame(maxWidth: .infinity)
                    .frame(height: ObserveCelebrationLayout.buttonHeight)
                    .background(
                        Capsule(style: .continuous)
                            .fill(GaiaColor.oliveGreen500)
                    )
            }
            .buttonStyle(.plain)
            .opacity(animateIn ? 1 : 0)
            .offset(y: animateIn ? 0 : 10)
            .animation(.easeInOut(duration: 0.5).delay(0.9), value: animateIn)
            .padding(.horizontal, GaiaSpacing.md + 4)
            .padding(.top, GaiaSpacing.md)
            .padding(.bottom, max(GaiaSpacing.md, bottomInset))
        }
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [
                    GaiaColor.paperWhite50.opacity(0.001),
                    GaiaColor.paperWhite50
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .shadow(color: GaiaShadow.lgColor, radius: GaiaShadow.lgRadius, x: 0, y: GaiaShadow.lgYOffset)
    }
}
