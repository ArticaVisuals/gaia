import Foundation

struct Species: Identifiable, Codable, Hashable {
    struct Coordinate: Codable, Hashable {
        let latitude: Double
        let longitude: Double
    }

    let id: String
    let commonName: String
    let scientificName: String
    let category: String
    let status: String
    let findCountLabel: String
    let summary: String
    let storyIDs: [String]
    let galleryAssetNames: [String]
    let mapCoordinate: Coordinate
}
