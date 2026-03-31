import Foundation

enum ObserveStep {
    case camera
    case loading
    case details
    case share
}

final class ObserveViewModel: ObservableObject {
    @Published var step: ObserveStep = .camera
}
