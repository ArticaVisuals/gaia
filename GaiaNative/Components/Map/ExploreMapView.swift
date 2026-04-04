import CoreLocation
import MapKit
import SwiftUI
import UIKit

private enum GaiaPinMapConfig {
    static let clusterReuseID = "gaia.cluster"
    static let observationReuseID = "gaia.observation"
    static let clusteringIdentifier = "gaia.cluster.members"
    static let clusterBlankMaxZoom = 6.8
    static let singlePhotoMinZoom = 14.2
    static let markerVisualSize: CGFloat = 62
    static let markerTouchPadding: CGFloat = 18
    static let markerMinScale: CGFloat = 0.34
    static let markerScaleStartZoom = 3.0
    static let markerScaleEndZoom = 14.0
    static let recenterZoom = 14.4
}

struct ExploreMapView: View {
    let observations: [Observation]
    let recenterRequestID: UUID?
    var onSelectObservation: ((Observation) -> Void)? = nil
    var showsMarkers: Bool = true
    var initialZoomOverride: CGFloat? = nil

    @StateObject private var locationController = GaiaMapLocationController()

    var body: some View {
        ExploreMapRepresentable(
            observations: observations,
            showsMarkers: showsMarkers,
            initialZoomOverride: initialZoomOverride,
            onSelectObservation: onSelectObservation,
            locationController: locationController
        )
        .onChange(of: recenterRequestID) { _, newRequestID in
            guard newRequestID != nil else { return }
            locationController.requestRecenter()
        }
    }
}

