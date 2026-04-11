import PhotosUI
import SwiftUI

private enum OnboardingScreen: Equatable {
    case welcome
    case signUp
    case login
    case avatar
    case interests
    case tutorial
}

private struct OnboardingInterest: Identifiable, Hashable {
    let title: String

    var id: String { title }

    static let all: [OnboardingInterest] = [
        .init(title: "Plants"),
        .init(title: "Fungi"),
        .init(title: "Birds"),
        .init(title: "Reptiles"),
        .init(title: "Insects"),
        .init(title: "Mammals"),
        .init(title: "Marine Life"),
        .init(title: "Wildflowers"),
        .init(title: "Trees"),
        .init(title: "Pollinators"),
        .init(title: "Alpine Ecology"),
        .init(title: "Nocturnal Life")
    ]

    static let defaultSelection: Set<String> = [
        "Plants",
        "Fungi",
        "Mammals",
        "Trees"
    ]
}

private struct OnboardingAvatarOption: Identifiable, Equatable {
    let id: String
    let title: String
    let imageName: String?
    let initials: String?
    let background: Color

    static let all: [OnboardingAvatarOption] = [
        .init(
            id: "maya",
            title: "Maya",
            imageName: "profile-avatar-maya",
            initials: nil,
            background: GaiaColor.oliveGreen50
        ),
        .init(
            id: "lena",
            title: "Lena",
            imageName: "profile-avatar-lena",
            initials: nil,
            background: GaiaColor.broccoliBrown50
        ),
        .init(
            id: "noah",
            title: "Noah",
            imageName: "profile-avatar-noah",
            initials: nil,
            background: GaiaColor.asparagusGreen100
        ),
        .init(
            id: "alice",
            title: "Alice",
            imageName: "find-avatar-alice",
            initials: nil,
            background: GaiaColor.paperWhite100
        ),
        .init(
            id: "sprout",
            title: "Sprout",
            imageName: nil,
            initials: "SP",
            background: GaiaColor.oliveGreen100
        ),
        .init(
            id: "trail",
            title: "Trail",
            imageName: nil,
            initials: "TR",
            background: GaiaColor.broccoliBrown100
        )
    ]
}

private struct OnboardingParticle: Identifiable {
    let id = UUID()
    let origin: CGPoint
    let size: CGFloat
    let opacity: Double
    let drift: CGSize
    let delay: Double
    let duration: Double

    static let all: [OnboardingParticle] = [
        .init(origin: CGPoint(x: 86, y: 180), size: 6, opacity: 0.35, drift: CGSize(width: 10, height: -12), delay: 0.1, duration: 4.2),
        .init(origin: CGPoint(x: 126, y: 250), size: 4, opacity: 0.4, drift: CGSize(width: -12, height: 10), delay: 0.3, duration: 3.8),
        .init(origin: CGPoint(x: 306, y: 200), size: 8, opacity: 0.24, drift: CGSize(width: -10, height: -14), delay: 0.0, duration: 4.8),
        .init(origin: CGPoint(x: 256, y: 320), size: 5, opacity: 0.32, drift: CGSize(width: 16, height: -10), delay: 0.6, duration: 4.1),
        .init(origin: CGPoint(x: 86, y: 380), size: 7, opacity: 0.28, drift: CGSize(width: 12, height: 8), delay: 0.2, duration: 4.6),
        .init(origin: CGPoint(x: 326, y: 150), size: 4, opacity: 0.42, drift: CGSize(width: -14, height: 12), delay: 0.9, duration: 4.0),
        .init(origin: CGPoint(x: 186, y: 140), size: 10, opacity: 0.18, drift: CGSize(width: 8, height: -10), delay: 0.4, duration: 5.0),
        .init(origin: CGPoint(x: 346, y: 400), size: 6, opacity: 0.24, drift: CGSize(width: -8, height: -8), delay: 0.8, duration: 4.4)
    ]
}

private struct OnboardingTutorialPage: Identifiable {
    enum Media {
        case none
        case observeCard
        case journalCard
    }

    let id: Int
    let title: String
    let subtitle: String
    let media: Media
    let buttonTitle: String
}

private extension OnboardingTutorialPage {
    static func pages(displayName: String) -> [OnboardingTutorialPage] {
        [
            .init(
                id: 0,
                title: "Welcome, \(displayName)",
                subtitle: "Every great explorer starts with a single step. Let’s show you around.",
                media: .none,
                buttonTitle: "Continue"
            ),
            .init(
                id: 1,
                title: "Observe",
                subtitle: "Tap the binoculars whenever you spot something. Snap a photo, and we help you identify it.",
                media: .observeCard,
                buttonTitle: "Continue"
            ),
            .init(
                id: 2,
                title: "Your Field Journal",
                subtitle: "Every find builds your journal. Track species, earn medals, and watch your impact grow over time.",
                media: .journalCard,
                buttonTitle: "Start Exploring"
            )
        ]
    }
}

