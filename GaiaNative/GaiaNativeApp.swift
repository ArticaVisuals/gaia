import AVFoundation
import CoreText
import SwiftUI
import UIKit

@main
struct GaiaNativeApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var contentStore = ContentStore()
    @State private var showsSplash = true

    init() {
        FontRegistrar.registerBundledFontsIfNeeded()
        TabBarAppearanceConfigurator.configure()
        AppAudioSessionConfigurator.configureForPassivePlayback()
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                if showsSplash {
                    GaiaColor.splashBackground
                        .ignoresSafeArea()
                }

                AppRootView()
                    .environmentObject(appState)
                    .environmentObject(contentStore)

                if showsSplash {
                    SplashScreenView {
                        showsSplash = false
                    }
                    .ignoresSafeArea()
                }
            }
        }
    }
}

enum AppAudioSessionConfigurator {
    private static var hasConfigured = false

    static func configureForPassivePlayback() {
        guard !hasConfigured else { return }
        hasConfigured = true

        do {
            // Keep silent launch video from interrupting any audio the user is already playing.
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
        } catch {
            #if DEBUG
            print("Failed to configure passive audio session: \(error)")
            #endif
        }
    }
}

enum TabBarAppearanceConfigurator {
    private static var hasConfigured = false

    static func configure() {
        guard !hasConfigured else { return }
        hasConfigured = true

        let tabBar = UITabBar.appearance()
        let selectedColor = UIColor(GaiaColor.oliveGreen500)
        let deselectedColor = UIColor(GaiaColor.oliveGreen200)

        if #available(iOS 26.0, *) {
            tabBar.tintColor = selectedColor
            tabBar.unselectedItemTintColor = deselectedColor
            tabBar.isTranslucent = true
            return
        }

        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialLight)
        appearance.backgroundColor = UIColor.white.withAlphaComponent(0.46)
        appearance.shadowColor = .clear
        configure(
            itemAppearance: appearance.stackedLayoutAppearance,
            selectedColor: selectedColor,
            deselectedColor: deselectedColor
        )
        configure(
            itemAppearance: appearance.inlineLayoutAppearance,
            selectedColor: selectedColor,
            deselectedColor: deselectedColor
        )
        configure(
            itemAppearance: appearance.compactInlineLayoutAppearance,
            selectedColor: selectedColor,
            deselectedColor: deselectedColor
        )

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
