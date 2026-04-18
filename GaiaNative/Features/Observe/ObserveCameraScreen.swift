// figma: https://www.figma.com/design/X0NcuRE0WKmsqR36cvlcij/Write-Test-Pro?node-id=48-1688&m=dev (Camera)
import SwiftUI
import AVFoundation
#if os(iOS)
import UIKit
import ImageIO
import PhotosUI
#endif

struct ObserveCameraScreen: View {
    let onClose: () -> Void
    let onShutter: () -> Void
    let onPhotoImport: () -> Void
    let onAudioSend: (URL) -> Void

    @StateObject private var cameraService = CameraService()
    @StateObject private var audioRecordingService = AudioRecordingService()
    @State private var selectedZoom: CGFloat = 1
    @State private var flashOpacity = 0.0
    @State private var isAudioRecorderPresented = false
    @State private var isPhotoPickerPresented = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var importedThumbnailImage: UIImage?

    private let zoomOptions: [CGFloat] = [0.5, 1, 2]

    var body: some View {
        GeometryReader { proxy in
            let viewportWidth = min(proxy.size.width, UIScreen.main.bounds.width)
            let viewportHeight = max(proxy.size.height, UIScreen.main.bounds.height)
            let sideInset = max(36, (viewportWidth - 330) / 2)
            // Slightly widen the control rail so side buttons visually align with the viewfinder brackets in Figma.
            let controlsWidth = max(0, (viewportWidth - (sideInset * 2)) + 3)

            ZStack {
                cameraLayer

                LinearGradient(
                    colors: [Color.black.opacity(0.02), Color.black.opacity(0.02), Color.black.opacity(0.48)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ObserveCameraTopBar(
                    sideInset: sideInset,
                    topInset: proxy.safeAreaInsets.top + 16,
                    onClose: onClose
                )

                ObserveCameraMatchCard()
                    .frame(width: min(330, viewportWidth - (sideInset * 2)))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .padding(.top, proxy.safeAreaInsets.top + 82)
                    .allowsHitTesting(false)

                ObserveCameraControls(
                    selectedZoom: selectedZoom,
                    zoomOptions: zoomOptions,
                    importedThumbnailImage: importedThumbnailImage,
                    controlsWidth: controlsWidth,
                    bottomInset: proxy.safeAreaInsets.bottom + 29,
                    onSelectZoom: setZoom,
                    onImportTap: presentPhotoPicker,
                    onShutter: handleShutter,
                    onMicrophoneTap: presentAudioRecorder
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

                if isAudioRecorderPresented {
                    Color.black.opacity(0.32)
                        .ignoresSafeArea()
                        .onTapGesture(perform: dismissAudioRecorder)
                        .transition(.opacity)

                    ObserveAudioRecorderSheet(
                        service: audioRecordingService,
                        bottomInset: proxy.safeAreaInsets.bottom,
                        onDismiss: dismissAudioRecorder,
                        onSend: handleAudioSend
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .frame(width: viewportWidth, height: viewportHeight)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea()
            .animation(GaiaMotion.softSpring, value: isAudioRecorderPresented)
        }
        .task {
            cameraService.start()
        }
        .onDisappear {
            cameraService.stop()
        }
        .photosPicker(
            isPresented: $isPhotoPickerPresented,
            selection: $selectedPhotoItem,
            matching: .images,
            preferredItemEncoding: .current
        )
        .task(id: selectedPhotoItem) {
            await handlePhotoSelection()
        }
    }

    @ViewBuilder
    private var cameraLayer: some View {
        if cameraService.isAuthorized && !cameraService.isUnavailable {
            CameraPreviewView(session: cameraService.session)
                .ignoresSafeArea()
        } else {
            GaiaAssetImage(name: "observe-camera-background", contentMode: .fill)
            .ignoresSafeArea()
        }
    }

    private func setZoom(_ value: CGFloat) {
        guard selectedZoom != value else { return }
        withAnimation(.interactiveSpring(response: 0.2, dampingFraction: 0.86)) {
            selectedZoom = value
        }
        cameraService.setZoomFactor(value)
        HapticsService.selectionChanged()
    }

    private func handleShutter() {
        HapticsService.selectionChanged()
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

    private func presentAudioRecorder() {
        withAnimation(GaiaMotion.softSpring) {
            isAudioRecorderPresented = true
        }
    }

    private func presentPhotoPicker() {
        isPhotoPickerPresented = true
    }

    private func dismissAudioRecorder() {
        audioRecordingService.discardRecording()
        withAnimation(GaiaMotion.softSpring) {
            isAudioRecorderPresented = false
        }
    }

    private func handleAudioSend(_ clipURL: URL) {
        onAudioSend(clipURL)
        audioRecordingService.clearStateAfterSend()
        withAnimation(GaiaMotion.softSpring) {
            isAudioRecorderPresented = false
        }
    }

    @MainActor
    private func handlePhotoSelection() async {
        guard let selectedPhotoItem else { return }

        do {
            guard
                let imageData = try await selectedPhotoItem.loadTransferable(type: Data.self),
                let image = await downsampledThumbnailImage(from: imageData, targetSize: CGSize(width: 64, height: 64))
            else {
                self.selectedPhotoItem = nil
                return
            }

            importedThumbnailImage = image
            HapticsService.selectionChanged()
            onPhotoImport()
        } catch {
            // Ignore cancelled or failed imports and keep the user in camera mode.
        }

        self.selectedPhotoItem = nil
    }

    #if os(iOS)
    private func downsampledThumbnailImage(from data: Data, targetSize: CGSize) async -> UIImage? {
        let scale = UIScreen.main.scale
        let maximumPixelSize = max(targetSize.width, targetSize.height) * scale

        return await Task.detached(priority: .userInitiated) {
            let sourceOptions: [CFString: Any] = [
                kCGImageSourceShouldCache: false
            ]

            guard let source = CGImageSourceCreateWithData(data as CFData, sourceOptions as CFDictionary) else {
                return nil
            }

            let thumbnailOptions: [CFString: Any] = [
                kCGImageSourceCreateThumbnailFromImageAlways: true,
                kCGImageSourceCreateThumbnailWithTransform: true,
                kCGImageSourceShouldCacheImmediately: true,
                kCGImageSourceThumbnailMaxPixelSize: maximumPixelSize
            ]

            guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, thumbnailOptions as CFDictionary) else {
                return nil
            }

            return UIImage(cgImage: cgImage)
        }.value
    }
    #endif
}

private struct ObserveCameraMatchCard: View {
    var body: some View {
        HStack(alignment: .top, spacing: GaiaSpacing.md - 4) {
            VStack(alignment: .leading, spacing: GaiaSpacing.xxs) {
                Text("Green Sea Turtle")
                    .gaiaFont(.title1)
                    .foregroundStyle(GaiaColor.textPrimary)
                    .lineLimit(2)

                Text("Chelonia mydas")
                    .gaiaFont(.caption)
                    .foregroundStyle(GaiaColor.inkBlack300)
                    .lineLimit(1)
            }

            Spacer(minLength: GaiaSpacing.md)

            Text("94% Match")
                .gaiaFont(.caption)
                .foregroundStyle(GaiaColor.inkBlack300)
        }
        .padding(.horizontal, GaiaSpacing.md)
        .padding(.vertical, GaiaSpacing.sm + 2)
        .background(
            GaiaMaterialBackground(cornerRadius: GaiaRadius.lg, showsShadow: true)
        )
        .clipShape(RoundedRectangle(cornerRadius: GaiaRadius.lg, style: .continuous))
    }
}

private struct ObserveCameraTopBar: View {
    let sideInset: CGFloat
    let topInset: CGFloat
    let onClose: () -> Void

    var body: some View {
        ObserveCameraGlassIconButton(accessibilityLabel: "Close camera", action: onClose) {
            GaiaIcon(kind: .close, size: 32, tint: GaiaColor.paperStrong)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(.leading, sideInset)
        .padding(.top, topInset)
    }
}

private struct ObserveCameraControls: View {
    let selectedZoom: CGFloat
    let zoomOptions: [CGFloat]
    let importedThumbnailImage: UIImage?
    let controlsWidth: CGFloat
    let bottomInset: CGFloat
    let onSelectZoom: (CGFloat) -> Void
    let onImportTap: () -> Void
    let onShutter: () -> Void
    let onMicrophoneTap: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            ObserveCameraZoomSelector(
                selectedZoom: selectedZoom,
                zoomOptions: zoomOptions,
                onSelectZoom: onSelectZoom
            )

            HStack(alignment: .center) {
                ObserveThumbnailButton(
                    thumbnailImage: importedThumbnailImage,
                    action: onImportTap
                )

                Spacer(minLength: 24)

                ObserveShutterButton(action: onShutter)

                Spacer(minLength: 24)

                ObserveCameraGlassIconButton(accessibilityLabel: "Record sound", action: onMicrophoneTap) {
                    GaiaIcon(kind: .microphone, size: 32, tint: GaiaColor.paperStrong)
                }
            }
            .frame(width: min(330, controlsWidth))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .padding(.bottom, bottomInset)
    }
}

private struct ObserveCameraGlassIconButton<Label: View>: View {
    let accessibilityLabel: String
    let action: () -> Void
    @ViewBuilder let label: () -> Label

    var body: some View {
        GlassCircleButton(size: 52, action: {
            HapticsService.selectionChanged()
            action()
        }) {
            label()
        }
        .accessibilityLabel(accessibilityLabel)
    }
}

private struct ObserveCameraZoomSelector: View {
    let selectedZoom: CGFloat
    let zoomOptions: [CGFloat]
    let onSelectZoom: (CGFloat) -> Void

    @State private var dragStartIndex: Int?

    private let pillSize: CGFloat = 38
    private let pillSpacing: CGFloat = 8

    private var selectedIndex: Int {
        zoomOptions.firstIndex(of: selectedZoom) ?? 0
    }

    private var step: CGFloat {
        pillSize + pillSpacing
    }

    private var rowOffset: CGFloat {
        rowOffset(for: selectedIndex)
    }

    private func rowOffset(for index: Int) -> CGFloat {
        let centeredIndex = CGFloat(zoomOptions.count - 1) / 2
        return (centeredIndex - CGFloat(index)) * step
    }

    private var frameWidth: CGFloat {
        (CGFloat(max(zoomOptions.count - 1, 0)) * step * 2) + pillSize
    }

    var body: some View {
        HStack(spacing: pillSpacing) {
            ForEach(Array(zoomOptions.enumerated()), id: \.offset) { _, option in
                Button(action: { onSelectZoom(option) }) {
                    Text(zoomLabel(for: option))
                        .gaiaFont(.callout)
                        .foregroundStyle(zoomTextColor(for: option))
                        .frame(width: pillSize, height: pillSize)
                        .background(
                            Capsule()
                                .fill(zoomBackground(for: option))
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .offset(x: rowOffset)
        .frame(width: frameWidth, height: pillSize, alignment: .center)
        .contentShape(Rectangle())
        .simultaneousGesture(zoomDragGesture, including: .gesture)
        .animation(.interactiveSpring(response: 0.2, dampingFraction: 0.86), value: selectedZoom)
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

    private var zoomDragGesture: some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onChanged { value in
                guard !zoomOptions.isEmpty else { return }
                if dragStartIndex == nil {
                    dragStartIndex = selectedIndex
                }
                guard let startIndex = dragStartIndex else { return }

                let indexDelta = Int((value.translation.width / step).rounded(.toNearestOrAwayFromZero))
                let clampedIndex = min(max(startIndex - indexDelta, 0), zoomOptions.count - 1)
                let selected = zoomOptions[clampedIndex]
                guard selectedZoom != selected else { return }
                onSelectZoom(selected)
            }
            .onEnded { _ in
                dragStartIndex = nil
            }
    }
}

private struct ObserveThumbnailButton: View {
    let thumbnailImage: UIImage?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                GaiaMaterialBackground(cornerRadius: 26, interactive: true)

                if let thumbnailImage {
                    Image(uiImage: thumbnailImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        .padding(1)
                } else {
                    GaiaAssetImage(name: "observe-camera-thumb")
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        .padding(1)
                }
            }
            .frame(width: 52, height: 52)
        }
        .buttonStyle(GlassReactiveButtonStyle())
        .accessibilityLabel("Choose photo from library")
        .accessibilityHint("Opens your photo library to upload an image")
    }
}

private struct ObserveShutterButton: View {
    let action: () -> Void
    @GestureState private var isPressed = false

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(isPressed ? 0.58 : 0.5))
                    .frame(width: 85, height: 85)
                    .shadow(color: Color.black.opacity(0.12), radius: 18, x: 0, y: 6)
                    .scaleEffect(isPressed ? 0.965 : 1)

                Circle()
                    .fill(GaiaColor.paperStrong)
                    .frame(width: 73, height: 73)
                    .scaleEffect(isPressed ? 0.9 : 1)
            }
            .scaleEffect(isPressed ? 0.975 : 1)
            .animation(.spring(response: 0.2, dampingFraction: 0.75), value: isPressed)
        }
        .buttonStyle(.plain)
        .contentShape(Circle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .updating($isPressed) { _, state, _ in
                    state = true
                }
        )
        .accessibilityLabel("Take photo")
    }
}

private struct ObserveViewfinderBrackets: View {
    var body: some View {
        GeometryReader { proxy in
            let bracketSize: CGFloat = 43
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
        let strokeWidth: CGFloat = 2.5
        let armLength: CGFloat = 28
        let cornerRadius: CGFloat = 3

        Path { path in
            let inset = strokeWidth / 2
            path.move(to: CGPoint(x: armLength, y: inset))
            path.addLine(to: CGPoint(x: inset + cornerRadius, y: inset))
            path.addArc(
                tangent1End: CGPoint(x: inset, y: inset),
                tangent2End: CGPoint(x: inset, y: inset + cornerRadius),
                radius: cornerRadius
            )
            path.addLine(to: CGPoint(x: inset, y: armLength))
        }
        .stroke(
            GaiaColor.paperStrong.opacity(0.7),
            style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round, lineJoin: .round)
        )
        .scaleEffect(x: xScale, y: yScale, anchor: .center)
    }

    private var xScale: CGFloat {
        switch position {
        case .topLeft, .bottomLeft: 1
        case .topRight, .bottomRight: -1
        }
    }

    private var yScale: CGFloat {
        switch position {
        case .topLeft, .topRight: 1
        case .bottomLeft, .bottomRight: -1
        }
    }
}

private struct ObserveAudioRecorderSheet: View {
    @ObservedObject var service: AudioRecordingService
    let bottomInset: CGFloat
    let onDismiss: () -> Void
    let onSend: (URL) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: GaiaSpacing.md) {
            Capsule()
                .fill(GaiaColor.greyMuted.opacity(0.28))
                .frame(width: 42, height: 4)
                .frame(maxWidth: .infinity)
                .padding(.top, GaiaSpacing.sm)

            HStack(alignment: .top, spacing: GaiaSpacing.sm) {
                VStack(alignment: .leading, spacing: GaiaSpacing.xs) {
                    Text("Add an audio note")
                        .gaiaFont(.title3Medium)
                        .foregroundStyle(GaiaColor.textPrimary)

                    Text(subtitle)
                        .gaiaFont(.subheadline)
                        .foregroundStyle(GaiaColor.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: GaiaSpacing.sm)

                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(GaiaColor.inkBlack400)
                        .frame(width: 30, height: 30)
                        .background(
                            Circle()
                                .fill(GaiaColor.oliveGreen100.opacity(0.6))
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Close audio recorder")
            }

            recorderBody
        }
        .padding(.horizontal, GaiaSpacing.md)
        .padding(.bottom, max(GaiaSpacing.md, bottomInset))
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: GaiaRadius.sheet, style: .continuous)
                .fill(GaiaColor.surfaceSheet)
                .overlay(
                    RoundedRectangle(cornerRadius: GaiaRadius.sheet, style: .continuous)
                        .stroke(GaiaColor.borderStrong, lineWidth: 1)
                )
                .shadow(color: GaiaShadow.lgColor, radius: GaiaShadow.lgRadius, x: 0, y: GaiaShadow.lgYOffset)
        )
        .padding(.horizontal, GaiaSpacing.md)
        .padding(.bottom, GaiaSpacing.sm)
    }

    @ViewBuilder
    private var recorderBody: some View {
        if service.permissionState == .denied {
            VStack(alignment: .leading, spacing: GaiaSpacing.sm) {
                Text("Microphone access is currently disabled for Gaia.")
                    .gaiaFont(.callout)
                    .foregroundStyle(GaiaColor.textPrimary)

                Button(action: openSettings) {
                    Text("Open Settings")
                        .gaiaFont(.calloutMedium)
                        .foregroundStyle(GaiaColor.paperStrong)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(GaiaColor.olive, in: Capsule())
                }
                .buttonStyle(.plain)
            }
            .padding(.top, GaiaSpacing.xs)
        } else {
            VStack(spacing: GaiaSpacing.md) {
                ZStack {
                    Circle()
                        .fill(
                            service.isRecording
                                ? GaiaColor.vermillion100.opacity(0.95)
                                : GaiaColor.oliveGreen100.opacity(0.9)
                        )
                        .frame(width: 86, height: 86)

                    Image(systemName: service.isRecording ? "waveform.circle.fill" : "mic.circle.fill")
                        .font(.system(size: 42, weight: .regular))
                        .foregroundStyle(service.isRecording ? GaiaColor.vermillion500 : GaiaColor.oliveGreen700)
                }
                .padding(.top, GaiaSpacing.sm)

                Text(formatDuration(service.elapsedTime))
                    .gaiaFont(.title1)
                    .foregroundStyle(GaiaColor.textPrimary)
                    .monospacedDigit()

                if let errorMessage = service.errorMessage {
                    Text(errorMessage)
                        .gaiaFont(.footnote)
                        .foregroundStyle(GaiaColor.vermillion500)
                        .multilineTextAlignment(.center)
                }

                controls
            }
            .frame(maxWidth: .infinity)
        }
    }

    @ViewBuilder
    private var controls: some View {
        if service.isRecording {
            ObserveRecorderPrimaryButton(
                title: "Stop Recording",
                color: GaiaColor.vermillion500
            ) {
                service.stopRecording()
            }
        } else if let clipURL = service.recordedFileURL {
            VStack(spacing: GaiaSpacing.sm) {
                HStack(spacing: GaiaSpacing.sm) {
                    ObserveRecorderSecondaryButton(title: "Re-record") {
                        service.discardRecording()
                        service.startRecording()
                    }

                    ObserveRecorderPrimaryButton(
                        title: "Send",
                        color: GaiaColor.olive
                    ) {
                        onSend(clipURL)
                    }
                }

                Text("Clip ready to upload")
                    .gaiaFont(.footnote)
                    .foregroundStyle(GaiaColor.textSecondary)
            }
        } else {
            ObserveRecorderPrimaryButton(
                title: "Start Recording",
                color: GaiaColor.olive
            ) {
                service.startRecording()
            }
        }
    }

    private var subtitle: String {
        if service.isRecording {
            return "Recording in progress. Tap stop when you’re ready to send."
        }
        if service.recordedFileURL != nil {
            return "Preview is ready. Send to attach it to this observation."
        }
        return "Capture a quick voice note to send with this observation."
    }

    private func openSettings() {
        #if os(iOS)
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
        #endif
    }

    private func formatDuration(_ value: TimeInterval) -> String {
        let totalSeconds = Int(max(0, value.rounded(.down)))
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%01d:%02d", minutes, seconds)
    }
}

private struct ObserveRecorderPrimaryButton: View {
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .gaiaFont(.calloutMedium)
                .foregroundStyle(GaiaColor.paperStrong)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(color, in: Capsule())
        }
        .buttonStyle(.plain)
    }
}