private enum OnboardingLayout {
    static let topContentInset = GaiaSpacing.xxxl + GaiaSpacing.xl + GaiaSpacing.md + GaiaSpacing.sm
    static let splashTitleSpacing = GaiaSpacing.md
    static let splashButtonSpacing = GaiaSpacing.cardInset
    static let formSectionGap = GaiaSpacing.lg - GaiaSpacing.xxs - GaiaSpacing.xxs
    static let socialButtonsSpacing = GaiaSpacing.cardInset
    static let tutorialMediaCornerRadius = GaiaRadius.sheet
    static let tutorialCardBottomPadding = GaiaSpacing.lg + GaiaSpacing.xs + GaiaSpacing.xxs
    static let tutorialIconTrailing = GaiaSpacing.cardInset + GaiaSpacing.sm - GaiaSpacing.xxs
    static let tutorialIconBottom = GaiaSpacing.xxl - GaiaSpacing.xxs
    static let journalMetricSpacing = GaiaSpacing.lg + GaiaSpacing.sm + GaiaSpacing.xxs
    static let journalCardVerticalPadding = GaiaSpacing.lg - GaiaSpacing.xxs - GaiaSpacing.xxs
    static let interestChipHeight = GaiaSpacing.lg + GaiaSpacing.sm + GaiaSpacing.xxs
}

struct OnboardingFlowScreen: View {
    let onComplete: () -> Void

    @State private var screen: OnboardingScreen = .welcome
    @State private var transitionDirection: Edge = .trailing
    @State private var displayName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var loginEmail = ""
    @State private var loginPassword = ""
    @State private var selectedAvatarID: String?
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedPhotoImage: UIImage?
    @State private var selectedInterests = OnboardingInterest.defaultSelection
    @State private var tutorialPage = 0
    @FocusState private var focusedField: OnboardingFocusField?

    var body: some View {
        ZStack {
            if screen == .welcome {
                OnboardingWelcomeSplash(
                    onCreateAccount: {
                        focusedField = nil
                        navigate(to: .signUp)
                    },
                    onLogIn: {
                        focusedField = nil
                        navigate(to: .login)
                    }
                )
                .transition(screenTransition)
            }

            if screen == .signUp {
                OnboardingSignUpScreen(
                    displayName: $displayName,
                    email: $email,
                    password: $password,
                    focusedField: $focusedField,
                    onBack: { navigate(to: .welcome, forward: false) },
                    onContinue: {
                        focusedField = nil
                        navigate(to: .avatar)
                    },
                    onSocialAuth: {
                        focusedField = nil
                        displayName = resolvedDisplayName
                        tutorialPage = 0
                        navigate(to: .tutorial)
                    },
                    onShowLogin: {
                        focusedField = nil
                        navigate(to: .login)
                    }
                )
                .transition(screenTransition)
            }

            if screen == .login {
                OnboardingLoginScreen(
                    email: $loginEmail,
                    password: $loginPassword,
                    focusedField: $focusedField,
                    onBack: { navigate(to: .welcome, forward: false) },
                    onContinue: {
                        focusedField = nil
                        finish()
                    },
                    onSocialAuth: {
                        focusedField = nil
                        finish()
                    },
                    onShowSignUp: {
                        focusedField = nil
                        navigate(to: .signUp, forward: false)
                    }
                )
                .transition(screenTransition)
            }

            if screen == .avatar {
                OnboardingAvatarScreen(
                    displayName: resolvedDisplayName,
                    selectedAvatarID: $selectedAvatarID,
                    selectedPhotoItem: $selectedPhotoItem,
                    selectedPhotoImage: $selectedPhotoImage,
                    onBack: { navigate(to: .signUp, forward: false) },
                    onContinue: { navigate(to: .interests) },
                    onSkip: { navigate(to: .interests) }
                )
                .transition(screenTransition)
            }

            if screen == .interests {
                OnboardingInterestsScreen(
                    selectedInterests: $selectedInterests,
                    onBack: { navigate(to: .avatar, forward: false) },
                    onCreateAccount: {
                        tutorialPage = 0
                        navigate(to: .tutorial)
                    }
                )
                .transition(screenTransition)
            }

            if screen == .tutorial {
                OnboardingTutorialScreen(
                    displayName: resolvedDisplayName,
                    pageIndex: $tutorialPage,
                    onAdvance: {
                        if tutorialPage == OnboardingTutorialPage.pages(displayName: resolvedDisplayName).count - 1 {
                            finish()
                        } else {
                            HapticsService.selectionChanged()
                            withAnimation(GaiaMotion.spring) {
                                tutorialPage += 1
                            }
                        }
                    }
                )
                .transition(screenTransition)
            }
        }
        .background(GaiaColor.paperWhite50.ignoresSafeArea())
        .animation(GaiaMotion.softSpring, value: screen)
        .animation(GaiaMotion.softSpring, value: tutorialPage)
        .onChange(of: selectedPhotoItem) { _, newValue in
            loadSelectedPhoto(from: newValue)
        }
    }

    private var resolvedDisplayName: String {
        let trimmed = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Alice" : trimmed
    }

    private var screenTransition: AnyTransition {
        .asymmetric(
            insertion: .move(edge: transitionDirection).combined(with: .opacity),
            removal: .move(edge: transitionDirection.opposite).combined(with: .opacity)
        )
    }

    private func navigate(to newScreen: OnboardingScreen, forward: Bool = true) {
        HapticsService.selectionChanged()
        transitionDirection = forward ? .trailing : .leading
        withAnimation(GaiaMotion.softSpring) {
            screen = newScreen
        }
    }

    private func finish() {
        HapticsService.selectionChanged()
        onComplete()
    }

    private func loadSelectedPhoto(from item: PhotosPickerItem?) {
        guard let item else {
            return
        }

        Task {
            guard let data = try? await item.loadTransferable(type: Data.self),
                  let image = UIImage(data: data) else {
                return
            }

            await MainActor.run {
                selectedPhotoImage = image
                selectedAvatarID = nil
            }
        }
    }
}

private enum OnboardingFocusField: Hashable {
    case displayName
    case signUpEmail
    case signUpPassword
    case loginEmail
    case loginPassword
}

