import SwiftUI

struct ObserveFlowScreen: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel = ObserveViewModel()

    var body: some View {
        if #available(iOS 18.0, *) {
            flowContent
                .toolbarVisibility(.hidden, for: .tabBar)
        } else {
            flowContent
        }
    }

    private var flowContent: some View {
        Group {
            switch viewModel.step {
            case .camera:
                ObserveCameraScreen(
                    onClose: { appState.select(section: .explore) },
                    onShutter: { viewModel.step = .loading },
                    onPhotoImport: { viewModel.step = .loading },
                    onAudioSend: { clipURL in
                        viewModel.submitAudioObservation(url: clipURL)
                    }
                )
            case .loading:
                ObserveLoadingScreen {
                    viewModel.step = .details
                }
            case .details:
                ObserveDetailsScreen(
                    onBack: { viewModel.step = .camera },
                    onContinue: { viewModel.step = .share }
                )
            case .share:
                ObserveShareScreen(
                    onBack: { viewModel.step = .details },
                    onDone: { appState.select(section: .explore) }
                )
            }
        }
        .animation(GaiaMotion.softSpring, value: viewModel.step)
    }
}
