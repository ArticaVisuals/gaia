import SwiftUI

struct GaiaAsyncImage: View {
    let name: String

    var body: some View {
        GaiaAssetImage(name: name)
            .background(GaiaColor.paperWhite100)
            .clipShape(RoundedRectangle(cornerRadius: GaiaRadius.card, style: .continuous))
    }
}
