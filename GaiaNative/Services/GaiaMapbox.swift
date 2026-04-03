import CoreLocation
import Foundation

enum GaiaMapbox {
    // Kept for existing call sites while the prototype uses native Apple Maps.
    static let fallbackCenter = CLLocationCoordinate2D(latitude: 34.1368, longitude: -118.1256)
}