private struct ObserveRecorderSecondaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .gaiaFont(.calloutMedium)
                .foregroundStyle(GaiaColor.oliveGreen700)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    Capsule()
                        .fill(GaiaColor.oliveGreen100.opacity(0.8))
                )
        }
        .buttonStyle(.plain)
    }
}

private struct ObserveCameraStatusOverlay: View {
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: GaiaSpacing.sm) {
            Text(title)
                .gaiaFont(.title3Medium)
                .foregroundStyle(GaiaColor.paperStrong)

            Text(message)
                .gaiaFont(.subheadline)
                .foregroundStyle(GaiaColor.textInverse)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, GaiaSpacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}

@MainActor
final class AudioRecordingService: NSObject, ObservableObject {
    enum PermissionState {
        case undetermined
        case denied
        case granted
    }

    @Published private(set) var permissionState: PermissionState
    @Published private(set) var isRecording = false
    @Published private(set) var recordedFileURL: URL?
    @Published private(set) var elapsedTime: TimeInterval = 0
    @Published private(set) var errorMessage: String?

    private let audioSession = AVAudioSession.sharedInstance()
    private var recorder: AVAudioRecorder?
    private var timer: Timer?

    override init() {
        permissionState = AudioRecordingService.currentPermissionState()
        super.init()
    }

