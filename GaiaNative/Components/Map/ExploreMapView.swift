import CoreLocation
@_spi(Restricted) import MapboxMaps
import SwiftUI

private enum GaiaPinMapConfig {
    static let sourceID = "gaia-observation-source"
    static let queryLayerID = "gaia-observation-query-layer"
    static let clusterMaxZoom = 14.0
    static let clusterRadius = 50.0
    static let photoZoom = 14.2
    static let zoomHysteresis = 0.35
}

private struct ClusterMarkerState: Identifiable {
    let id: String
    let coordinate: CLLocationCoordinate2D
    let count: Int
    let clusterID: Int64?
}

struct ExploreMapView: View {
    let observations: [Observation]
    let recenterRequestID: UUID?
    var onSelectObservation: ((Observation) -> Void)? = nil
    var showsMarkers: Bool = true
    var initialZoomOverride: CGFloat? = nil

    @StateObject private var locationController = GaiaMapLocationController()
    @State private var viewport: Viewport
    @State private var hasAppliedInitialViewport = false
    @State private var isPhotoMode = false
    @State private var clusterMarkers: [ClusterMarkerState] = []

    init(
        observations: [Observation],
        recenterRequestID: UUID?,
        onSelectObservation: ((Observation) -> Void)? = nil,
        showsMarkers: Bool = true,
        initialZoomOverride: CGFloat? = nil
    ) {
        self.observations = observations
        self.recenterRequestID = recenterRequestID
        self.onSelectObservation = onSelectObservation
        self.showsMarkers = showsMarkers
        self.initialZoomOverride = initialZoomOverride
        _viewport = State(initialValue: Self.initialViewport(for: observations, zoomOverride: initialZoomOverride))
    }

