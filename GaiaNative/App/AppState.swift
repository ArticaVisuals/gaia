import Foundation

enum FindDetailsTab: String, CaseIterable, Identifiable, Codable {
    case find = "Find"
    case activity = "Activity"

    var id: String { rawValue }
}

enum ProfileTab: String, CaseIterable, Identifiable, Codable {
    case impact = "Impact"
    case community = "Community"

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
    @Published var showsFindDetailsPrototype = false
    @Published var showsStoryDeck = false
    @Published var showsProjectDetail = false
    @Published var selectedFindTab: FindDetailsTab = .find
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

        if let launchFindDetailsPrototype = Self.launchFindDetailsPrototype {
            openFindDetailsPrototype(
                speciesID: launchFindDetailsPrototype.speciesID,
                tab: launchFindDetailsPrototype.tab
            )
        }

        if let launchStoryDeck = Self.launchStoryDeck {
            selectedStoryID = launchStoryDeck.storyID
            selectedSpeciesID = launchStoryDeck.speciesID ?? selectedSpeciesID
            showsStoryDeck = true
        }

        if let launchProjectDetail = Self.launchProjectDetail {
            selectedProject = launchProjectDetail
            showsProjectDetail = true
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

    func openFindDetails(speciesID: String?, tab: FindDetailsTab = .find) {
        openFindDetailsPrototype(speciesID: speciesID, tab: tab)
    }

    func openFindDetailsPrototype(speciesID: String?, tab: FindDetailsTab = .find) {
        selectedSpeciesID = speciesID
        selectedFindTab = tab
        showsFindDetailsPrototype = true
    }

    func closeFindDetailsPrototype() {
        showsFindDetailsPrototype = false
    }

    func openStoryDeck(_ storyID: String?, speciesID: String? = nil) {
        if let speciesID {
            selectedSpeciesID = speciesID
        }
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

    private static var launchFindDetailsPrototype: (speciesID: String?, tab: FindDetailsTab)? {
        let arguments = ProcessInfo.processInfo.arguments

        guard let speciesIndex = arguments.firstIndex(of: "-gaiaFindDetailsPrototype"),
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
            tab = .find
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

    private static var launchProjectDetail: ProjectSelection? {
        let arguments = ProcessInfo.processInfo.arguments

        guard let projectIndex = arguments.firstIndex(of: "-gaiaProjectDetail"),
              arguments.indices.contains(projectIndex + 1) else {
            return nil
        }

        let projectID = arguments[projectIndex + 1]

        switch projectID {
        case "project-creek":
            return ProjectSelection(
                id: projectID,
                title: "Creek Recovery",
                tag: "Waterway",
                countLabel: "24",
                imageName: "find-project-creek"
            )
        case "project-pollinator":
            return ProjectSelection(
                id: projectID,
                title: "Pollinator Corridor",
                tag: "Garden",
                countLabel: "24",
                imageName: "find-project-pollinator"
            )
        default:
            return ProjectSelection(
                id: projectID,
                title: projectID,
                tag: "",
                countLabel: "",
                imageName: "find-project-pollinator"
            )
        }
    }
}
