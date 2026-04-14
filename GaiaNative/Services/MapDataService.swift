import Foundation

struct MapDataService {
    func expandedObservations(
        from observations: [Observation],
        targetCount: Int,
        seed: String
    ) -> [Observation] {
        guard !observations.isEmpty, observations.count < targetCount else {
            return observations
        }

        let bounds = CoordinateBounds(observations: observations)
        let latitudeJitter = max(bounds.latitudeSpan * 0.045, 0.0022)
        let longitudeJitter = max(bounds.longitudeSpan * 0.045, 0.0022)
        let minimumSpacing = max(min(bounds.latitudeSpan, bounds.longitudeSpan) * 0.014, 0.00055)
        let thumbnailAssetNames = observations.compactMap(\.thumbnailAssetName)
        var generator = SeededGenerator(seed: stableSeed(for: seed, observations: observations))
        var expanded = observations

        while expanded.count < targetCount {
            let anchorIndex = Int(generator.nextUnitInterval() * Double(observations.count))
            let anchor = observations[min(anchorIndex, observations.count - 1)]
            let coordinate = nextCoordinate(
                near: anchor,
                bounds: bounds,
                latitudeJitter: latitudeJitter,
                longitudeJitter: longitudeJitter,
                minimumSpacing: minimumSpacing,
                existingObservations: expanded,
                generator: &generator
            )
            let generatedIndex = expanded.count + 1
            let thumbnailAssetName = thumbnailAssetNames.isEmpty
                ? anchor.thumbnailAssetName
                : thumbnailAssetNames[generatedIndex % thumbnailAssetNames.count]

            expanded.append(
                Observation(
                    id: "\(anchor.speciesID)-find-\(generatedIndex)",
                    speciesID: anchor.speciesID,
                    latitude: coordinate.latitude,
                    longitude: coordinate.longitude,
                    thumbnailAssetName: thumbnailAssetName
                )
            )
        }

        return expanded
    }

    func prototypeObservations(from baseObservations: [Observation]) -> [Observation] {
        let existingIDs = Set(baseObservations.map(\.id))
        let generatedObservations = Self.prototypeSeeds
            .flatMap(makeObservations(for:))
            .filter { !existingIDs.contains($0.id) }

        return baseObservations + generatedObservations
    }

    private func nextCoordinate(
        near anchor: Observation,
        bounds: CoordinateBounds,
        latitudeJitter: Double,
        longitudeJitter: Double,
        minimumSpacing: Double,
        existingObservations: [Observation],
        generator: inout SeededGenerator
    ) -> (latitude: Double, longitude: Double) {
        for _ in 0..<24 {
            let candidateLatitude = clamp(
                anchor.latitude + (generator.nextCenteredUnitInterval() * latitudeJitter),
                minimum: bounds.minLatitude,
                maximum: bounds.maxLatitude
            )
            let candidateLongitude = clamp(
                anchor.longitude + (generator.nextCenteredUnitInterval() * longitudeJitter),
                minimum: bounds.minLongitude,
                maximum: bounds.maxLongitude
            )

            let isSeparatedFromNeighbors = existingObservations.allSatisfy { observation in
                let latitudeDelta = candidateLatitude - observation.latitude
                let longitudeDelta = candidateLongitude - observation.longitude
                let distanceSquared = (latitudeDelta * latitudeDelta) + (longitudeDelta * longitudeDelta)
                return distanceSquared >= (minimumSpacing * minimumSpacing)
            }

            if isSeparatedFromNeighbors {
                return (candidateLatitude, candidateLongitude)
            }
        }

        return (
            clamp(anchor.latitude + (generator.nextCenteredUnitInterval() * latitudeJitter), minimum: bounds.minLatitude, maximum: bounds.maxLatitude),
            clamp(anchor.longitude + (generator.nextCenteredUnitInterval() * longitudeJitter), minimum: bounds.minLongitude, maximum: bounds.maxLongitude)
        )
    }

    private func stableSeed(for seed: String, observations: [Observation]) -> UInt64 {
        var hash: UInt64 = 1_469_598_103_934_665_603

        for byte in seed.utf8 {
            hash ^= UInt64(byte)
            hash &*= 1_099_511_628_211
        }

        for observation in observations {
            for byte in observation.id.utf8 {
                hash ^= UInt64(byte)
                hash &*= 1_099_511_628_211
            }
        }

        return hash
    }

    private func clamp(_ value: Double, minimum: Double, maximum: Double) -> Double {
        min(max(value, minimum), maximum)
    }
}

private struct CoordinateBounds {
    let minLatitude: Double
    let maxLatitude: Double
    let minLongitude: Double
    let maxLongitude: Double

