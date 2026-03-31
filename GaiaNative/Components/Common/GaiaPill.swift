import SwiftUI

struct GaiaPill: View {
    let title: String
    var fill: Color = GaiaColor.brown
    var foreground: Color = GaiaColor.paperStrong

    var body: some View {
        Text(title)
            .font(.custom("Neue Haas Unica W1G", size: 13))
            .foregroundStyle(foreground)
            .padding(.horizontal, 16)
            .frame(height: 29)
            .background(fill, in: Capsule())
    }
}