private struct OnboardingWelcomeSplash: View {
    let onCreateAccount: () -> Void
    let onLogIn: () -> Void

    @State private var animateIn = false

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .bottom) {
                GaiaAssetImage(name: "coast-live-oak-hero")
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .scaleEffect(animateIn ? 1.04 : 1.0)
                    .animation(.easeInOut(duration: 8).repeatForever(autoreverses: true), value: animateIn)
                    .overlay {
                        LinearGradient(
                            colors: [
                                GaiaColor.inkBlack900.opacity(0.08),
                                GaiaColor.inkBlack900.opacity(0.18),
                                GaiaColor.inkBlack900.opacity(0.56)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    }
                    .ignoresSafeArea()

                OnboardingParticleField(isAnimating: animateIn)
                    .frame(width: 286, height: 266)
                    .offset(y: -160)
                    .accessibilityHidden(true)

                VStack(spacing: 0) {
                    VStack(spacing: OnboardingLayout.splashTitleSpacing) {
                        Text("Gaia")
                            .gaiaFont(.heroMedium)
                            .foregroundStyle(GaiaColor.paperWhite50)
                            .scaleEffect(x: 1.42, y: 1.42, anchor: .center)
                            .opacity(animateIn ? 1 : 0)
                            .offset(y: animateIn ? 0 : -18)
                            .animation(GaiaMotion.spring.delay(0.08), value: animateIn)

                        Text("Add to the living\nrecord of life.")
                            .gaiaFont(.title1)
                            .foregroundStyle(GaiaColor.paperWhite50.opacity(0.82))
                            .multilineTextAlignment(.center)
                            .opacity(animateIn ? 1 : 0)
                            .offset(y: animateIn ? 0 : 14)
                            .animation(.easeOut(duration: 0.6).delay(0.2), value: animateIn)
                    }
                    .padding(.top, GaiaSpacing.xl)

                    Spacer(minLength: 0)

                    VStack(spacing: OnboardingLayout.splashButtonSpacing) {
                        OnboardingPrimaryButton(title: "Start Exploring", action: onCreateAccount)
                            .opacity(animateIn ? 1 : 0)
                            .offset(y: animateIn ? 0 : 22)
                            .animation(GaiaMotion.spring.delay(0.34), value: animateIn)

                        OnboardingSecondaryButton(title: "Log In", action: onLogIn)
                            .opacity(animateIn ? 1 : 0)
                            .offset(y: animateIn ? 0 : 22)
                            .animation(GaiaMotion.spring.delay(0.42), value: animateIn)
                    }
                    .padding(.horizontal, GaiaSpacing.md)
                    .padding(.bottom, max(GaiaSpacing.lg, proxy.safeAreaInsets.bottom + GaiaSpacing.sm))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            animateIn = true
        }
    }
}

private struct OnboardingParticleField: View {
    let isAnimating: Bool

    var body: some View {
        ZStack {
            ForEach(OnboardingParticle.all) { particle in
                Circle()
                    .fill(GaiaColor.paperWhite50.opacity(particle.opacity))
                    .frame(width: particle.size, height: particle.size)
                    .offset(
                        x: particle.origin.x + (isAnimating ? particle.drift.width : 0),
                        y: particle.origin.y + (isAnimating ? particle.drift.height : 0)
                    )
                    .blur(radius: particle.size > 8 ? 1.6 : 0)
                    .animation(
                        .easeInOut(duration: particle.duration)
                            .repeatForever(autoreverses: true)
                            .delay(particle.delay),
                        value: isAnimating
                    )
            }
        }
    }
}

private struct OnboardingSignUpScreen: View {
    @Binding var displayName: String
    @Binding var email: String
    @Binding var password: String
    @FocusState.Binding var focusedField: OnboardingFocusField?

    let onBack: () -> Void
    let onContinue: () -> Void
    let onSocialAuth: () -> Void
    let onShowLogin: () -> Void

    var body: some View {
        OnboardingFormContainer(backAction: onBack) {
            VStack(alignment: .leading, spacing: 0) {
                Text("Let’s get to know you.")
                    .gaiaFont(.displayMedium)
                    .foregroundStyle(GaiaColor.inkBlack500)
                    .padding(.top, OnboardingLayout.topContentInset)

                Spacer().frame(height: GaiaSpacing.xl)

                OnboardingInputField(
                    label: "Display Name",
                    text: $displayName,
                    prompt: "What should we call you?"
                )
                .focused($focusedField, equals: .displayName)
                .submitLabel(.next)
                .textContentType(.name)
                .onSubmit { focusedField = .signUpEmail }

                Spacer().frame(height: GaiaSpacing.md)

                OnboardingInputField(
                    label: "Email",
                    text: $email,
                    prompt: "your@email.com"
                )
                .focused($focusedField, equals: .signUpEmail)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.next)
                .textContentType(.emailAddress)
                .onSubmit { focusedField = .signUpPassword }

                Spacer().frame(height: GaiaSpacing.md)

                OnboardingSecureField(
                    label: "Password",
                    text: $password,
                    prompt: "Create a password"
                )
                .focused($focusedField, equals: .signUpPassword)
                .submitLabel(.done)
                .textContentType(.newPassword)
                .onSubmit {
                    focusedField = nil
                    onContinue()
                }

                OnboardingPasswordStrengthBar(strength: passwordStrength)
                    .padding(.top, GaiaSpacing.sm)

                Spacer().frame(height: 33)

                OnboardingPrimaryButton(title: "Continue", action: onContinue)

                Spacer().frame(height: OnboardingLayout.formSectionGap)

                OnboardingDivider(label: "or continue with")

                Spacer().frame(height: OnboardingLayout.formSectionGap)

                HStack(spacing: OnboardingLayout.socialButtonsSpacing) {
                    OnboardingSocialButton(title: "Apple", icon: .apple, action: onSocialAuth)
                    OnboardingSocialButton(title: "Google", icon: .google, action: onSocialAuth)
                }

                Spacer().frame(height: OnboardingLayout.formSectionGap)

                Button(action: onShowLogin) {
                    HStack(spacing: 0) {
                        Text("Already exploring? ")
                            .gaiaFont(.subheadline)
                            .foregroundStyle(GaiaColor.inkBlack300)

                        Text("Log in")
                            .gaiaFont(.subheadline)
                            .foregroundStyle(GaiaColor.oliveGreen500)
                    }
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity)
                .padding(.bottom, GaiaSpacing.xl)
            }
        }
        .scrollDismissesKeyboard(.interactively)
    }

    private var passwordStrength: Int {
        min(max(password.count / 3, 0), 4)
    }
}

