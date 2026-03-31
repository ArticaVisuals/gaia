import SwiftUI

enum GaiaMotion {
    static let spring = Animation.spring(response: 0.42, dampingFraction: 0.88)
    static let softSpring = Animation.spring(response: 0.55, dampingFraction: 0.9)
    static let quickEase = Animation.easeInOut(duration: 0.22)
}
