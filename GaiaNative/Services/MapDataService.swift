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
