import CoreText
import MapboxMaps
import SwiftUI
import UIKit

@main
struct GaiaNativeApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var contentStore = ContentStore()

    init() {
        FontRegistrar.registerBundledFontsIfNeeded()
        GaiaMapbox.configure()
        TabBarAppearanceConfigurator.configure()
    }

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environmentObject(appState)
                .environmentObject(contentStore)
        }
    }
}

enum TabBarAppearanceConfigurator {
    private static var hasConfigured = false

    static func configure() {
        guard !hasConfigured else { return }
        hasConfigured = true

        let selectedColor = UIColor(red: 103 / 255, green: 118 / 255, blue: 91 / 255, alpha: 1)
        let deselectedColor = UIColor(red: 200 / 255, green: 207 / 255, blue: 191 / 255, alpha: 1)
        let tabBar = UITabBar.appearance()
        let appearance = tabBar.standardAppearance

        appearance.configureWithTransparentBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialLight)
        appearance.backgroundColor = UIColor.white.withAlphaComponent(0.46)
        appearance.shadowColor = .clear
        configure(itemAppearance: appearance.stackedLayoutAppearance, selectedColor: selectedColor, deselectedColor: deselectedColor)
        configure(itemAppearance: appearance.inlineLayoutAppearance, selectedColor: selectedColor, deselectedColor: deselectedColor)
        configure(itemAppearance: appearance.compactInlineLayoutAppearance, selectedColor: selectedColor, deselectedColor: deselectedColor)

        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        tabBar.tintColor = selectedColor
        tabBar.unselectedItemTintColor = deselectedColor
        tabBar.isTranslucent = true
    }

    private static func configure(
        itemAppearance: UITabBarItemAppearance,
        selectedColor: UIColor,
        deselectedColor: UIColor
    ) {
        itemAppearance.normal.iconColor = deselectedColor
        itemAppearance.normal.titleTextAttributes = [.foregroundColor: deselectedColor]
        itemAppearance.selected.iconColor = selectedColor
        itemAppearance.selected.titleTextAttributes = [.foregroundColor: selectedColor]
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