private struct OnboardingLoginScreen: View {
    @Binding var email: String
    @Binding var password: String
    @FocusState.Binding var focusedField: OnboardingFocusField?

    let onBack: () -> Void
    let onContinue: () -> Void
    let onSocialAuth: () -> Void
    let onShowSignUp: () -> Void

    var body: some View {
        OnboardingFormContainer(backAction: onBack) {
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Welcome back.")
                        .gaiaFont(.displayMedium)
                        .foregroundStyle(GaiaColor.inkBlack500)

                    Text("Pick up where you left off.")
                        .gaiaFont(.subheadline)
                        .foregroundStyle(GaiaColor.inkBlack300)
                }
                .padding(.top, OnboardingLayout.topContentInset)

                VStack {
                    GaiaProfileAvatar(
                        imageName: "find-avatar-alice",
                        size: 72,
                        borderWidth: 0.5,
                        strokeColor: GaiaColor.paperWhite100,
                        backgroundColor: GaiaColor.paperWhite100
                    )
                }
                .frame(maxWidth: .infinity)
                .padding(.top, GaiaSpacing.xl)
                .padding(.bottom, GaiaSpacing.md)

                OnboardingInputField(
                    label: "Email",
                    text: $email,
                    prompt: "your@email.com"
                )
                .focused($focusedField, equals: .loginEmail)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.next)
                .textContentType(.emailAddress)
                .onSubmit { focusedField = .loginPassword }

                Spacer().frame(height: GaiaSpacing.md)

                OnboardingSecureField(
                    label: "Password",
                    text: $password,
                    prompt: "Enter your password"
                )
                .focused($focusedField, equals: .loginPassword)
                .submitLabel(.done)
                .textContentType(.password)
                .onSubmit {
                    focusedField = nil
                    onContinue()
                }

                Button(action: {}) {
                    Text("Forgot password?")
                        .gaiaFont(.footnote)
                        .foregroundStyle(GaiaColor.broccoliBrown500)
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.top, GaiaSpacing.sm)

                Spacer().frame(height: 33)

                OnboardingPrimaryButton(title: "Continue", action: onContinue)

                Spacer().frame(height: OnboardingLayout.formSectionGap)

                OnboardingDivider(label: "or")

                Spacer().frame(height: OnboardingLayout.formSectionGap)

                HStack(spacing: OnboardingLayout.socialButtonsSpacing) {
                    OnboardingSocialButton(title: "Apple", icon: .apple, action: onSocialAuth)
                    OnboardingSocialButton(title: "Google", icon: .google, action: onSocialAuth)
                }

                Spacer().frame(height: OnboardingLayout.formSectionGap)

                Button(action: onShowSignUp) {
                    HStack(spacing: 0) {
                        Text("New here? ")
                            .gaiaFont(.subheadline)
                            .foregroundStyle(GaiaColor.inkBlack300)

                        Text("Create account")
                            .gaiaFont(.subheadline)
                            .foregroundStyle(GaiaColor.oliveGreen500)
                    }
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity)
                .padding(.bottom, GaiaSpacing.xl)
            }
        }
        .scrollDismissesKeyboard(.interactively)
    }
}

private struct OnboardingAvatarScreen: View {
    let displayName: String
    @Binding var selectedAvatarID: String?
    @Binding var selectedPhotoItem: PhotosPickerItem?
    @Binding var selectedPhotoImage: UIImage?

    let onBack: () -> Void
    let onContinue: () -> Void
    let onSkip: () -> Void

    private let columns = Array(repeating: GridItem(.flexible(), spacing: GaiaSpacing.sm), count: 3)