private struct ExploreMapRepresentable: UIViewRepresentable {
    let observations: [Observation]
    let showsMarkers: Bool
    let initialZoomOverride: CGFloat?
    let onSelectObservation: ((Observation) -> Void)?
    @ObservedObject var locationController: GaiaMapLocationController

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        mapView.delegate = context.coordinator
        mapView.mapType = .standard
        mapView.showsCompass = false
        mapView.showsScale = false
        mapView.isRotateEnabled = false
        mapView.register(
            GaiaHostedMarkerAnnotationView.self,
            forAnnotationViewWithReuseIdentifier: GaiaPinMapConfig.observationReuseID
        )
        mapView.register(
            GaiaHostedMarkerAnnotationView.self,
            forAnnotationViewWithReuseIdentifier: GaiaPinMapConfig.clusterReuseID
        )
        mapView.showsUserLocation = locationController.isAuthorized
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        context.coordinator.parent = self
        context.coordinator.update(mapView)
    }

    final class Coordinator: NSObject, MKMapViewDelegate {
        var parent: ExploreMapRepresentable

        private var hasAppliedInitialRegion = false
        private var lastObservationSignature: Int?
        private var lastFollowViewportRequestID: UUID?
        private var observationAnnotationsByID: [String: GaiaObservationAnnotation] = [:]

        init(parent: ExploreMapRepresentable) {
            self.parent = parent
        }

        func update(_ mapView: MKMapView) {
            mapView.showsUserLocation = parent.locationController.isAuthorized
            syncObservationAnnotations(in: mapView)

            let signature = Self.observationsSignature(parent.observations)
            if !hasAppliedInitialRegion {
                let initialRegion = ExploreMapView.initialRegion(
                    for: parent.observations,
                    zoomOverride: parent.initialZoomOverride
                )
                mapView.setRegion(initialRegion, animated: false)
                hasAppliedInitialRegion = true
            } else if signature != lastObservationSignature, !parent.locationController.isFollowingUser {
                let updatedRegion = ExploreMapView.initialRegion(
                    for: parent.observations,
                    zoomOverride: parent.initialZoomOverride
                )
                mapView.setRegion(updatedRegion, animated: true)
            }
            lastObservationSignature = signature

            if let requestID = parent.locationController.followViewportRequestID,
               requestID != lastFollowViewportRequestID,
               let centerCoordinate = parent.locationController.centerCoordinate {
                lastFollowViewportRequestID = requestID
                let region = MKCoordinateRegion(
                    center: centerCoordinate,
                    span: ExploreMapView.span(for: GaiaPinMapConfig.recenterZoom)
                )
                mapView.setRegion(region, animated: true)
            }

            refreshVisibleAnnotationViews(in: mapView)
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation {
                return nil
            }

            if annotation is MKClusterAnnotation {
                let view = mapView.dequeueReusableAnnotationView(
                    withIdentifier: GaiaPinMapConfig.clusterReuseID,
                    for: annotation
                ) as! GaiaHostedMarkerAnnotationView
                view.annotation = annotation
                view.clusteringIdentifier = nil
                view.displayPriority = .required
                view.collisionMode = .circle
                configure(view, for: annotation, zoom: ExploreMapView.zoomLevel(for: mapView.region))
                return view
            }

            if annotation is GaiaObservationAnnotation {
                let view = mapView.dequeueReusableAnnotationView(
                    withIdentifier: GaiaPinMapConfig.observationReuseID,
                    for: annotation
                ) as! GaiaHostedMarkerAnnotationView
                view.annotation = annotation
                view.clusteringIdentifier = GaiaPinMapConfig.clusteringIdentifier
                view.displayPriority = .required
                view.collisionMode = .circle
                configure(view, for: annotation, zoom: ExploreMapView.zoomLevel(for: mapView.region))
                return view
            }

            return nil
        }

        func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
            refreshVisibleAnnotationViews(in: mapView)
        }

        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            if let cluster = view.annotation as? MKClusterAnnotation {
                mapView.deselectAnnotation(cluster, animated: false)
                mapView.showAnnotations(cluster.memberAnnotations, animated: true)
                return
            }

            if let observationAnnotation = view.annotation as? GaiaObservationAnnotation {
                mapView.deselectAnnotation(observationAnnotation, animated: false)
                parent.onSelectObservation?(observationAnnotation.observation)
            }
        }

        private func syncObservationAnnotations(in mapView: MKMapView) {
            guard parent.showsMarkers else {
                if !observationAnnotationsByID.isEmpty {
                    mapView.removeAnnotations(Array(observationAnnotationsByID.values))
                    observationAnnotationsByID.removeAll()
                }
                return
            }

            let desiredObservations = Dictionary(uniqueKeysWithValues: parent.observations.map { ($0.id, $0) })
            let staleIDs = Set(observationAnnotationsByID.keys).subtracting(desiredObservations.keys)
            if !staleIDs.isEmpty {
                let staleAnnotations = staleIDs.compactMap { observationAnnotationsByID.removeValue(forKey: $0) }
                mapView.removeAnnotations(staleAnnotations)
            }

            var newAnnotations: [GaiaObservationAnnotation] = []
            for observation in parent.observations {
                if let existing = observationAnnotationsByID[observation.id] {
                    existing.update(with: observation)
                } else {
                    let annotation = GaiaObservationAnnotation(observation: observation)
                    observationAnnotationsByID[observation.id] = annotation
                    newAnnotations.append(annotation)
                }
            }

            if !newAnnotations.isEmpty {
                mapView.addAnnotations(newAnnotations)
            }
        }

        private func refreshVisibleAnnotationViews(in mapView: MKMapView) {
            let zoom = ExploreMapView.zoomLevel(for: mapView.region)
            for annotation in mapView.annotations {
                guard let view = mapView.view(for: annotation) as? GaiaHostedMarkerAnnotationView else { continue }
                configure(view, for: annotation, zoom: zoom)
            }
        }

        private func configure(_ view: GaiaHostedMarkerAnnotationView, for annotation: MKAnnotation, zoom: Double) {
            let farOutCluster = zoom <= GaiaPinMapConfig.clusterBlankMaxZoom
            let showsSinglePhoto = zoom >= GaiaPinMapConfig.singlePhotoMinZoom
            let markerScale = ExploreMapView.markerScale(for: zoom)

            if let observationAnnotation = annotation as? GaiaObservationAnnotation {
                if showsSinglePhoto {
                    let imageName = observationAnnotation.observation.thumbnailAssetName ?? "none"
                    view.apply(
                        content: AnyView(
                            MarkerRenderContainer {
                                MapAnnotationPhotoPin(imageName: observationAnnotation.observation.thumbnailAssetName)
                            }
                        ),
                        renderKey: "single.photo.\(imageName)"
                    )
                } else {
                    view.apply(
                        content: AnyView(MarkerRenderContainer { MapAnnotationBlankPin() }),
                        renderKey: "single.blank"
                    )
                }
            } else if let clusterAnnotation = annotation as? MKClusterAnnotation {
                if farOutCluster {
                    view.apply(
                        content: AnyView(MarkerRenderContainer { MapAnnotationBlankPin() }),
                        renderKey: "cluster.blank"
                    )
                } else {
                    let count = observationCount(in: clusterAnnotation)
                    view.apply(
                        content: AnyView(MarkerRenderContainer { MapAnnotationClusterPin(count: count) }),
                        renderKey: "cluster.count.\(count)"
                    )
                }
            }

            view.setScale(markerScale)
        }

        private func observationCount(in cluster: MKClusterAnnotation) -> Int {
            cluster.memberAnnotations.reduce(0) { total, member in
                total + observationCount(for: member)
            }
        }

        private func observationCount(for annotation: MKAnnotation) -> Int {
            if annotation is GaiaObservationAnnotation {
                return 1
            }

            if let nestedCluster = annotation as? MKClusterAnnotation {
                return observationCount(in: nestedCluster)
            }

            return 0
        }

        private static func observationsSignature(_ observations: [Observation]) -> Int {
            var hasher = Hasher()
            hasher.combine(observations.count)
            for observation in observations {
                hasher.combine(observation.id)
                hasher.combine(observation.latitude.bitPattern)
                hasher.combine(observation.longitude.bitPattern)
                hasher.combine(observation.thumbnailAssetName)
            }
            return hasher.finalize()
        }
    }
}

