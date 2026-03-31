import Foundation

enum DeepLink {
    case profile(tab: ProfileTab)
    case findDetails(speciesID: String, tab: FindDetailsTab)

    init?(url: URL) {
        switch url.host() {
        case "profile":
            let tab = ProfileTab(rawValue: url.lastPathComponent.capitalized) ?? .impact
            self = .profile(tab: tab)
        case "find":
            let components = url.pathComponents.filter { $0 != "/" }
            guard let speciesID = components.first else { return nil }
            let tab = FindDetailsTab(rawValue: components.dropFirst().first?.capitalized ?? "Learn") ?? .learn
            self = .findDetails(speciesID: speciesID, tab: tab)
        default:
            return nil
        }
    }
}
