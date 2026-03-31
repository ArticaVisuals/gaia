import Foundation

final class ProfileViewModel: ObservableObject {
    @Published var selectedTab: ProfileTab = .impact
}
