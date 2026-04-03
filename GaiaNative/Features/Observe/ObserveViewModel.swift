import Foundation

enum ObserveStep {
    case camera
    case loading
    case details
    case share
}

final class ObserveViewModel: ObservableObject {
    @Published var step: ObserveStep = .camera
    @Published private(set) var lastAudioClipURL: URL?

    func submitAudioObservation(url: URL) {
        lastAudioClipURL = url
        step = .loading
    }
}
