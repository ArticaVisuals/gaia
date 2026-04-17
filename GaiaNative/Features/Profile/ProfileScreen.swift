// figma: https://www.figma.com/design/4e4G3tnSR7AdPbf0jAYPP1/Gaia?node-id=1711-181330 (Profile Impact Shell), 1609-176893 (Profile Community Shell)
import SwiftUI
import UIKit

struct ProfileScreen: View {
    let forcedTab: ProfileTab?

    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var contentStore: ContentStore
    @StateObject private var viewModel = ProfileViewModel()
    @State private var showsLaunchBioCalendar = false

    var body: some View {
        GeometryReader { proxy in
            let safeAreaWidth = max(0, proxy.size.width - proxy.safeAreaInsets.leading - proxy.safeAreaInsets.trailing)
            let contentWidth = min(safeAreaWidth, UIScreen.main.bounds.width)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    ProfileHeaderCard(profile: contentStore.profile)

                    ProfileUnderlineTabs(selection: $viewModel.selectedTab)

                    tabContent(for: viewModel.selectedTab)
                        .padding(.bottom, 120)
                }
                .frame(width: contentWidth, alignment: .leading)
                .padding(.leading, proxy.safeAreaInsets.leading)
            }
            .safeAreaInset(edge: .top, spacing: 0) {
                profileTopChrome(
                    contentWidth: contentWidth,
                    leadingInset: proxy.safeAreaInsets.leading
                )
            }
        }
        .background(GaiaColor.paperWhite50)
        .onAppear {
            let initialTab = shouldAutoOpenBioCalendar ? .impact : (forcedTab ?? appState.selectedProfileTab)
            viewModel.selectedTab = initialTab

            if shouldAutoOpenBioCalendar, !showsLaunchBioCalendar {
                DispatchQueue.main.async {
                    showsLaunchBioCalendar = true
                }
            }
        }
        .onChange(of: viewModel.selectedTab) { _, newValue in
            appState.selectedProfileTab = newValue
        }
        .fullScreenCover(isPresented: $showsLaunchBioCalendar) {
            ProfileBioCalendarScreen {
                showsLaunchBioCalendar = false
            }
        }
    }

    @ViewBuilder
    private var profileTopActions: some View {
        HStack(spacing: GaiaSpacing.sm) {
            Spacer(minLength: 0)

            ToolbarGlassButton(
                icon: .gear,
                accessibilityLabel: "Settings",
                action: {}
            )

            ToolbarGlassButton(
                icon: .more,
                accessibilityLabel: "More",
                action: {}
            )
        }
    }

    @ViewBuilder
    private func profileTopChrome(contentWidth: CGFloat, leadingInset: CGFloat) -> some View {
        profileTopActions
            .padding(.horizontal, GaiaSpacing.md)
            .padding(.top, GaiaSpacing.sm)
            .padding(.bottom, GaiaSpacing.md)
            .frame(width: contentWidth, alignment: .trailing)
            .padding(.leading, leadingInset)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private func tabContent(for tab: ProfileTab) -> some View {
        switch tab {
        case .impact:
            ProfileImpactTab(profile: contentStore.profile)
        case .community:
            ProfileCommunityTab(posts: contentStore.communityPosts)
        }
    }

    private var shouldAutoOpenBioCalendar: Bool {
        ProcessInfo.processInfo.arguments.contains("-gaiaProfileBioCalendar")
    }
}

private struct ProfileUnderlineTabs: View {
    @Binding var selection: ProfileTab

