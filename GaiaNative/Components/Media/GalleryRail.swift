import SwiftUI

struct GalleryRail: View {
    let imageNames: [String]

    private let itemWidths: [CGFloat] = [181, 112, 84, 181, 182]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(imageNames.enumerated()), id: \.offset) { index, imageName in
                    galleryImage(name: imageName, width: itemWidths[safe: index] ?? 112, index: index)
                }
            }
            .padding(.horizontal, GaiaSpacing.md)
        }
    }

    @ViewBuilder
    private func galleryImage(name: String, width: CGFloat, index: Int) -> some View {
        let shape = RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)

        GaiaAssetImage(name: name)
            .frame(width: width, height: 112)
            .scaleEffect(scale(for: index), anchor: anchor(for: index))
            .offset(x: xOffset(for: index), y: yOffset(for: index))
            .clipShape(shape)
            .overlay(
                shape
                    .stroke(GaiaColor.broccoliBrown200, lineWidth: 0.5)
            )
            .shadow(color: GaiaShadow.smallColor, radius: GaiaShadow.smallRadius, x: 0, y: GaiaShadow.smallYOffset)
    }

    private func scale(for index: Int) -> CGFloat {
        switch index {
        case 0: return 1.02
        case 1: return 1.03
        case 2: return 1.12
        case 3: return 1.08
        default: return 1.04
        }
    }

    private func xOffset(for index: Int) -> CGFloat {
        switch index {
        case 0: return -4
        case 1: return 4
        case 2: return 10
        case 3: return 2
        default: return 0
        }
    }

    private func yOffset(for index: Int) -> CGFloat {
        switch index {
        case 0: return 0
        case 1: return -1
        case 2: return 1
        default: return 0
        }
    }

    private func anchor(for index: Int) -> UnitPoint {
        switch index {
        case 0: return .center
        case 1: return .center
        case 2: return .trailing
        case 3: return .center
        default: return .center
        }
    }
}

private extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
