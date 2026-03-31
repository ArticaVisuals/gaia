import Foundation

struct ActivityEvent: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let timestampLabel: String
}
