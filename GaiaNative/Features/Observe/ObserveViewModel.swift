import Foundation

enum ObserveStep: String {
    case camera
    case loading
    case details
    case celebration
    case share
}

final class ObserveViewModel: ObservableObject {
    @Published var step: ObserveStep
    @Published private(set) var lastAudioClipURL: URL?

    init() {
        step = Self.launchStep ?? .camera
    }

    func submitAudioObservation(url: URL) {
        lastAudioClipURL = url
        step = .loading
    }

    private static var launchStep: ObserveStep? {
        let arguments = ProcessInfo.processInfo.arguments

        guard let flagIndex = arguments.firstIndex(of: "-gaiaObserveStep"),
              arguments.indices.contains(flagIndex + 1) else {
            return nil
        }

        return ObserveStep(rawValue: arguments[flagIndex + 1].lowercased())
    }
}
