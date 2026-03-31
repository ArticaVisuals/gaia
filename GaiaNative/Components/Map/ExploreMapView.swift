import CoreLocation
import MapKit
import SwiftUI
import UIKit

struct ExploreMapView: UIViewRepresentable {
    let observations: [Observation]
    let recenterRequestID: UUID?
    var onSelectObservation: ((Observation) -> Void)? = nil

    func makeCoordinator() -> Coordinator {
        Coordinator(onSelectObservation: onSelectObservation)
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        mapView.delegate = context.coordinator
        context.coordinator.attach(to: mapView)
        mapView.pointOfInterestFilter = .excludingAll
        mapView.showsCompass = false
        mapView.showsScale = false
        mapView.showsTraffic = false
        mapView.showsBuildings = true
        mapView.isScrollEnabled = true
        mapView.isZoomEnabled = true
        mapView.isMultipleTouchEnabled = true
        mapView.isRotateEnabled = false
        mapView.isPitchEnabled = false
        mapView.mapType = .mutedStandard
        mapView.register(PhotoPinAnnotationView.self, forAnnotationViewWithReuseIdentifier: PhotoPinAnnotationView.reuseIdentifier)
        mapView.register(ClusterPinAnnotationView.self, forAnnotationViewWithReuseIdentifier: ClusterPinAnnotationView.reuseIdentifier)
        mapView.setRegion(Self.region(for: observations), animated: false)
        context.coordinator.apply(observations: observations, to: mapView)
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        context.coordinator.onSelectObservation = onSelectObservation
        context.coordinator.apply(observations: observations, to: mapView)
        context.coordinator.handleRecenterRequest(recenterRequestID, in: mapView)
    }

