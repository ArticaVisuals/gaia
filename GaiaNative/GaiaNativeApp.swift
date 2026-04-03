import CoreText
import SwiftUI
import UIKit

@main
struct GaiaNativeApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var contentStore = ContentStore()

    init() {
        FontRegistrar.registerBundledFontsIfNeeded()
        TabBarAppearanceConfigurator.configure()
    }

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environmentObject(appState)
                .environmentObject(contentStore)
                .task {
                    contentStore.loadBundledContentIfAvailable()
                }
        }
    }
}

enum TabBarAppearanceConfigurator {
    private static var hasConfigured = false

    static func configure() {
        guard !hasConfigured else { return }
        hasConfigured = true

        let olive500 = UIColor(red: 103 / 255, green: 118 / 255, blue: 91 / 255, alpha: 1)
        let paperBase = UIColor(red: 252 / 255, green: 250 / 255, blue: 241 / 255, alpha: 0.96)
        let borderColor = UIColor(red: 216 / 255, green: 201 / 255, blue: 184 / 255, alpha: 0.72)
        let selectedColor = olive500
        let deselectedColor = olive500
        let titleFont = tabTitleFont()
        let tabBar = UITabBar.appearance()
        let tabBarItem = UITabBarItem.appearance()
        let appearance = UITabBarAppearance()

        appearance.configureWithOpaqueBackground()
        appearance.backgroundEffect = nil
        appearance.backgroundColor = paperBase
        appearance.shadowColor = borderColor
        configure(
            itemAppearance: appearance.stackedLayoutAppearance,
            selectedColor: selectedColor,
            deselectedColor: deselectedColor,
            titleFont: titleFont
        )
        configure(
            itemAppearance: appearance.inlineLayoutAppearance,
            selectedColor: selectedColor,
            deselectedColor: deselectedColor,
            titleFont: titleFont
        )
        configure(
            itemAppearance: appearance.compactInlineLayoutAppearance,
            selectedColor: selectedColor,
            deselectedColor: deselectedColor,
            titleFont: titleFont
        )

        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        tabBar.tintColor = selectedColor
        tabBar.unselectedItemTintColor = deselectedColor
        tabBar.isTranslucent = false

        // Keep the tab label color consistent across selection states.
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: olive500,
            .font: titleFont
        ]
        tabBarItem.setTitleTextAttributes(titleAttributes, for: .normal)
        tabBarItem.setTitleTextAttributes(titleAttributes, for: .selected)
        tabBarItem.setTitleTextAttributes(titleAttributes, for: .disabled)
        tabBarItem.setTitleTextAttributes(titleAttributes, for: .focused)
    }

    private static func configure(
        itemAppearance: UITabBarItemAppearance,
        selectedColor: UIColor,
        deselectedColor: UIColor,
        titleFont: UIFont
    ) {
        let normalAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: deselectedColor,
            .font: titleFont
        ]
        let selectedAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: selectedColor,
            .font: titleFont
        ]

        apply(color: deselectedColor, attributes: normalAttributes, to: itemAppearance.normal)
        apply(color: selectedColor, attributes: selectedAttributes, to: itemAppearance.selected)
        apply(color: deselectedColor, attributes: normalAttributes, to: itemAppearance.disabled)
        apply(color: deselectedColor, attributes: normalAttributes, to: itemAppearance.focused)
    }

    private static func apply(
        color: UIColor,
        attributes: [NSAttributedString.Key: Any],
        to stateAppearance: UITabBarItemStateAppearance
    ) {
        stateAppearance.iconColor = color
        stateAppearance.titleTextAttributes = attributes
    }

    private static func tabTitleFont() -> UIFont {
        let candidates = [
            "Neue Haas Unica W1G",
            "NeueHaasUnica-Regular",
            "Neue Haas Unica",
            "NeueHaasUnica"
        ]

        if let font = candidates.lazy.compactMap({ UIFont(name: $0, size: 10) }).first {
            return font
        }

        return .systemFont(ofSize: 10, weight: .regular)
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
