import SwiftUI

enum AppSection: String, CaseIterable, Identifiable {
    case explore
    case log
    case observe
    case activity
    case profile

    var id: String { rawValue }

    var title: String {
        switch self {
        case .explore: return "Explore"
        case .log: return "Log"
        case .observe: return "Observe"
        case .activity: return "Activity"
        case .profile: return "Profile"
        }
    }

    var symbolName: String {
        switch self {
        case .explore: return "safari"
        case .log: return "book.closed"
        case .observe: return "camera"
        case .activity: return "bell"
        case .profile: return "person"
        }
    }
}

struct AppRouter: View {
    let section: AppSection

    var body: some View {
        switch section {
        case .explore:
            ExploreScreen()
        case .log:
            LogScreen()
        case .observe:
            ObserveFlowScreen()
        case .activity:
            ActivityScreen()
        case .profile:
            ProfileScreen(forcedTab: profileLaunchTab())
        }
    }

    private func profileLaunchTab() -> ProfileTab? {
        let arguments = ProcessInfo.processInfo.arguments
        guard let flagIndex = arguments.firstIndex(of: "-gaiaProfileTab"),
              arguments.indices.contains(flagIndex + 1) else {
            return nil
        }

        return ProfileTab(rawValue: arguments[flagIndex + 1].capitalized)
    }
}