    var body: some View {
        OnboardingFormContainer(backAction: onBack) {
            VStack(alignment: .leading, spacing: 0) {
                Text("Your field identity")
                    .gaiaFont(.displayMedium)
                    .foregroundStyle(GaiaColor.inkBlack500)
                    .padding(.top, OnboardingLayout.topContentInset)

                Spacer().frame(height: GaiaSpacing.xl)

                PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                    OnboardingAvatarUploadCard(
                        displayName: displayName,
                        selectedPhotoImage: selectedPhotoImage,
                        selectedPreset: selectedPreset
                    )
                }
                .buttonStyle(.plain)

                Spacer().frame(height: GaiaSpacing.sm)

                Text(selectedPhotoImage == nil ? "Add a photo" : "Photo selected")
                    .gaiaFont(.subheadline)
                    .foregroundStyle(GaiaColor.oliveGreen500)
                    .frame(maxWidth: .infinity)

                Spacer().frame(height: GaiaSpacing.md)

                Text("Or choose an avatar")
                    .gaiaFont(.footnote)
                    .foregroundStyle(GaiaColor.inkBlack300)

                Spacer().frame(height: GaiaSpacing.sm)

                LazyVGrid(columns: columns, spacing: GaiaSpacing.sm) {
                    ForEach(OnboardingAvatarOption.all) { option in
                        Button {
                            HapticsService.selectionChanged()
                            selectedAvatarID = option.id
                            selectedPhotoItem = nil
                            selectedPhotoImage = nil
                        } label: {
                            OnboardingAvatarTile(
                                option: option,
                                isSelected: selectedAvatarID == option.id
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }

                Spacer().frame(height: GaiaSpacing.xl)

                OnboardingPrimaryButton(title: "Continue", action: onContinue)

                Spacer().frame(height: 12)

                Button(action: onSkip) {
                    Text("Skip for now")
                        .gaiaFont(.subheadline)
                        .foregroundStyle(GaiaColor.inkBlack300)
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity)
                .padding(.bottom, GaiaSpacing.xl)
            }
        }
    }

    private var selectedPreset: OnboardingAvatarOption? {
        guard let selectedAvatarID else {
            return nil
        }

        return OnboardingAvatarOption.all.first { $0.id == selectedAvatarID }
    }
}

private struct OnboardingInterestsScreen: View {
    @Binding var selectedInterests: Set<String>

    let onBack: () -> Void
    let onCreateAccount: () -> Void

    var body: some View {
        OnboardingFormContainer(backAction: onBack) {
            VStack(alignment: .leading, spacing: 0) {
                Text("What draws you\noutside?")
                    .gaiaFont(.displayMedium)
                    .foregroundStyle(GaiaColor.inkBlack500)
                    .padding(.top, OnboardingLayout.topContentInset)

                Spacer().frame(height: 10)

                Text("Pick at least 3, we’ll personalize your experience.")
                    .gaiaFont(.subheadline)
                    .foregroundStyle(GaiaColor.inkBlack300)

                Spacer().frame(height: GaiaSpacing.lg)

                OnboardingWrapLayout(horizontalSpacing: 12, verticalSpacing: 12) {
                    ForEach(OnboardingInterest.all) { interest in
                        let isSelected = selectedInterests.contains(interest.id)

                        Button {
                            withAnimation(GaiaMotion.spring) {
                                if isSelected {
                                    selectedInterests.remove(interest.id)
                                } else {
                                    selectedInterests.insert(interest.id)
                                }
                            }
                            HapticsService.selectionChanged()
                        } label: {
                            OnboardingInterestChip(
                                title: interest.title,
                                isSelected: isSelected
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }

                Spacer().frame(height: GaiaSpacing.md)

                Text("\(selectedInterests.count) selected")
                    .gaiaFont(.footnote)
                    .foregroundStyle(GaiaColor.oliveGreen500)

                Spacer(minLength: GaiaSpacing.xxxl)

                OnboardingPrimaryButton(
                    title: "Create Account",
                    action: onCreateAccount,
                    isEnabled: selectedInterests.count >= 3
                )
                .padding(.bottom, GaiaSpacing.xl)
            }
        }
    }
}

private struct OnboardingTutorialScreen: View {
    let displayName: String
    @Binding var pageIndex: Int
    let onAdvance: () -> Void

    var body: some View {
        let pages = OnboardingTutorialPage.pages(displayName: displayName)

        GeometryReader { proxy in
            ZStack {
                tutorialBackground

                VStack(spacing: 0) {
                    TabView(selection: $pageIndex) {
                        ForEach(pages) { page in
                            OnboardingTutorialPageView(page: page)
                                .tag(page.id)
                                .frame(width: proxy.size.width)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .animation(GaiaMotion.softSpring, value: pageIndex)

                    VStack(alignment: .leading, spacing: GaiaSpacing.lg) {
                        OnboardingPageDots(
                            count: pages.count,
                            currentIndex: pageIndex,
                            onSelect: { index in
                                HapticsService.selectionChanged()
                                withAnimation(GaiaMotion.softSpring) {
                                    pageIndex = index
                                }
                            }
                        )

                        OnboardingPrimaryButton(
                            title: pages[pageIndex].buttonTitle,
                            action: onAdvance
                        )
                    }
                    .padding(.horizontal, GaiaSpacing.md)
                    .padding(.bottom, max(GaiaSpacing.xl, proxy.safeAreaInsets.bottom + GaiaSpacing.sm))
                }
            }
            .ignoresSafeArea()
        }
    }

    private var tutorialBackground: some View {
        Group {
            if pageIndex == 0 {
                LinearGradient(
                    colors: [
                        GaiaColor.oliveGreen100.opacity(0.65),
                        GaiaColor.paperWhite50
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            } else {
                GaiaColor.paperWhite50
            }
        }
    }
}

private struct OnboardingTutorialPageView: View {
    let page: OnboardingTutorialPage

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            switch page.media {
            case .none:
                Spacer(minLength: 0)
                content
            case .observeCard:
                VStack(alignment: .leading, spacing: GaiaSpacing.xl) {
                    Spacer().frame(height: 96)
                    OnboardingObserveTutorialCard()
                        .frame(maxWidth: .infinity, alignment: .center)
                    content
                    Spacer(minLength: 0)
                }
            case .journalCard:
                VStack(alignment: .leading, spacing: GaiaSpacing.xl) {
                    Spacer().frame(height: 96)
                    OnboardingJournalPreviewCard()
                        .frame(maxWidth: .infinity, alignment: .center)
                    content
                    Spacer(minLength: 0)
                }
            }
        }
        .padding(.horizontal, GaiaSpacing.md)
        .padding(.bottom, GaiaSpacing.lg)
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(page.title)
                .gaiaFont(.displayMedium)
                .foregroundStyle(GaiaColor.inkBlack500)

            Text(page.subtitle)
                .gaiaFont(.subheadline)
                .foregroundStyle(GaiaColor.inkBlack300)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct OnboardingObserveTutorialCard: View {
    @State private var animateIcon = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            GaiaAssetImage(name: "observe-photo-highlight")
                .frame(width: 306, height: 343)
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: OnboardingLayout.tutorialMediaCornerRadius,
                        style: .continuous
                    )
                )

            VStack {
                Spacer()

                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Coast Live Oak")
                            .gaiaFont(.title2)
                            .foregroundStyle(GaiaColor.inkBlack500)

                        Text("Quercus agrifolia")
                            .gaiaFont(.footnote)
                            .foregroundStyle(GaiaColor.inkBlack300)
                    }
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, GaiaSpacing.md)
                .padding(.vertical, GaiaSpacing.buttonHorizontalLarge)
                .frame(width: 202)
                .background(
                    RoundedRectangle(cornerRadius: GaiaRadius.lg, style: .continuous)
                        .fill(GaiaColor.paperWhite50)
                        .shadow(color: GaiaColor.shadowNav, radius: 18, x: 0, y: 10)
                )
                .padding(.leading, GaiaSpacing.lg - GaiaSpacing.xxs - GaiaSpacing.xxs)
                .padding(.bottom, OnboardingLayout.tutorialCardBottomPadding)
            }
            .frame(width: 306, height: 343, alignment: .bottomLeading)

            ZStack {
                Circle()
                    .fill(GaiaColor.oliveGreen500)

                GaiaIcon(kind: .observe(selected: true), size: 20)
                    .frame(width: 20, height: 20)
            }
            .frame(width: 54, height: 54)
            .scaleEffect(animateIcon ? 1 : 0.9)
            .shadow(color: GaiaColor.shadowNav, radius: 20, x: 0, y: 10)
            .padding(.trailing, OnboardingLayout.tutorialIconTrailing)
            .padding(.bottom, OnboardingLayout.tutorialIconBottom)
            .animation(.easeInOut(duration: 1.3).repeatForever(autoreverses: true), value: animateIcon)
        }
        .onAppear {
            animateIcon = true
        }
    }
}

private struct OnboardingJournalPreviewCard: View {
    private let profileGridLevels: [Int] = [
        4, 4, 0, 3, 3, 1, 3, 2, 3, 4, 2, 1,
        3, 1, 2, 1, 1, 2, 0, 2, 0, 3, 0, 1,
        1, 4, 4, 2, 3, 1, 0, 0, 0, 1, 1, 0,
        2, 3, 1, 3, 1, 1, 2, 0, 3, 2, 3, 2
    ]

    private let columns = Array(repeating: GridItem(.fixed(16), spacing: 4), count: 12)

    var body: some View {
        VStack(spacing: GaiaSpacing.md) {
            HStack(spacing: OnboardingLayout.journalMetricSpacing) {
                OnboardingJournalMetric(title: "Species", value: "63")
                OnboardingJournalMetric(title: "IDs", value: "23")
                OnboardingJournalMetric(title: "Projects", value: "4")
            }
            .frame(maxWidth: .infinity)

            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(Array(profileGridLevels.enumerated()), id: \.offset) { _, level in
                    RoundedRectangle(cornerRadius: GaiaRadius.sm, style: .continuous)
                        .fill(levelColor(level))
                        .frame(width: 16, height: 16)
                }
            }

            Rectangle()
                .fill(GaiaColor.oliveGreen100)
                .frame(height: 1)

            HStack(spacing: GaiaSpacing.pillHorizontal) {
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
                        .frame(width: proxy.size.width * 0.55)
                }
            }
            .frame(height: 6)
        }
        .padding(.horizontal, GaiaSpacing.md)
        .padding(.vertical, OnboardingLayout.journalCardVerticalPadding)
        .frame(width: 310)
        .background(
            RoundedRectangle(cornerRadius: GaiaRadius.storyCard, style: .continuous)
                .fill(GaiaColor.neutralWhite)
                .overlay(
                    RoundedRectangle(cornerRadius: GaiaRadius.storyCard, style: .continuous)
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

private struct OnboardingJournalMetric: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: GaiaSpacing.xxs) {
            Text(value)
                .gaiaFont(.title2)
                .foregroundStyle(GaiaColor.inkBlack500)

            Text(title)
                .gaiaFont(.caption)
                .foregroundStyle(GaiaColor.inkBlack300)
        }
        .frame(width: 40)
    }
}

private struct OnboardingFormContainer<Content: View>: View {
    let backAction: () -> Void
    @ViewBuilder let content: () -> Content

    var body: some View {
        GeometryReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    content()
                }
                .frame(minHeight: proxy.size.height, alignment: .top)
                .padding(.horizontal, GaiaSpacing.md)
            }
            .background(GaiaColor.paperWhite50)
            .overlay(alignment: .topLeading) {
                ToolbarGlassButton(icon: .back, accessibilityLabel: "Back", action: backAction)
                    .padding(.leading, GaiaSpacing.md)
                    .safeAreaPadding(.top, 8)
            }
        }
        .background(GaiaColor.paperWhite50.ignoresSafeArea())
    }
}

