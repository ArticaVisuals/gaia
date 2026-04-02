import SwiftUI

struct ObserveCameraScreen: View {
    let onClose: () -> Void
    let onShutter: () -> Void

    @StateObject private var cameraService = CameraService()
    @State private var selectedZoom: CGFloat = 1
    @State private var flashOpacity = 0.0

    private let zoomOptions: [CGFloat] = [0.5, 1, 2]

    var body: some View {
        GeometryReader { proxy in
            let viewportWidth = min(proxy.size.width, UIScreen.main.bounds.width)
            let viewportHeight = max(proxy.size.height, UIScreen.main.bounds.height)
            let sideInset = max(36, (viewportWidth - 330) / 2)
            let controlsWidth = max(0, viewportWidth - (sideInset * 2))

            ZStack {
                cameraLayer

                LinearGradient(
                    colors: [Color.black.opacity(0.02), Color.black.opacity(0.02), Color.black.opacity(0.48)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ObserveViewfinderBrackets()
                    .frame(width: viewportWidth, height: viewportHeight)
                    .allowsHitTesting(false)

                ObserveCameraTopBar(
                    sideInset: sideInset,
                    topInset: proxy.safeAreaInsets.top + 16,
                    onClose: onClose
                )

                ObserveCameraControls(
                    selectedZoom: selectedZoom,
                    zoomOptions: zoomOptions,
                    controlsWidth: controlsWidth,
                    bottomInset: proxy.safeAreaInsets.bottom + 29,
                    onSelectZoom: setZoom,
                    onShutter: handleShutter
                )

                if flashOpacity > 0 {
                    Color.white
                        .opacity(flashOpacity)
                        .ignoresSafeArea()
                }

                if cameraService.authorizationDenied {
                    ObserveCameraStatusOverlay(
                        title: "Enable Camera",
                        message: "Gaia needs camera access to observe living things."
                    )
                }
            }
            .frame(width: viewportWidth, height: viewportHeight)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
        }
        .task {
            cameraService.start()
        }
        .onDisappear {
            cameraService.stop()
        }
    }

    @ViewBuilder
    private var cameraLayer: some View {
        if cameraService.isAuthorized && !cameraService.isUnavailable {
            CameraPreviewView(session: cameraService.session)
                .ignoresSafeArea()
        } else {
            ZStack {
                LinearGradient(
                    colors: [
                        GaiaColor.paperWhite50,
                        GaiaColor.oliveGreen100.opacity(0.82),
                        GaiaColor.oliveGreen700.opacity(0.92)
                    ],
                    startPoint: .topTrailing,
                    endPoint: .bottomLeading
                )
                .overlay(
                    RadialGradient(
                        colors: [Color.white.opacity(0.7), Color.clear],
                        center: .topTrailing,
                        startRadius: 12,
                        endRadius: 280
                    )
                )
                .overlay(
                    LinearGradient(
                        colors: [Color.clear, Color.black.opacity(0.38)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
            .ignoresSafeArea()
        }
    }

    private func setZoom(_ value: CGFloat) {
        selectedZoom = value
        let effectiveZoom = value < 1 ? 1 : value
        cameraService.setZoomFactor(effectiveZoom)
        HapticsService.selectionChanged()
    }

    private func handleShutter() {
        withAnimation(.easeOut(duration: 0.08)) {
            flashOpacity = 0.72
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            withAnimation(.easeOut(duration: 0.18)) {
                flashOpacity = 0
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            onShutter()
        }
    }
}

private struct ObserveCameraTopBar: View {
    let sideInset: CGFloat
    let topInset: CGFloat
    let onClose: () -> Void

    var body: some View {
        GlassCircleButton(size: 52, action: onClose) {
            GaiaIcon(kind: .close, size: 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(.leading, sideInset)
        .padding(.top, topInset)
    }
}

private struct ObserveCameraControls: View {
    let selectedZoom: CGFloat
    let zoomOptions: [CGFloat]
    let controlsWidth: CGFloat
    let bottomInset: CGFloat
    let onSelectZoom: (CGFloat) -> Void
    let onShutter: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 8) {
                ForEach(zoomOptions, id: \.self) { option in
                    Button(action: { onSelectZoom(option) }) {
                        Text(zoomLabel(for: option))
                            .font(GaiaTypography.callout)
                            .foregroundStyle(zoomTextColor(for: option))
                            .frame(width: 38, height: 38)
                            .background(
                                Capsule()
                                    .fill(zoomBackground(for: option))
                            )
                    }
                    .buttonStyle(.plain)
                }
            }

            HStack(alignment: .center) {
                ObserveThumbnailButton()

                Spacer(minLength: 24)

                ObserveShutterButton(action: onShutter)

                Spacer(minLength: 24)

                GlassCircleButton(size: 52, action: {}) {
                    GaiaIcon(kind: .microphone, size: 32, tint: GaiaColor.paperStrong)
                }
            }
            .frame(width: min(330, controlsWidth))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .padding(.bottom, bottomInset)
    }

    private func zoomLabel(for option: CGFloat) -> String {
        switch option {
        case 0.5:
            return ".5"
        case 1:
            return "1x"
        default:
            return "2"
        }
    }

    private func zoomBackground(for option: CGFloat) -> Color {
        selectedZoom == option ? Color.black.opacity(0.35) : .clear
    }

    private func zoomTextColor(for option: CGFloat) -> Color {
        selectedZoom == option ? Color(red: 246 / 255, green: 210 / 255, blue: 20 / 255) : GaiaColor.paperStrong
    }
}

private struct ObserveThumbnailButton: View {
    var body: some View {
        Button(action: {}) {
            ZStack {
                GaiaMaterialBackground(cornerRadius: 26)

                GaiaAssetImage(name: "observe-camera-thumb")
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    .padding(1)
            }
            .frame(width: 52, height: 52)
        }
        .buttonStyle(.plain)
    }
}

private struct ObserveShutterButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.5))
                    .frame(width: 85, height: 85)
                    .shadow(color: Color.black.opacity(0.12), radius: 18, x: 0, y: 6)

                Circle()
                    .fill(GaiaColor.paperStrong)
                    .frame(width: 73, height: 73)
            }
        }
        .buttonStyle(.plain)
        .contentShape(Circle())
    }
}

private struct ObserveViewfinderBrackets: View {
    var body: some View {
        GeometryReader { proxy in
            let bracketSize: CGFloat = 44
            let sideInset = max(36, (proxy.size.width - 330) / 2)
            let topY = proxy.size.height * 0.22
            let bottomY = proxy.size.height * 0.73

            ZStack {
                ObserveBracketCorner(position: .topLeft)
                    .frame(width: bracketSize, height: bracketSize)
                    .position(x: sideInset + bracketSize / 2, y: topY)

                ObserveBracketCorner(position: .topRight)
                    .frame(width: bracketSize, height: bracketSize)
                    .position(x: proxy.size.width - sideInset - bracketSize / 2, y: topY)

                ObserveBracketCorner(position: .bottomLeft)
                    .frame(width: bracketSize, height: bracketSize)
                    .position(x: sideInset + bracketSize / 2, y: bottomY)

                ObserveBracketCorner(position: .bottomRight)
                    .frame(width: bracketSize, height: bracketSize)
                    .position(x: proxy.size.width - sideInset - bracketSize / 2, y: bottomY)
            }
        }
    }
}

private struct ObserveBracketCorner: View {
    enum Position {
        case topLeft
        case topRight
        case bottomLeft
        case bottomRight
    }

    let position: Position

    var body: some View {
        ZStack(alignment: alignment) {
            Rectangle()
                .fill(GaiaColor.paperStrong.opacity(0.78))
                .frame(width: 28, height: 2.5)

            Rectangle()
                .fill(GaiaColor.paperStrong.opacity(0.78))
                .frame(width: 2.5, height: 28)
        }
    }

    private var alignment: Alignment {
        switch position {
        case .topLeft: .topLeading
        case .topRight: .topTrailing
        case .bottomLeft: .bottomLeading
        case .bottomRight: .bottomTrailing
        }
    }
}

private struct ObserveCameraStatusOverlay: View {
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: GaiaSpacing.sm) {
            Text(title)
                .font(GaiaTypography.title)
                .foregroundStyle(GaiaColor.paperStrong)

            Text(message)
                .font(GaiaTypography.subheadline)
                .foregroundStyle(GaiaColor.paperWhite100)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, GaiaSpacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}