    var body: some View {
        ZStack(alignment: .bottom) {
            Rectangle()
                .fill(GaiaColor.blackishGrey200)
                .frame(height: 1)

            HStack(spacing: 0) {
                ForEach(ProfileTab.allCases, id: \.self) { tab in
                    tabButton(for: tab)
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .frame(height: 44)
    }

    @ViewBuilder
    private func tabButton(for tab: ProfileTab) -> some View {
        let isSelected = selection == tab
        Button {
            selection = tab
        } label: {
            ZStack(alignment: .bottom) {
                Text(tab.rawValue)
                    .gaiaFont(.body)
                    .foregroundStyle(
                        isSelected
                            ? GaiaColor.oliveGreen500
                            : GaiaColor.blackishGrey200
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                if isSelected {
                    Rectangle()
                        .fill(GaiaColor.oliveGreen500)
                        .frame(height: 3)
                }
            }
            .frame(height: 44)
        }
        .buttonStyle(.plain)
    }
}

private struct ProfilePreviewTab: View {
    @State private var showsSignUpIdentity = false
    @State private var showsBioCalendar = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: GaiaSpacing.lg) {
                Text("Unlinked Screens")
                    .gaiaFont(.title3)
                    .foregroundStyle(GaiaColor.inkBlack300)

                Text("First-pass implementations that still need final routing decisions.")
                    .gaiaFont(.subheadline)
                    .foregroundStyle(GaiaColor.blackishGrey500)
                    .fixedSize(horizontal: false, vertical: true)

                previewButton(
                    title: "Sign Up Identity",
                    subtitle: "Onboarding Field Journal step",
                    action: { showsSignUpIdentity = true }
                )

                previewButton(
                    title: "Bio Calendar Detail",
                    subtitle: "Expanded calendar analytics screen",
                    action: { showsBioCalendar = true }
                )
            }
            .padding(.top, GaiaSpacing.sm)
            .padding(.bottom, 120)
        }
        .fullScreenCover(isPresented: $showsSignUpIdentity) {
            SignUpIdentityScreen {
                showsSignUpIdentity = false
            }
        }
        .fullScreenCover(isPresented: $showsBioCalendar) {
            ProfileBioCalendarScreen {
                showsBioCalendar = false
            }
        }
    }

    private func previewButton(title: String, subtitle: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            GaiaDataCard {
                VStack(alignment: .leading, spacing: GaiaSpacing.sm) {
                    Text(title)
                        .gaiaFont(.title2)
                        .foregroundStyle(GaiaColor.inkBlack300)

                    Text(subtitle)
                        .gaiaFont(.footnote)
                        .foregroundStyle(GaiaColor.blackishGrey500)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

private struct SignUpIdentityScreen: View {
    let onClose: () -> Void

    private let profileGridLevels: [Int] = [
        4, 4, 0, 3, 3, 1, 3, 2, 3, 4, 2, 1,
        3, 1, 2, 1, 1, 2, 0, 2, 0, 3, 0, 1,
        1, 4, 4, 2, 3, 1, 0, 0, 0, 1, 1, 0,
        2, 3, 1, 3, 1, 1, 2, 0, 3, 2, 3, 2
    ]

    var body: some View {
        GeometryReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    VStack(alignment: .leading, spacing: GaiaSpacing.xl) {
                        SignUpIdentityPreviewCard(levels: profileGridLevels)
                            .frame(maxWidth: .infinity, alignment: .center)

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Your Field Journal")
                                .gaiaFont(.displayMedium)
                                .foregroundStyle(GaiaColor.inkBlack500)

                            Text("Every find builds your journal. Track species, earn medals, and watch your impact grow over time.")
                                .gaiaFont(.subheadline)
                                .foregroundStyle(GaiaColor.inkBlack300)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .padding(.top, 96)
                    .padding(.horizontal, GaiaSpacing.md)

                    Spacer(minLength: 65)

                    HStack(spacing: GaiaSpacing.sm) {
                        Circle()
                            .fill(GaiaColor.oliveGreen500)
                            .frame(width: 8, height: 8)
                        Circle()
                            .fill(GaiaColor.oliveGreen500)
                            .frame(width: 8, height: 8)
                        Circle()
                            .fill(GaiaColor.oliveGreen500)
                            .frame(width: 8, height: 8)
                    }
                    .padding(.horizontal, GaiaSpacing.md)

                    Spacer(minLength: 48)

                    Button(action: onClose) {
                        Text("Start Exploring")
                            .gaiaFont(.body)
                            .foregroundStyle(GaiaColor.paperWhite50)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Capsule(style: .continuous).fill(GaiaColor.oliveGreen500))
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, GaiaSpacing.md)
                    .padding(.bottom, GaiaSpacing.xl)
                }
                .frame(minHeight: proxy.size.height, alignment: .top)
            }
        }
        .background(GaiaColor.paperWhite50.ignoresSafeArea())
        .overlay(alignment: .topLeading) {
            ToolbarGlassButton(icon: .back, accessibilityLabel: "Back", action: onClose)
                .padding(.leading, GaiaSpacing.md)
                .safeAreaPadding(.top, 8)
        }
    }
}

private struct SignUpIdentityPreviewCard: View {
    let levels: [Int]

    private let columns: [GridItem] = Array(repeating: GridItem(.fixed(16), spacing: 4), count: 12)

    var body: some View {
        VStack(spacing: GaiaSpacing.md) {
            HStack(spacing: 34) {
                SignUpIdentityMetric(title: "Species", value: "63")
                SignUpIdentityMetric(title: "IDs", value: "23")
                SignUpIdentityMetric(title: "Projects", value: "4")
            }
            .frame(maxWidth: .infinity)

            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(Array(levels.enumerated()), id: \.offset) { _, level in
                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                        .fill(levelColor(level))
                        .frame(width: 16, height: 16)
                }
            }

            Rectangle()
                .fill(GaiaColor.oliveGreen100)
                .frame(height: 1)

            HStack(spacing: 10) {
                ForEach(0..<6, id: \.self) { _ in
                    Circle()
                        .fill(GaiaColor.paperWhite50)
                        .overlay(
                            Circle()
                                .stroke(GaiaColor.broccoliBrown200, lineWidth: 0.5)
                        )
                        .frame(width: 32, height: 32)
                }
            }
            .frame(maxWidth: .infinity)

            HStack {
                Text("Level 3")
                    .gaiaFont(.caption)
                    .foregroundStyle(GaiaColor.inkBlack300)

                Spacer(minLength: 0)

                Text("55% there")
                    .gaiaFont(.caption)
                    .foregroundStyle(GaiaColor.inkBlack300)
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule(style: .continuous)
                        .fill(GaiaColor.oliveGreen100)
                    Capsule(style: .continuous)
                        .fill(GaiaColor.oliveGreen500)
                        .frame(width: proxy.size.width * (153 / 278))
                }
            }
            .frame(height: 6)
        }
        .padding(.horizontal, GaiaSpacing.md)
        .padding(.vertical, 20)
        .frame(width: 310)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(GaiaColor.oliveGreen100, lineWidth: 1)
                )
        )
    }

    private func levelColor(_ level: Int) -> Color {
        switch level {
        case 4:
            return GaiaColor.oliveGreen500
        case 3:
            return GaiaColor.oliveGreen400
        case 2:
            return GaiaColor.oliveGreen200
        case 1:
            return GaiaColor.oliveGreen100
        default:
            return GaiaColor.oliveGreen50
        }
    }
}

private struct SignUpIdentityMetric: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: GaiaSpacing.sm) {
            Text(value)
                .gaiaFont(.title2)
                .foregroundStyle(GaiaColor.inkBlack500)
                .frame(height: 29)

            Text(title)
                .gaiaFont(.caption)
                .foregroundStyle(GaiaColor.inkBlack300)
        }
        .frame(width: 40)
    }
}
