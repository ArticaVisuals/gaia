import CoreLocation
import MapboxMaps
import SwiftUI

struct ExploreMapView: View {
    let observations: [Observation]
    let recenterRequestID: UUID?
    var onSelectObservation: ((Observation) -> Void)? = nil

    @StateObject private var locationController = GaiaMapLocationController()
    @State private var viewport: Viewport
    @State private var hasAppliedInitialViewport = false

    init(
        observations: [Observation],
        recenterRequestID: UUID?,
        onSelectObservation: ((Observation) -> Void)? = nil
    ) {
        self.observations = observations
        self.recenterRequestID = recenterRequestID
        self.onSelectObservation = onSelectObservation
        _viewport = State(initialValue: Self.initialViewport(for: observations))
    }

    var body: some View {
        MapReader { _ in
            Map(viewport: $viewport) {
                if locationController.isAuthorized {
                    Puck2D()
                }

                ForEvery(observations) { observation in
                    MapViewAnnotation(
                        coordinate: CLLocationCoordinate2D(
                            latitude: observation.latitude,
                            longitude: observation.longitude
                        )
                    ) {
                        MapAnnotationPhotoPin(imageName: observation.thumbnailAssetName)
                            .contentShape(Circle())
                            .onTapGesture {
                                onSelectObservation?(observation)
                            }
                    }
                    .allowOverlap(true)
                }
            }
            .mapStyle(MapStyle(uri: GaiaMapbox.styleURI))
            .onAppear {
                guard !hasAppliedInitialViewport else { return }
                hasAppliedInitialViewport = true
                viewport = Self.initialViewport(for: observations)
            }
            .onChange(of: observations) { _, newObservations in
                guard !locationController.isFollowingUser else { return }
                viewport = Self.initialViewport(for: newObservations)
            }
            .onChange(of: recenterRequestID) { _, newRequestID in
                guard newRequestID != nil else { return }
                locationController.requestRecenter()
            }
            .onChange(of: locationController.centerCoordinate) { _, coordinate in
                guard let coordinate else { return }
                withViewportAnimation(.default(maxDuration: 1.0)) {
                    viewport = .camera(center: coordinate, zoom: 14.4, bearing: 0, pitch: 0)
                }
            }
            .onChange(of: locationController.followViewportRequestID) { _, requestID in
                guard requestID != nil else { return }
                withViewportAnimation(.default(maxDuration: 1.0)) {
                    viewport = .followPuck(zoom: 14.4, pitch: 0)
                }
            }
        }
    }

    private static func initialViewport(for observations: [Observation]) -> Viewport {
        guard let first = observations.first else {
            return .camera(center: GaiaMapbox.fallbackCenter, zoom: 11.8, bearing: 0, pitch: 0)
        }

        let latitudes = observations.map(\.latitude)
        let longitudes = observations.map(\.longitude)
        let minLatitude = latitudes.min() ?? first.latitude
        let maxLatitude = latitudes.max() ?? first.latitude
        let minLongitude = longitudes.min() ?? first.longitude
        let maxLongitude = longitudes.max() ?? first.longitude

        let latitudeDelta = maxLatitude - minLatitude
        let longitudeDelta = maxLongitude - minLongitude
        let maxDelta = max(latitudeDelta, longitudeDelta)

        let center = CLLocationCoordinate2D(
            latitude: (minLatitude + maxLatitude) / 2,
            longitude: (minLongitude + maxLongitude) / 2
        )

        let zoom: CGFloat
        switch maxDelta {
        case ..<0.008:
            zoom = 12.8
        case ..<0.015:
            zoom = 12.2
        case ..<0.03:
            zoom = 11.6
        case ..<0.06:
            zoom = 10.8
        default:
            zoom = 10.0
        }

        return .camera(center: center, zoom: zoom, bearing: 0, pitch: 0)
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
