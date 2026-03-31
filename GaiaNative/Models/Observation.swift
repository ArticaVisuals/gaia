import Foundation

struct Observation: Identifiable, Codable, Hashable {
    let id: String
    let speciesID: String
    let latitude: Double
    let longitude: Double
    let thumbnailAssetName: String?
}
