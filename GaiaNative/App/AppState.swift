import Foundation

enum FindDetailsTab: String, CaseIterable, Identifiable, Codable {
    case find = "Find"
    case activity = "Activity"
    case learn = "Learn"

    var id: String { rawValue }
}

enum ProfileTab: String, CaseIterable, Identifiable, Codable {
    case impact = "Impact"
    case community = "Community"
    case preview = "Preview"

    var id: String { rawValue }
}

struct ProjectSelection: Identifiable, Hashable {
    let id: String
    let title: String
    let tag: String
    let countLabel: String
    let imageName: String
}

final class AppState: ObservableObject {
    @Published var selectedSection: AppSection
    @Published var showsFindDetails = false
    @Published var showsStoryDeck = false
    @Published var showsProjectDetail = false
    @Published var selectedFindTab: FindDetailsTab = .learn
    @Published var selectedSpeciesID: String?
    @Published var selectedProfileTab: ProfileTab = .impact
    @Published var selectedStoryID: String?
    @Published var selectedProject: ProjectSelection?

    init() {
        if let section = Self.launchSection {
            selectedSection = section
        } else {
            selectedSection = .explore
        }

        if let launchFindDetails = Self.launchFindDetails {
            selectedFindTab = launchFindDetails.tab
            selectedSpeciesID = launchFindDetails.speciesID
            showsFindDetails = true
        }

        if let launchStoryDeck = Self.launchStoryDeck {
            selectedStoryID = launchStoryDeck.storyID
            selectedSpeciesID = launchStoryDeck.speciesID ?? selectedSpeciesID
            showsStoryDeck = true
        }
    }

    func select(section: AppSection) {
        selectedSection = section
        switch section {
        case .log, .profile:
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

    func openProjectDetail(_ project: ProjectSelection) {
        selectedProject = project
        showsProjectDetail = true
    }

    func closeProjectDetail() {
        showsProjectDetail = false
        selectedProject = nil
    }

    private static var launchSection: AppSection? {
        let arguments = ProcessInfo.processInfo.arguments

        guard let flagIndex = arguments.firstIndex(of: "-gaiaSection"),
              arguments.indices.contains(flagIndex + 1) else {
            return nil
        }

        return AppSection(rawValue: arguments[flagIndex + 1].lowercased())
    }

    private static var launchFindDetails: (speciesID: String?, tab: FindDetailsTab)? {
        let arguments = ProcessInfo.processInfo.arguments

        guard let speciesIndex = arguments.firstIndex(of: "-gaiaFindDetails"),
              arguments.indices.contains(speciesIndex + 1) else {
            return nil
        }

        let speciesID = arguments[speciesIndex + 1]
        let tab: FindDetailsTab

        if let tabIndex = arguments.firstIndex(of: "-gaiaFindTab"),
           arguments.indices.contains(tabIndex + 1),
           let launchTab = FindDetailsTab(rawValue: arguments[tabIndex + 1].capitalized) {
            tab = launchTab
        } else {
            tab = .learn
        }

        return (speciesID: speciesID, tab: tab)
    }

    private static var launchStoryDeck: (storyID: String, speciesID: String?)? {
        let arguments = ProcessInfo.processInfo.arguments

        guard let storyIndex = arguments.firstIndex(of: "-gaiaStoryDeck"),
              arguments.indices.contains(storyIndex + 1) else {
            return nil
        }

        let storyID = arguments[storyIndex + 1]
        let speciesID: String?

        if let speciesIndex = arguments.firstIndex(of: "-gaiaStorySpecies"),
           arguments.indices.contains(speciesIndex + 1) {
            speciesID = arguments[speciesIndex + 1]
        } else {
            speciesID = nil
        }

        return (storyID: storyID, speciesID: speciesID)
    }
}
