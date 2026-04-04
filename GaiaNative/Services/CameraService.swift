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
    private var activeInput: AVCaptureDeviceInput?
    private var wideDevice: AVCaptureDevice?
    private var ultraWideDevice: AVCaptureDevice?

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
            guard let device = self.device(for: factor) else { return }
            guard self.activateDeviceIfNeeded(device) else { return }
            self.applyZoom(factor, on: device)
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

        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera, .builtInUltraWideCamera],
            mediaType: .video,
            position: .back
        )
        wideDevice = discoverySession.devices.first(where: { $0.deviceType == .builtInWideAngleCamera })
        ultraWideDevice = discoverySession.devices.first(where: { $0.deviceType == .builtInUltraWideCamera })

        guard let device = wideDevice ?? ultraWideDevice else {
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
            activeInput = input
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

    private func device(for requestedZoom: CGFloat) -> AVCaptureDevice? {
        if requestedZoom < 1, let ultraWideDevice {
            return ultraWideDevice
        }

        return wideDevice ?? activeDevice
    }

    @discardableResult
    private func activateDeviceIfNeeded(_ device: AVCaptureDevice) -> Bool {
        guard activeDevice?.uniqueID != device.uniqueID else { return true }
        guard let currentInput = activeInput else { return false }

        do {
            let input = try AVCaptureDeviceInput(device: device)
            session.beginConfiguration()
            session.removeInput(currentInput)

            guard session.canAddInput(input) else {
                session.addInput(currentInput)
                session.commitConfiguration()
                return false
            }

            session.addInput(input)
            session.commitConfiguration()

            activeInput = input
            activeDevice = device
            return true
        } catch {
            return false
        }
    }

    private func applyZoom(_ requestedZoom: CGFloat, on device: AVCaptureDevice) {
        let deviceZoom: CGFloat
        if requestedZoom < 1, device.deviceType == .builtInUltraWideCamera {
            // The ultra-wide lens native field of view corresponds to the 0.5x UI stop.
            deviceZoom = 1
        } else {
            deviceZoom = requestedZoom
        }

        let minZoom = device.minAvailableVideoZoomFactor
        let maxZoom = min(device.maxAvailableVideoZoomFactor, 2.0)
        let clampedZoom = max(minZoom, min(maxZoom, deviceZoom))

        do {
            try device.lockForConfiguration()
            device.videoZoomFactor = clampedZoom
            device.unlockForConfiguration()
        } catch {
            return
        }
    }
}
