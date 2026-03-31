import Foundation

struct CommunityPost: Identifiable, Codable, Hashable {
    let id: String
    let author: String
    let title: String
    let subtitle: String
}
