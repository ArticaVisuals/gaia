import AVFoundation
import Foundation

final class CameraService: NSObject, ObservableObject {
    @Published private(set) var isAuthorized = false
    @Published private(set) var authorizationDenied = false
    @Published private(set) var isRunning = false
    @Published private(set) var isUnavailable = false

    let session = AVCaptureSession()

    private let sessionQueue = DispatchQueue(label: "com.gaia.prototype.camera.session")
    private var isConfigured = false
    private var activeDevice: AVCaptureDevice?

    func start() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            DispatchQueue.main.async {
                self.isAuthorized = true
                self.authorizationDenied = false
            }
            configureAndStartSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    self.isAuthorized = granted
                    self.authorizationDenied = !granted
                }

                if granted {
                    self.configureAndStartSession()
                }
            }
        case .denied, .restricted:
            DispatchQueue.main.async {
                self.isAuthorized = false
                self.authorizationDenied = true
            }
        @unknown default:
            DispatchQueue.main.async {
                self.isAuthorized = false
                self.authorizationDenied = true
            }
        }
    }

    func stop() {
        sessionQueue.async {
            guard self.session.isRunning else { return }
            self.session.stopRunning()
            DispatchQueue.main.async {
                self.isRunning = false
            }
        }
    }

    func setZoomFactor(_ factor: CGFloat) {
        sessionQueue.async {
            guard let device = self.activeDevice else { return }

            let minZoom = max(1.0, device.minAvailableVideoZoomFactor)
            let maxZoom = min(device.maxAvailableVideoZoomFactor, 2.0)
            let requestedZoom = max(minZoom, min(maxZoom, factor))

            do {
                try device.lockForConfiguration()
                device.videoZoomFactor = requestedZoom
                device.unlockForConfiguration()
            } catch {
                return
            }
        }
    }

    private func configureAndStartSession() {
        sessionQueue.async {
            if !self.isConfigured {
                self.configureSession()
            }

            guard self.isConfigured, !self.session.isRunning else { return }
            self.session.startRunning()
            DispatchQueue.main.async {
                self.isRunning = true
            }
        }
    }

    private func configureSession() {
        session.beginConfiguration()
        session.sessionPreset = .photo

        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            session.commitConfiguration()
            DispatchQueue.main.async {
                self.isUnavailable = true
            }
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: device)

            guard session.canAddInput(input) else {
                session.commitConfiguration()
                DispatchQueue.main.async {
                    self.isUnavailable = true
                }
                return
            }

            session.addInput(input)
            activeDevice = device
            isConfigured = true
            session.commitConfiguration()
            DispatchQueue.main.async {
                self.isUnavailable = false
            }
        } catch {
            session.commitConfiguration()
            DispatchQueue.main.async {
                self.isUnavailable = true
            }
        }
    }
}