private struct OnboardingInputField: View {
    let label: String
    @Binding var text: String
    let prompt: String

    var body: some View {
        VStack(alignment: .leading, spacing: GaiaSpacing.sm) {
            Text(label)
                .gaiaFont(.footnote)
                .foregroundStyle(GaiaColor.inkBlack300)

            TextField("", text: $text, prompt: promptText)
                .gaiaFont(.subheadline)
                .foregroundStyle(GaiaColor.inkBlack500)
                .padding(.horizontal, GaiaSpacing.md)
                .padding(.vertical, GaiaSpacing.cardInset + GaiaSpacing.sm - GaiaSpacing.xxs)
                .background(fieldBackground)
        }
    }

    private var promptText: Text {
        Text(prompt)
    }

    private var fieldBackground: some View {
        RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
            .fill(GaiaColor.paperWhite50)
            .overlay(
                RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                    .stroke(GaiaColor.broccoliBrown200, lineWidth: 0.5)
            )
    }
}

private struct OnboardingSecureField: View {
    let label: String
    @Binding var text: String
    let prompt: String

    var body: some View {
        VStack(alignment: .leading, spacing: GaiaSpacing.sm) {
            Text(label)
                .gaiaFont(.footnote)
                .foregroundStyle(GaiaColor.inkBlack300)

            SecureField("", text: $text, prompt: promptText)
                .gaiaFont(.subheadline)
                .foregroundStyle(GaiaColor.inkBlack500)
                .padding(.horizontal, GaiaSpacing.md)
                .padding(.vertical, GaiaSpacing.cardInset + GaiaSpacing.sm - GaiaSpacing.xxs)
                .background(fieldBackground)
        }
    }