    private static func region(for observations: [Observation]) -> MKCoordinateRegion {
        guard let first = observations.first else {
            return MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 34.1368, longitude: -118.1256),
                span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
            )
        }

        let lats = observations.map(\.latitude)
        let lngs = observations.map(\.longitude)
        let minLat = lats.min() ?? first.latitude
        let maxLat = lats.max() ?? first.latitude
        let minLng = lngs.min() ?? first.longitude
        let maxLng = lngs.max() ?? first.longitude

        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLng + maxLng) / 2
        )

        let latDelta = max((maxLat - minLat) * 2.2, 0.035)
        let lngDelta = max((maxLng - minLng) * 2.2, 0.035)

        return MKCoordinateRegion(
            center: center,
            span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lngDelta)
        )
    }

    final class Coordinator: NSObject, CLLocationManagerDelegate, MKMapViewDelegate {
        private var hasSetInitialRegion = false
        private let locationManager = CLLocationManager()
        private weak var mapView: MKMapView?
        private var lastHandledRecenterRequestID: UUID?
        private var pendingRecentering = false
        var onSelectObservation: ((Observation) -> Void)?

        init(onSelectObservation: ((Observation) -> Void)?) {
            self.onSelectObservation = onSelectObservation
            super.init()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        }

        func attach(to mapView: MKMapView) {
            self.mapView = mapView
            updateUserLocationVisibility(on: mapView)
        }

        func apply(observations: [Observation], to mapView: MKMapView) {
            let existing = mapView.annotations.compactMap { $0 as? ObservationAnnotation }
            let existingIDs = Set(existing.map(\.observation.id))
            let incomingIDs = Set(observations.map(\.id))

            let staleAnnotations = existing.filter { !incomingIDs.contains($0.observation.id) }
            if !staleAnnotations.isEmpty {
                mapView.removeAnnotations(staleAnnotations)
            }

            let newAnnotations = observations
                .filter { !existingIDs.contains($0.id) }
                .map(ObservationAnnotation.init(observation:))

            if !newAnnotations.isEmpty {
                mapView.addAnnotations(newAnnotations)
            }

            if !hasSetInitialRegion {
                mapView.setRegion(ExploreMapView.region(for: observations), animated: false)
                hasSetInitialRegion = true
            }
        }

        func handleRecenterRequest(_ requestID: UUID?, in mapView: MKMapView) {
            guard let requestID, requestID != lastHandledRecenterRequestID else { return }
            lastHandledRecenterRequestID = requestID
            centerOnUser(in: mapView)
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if let cluster = annotation as? MKClusterAnnotation {
                let view = mapView.dequeueReusableAnnotationView(
                    withIdentifier: ClusterPinAnnotationView.reuseIdentifier,
                    for: cluster
                ) as? ClusterPinAnnotationView
                view?.configure(count: cluster.memberAnnotations.count)
                return view
            }

            guard let observationAnnotation = annotation as? ObservationAnnotation else {
                return nil
            }

            let view = mapView.dequeueReusableAnnotationView(
                withIdentifier: PhotoPinAnnotationView.reuseIdentifier,
                for: observationAnnotation
            ) as? PhotoPinAnnotationView
            view?.configure(imageName: observationAnnotation.observation.thumbnailAssetName)
            view?.onActivate = { [weak self] in
                self?.onSelectObservation?(observationAnnotation.observation)
            }
            return view
        }

        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let cluster = view.annotation as? MKClusterAnnotation else { return }

            let coordinates = cluster.memberAnnotations.map(\.coordinate)
            guard !coordinates.isEmpty else { return }

            let rect = coordinates.reduce(MKMapRect.null) { partialResult, coordinate in
                let point = MKMapPoint(coordinate)
                let pointRect = MKMapRect(x: point.x, y: point.y, width: 0, height: 0)
                return partialResult.isNull ? pointRect : partialResult.union(pointRect)
            }

            let paddedRect = mapView.mapRectThatFits(
                rect,
                edgePadding: UIEdgeInsets(top: 100, left: 72, bottom: 140, right: 72)
            )
            mapView.setVisibleMapRect(paddedRect, animated: true)

            DispatchQueue.main.async {
                view.isSelected = false
            }
        }

        func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
            guard let mapView else { return }

            updateUserLocationVisibility(on: mapView)

            switch manager.authorizationStatus {
            case .authorizedAlways, .authorizedWhenInUse:
                if pendingRecentering {
                    centerOnUser(in: mapView)
                }
            case .denied, .restricted:
                pendingRecentering = false
            case .notDetermined:
                break
            @unknown default:
                pendingRecentering = false
            }
        }

        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            guard pendingRecentering, let location = locations.last, let mapView else { return }
            recenter(on: location.coordinate, in: mapView)
        }

        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            pendingRecentering = false
        }

        private func centerOnUser(in mapView: MKMapView) {
            switch locationManager.authorizationStatus {
            case .authorizedAlways, .authorizedWhenInUse:
                updateUserLocationVisibility(on: mapView)
                if let coordinate = locationManager.location?.coordinate ?? mapView.userLocation.location?.coordinate {
                    recenter(on: coordinate, in: mapView)
                } else {
                    pendingRecentering = true
                    locationManager.requestLocation()
                }
            case .notDetermined:
                pendingRecentering = true
                locationManager.requestWhenInUseAuthorization()
            case .denied, .restricted:
                pendingRecentering = false
            @unknown default:
                pendingRecentering = false
            }
        }

        private func recenter(on coordinate: CLLocationCoordinate2D, in mapView: MKMapView) {
            pendingRecentering = false
            let region = MKCoordinateRegion(
                center: coordinate,
                latitudinalMeters: 1500,
                longitudinalMeters: 1500
            )
            mapView.setRegion(mapView.regionThatFits(region), animated: true)
        }

        private func updateUserLocationVisibility(on mapView: MKMapView) {
            switch locationManager.authorizationStatus {
            case .authorizedAlways, .authorizedWhenInUse:
                mapView.showsUserLocation = true
            default:
                mapView.showsUserLocation = false
            }
        }
    }
}

private final class ObservationAnnotation: NSObject, MKAnnotation {
    let observation: Observation
    let coordinate: CLLocationCoordinate2D

    init(observation: Observation) {
        self.observation = observation
        self.coordinate = CLLocationCoordinate2D(latitude: observation.latitude, longitude: observation.longitude)
    }
}

private final class PhotoPinAnnotationView: MKAnnotationView {
    static let reuseIdentifier = "PhotoPinAnnotationView"

    var onActivate: (() -> Void)?

