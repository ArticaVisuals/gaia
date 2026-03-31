import SwiftUI

struct AnimationCoordinator {
    static func animate(_ action: @escaping () -> Void) {
        withAnimation(GaiaMotion.spring, action)
    }
}
