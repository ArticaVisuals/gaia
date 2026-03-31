import CoreLocation
import Foundation
import MapboxMaps

enum GaiaMapbox {
    static let accessToken = "pk.eyJ1IjoiYXJ0aWNhdmlzdWFscyIsImEiOiJjbW1nNDdyeGYwMTY2MnpvaXVmYXNpMHAxIn0.yUA1pC9B2jBzt1P2dyTdoA"
    static let styleURI = StyleURI(rawValue: "mapbox://styles/articavisuals/cmmvc02ke00e901rng9w6e58b")!
    static let fallbackCenter = CLLocationCoordinate2D(latitude: 34.1368, longitude: -118.1256)

    static func configure() {
        MapboxOptions.accessToken = accessToken
    }
}
