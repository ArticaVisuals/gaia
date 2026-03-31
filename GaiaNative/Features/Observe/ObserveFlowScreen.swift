import SwiftUI

struct ObserveFlowScreen: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel = ObserveViewModel()

    var body: some View {
        Group {
            switch viewModel.step {
            case .camera:
                ObserveCameraScreen(
                    onClose: { appState.select(section: .explore) },
                    onShutter: { viewModel.step = .loading }
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
