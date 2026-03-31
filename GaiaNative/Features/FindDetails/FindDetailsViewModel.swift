import Foundation

final class FindDetailsViewModel: ObservableObject {
    @Published var selectedTab: FindDetailsTab = .learn
    @Published var showsExpandedMap = false
}
