import Foundation

enum FindDetailsTab: String, CaseIterable, Identifiable, Codable {
    case find = "Find"
    case activity = "Activity"
    case learn = "Learn"

    var id: String { rawValue }
}

enum ProfileTab: String, CaseIterable, Identifiable, Codable {
    case impact = "Impact"
    case log = "Log"
    case community = "Community"

    var id: String { rawValue }
}

final class AppState: ObservableObject {
    @Published var selectedSection: AppSection
    @Published var showsFindDetails = false
    @Published var showsStoryDeck = false
    @Published var selectedFindTab: FindDetailsTab = .learn
    @Published var selectedSpeciesID: String?
    @Published var selectedProfileTab: ProfileTab = .impact
    @Published var selectedStoryID: String?

    init() {
        if let section = Self.launchSection {
            selectedSection = section
        } else {
            selectedSection = .explore
        }
    }

    func select(section: AppSection) {
        selectedSection = section
        switch section {
        case .log:
            selectedProfileTab = .log
        case .profile:
            selectedProfileTab = .impact
        case .explore, .observe, .activity:
            break
        }
    }

    func openSampleFind(tab: FindDetailsTab = .learn) {
        selectedFindTab = tab
        selectedSpeciesID = nil
        showsFindDetails = true
    }

    func openFindDetails(speciesID: String?, tab: FindDetailsTab = .learn) {
        selectedFindTab = tab
        selectedSpeciesID = speciesID
        showsFindDetails = true
    }

    func closeFindDetails() {
        showsFindDetails = false
    }

    func openStoryDeck(_ storyID: String?) {
        selectedStoryID = storyID
        showsStoryDeck = true
    }

    func closeStoryDeck() {
        showsStoryDeck = false
        selectedStoryID = nil
    }

    private static var launchSection: AppSection? {
        let arguments = ProcessInfo.processInfo.arguments

        guard let flagIndex = arguments.firstIndex(of: "-gaiaSection"),
              arguments.indices.contains(flagIndex + 1) else {
            return nil
        }

        return AppSection(rawValue: arguments[flagIndex + 1].lowercased())
    }
}