    private let glowContainer = UIView()
    private let materialView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialLight))
    private let ringOverlay = UIView()
    private let imageContainer = UIView()
    private let imageView = UIImageView()
    private let fallbackGradient = CAGradientLayer()
    private let ambientGlowLayer = CALayer()
    private let glowBlobSpecs: [(color: UIColor, radius: CGFloat, xAmplitude: CGFloat, yAmplitude: CGFloat, duration: CFTimeInterval, alpha: Float)] = [
        (UIColor(red: 103 / 255, green: 118 / 255, blue: 91 / 255, alpha: 1), 24, 9, 7, 4.6, 0.40),
        (UIColor(red: 79 / 255, green: 90 / 255, blue: 69 / 255, alpha: 1), 20, 8, 9, 5.4, 0.34),
        (UIColor(red: 163 / 255, green: 174 / 255, blue: 149 / 255, alpha: 1), 18, 7, 8, 6.1, 0.28)
    ]
    private var glowBlobLayers: [CALayer] = []
    private var glowAnimationsStarted = false
    private lazy var pressRecognizer: UILongPressGestureRecognizer = {
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(handlePress(_:)))
        recognizer.minimumPressDuration = 0
        recognizer.allowableMovement = 18
        recognizer.cancelsTouchesInView = false
        return recognizer
    }()
    private var isPressing = false

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        onActivate = nil
        isPressing = false
        layer.removeAllAnimations()
        transform = .identity
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        bounds = CGRect(origin: .zero, size: CGSize(width: 62, height: 62))
        frame.size = bounds.size

        glowContainer.frame = bounds
        materialView.frame = bounds
        ringOverlay.frame = bounds
        imageContainer.frame = CGRect(x: 2.486, y: 2.195, width: 57.343, height: 57.343)
        imageView.frame = imageContainer.bounds
        fallbackGradient.frame = imageContainer.bounds

        let center = CGPoint(x: glowContainer.bounds.midX, y: glowContainer.bounds.midY)
        ambientGlowLayer.bounds = CGRect(origin: .zero, size: CGSize(width: 56, height: 56))
        ambientGlowLayer.position = center
        ambientGlowLayer.cornerRadius = 28
        ambientGlowLayer.backgroundColor = UIColor(red: 121 / 255, green: 141 / 255, blue: 108 / 255, alpha: 0.24).cgColor
        ambientGlowLayer.shadowPath = UIBezierPath(ovalIn: ambientGlowLayer.bounds).cgPath
        ambientGlowLayer.shadowColor = UIColor(red: 121 / 255, green: 141 / 255, blue: 108 / 255, alpha: 1).cgColor
        ambientGlowLayer.shadowOpacity = 0.36
        ambientGlowLayer.shadowOffset = .zero
        ambientGlowLayer.shadowRadius = 26

        for (index, spec) in glowBlobSpecs.enumerated() {
            guard glowBlobLayers.indices.contains(index) else { continue }
            let layer = glowBlobLayers[index]
            let size = CGSize(width: spec.radius * 2, height: spec.radius * 2)
            layer.bounds = CGRect(origin: .zero, size: size)
            layer.position = center
            layer.cornerRadius = spec.radius
            layer.shadowPath = UIBezierPath(ovalIn: CGRect(origin: .zero, size: size)).cgPath
            layer.backgroundColor = spec.color.withAlphaComponent(CGFloat(spec.alpha) * 0.95).cgColor
            layer.shadowColor = spec.color.cgColor
            layer.shadowOpacity = min(1, spec.alpha * 1.15)
            layer.shadowOffset = .zero
            layer.shadowRadius = spec.radius * 1.35
        }

        startGlowAnimationsIfNeeded()
    }

    func configure(imageName: String?) {
        if let imageName, let image = AssetCatalog.uiImage(named: imageName) {
            imageView.image = image
            imageView.isHidden = false
            fallbackGradient.isHidden = true
        } else {
            imageView.image = nil
            imageView.isHidden = true
            fallbackGradient.isHidden = false
        }
    }

    private func commonInit() {
        collisionMode = .circle
        centerOffset = .zero
        displayPriority = .required
        clusteringIdentifier = "gaia-observation"
        backgroundColor = .clear
        frame = CGRect(origin: .zero, size: CGSize(width: 62, height: 62))

        glowContainer.backgroundColor = .clear
        glowContainer.isUserInteractionEnabled = false
        glowContainer.layer.masksToBounds = false
        layer.masksToBounds = false
        addSubview(glowContainer)

        ambientGlowLayer.backgroundColor = UIColor.clear.cgColor
        glowContainer.layer.addSublayer(ambientGlowLayer)

        for spec in glowBlobSpecs {
            let glowLayer = CALayer()
            glowLayer.backgroundColor = spec.color.withAlphaComponent(CGFloat(spec.alpha) * 0.95).cgColor
            glowContainer.layer.addSublayer(glowLayer)
            glowBlobLayers.append(glowLayer)
        }

        materialView.clipsToBounds = true
        materialView.layer.cornerRadius = 31
        materialView.layer.cornerCurve = .continuous
        materialView.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        glowContainer.addSubview(materialView)

        ringOverlay.layer.cornerRadius = 31
        ringOverlay.layer.cornerCurve = .continuous
        ringOverlay.layer.borderWidth = 1.0
        ringOverlay.layer.borderColor = UIColor.white.withAlphaComponent(0.18).cgColor
        ringOverlay.backgroundColor = UIColor.white.withAlphaComponent(0.02)
        ringOverlay.isUserInteractionEnabled = false
        glowContainer.addSubview(ringOverlay)

        imageContainer.layer.cornerRadius = 28.6715
        imageContainer.layer.cornerCurve = .continuous
        imageContainer.layer.borderWidth = 1.506
        imageContainer.layer.borderColor = UIColor.white.withAlphaComponent(0.50).cgColor
        imageContainer.clipsToBounds = true
        imageContainer.backgroundColor = UIColor(red: 254 / 255, green: 253 / 255, blue: 249 / 255, alpha: 1)
        glowContainer.addSubview(imageContainer)

        fallbackGradient.colors = [
            UIColor(red: 149 / 255, green: 194 / 255, blue: 135 / 255, alpha: 1).cgColor,
            UIColor(red: 103 / 255, green: 118 / 255, blue: 91 / 255, alpha: 1).cgColor
        ]
        fallbackGradient.startPoint = CGPoint(x: 0.5, y: 0)
        fallbackGradient.endPoint = CGPoint(x: 0.5, y: 1)
        imageContainer.layer.addSublayer(fallbackGradient)

        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageContainer.addSubview(imageView)

        addGestureRecognizer(pressRecognizer)
    }

    @objc
    private func handlePress(_ gesture: UILongPressGestureRecognizer) {
        let location = gesture.location(in: self)
        let isInside = bounds.insetBy(dx: -8, dy: -8).contains(location)

        switch gesture.state {
        case .began:
            setPressed(true)
        case .changed:
            setPressed(isInside)
        case .ended:
            let shouldActivate = isPressing && isInside
            setPressed(false)
            if shouldActivate {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
                    self?.onActivate?()
                }
            }
        case .cancelled, .failed:
            setPressed(false)
        default:
            break
        }
    }

    private func setPressed(_ pressed: Bool) {
        guard pressed != isPressing else { return }
        isPressing = pressed

        let targetTransform = pressed ? CGAffineTransform(scaleX: 0.94, y: 0.94) : .identity
        let animator = UIViewPropertyAnimator(duration: pressed ? 0.18 : 0.22, dampingRatio: 0.84) {
            self.transform = targetTransform
        }
        animator.startAnimation()
    }

    private func startGlowAnimationsIfNeeded() {
        guard !glowAnimationsStarted, !glowContainer.bounds.isEmpty else { return }
        glowAnimationsStarted = true

        let center = CGPoint(x: glowContainer.bounds.midX, y: glowContainer.bounds.midY)

        for (index, spec) in glowBlobSpecs.enumerated() {
            guard glowBlobLayers.indices.contains(index) else { continue }
            let layer = glowBlobLayers[index]

            let xAnimation = CAKeyframeAnimation(keyPath: "position.x")
            xAnimation.values = [center.x - spec.xAmplitude, center.x + spec.xAmplitude, center.x - spec.xAmplitude]
            xAnimation.keyTimes = [0, 0.5, 1]
            xAnimation.duration = spec.duration
            xAnimation.repeatCount = .infinity
            xAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            xAnimation.autoreverses = true

            let yAnimation = CAKeyframeAnimation(keyPath: "position.y")
            yAnimation.values = [center.y - spec.yAmplitude, center.y + spec.yAmplitude, center.y - spec.yAmplitude]
            yAnimation.keyTimes = [0, 0.5, 1]
            yAnimation.duration = spec.duration * 1.12
            yAnimation.repeatCount = .infinity
            yAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            yAnimation.autoreverses = true

            let opacityAnimation = CAKeyframeAnimation(keyPath: "opacity")
            opacityAnimation.values = [spec.alpha * 0.68, spec.alpha, spec.alpha * 0.72]
            opacityAnimation.keyTimes = [0, 0.5, 1]
            opacityAnimation.duration = spec.duration * 0.9
            opacityAnimation.repeatCount = .infinity
            opacityAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            opacityAnimation.autoreverses = true

            let phaseOffset = Double(index) * 0.45
            xAnimation.beginTime = CACurrentMediaTime() + phaseOffset
            yAnimation.beginTime = CACurrentMediaTime() + phaseOffset * 0.7
            opacityAnimation.beginTime = CACurrentMediaTime() + phaseOffset * 0.5

            layer.add(xAnimation, forKey: "organicGlowX")
            layer.add(yAnimation, forKey: "organicGlowY")
            layer.add(opacityAnimation, forKey: "organicGlowOpacity")
        }
    }
}