    private var promptText: Text {
        Text(prompt)
    }

    private var fieldBackground: some View {
        RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
            .fill(GaiaColor.paperWhite50)
            .overlay(
                RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                    .stroke(GaiaColor.broccoliBrown200, lineWidth: 0.5)
            )
    }
}

private struct OnboardingPasswordStrengthBar: View {
    let strength: Int

    var body: some View {
        HStack(spacing: GaiaSpacing.sm) {
            ForEach(0..<4, id: \.self) { index in
                Capsule(style: .continuous)
                    .fill(index < strength ? GaiaColor.oliveGreen500 : GaiaColor.oliveGreen200)
                    .frame(height: 4)
            }
        }
        .frame(maxWidth: .infinity)
        .animation(GaiaMotion.quickEase, value: strength)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Password strength")
        .accessibilityValue("\(strength) of 4")
    }
}

private struct OnboardingPrimaryButton: View {
    let title: String
    let action: () -> Void
    var isEnabled: Bool = true

    var body: some View {
        Button(action: action) {
            Text(title)
                .gaiaFont(.bodyBold)
                .foregroundStyle(GaiaColor.paperWhite50)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    Capsule(style: .continuous)
                        .fill(isEnabled ? GaiaColor.oliveGreen500 : GaiaColor.oliveGreen200)
                )
        }
        .buttonStyle(OnboardingPressStyle())
        .disabled(!isEnabled)
    }
}

private struct OnboardingSecondaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .gaiaFont(.body)
                .foregroundStyle(GaiaColor.paperWhite50)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    Capsule(style: .continuous)
                        .fill(GaiaColor.overlay.opacity(0.14))
                        .overlay(
                            Capsule(style: .continuous)
                                .stroke(GaiaColor.paperWhite50, lineWidth: 1)
                        )
                )
        }
        .buttonStyle(OnboardingPressStyle())
    }
}

private struct OnboardingPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.interactiveSpring(response: 0.2, dampingFraction: 0.82), value: configuration.isPressed)
    }
}

private struct OnboardingDivider: View {
    let label: String

    var body: some View {
        HStack(spacing: GaiaSpacing.cardInset) {
            Rectangle()
                .fill(GaiaColor.broccoliBrown200)
                .frame(height: 0.5)

            Text(label)
                .gaiaFont(.footnote)
                .foregroundStyle(GaiaColor.broccoliBrown500)

            Rectangle()
                .fill(GaiaColor.broccoliBrown200)
                .frame(height: 0.5)
        }
    }
}

private enum OnboardingSocialIcon {
    case apple
    case google
}

private struct OnboardingSocialButton: View {
    let title: String
    let icon: OnboardingSocialIcon
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: GaiaSpacing.sm) {
                Circle()
                    .fill(GaiaColor.inkBlack500)
                    .frame(width: 20, height: 20)

                Text(title)
                    .gaiaFont(.subheadline)
                    .foregroundStyle(GaiaColor.inkBlack500)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 45)
            .background(
                RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                    .fill(GaiaColor.paperWhite50)
                    .overlay(
                        RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                            .stroke(GaiaColor.broccoliBrown200, lineWidth: 0.5)
                    )
            )
        }
        .buttonStyle(OnboardingPressStyle())
    }
}

private struct OnboardingAvatarUploadCard: View {
    let displayName: String
    let selectedPhotoImage: UIImage?
    let selectedPreset: OnboardingAvatarOption?

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                .fill(GaiaColor.oliveGreen50)

            RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                .stroke(
                    GaiaColor.oliveGreen200,
                    style: StrokeStyle(lineWidth: 1, dash: [6, 4])
                )