private struct MarkerRenderContainer<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .frame(width: GaiaPinMapConfig.markerVisualSize, height: GaiaPinMapConfig.markerVisualSize)
            .padding(GaiaPinMapConfig.markerTouchPadding)
            .contentShape(Circle())
    }
}

private final class GaiaHostedMarkerAnnotationView: MKAnnotationView {
    private var hostingController: UIHostingController<AnyView>?
    private var currentRenderKey: String?

    private var contentSize: CGSize {
        let width = GaiaPinMapConfig.markerVisualSize + (GaiaPinMapConfig.markerTouchPadding * 2)
        let height = GaiaPinMapConfig.markerVisualSize + (GaiaPinMapConfig.markerTouchPadding * 2)
        return CGSize(width: width, height: height)
    }

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        isOpaque = false
        canShowCallout = false
        frame = CGRect(origin: .zero, size: contentSize)
        bounds = CGRect(origin: .zero, size: contentSize)
        centerOffset = .zero
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        currentRenderKey = nil
        transform = .identity
    }

    func apply(content: AnyView, renderKey: String) {
        let size = contentSize
        if bounds.size != size {
            bounds = CGRect(origin: .zero, size: size)
        }

        if let hostingController {
            guard currentRenderKey != renderKey else { return }
            currentRenderKey = renderKey
            hostingController.rootView = content
            return
        }

        let hostingController = UIHostingController(rootView: content)
        hostingController.view.backgroundColor = .clear
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(hostingController.view)
        NSLayoutConstraint.activate([
            hostingController.view.leadingAnchor.constraint(equalTo: leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: trailingAnchor),
            hostingController.view.topAnchor.constraint(equalTo: topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        self.hostingController = hostingController
        currentRenderKey = renderKey
    }

    func setScale(_ scale: CGFloat) {
        let currentScaleX = transform.a
        let currentScaleY = transform.d
        guard abs(currentScaleX - scale) > 0.0001 || abs(currentScaleY - scale) > 0.0001 else { return }
        transform = CGAffineTransform(scaleX: scale, y: scale)
    }
}

private final class GaiaObservationAnnotation: NSObject, MKAnnotation {
    var observation: Observation
    @objc dynamic var coordinate: CLLocationCoordinate2D

    init(observation: Observation) {
        self.observation = observation
        self.coordinate = CLLocationCoordinate2D(latitude: observation.latitude, longitude: observation.longitude)
    }

    func update(with observation: Observation) {
        self.observation = observation
        let nextCoordinate = CLLocationCoordinate2D(latitude: observation.latitude, longitude: observation.longitude)
        if abs(nextCoordinate.latitude - coordinate.latitude) > 0.000_000_1 ||
            abs(nextCoordinate.longitude - coordinate.longitude) > 0.000_000_1 {
            coordinate = nextCoordinate
        }
    }
}

private extension ExploreMapView {
    static func initialRegion(for observations: [Observation], zoomOverride: CGFloat? = nil) -> MKCoordinateRegion {
        guard let first = observations.first else {
            return MKCoordinateRegion(
                center: GaiaMapbox.fallbackCenter,
                span: span(for: Double(zoomOverride ?? 11.8))
            )
        }

        let latitudes = observations.map(\.latitude)
        let longitudes = observations.map(\.longitude)
        let minLatitude = latitudes.min() ?? first.latitude
        let maxLatitude = latitudes.max() ?? first.latitude
        let minLongitude = longitudes.min() ?? first.longitude
        let maxLongitude = longitudes.max() ?? first.longitude

        let center = CLLocationCoordinate2D(
            latitude: (minLatitude + maxLatitude) / 2,
            longitude: (minLongitude + maxLongitude) / 2
        )

        let zoom = Double(zoomOverride ?? initialViewportZoom(for: observations))
        return MKCoordinateRegion(center: center, span: span(for: zoom))
    }

    static func span(for zoom: Double) -> MKCoordinateSpan {
        let clampedZoom = max(2, min(18, zoom))
        let delta = max(0.0012, 360 / pow(2, clampedZoom))
        return MKCoordinateSpan(latitudeDelta: delta, longitudeDelta: delta)
    }

    static func zoomLevel(for region: MKCoordinateRegion) -> Double {
        let maxDelta = max(region.span.latitudeDelta, region.span.longitudeDelta)
        let safeDelta = max(maxDelta, 0.000_001)
        return log2(360 / safeDelta)
    }

    static func markerScale(for zoom: Double) -> CGFloat {
        let minZoom = GaiaPinMapConfig.markerScaleStartZoom
        let maxZoom = GaiaPinMapConfig.markerScaleEndZoom
        let clamped = min(max(zoom, minZoom), maxZoom)
        let progress = (clamped - minZoom) / max(0.0001, maxZoom - minZoom)
        let range = 1.0 - GaiaPinMapConfig.markerMinScale
        return GaiaPinMapConfig.markerMinScale + (CGFloat(progress) * range)
    }

    static func initialViewportZoom(for observations: [Observation]) -> CGFloat {
        guard let first = observations.first else { return 11.8 }

        let latitudes = observations.map(\.latitude)
        let longitudes = observations.map(\.longitude)
        let minLatitude = latitudes.min() ?? first.latitude
        let maxLatitude = latitudes.max() ?? first.latitude
        let minLongitude = longitudes.min() ?? first.longitude
        let maxLongitude = longitudes.max() ?? first.longitude
        let maxDelta = max(maxLatitude - minLatitude, maxLongitude - minLongitude)

        switch maxDelta {
        case ..<0.008:
            return 12.8
        case ..<0.015:
            return 12.2
        case ..<0.03:
            return 11.6
        case ..<0.06:
            return 10.8
        default:
            return 10.0
        }
    }
}

private final class GaiaMapLocationController: NSObject, ObservableObject {
    @Published var centerCoordinate: CLLocationCoordinate2D?
    @Published var followViewportRequestID: UUID?

    private let locationManager = CLLocationManager()
    private(set) var isFollowingUser = false

    var isAuthorized: Bool {
        switch locationManager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            return true
        default:
            return false
        }
    }

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func requestRecenter() {
        isFollowingUser = true

        switch locationManager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            if let coordinate = locationManager.location?.coordinate {
                centerCoordinate = coordinate
                followViewportRequestID = UUID()
            } else {
                locationManager.requestLocation()
            }
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            isFollowingUser = false
        @unknown default:
            isFollowingUser = false
        }
    }
}

extension GaiaMapLocationController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            guard isFollowingUser else { return }

            switch manager.authorizationStatus {
            case .authorizedAlways, .authorizedWhenInUse:
                if let coordinate = manager.location?.coordinate {
                    centerCoordinate = coordinate
                    followViewportRequestID = UUID()
                } else {
                    manager.requestLocation()
                }
            case .denied, .restricted:
                isFollowingUser = false
            case .notDetermined:
                break
            @unknown default:
                isFollowingUser = false
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let coordinate = locations.last?.coordinate else { return }
        Task { @MainActor in
            centerCoordinate = coordinate
            followViewportRequestID = UUID()
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            isFollowingUser = false
        }
    }
}