private final class ClusterPinAnnotationView: MKAnnotationView {
    static let reuseIdentifier = "ClusterPinAnnotationView"

    private let orbView = UIView()
    private let gradientLayer = CAGradientLayer()
    private let countLabel = UILabel()
    private let glowSpecs: [(color: UIColor, offset: CGSize, radius: CGFloat)] = [
        (UIColor(red: 116 / 255, green: 161 / 255, blue: 93 / 255, alpha: 0.55), CGSize(width: 0.968, height: 1.937), 4.841),
        (UIColor(red: 116 / 255, green: 161 / 255, blue: 93 / 255, alpha: 0.48), CGSize(width: 3.873, height: 8.715), 9.683),
        (UIColor(red: 116 / 255, green: 161 / 255, blue: 93 / 255, alpha: 0.28), CGSize(width: 9.683, height: 19.366), 12.588),
        (UIColor(red: 116 / 255, green: 161 / 255, blue: 93 / 255, alpha: 0.08), CGSize(width: 16.461, height: 33.89), 15.493),
        (UIColor(red: 116 / 255, green: 161 / 255, blue: 93 / 255, alpha: 0.01), CGSize(width: 25.176, height: 53.256), 16.461)
    ]
    private var glowLayers: [CAShapeLayer] = []

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        bounds = CGRect(origin: .zero, size: CGSize(width: 62, height: 62))
        frame.size = bounds.size
        orbView.frame = bounds
        gradientLayer.frame = orbView.bounds
        countLabel.frame = orbView.bounds

