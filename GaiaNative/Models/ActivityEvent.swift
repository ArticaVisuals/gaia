import Foundation

struct ActivityEvent: Identifiable, Codable, Hashable {
    let id: String
    let groupLabel: String?
    let title: String
    let subtitle: String
    let timestampLabel: String
    let actionLabel: String?
    let categoryIDs: [String]?
}