    func startRecording() {
        errorMessage = nil

        switch permissionState {
        case .granted:
            beginRecording()
        case .denied:
            errorMessage = "Microphone access is off. Enable it in Settings to record."
        case .undetermined:
            requestPermission { [weak self] granted in
                guard let self else { return }
                if granted {
                    self.startRecording()
                } else {
                    self.errorMessage = "Microphone access is required to capture audio."
                }
            }
        }
    }

    func stopRecording() {
        guard isRecording else { return }

        recorder?.stop()
        elapsedTime = recorder?.currentTime ?? elapsedTime
        isRecording = false
        stopTimer()
        deactivateAudioSession()
        HapticsService.selectionChanged()
    }

    func discardRecording() {
        if isRecording {
            recorder?.stop()
            isRecording = false
        }

        stopTimer()
        deactivateAudioSession()
        deleteRecordedFile()
        recorder = nil
        recordedFileURL = nil
        elapsedTime = 0
        errorMessage = nil
    }

    func clearStateAfterSend() {
        if isRecording {
            recorder?.stop()
            isRecording = false
        }

        stopTimer()
        deactivateAudioSession()
        recorder = nil
        recordedFileURL = nil
        elapsedTime = 0
        errorMessage = nil
    }

    private func beginRecording() {
        guard !isRecording else { return }
        deleteRecordedFile()
        recordedFileURL = nil
        elapsedTime = 0

        do {
            try audioSession.setCategory(
                .playAndRecord,
                mode: .default,
                options: [.defaultToSpeaker, .allowBluetoothHFP]
            )
            try audioSession.setActive(true)

            let url = FileManager.default.temporaryDirectory
                .appendingPathComponent("observe-audio-\(UUID().uuidString).m4a")
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12_000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]

            let recorder = try AVAudioRecorder(url: url, settings: settings)
            recorder.prepareToRecord()

            guard recorder.record() else {
                errorMessage = "Unable to start recording right now. Please try again."
                deactivateAudioSession()
                return
            }

            self.recorder = recorder
            recordedFileURL = url
            isRecording = true
            startTimer()
            HapticsService.selectionChanged()
        } catch {
            errorMessage = "Unable to access audio recording right now."
            deactivateAudioSession()
        }
    }

    private func requestPermission(completion: @escaping (Bool) -> Void) {
        AVAudioApplication.requestRecordPermission { [weak self] granted in
            DispatchQueue.main.async {
                guard let self else { return }
                self.permissionState = granted ? .granted : .denied
                completion(granted)
            }
        }
    }

    private func deleteRecordedFile() {
        guard let recordedFileURL else { return }
        try? FileManager.default.removeItem(at: recordedFileURL)
    }

    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(
            timeInterval: 0.1,
            target: self,
            selector: #selector(updateElapsedTime),
            userInfo: nil,
            repeats: true
        )

        if let timer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }

    @objc private func updateElapsedTime() {
        guard let recorder else { return }
        elapsedTime = recorder.currentTime
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func deactivateAudioSession() {
        try? audioSession.setActive(false, options: [.notifyOthersOnDeactivation])
    }

    private static func currentPermissionState() -> PermissionState {
        switch AVAudioApplication.shared.recordPermission {
        case .granted:
            return .granted
        case .denied:
            return .denied
        case .undetermined:
            return .undetermined
        @unknown default:
            return .denied
        }
    }
}