    var body: some View {
        MapReader { proxy in
            Map(viewport: $viewport) {
                if locationController.isAuthorized {
                    Puck2D()
                }

                clusteredObservationSource

                if showsMarkers {
                    if isPhotoMode {
                        ForEvery(observations) { observation in
                            MapViewAnnotation(
                                coordinate: CLLocationCoordinate2D(
                                    latitude: observation.latitude,
                                    longitude: observation.longitude
                                )
                            ) {
                                pinContainer {
                                    MapAnnotationPhotoPin(imageName: observation.thumbnailAssetName)
                                        .contentShape(Circle())
                                        .onTapGesture {
                                            onSelectObservation?(observation)
                                        }
                                }
                            }
                            .allowOverlap(true)
                        }
                    } else {
                        ForEvery(clusterMarkers) { marker in
                            MapViewAnnotation(coordinate: marker.coordinate) {
                                pinContainer {
                                    MapAnnotationClusterPin(count: marker.count)
                                        .contentShape(Circle())
                                        .onTapGesture {
                                            handleClusterTap(marker, proxy: proxy)
                                        }
                                }
                            }
                            .allowOverlap(true)
                        }
                    }
                }
            }
            .mapStyle(MapStyle(uri: GaiaMapbox.styleURI))
            .ornamentOptions(mapOrnamentOptions)
            .onStyleLoaded { _ in
                guard showsMarkers else { return }
                syncPhotoMode(for: currentZoom(in: proxy), proxy: proxy, forceClusterSync: true)
            }
            .onMapIdle { _ in
                guard showsMarkers else { return }
                syncClusterMarkers(using: proxy)
            }
            .onCameraChanged { event in
                guard showsMarkers else { return }
                syncPhotoMode(for: event.cameraState.zoom, proxy: proxy, forceClusterSync: false)
            }
            .onAppear {
                guard !hasAppliedInitialViewport else { return }
                hasAppliedInitialViewport = true
                viewport = Self.initialViewport(for: observations, zoomOverride: initialZoomOverride)
            }
            .onChange(of: observations) { _, newObservations in
                guard !locationController.isFollowingUser else { return }
                viewport = Self.initialViewport(for: newObservations, zoomOverride: initialZoomOverride)
                guard showsMarkers else { return }
                syncClusterMarkers(using: proxy)
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

    private var mapOrnamentOptions: OrnamentOptions {
        var options = OrnamentOptions(
            scaleBar: .init(visibility: .hidden),
            compass: .init(visibility: .hidden)
        )
        options.logo.visibility = .hidden
        options.attributionButton.visibility = .hidden
        return options
    }

    @MapContentBuilder
    private var clusteredObservationSource: some MapContent {
        sourceContent
        queryLayerContent
    }

    private var sourceContent: GeoJSONSource {
        var source = GeoJSONSource(id: GaiaPinMapConfig.sourceID)
        source.data = .featureCollection(featureCollection)
        source.cluster = true
        source.clusterMaxZoom = GaiaPinMapConfig.clusterMaxZoom
        source.clusterRadius = GaiaPinMapConfig.clusterRadius
        return source
    }

    private var queryLayerContent: CircleLayer {
        var layer = CircleLayer(id: GaiaPinMapConfig.queryLayerID, source: GaiaPinMapConfig.sourceID)
        layer.circleRadius = .constant(1)
        layer.circleOpacity = .constant(0)
        layer.circleStrokeOpacity = .constant(0)
        return layer
    }

    private var featureCollection: FeatureCollection {
        FeatureCollection(features: observations.map(Self.feature(for:)))
    }

    private func syncPhotoMode(for zoom: Double, proxy: MapProxy, forceClusterSync: Bool) {
        let threshold = isPhotoMode
            ? GaiaPinMapConfig.photoZoom - GaiaPinMapConfig.zoomHysteresis
            : GaiaPinMapConfig.photoZoom
        let shouldBePhotoMode = zoom >= threshold

        guard shouldBePhotoMode != isPhotoMode || forceClusterSync else { return }

        isPhotoMode = shouldBePhotoMode
        if shouldBePhotoMode {
            clusterMarkers = []
        } else {
            syncClusterMarkers(using: proxy)
        }
    }

    private func syncClusterMarkers(using proxy: MapProxy) {
        guard !isPhotoMode, let mapboxMap = proxy.map else { return }

        let options = SourceQueryOptions(
            sourceLayerIds: nil,
            filter: ["literal", true]
        )
        mapboxMap.querySourceFeatures(for: GaiaPinMapConfig.sourceID, options: options) { result in
            guard case let .success(features) = result else { return }
            let markers = Self.makeClusterMarkers(from: features)
            DispatchQueue.main.async {
                if !self.isPhotoMode {
                    self.clusterMarkers = markers
                }
            }
        }
    }

    private func handleClusterTap(_ marker: ClusterMarkerState, proxy: MapProxy) {
        guard let mapboxMap = proxy.map else { return }

        if marker.clusterID != nil {
            guard let feature = clusterFeature(for: marker) else { return }
            mapboxMap.getGeoJsonClusterExpansionZoom(
                forSourceId: GaiaPinMapConfig.sourceID,
                feature: feature
            ) { result in
                let zoom: CGFloat
                switch result {
                case let .success(value):
                    zoom = CGFloat((value.value as? NSNumber)?.doubleValue ?? GaiaPinMapConfig.photoZoom) + 0.5
                case .failure:
                    zoom = max(CGFloat(self.currentZoom(in: proxy) + 1.2), CGFloat(GaiaPinMapConfig.photoZoom + 0.1))
                }

                DispatchQueue.main.async {
                    withViewportAnimation(.default(maxDuration: 0.8)) {
                        viewport = .camera(center: marker.coordinate, zoom: zoom, bearing: 0, pitch: 0)
                    }
                }
            }
            return
        }

        let nextZoom = max(
            CGFloat(currentZoom(in: proxy) + 1.2),
            CGFloat(GaiaPinMapConfig.photoZoom + 0.1)
        )

        withViewportAnimation(.default(maxDuration: 0.8)) {
            viewport = .camera(center: marker.coordinate, zoom: nextZoom, bearing: 0, pitch: 0)
        }
    }

    private func clusterFeature(for marker: ClusterMarkerState) -> Feature? {
        guard let clusterID = marker.clusterID else {
            return nil
        }

        var feature = Feature(geometry: .point(Point(marker.coordinate)))
        feature.properties = [
            "cluster_id": .number(Double(clusterID)),
            "point_count": .number(Double(marker.count)),
            "cluster": .boolean(true)
        ]
        return feature
    }

    private func currentZoom(in proxy: MapProxy) -> Double {
        Double(proxy.map?.cameraState.zoom ?? Self.initialViewportZoom(for: observations))
    }

    private func pinContainer<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(18)
    }

    private static func makeClusterMarkers(from queriedFeatures: [QueriedSourceFeature]) -> [ClusterMarkerState] {
        var buckets: [String: ClusterMarkerState] = [:]

        for queried in queriedFeatures {
            let feature = queried.queriedFeature.feature
            guard let coordinate = feature.coordinate else { continue }
            let properties = feature.properties ?? [:]
            let clusterValue = properties["cluster"] ?? nil
            let pointCountValue = properties["point_count"] ?? nil
            let clusterIDValue = properties["cluster_id"] ?? nil

            let isCluster = clusterValue?.boolValue == true
            let count = max(1, Int(pointCountValue?.doubleValue ?? 1))
            let key: String
            let clusterID: Int64?

            if isCluster {
                clusterID = Int64(clusterIDValue?.doubleValue ?? 0)
                key = "cluster-\(clusterID ?? 0)"
            } else if let featureID = feature.identifier?.string {
                clusterID = nil
                key = "single-\(featureID)"
            } else {
                clusterID = nil
                key = "single-\(coordinate.latitude)-\(coordinate.longitude)"
            }

            guard buckets[key] == nil else { continue }

            buckets[key] = ClusterMarkerState(
                id: key,
                coordinate: coordinate,
                count: isCluster ? count : 1,
                clusterID: clusterID
            )
        }

        return buckets.values.sorted { lhs, rhs in
            if lhs.count == rhs.count {
                return lhs.id < rhs.id
            }
            return lhs.count > rhs.count
        }
    }

    private static func feature(for observation: Observation) -> Feature {
        var feature = Feature(
            geometry: .point(
                Point(
                    CLLocationCoordinate2D(
                        latitude: observation.latitude,
                        longitude: observation.longitude
                    )
                )
            )
        )
        feature.identifier = .string(observation.id)
        feature.properties = [
            "id": .string(observation.id),
            "species_id": .string(observation.speciesID)
        ]
        return feature
    }

    private static func initialViewport(for observations: [Observation], zoomOverride: CGFloat? = nil) -> Viewport {
        guard let first = observations.first else {
            return .camera(center: GaiaMapbox.fallbackCenter, zoom: zoomOverride ?? 11.8, bearing: 0, pitch: 0)
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

        return .camera(center: center, zoom: zoomOverride ?? initialViewportZoom(for: observations), bearing: 0, pitch: 0)
    }

    private static func initialViewportZoom(for observations: [Observation]) -> CGFloat {
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

private extension Feature {
    var coordinate: CLLocationCoordinate2D? {
        guard case let .point(point)? = geometry else { return nil }
        return point.coordinates
    }
}

private extension JSONValue {
    var boolValue: Bool? {
        if case let .boolean(value) = self { return value }
        return nil
    }

    var doubleValue: Double? {
        if case let .number(value) = self { return value }
        return nil
    }

    var stringValue: String? {
        if case let .string(value) = self { return value }
        return nil
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