        let circlePath = UIBezierPath(ovalIn: orbView.bounds).cgPath
        for (layer, spec) in zip(glowLayers, glowSpecs) {
            layer.path = circlePath
            layer.shadowPath = circlePath
            layer.fillColor = spec.color.withAlphaComponent(0.22).cgColor
            layer.shadowColor = spec.color.cgColor
            layer.shadowOpacity = 1
            layer.shadowOffset = spec.offset
            layer.shadowRadius = spec.radius
        }
    }

    func configure(count: Int) {
        countLabel.text = "\(count)"
        countLabel.font = .monospacedDigitSystemFont(ofSize: count >= 100 ? 26 : 32, weight: .regular)
    }

    private func commonInit() {
        collisionMode = .circle
        centerOffset = .zero
        displayPriority = .defaultHigh
        backgroundColor = .clear
        frame = CGRect(origin: .zero, size: CGSize(width: 62, height: 62))

        for _ in glowSpecs {
            let glowLayer = CAShapeLayer()
            glowLayer.fillColor = UIColor.clear.cgColor
            layer.addSublayer(glowLayer)
            glowLayers.append(glowLayer)
        }

        orbView.layer.cornerRadius = 31
        orbView.layer.cornerCurve = .continuous
        orbView.layer.borderWidth = 1.506
        orbView.layer.borderColor = UIColor.white.withAlphaComponent(0.50).cgColor
        orbView.clipsToBounds = true
        addSubview(orbView)

        gradientLayer.colors = [
            UIColor(red: 123 / 255, green: 179 / 255, blue: 105 / 255, alpha: 1).cgColor,
            UIColor(red: 110 / 255, green: 145 / 255, blue: 82 / 255, alpha: 1).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        orbView.layer.addSublayer(gradientLayer)

        countLabel.textAlignment = .center
        countLabel.textColor = UIColor(red: 224 / 255, green: 242 / 255, blue: 218 / 255, alpha: 1)
        countLabel.adjustsFontSizeToFitWidth = true
        countLabel.minimumScaleFactor = 0.7
        countLabel.shadowColor = UIColor(red: 128 / 255, green: 105 / 255, blue: 38 / 255, alpha: 0.09)
        countLabel.shadowOffset = CGSize(width: 0, height: 4)
        addSubview(countLabel)
    }
}