            if let selectedPhotoImage {
                Image(uiImage: selectedPhotoImage)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous))
            } else if let selectedPreset {
                presetPreview(selectedPreset)
            } else {
                GaiaIcon(kind: .plus, size: GaiaSpacing.lg)
                    .frame(width: GaiaSpacing.lg, height: GaiaSpacing.lg)
            }
        }
        .frame(height: 96)
    }

    @ViewBuilder
    private func presetPreview(_ option: OnboardingAvatarOption) -> some View {
        if let imageName = option.imageName {
            GaiaProfileAvatar(
                imageName: imageName,
                size: 72,
                borderWidth: 0.5,
                strokeColor: GaiaColor.paperWhite50,
                backgroundColor: option.background
            )
        } else {
            ZStack {
                Circle()
                    .fill(option.background)
                Text(option.initials ?? displayName.initials)
                    .gaiaFont(.subheadSerifMedium)
                    .foregroundStyle(GaiaColor.oliveGreen700)
            }
            .frame(width: 72, height: 72)
        }
    }
}

private struct OnboardingAvatarTile: View {
    let option: OnboardingAvatarOption
    let isSelected: Bool

    var body: some View {
        RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
            .fill(isSelected ? GaiaColor.oliveGreen50 : GaiaColor.paperWhite50)
            .overlay(
                RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                    .stroke(isSelected ? GaiaColor.oliveGreen500 : GaiaColor.broccoliBrown200, lineWidth: isSelected ? 1.5 : 0.5)
            )
            .frame(height: 79)
            .overlay {
                avatarBody
            }
            .animation(GaiaMotion.quickEase, value: isSelected)
    }

    @ViewBuilder
    private var avatarBody: some View {
        if let imageName = option.imageName {
            GaiaProfileAvatar(
                imageName: imageName,
                size: 46,
                borderWidth: 0.5,
                strokeColor: GaiaColor.paperWhite50,
                backgroundColor: option.background
            )
        } else {
            ZStack {
                Circle()
                    .fill(option.background)
                Text(option.initials ?? "")
                    .gaiaFont(.subheadSerifMedium)
                    .foregroundStyle(GaiaColor.oliveGreen700)
            }
            .frame(width: 46, height: 46)
        }
    }
}

private struct OnboardingInterestChip: View {
    let title: String
    let isSelected: Bool

    var body: some View {
        Text(title)
            .gaiaFont(.subheadline)
            .foregroundStyle(isSelected ? GaiaColor.paperWhite50 : GaiaColor.oliveGreen500)
            .padding(.horizontal, GaiaSpacing.buttonHorizontalLarge)
            .frame(height: OnboardingLayout.interestChipHeight)
            .background(
                Capsule(style: .continuous)
                    .fill(isSelected ? GaiaColor.oliveGreen500 : GaiaColor.paperWhite50)
                    .overlay(
                        Capsule(style: .continuous)
                            .stroke(isSelected ? GaiaColor.oliveGreen500 : GaiaColor.oliveGreen500.opacity(0.6), lineWidth: 1)
                    )
            )
            .scaleEffect(isSelected ? 1.02 : 1)
            .animation(GaiaMotion.quickEase, value: isSelected)
    }
}

private struct OnboardingPageDots: View {
    let count: Int
    let currentIndex: Int
    let onSelect: (Int) -> Void

    var body: some View {
        HStack(spacing: GaiaSpacing.sm) {
            ForEach(0..<count, id: \.self) { index in
                Button {
                    onSelect(index)
                } label: {
                    Circle()
                        .fill(index <= currentIndex ? GaiaColor.oliveGreen500 : GaiaColor.oliveGreen200)
                        .frame(width: 8, height: 8)
                        .scaleEffect(index == currentIndex ? 1 : 0.92)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Page \(index + 1)")
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Tutorial pages")
    }
}

private struct OnboardingWrapLayout<Content: View>: View {
    let horizontalSpacing: CGFloat
    let verticalSpacing: CGFloat
    @ViewBuilder let content: () -> Content

    var body: some View {
        OnboardingFlowLayout(horizontalSpacing: horizontalSpacing, verticalSpacing: verticalSpacing) {
            content()
        }
    }
}

private struct OnboardingFlowLayout: Layout {
    let horizontalSpacing: CGFloat
    let verticalSpacing: CGFloat

    init(horizontalSpacing: CGFloat, verticalSpacing: CGFloat) {
        self.horizontalSpacing = horizontalSpacing
        self.verticalSpacing = verticalSpacing
    }

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        let availableWidth = proposal.width ?? 0
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            if x > 0, x + size.width > availableWidth {
                x = 0
                y += rowHeight + verticalSpacing
                rowHeight = 0
            }

            rowHeight = max(rowHeight, size.height)
            x += size.width + horizontalSpacing
        }

        return CGSize(width: availableWidth, height: y + rowHeight)
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        var origin = CGPoint(x: bounds.minX, y: bounds.minY)
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            if origin.x > bounds.minX, origin.x + size.width > bounds.maxX {
                origin.x = bounds.minX
                origin.y += rowHeight + verticalSpacing
                rowHeight = 0
            }

            subview.place(
                at: origin,
                proposal: ProposedViewSize(width: size.width, height: size.height)
            )

            rowHeight = max(rowHeight, size.height)
            origin.x += size.width + horizontalSpacing
        }
    }
}

private extension Edge {
    var opposite: Edge {
        switch self {
        case .leading:
            return .trailing
        case .trailing:
            return .leading
        case .top:
            return .bottom
        case .bottom:
            return .top
        }
    }
}

private extension String {
    var initials: String {
        split(separator: " ")
            .prefix(2)
            .compactMap { $0.first }
            .map(String.init)
            .joined()
            .uppercased()
    }
}