    init(observations: [Observation]) {
        let latitudes = observations.map(\.latitude)
        let longitudes = observations.map(\.longitude)
        minLatitude = latitudes.min() ?? 0
        maxLatitude = latitudes.max() ?? 0
        minLongitude = longitudes.min() ?? 0
        maxLongitude = longitudes.max() ?? 0
    }

    var latitudeSpan: Double {
        max(maxLatitude - minLatitude, 0.001)
    }

    var longitudeSpan: Double {
        max(maxLongitude - minLongitude, 0.001)
    }
}

private struct SeededGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed == 0 ? 0x9E37_79B9_7F4A_7C15 : seed
    }

    mutating func nextUnitInterval() -> Double {
        let nextValue = nextUInt64() >> 11
        return Double(nextValue) / Double(1 << 53)
    }

    mutating func nextCenteredUnitInterval() -> Double {
        nextUnitInterval() - nextUnitInterval()
    }

    private mutating func nextUInt64() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var result = state
        result = (result ^ (result >> 30)) &* 0xBF58_476D_1CE4_E5B9
        result = (result ^ (result >> 27)) &* 0x94D0_49BB_1331_11EB
        return result ^ (result >> 31)
    }
}

private extension MapDataService {
    struct PrototypeClusterSeed {
        let id: String
        let latitude: Double
        let longitude: Double
        let count: Int
        let scale: Double
    }

    static let thumbnailCycle = [
        "coast-live-oak-hero",
        "coast-live-oak-gallery-1",
        "coast-live-oak-gallery-2",
        "coast-live-oak-gallery-3",
        "coast-live-oak-gallery-4"
    ]

    static let offsetTemplate: [(latitude: Double, longitude: Double)] = [
        (0.0000, 0.0000),
        (0.0032, 0.0046),
        (-0.0028, 0.0055),
        (0.0046, -0.0037),
        (-0.0048, -0.0024),
        (0.0060, 0.0014),
        (-0.0061, 0.0010),
        (0.0018, -0.0062),
        (-0.0019, -0.0067),
        (0.0053, 0.0060)
    ]

    // The added prototype pins stay mostly U.S.-centric, with a smaller set of
    // international clusters near recognizable park and trail regions.
    static let prototypeSeeds: [PrototypeClusterSeed] = [
        .init(id: "sf-golden-gate", latitude: 37.7694, longitude: -122.4862, count: 8, scale: 1.0),
        .init(id: "portland-forest-park", latitude: 45.5379, longitude: -122.7287, count: 8, scale: 0.94),
        .init(id: "seattle-discovery", latitude: 47.6588, longitude: -122.4051, count: 8, scale: 0.96),
        .init(id: "boulder-flatirons", latitude: 39.9994, longitude: -105.2817, count: 8, scale: 0.98),
        .init(id: "austin-barton-creek", latitude: 30.2641, longitude: -97.7930, count: 8, scale: 0.92),
        .init(id: "nyc-central-park", latitude: 40.7812, longitude: -73.9665, count: 8, scale: 0.9),
        .init(id: "smokies-trails", latitude: 35.6118, longitude: -83.4895, count: 8, scale: 1.02),
        .init(id: "acadia-loop", latitude: 44.3386, longitude: -68.2733, count: 8, scale: 0.95),
        .init(id: "vancouver-stanley", latitude: 49.3043, longitude: -123.1443, count: 8, scale: 0.88),
        .init(id: "banff-tunnel", latitude: 51.1784, longitude: -115.5708, count: 6, scale: 0.9),
        .init(id: "wicklow-glendalough", latitude: 53.0100, longitude: -6.3270, count: 6, scale: 0.94),
        .init(id: "torres-del-paine", latitude: -50.9423, longitude: -72.9653, count: 6, scale: 1.12),
        .init(id: "table-mountain", latitude: -33.9628, longitude: 18.4098, count: 6, scale: 0.98)
    ]

    func makeObservations(for seed: PrototypeClusterSeed) -> [Observation] {
        let longitudeCompensation = max(0.42, cos(seed.latitude * .pi / 180))

        return Self.offsetTemplate
            .prefix(seed.count)
            .enumerated()
            .map { index, offset in
                Observation(
                    id: "prototype-\(seed.id)-\(index + 1)",
                    speciesID: "coast-live-oak",
                    latitude: seed.latitude + (offset.latitude * seed.scale),
                    longitude: seed.longitude + ((offset.longitude * seed.scale) / longitudeCompensation),
                    thumbnailAssetName: Self.thumbnailCycle[index % Self.thumbnailCycle.count]
                )
            }
    }
}
