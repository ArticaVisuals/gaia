import CoreText
import MapboxMaps
import SwiftUI

@main
struct GaiaNativeApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var contentStore = ContentStore()

    init() {
        FontRegistrar.registerBundledFontsIfNeeded()
        GaiaMapbox.configure()
    }

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environmentObject(appState)
                .environmentObject(contentStore)
        }
    }
}

enum FontRegistrar {
    private static var hasRegistered = false

    static func registerBundledFontsIfNeeded() {
        guard !hasRegistered else { return }
        hasRegistered = true

        let candidateDirectories = [
            Bundle.main.resourceURL?.appendingPathComponent("Resources/Fonts", isDirectory: true),
            Bundle.main.resourceURL?.appendingPathComponent("Fonts", isDirectory: true)
        ].compactMap { $0 }

        for directory in candidateDirectories {
            guard let urls = try? FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil) else {
                continue
            }

            for url in urls where ["ttf", "otf"].contains(url.pathExtension.lowercased()) {
                CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
            }
        }
    }
}
