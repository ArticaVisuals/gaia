import SwiftUI

struct ProfileScreen: View {
    let forcedTab: ProfileTab?

    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var contentStore: ContentStore
    @StateObject private var viewModel = ProfileViewModel()
    @State private var previousTab: ProfileTab = .impact
    @State private var isHorizontalTabSwipeActive = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: GaiaSpacing.md) {
                profileTopActions
                    .padding(.horizontal, GaiaSpacing.md)
                    .padding(.top, GaiaSpacing.xs)

                ProfileHeaderCard(profile: contentStore.profile)
                    .padding(.horizontal, GaiaSpacing.md)

                DraggableTabSwitch(
                    tabs: ProfileTab.allCases,
                    selection: $viewModel.selectedTab,
                    title: { $0.rawValue }
                )

                ZStack(alignment: .topLeading) {
                    tabContent(for: viewModel.selectedTab)
                        .id(viewModel.selectedTab)
                        .transition(tabTransition)
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .animation(GaiaMotion.quickEase, value: viewModel.selectedTab)
                .animation(GaiaMotion.quickEase, value: previousTab)
                .horizontalTabSwipe(
                    tabs: ProfileTab.allCases,
                    selection: $viewModel.selectedTab,
                    onHorizontalDragStateChange: { isActive in
                        isHorizontalTabSwipeActive = isActive
                    }
                )
                .padding(.horizontal, GaiaSpacing.md)
                .padding(.bottom, 120)
            }
        }
        .scrollDisabled(isHorizontalTabSwipeActive)
        .background(GaiaColor.surfacePrimary)
        .onAppear {
            let initialTab = forcedTab ?? appState.selectedProfileTab
            previousTab = initialTab
            viewModel.selectedTab = initialTab
        }
        .onChange(of: viewModel.selectedTab) { oldValue, newValue in
            previousTab = oldValue
            appState.selectedProfileTab = newValue
        }
    }

    @ViewBuilder
    private var profileTopActions: some View {
        HStack(spacing: GaiaSpacing.sm) {
            Spacer(minLength: 0)

            GlassCircleButton(size: 48, action: {}) {
                Image("gaia-icon-gear-20")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(GaiaColor.inkBlack900)
                    .frame(width: 20, height: 20)
            }
            .accessibilityLabel("Settings")

            GlassCircleButton(size: 48, action: {}) {
                Image(systemName: "ellipsis")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(GaiaColor.inkBlack900)
            }
            .accessibilityLabel("More")
        }
    }

    @ViewBuilder
    private func tabContent(for tab: ProfileTab) -> some View {
        switch tab {
        case .impact:
            ProfileImpactTab(profile: contentStore.profile)
        case .community:
            ProfileCommunityTab(posts: contentStore.communityPosts)
        case .preview:
            ProfilePreviewTab()
        }
    }

    private var tabTransition: AnyTransition {
        let direction: CGFloat = tabDirection
        return .asymmetric(
            insertion: .offset(x: 26 * direction).combined(with: .opacity),
            removal: .offset(x: -26 * direction).combined(with: .opacity)
        )
    }

    private var tabDirection: CGFloat {
        guard let currentIndex = ProfileTab.allCases.firstIndex(of: viewModel.selectedTab),
              let previousIndex = ProfileTab.allCases.firstIndex(of: previousTab) else {
            return 1
        }

        return currentIndex >= previousIndex ? 1 : -1
    }
}

private struct ProfilePreviewTab: View {
    @State private var showsSignUpIdentity = false
    @State private var showsBioCalendar = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: GaiaSpacing.lg) {
                Text("Unlinked Screens")
                    .font(GaiaTypography.titleRegular)
                    .foregroundStyle(GaiaColor.inkBlack300)

                Text("First-pass implementations that still need final routing decisions.")
                    .font(GaiaTypography.subheadline)
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
                        .font(GaiaTypography.title2)
                        .foregroundStyle(GaiaColor.inkBlack300)

                    Text(subtitle)
                        .font(GaiaTypography.footnote)
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
                                .font(GaiaTypography.displayMedium)
                                .tracking(-0.5)
                                .foregroundStyle(GaiaColor.inkBlack500)

                            Text("Every find builds your journal. Track species, earn medals, and watch your impact grow over time.")
                                .font(GaiaTypography.subheadline)
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
                            .font(GaiaTypography.body)
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
                    .font(GaiaTypography.caption)
                    .foregroundStyle(GaiaColor.inkBlack300)
                    .tracking(0.25)

                Spacer(minLength: 0)

                Text("55% there")
                    .font(GaiaTypography.caption)
                    .foregroundStyle(GaiaColor.inkBlack300)
                    .tracking(0.25)
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
                .font(GaiaTypography.title2)
                .foregroundStyle(GaiaColor.inkBlack500)
                .frame(height: 29)

            Text(title)
                .font(GaiaTypography.caption)
                .foregroundStyle(GaiaColor.inkBlack300)
                .tracking(0.25)
        }
        .frame(width: 40)
    }
}
