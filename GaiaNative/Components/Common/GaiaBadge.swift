// figma: https://www.figma.com/design/4e4G3tnSR7AdPbf0jAYPP1/Gaia?node-id=2-123
import SwiftUI

struct GaiaBadge: View {
    enum Style: Hashable {
        case pill
        case animal(GaiaAnimalBadgeKind)
    }

    let title: String
    let style: Style
    var badgeSize: CGFloat
    var showsShadow: Bool

    init(
        title: String,
        style: Style = .pill,
        badgeSize: CGFloat = 48,
        showsShadow: Bool = false
    ) {
        self.title = title
        self.style = style
        self.badgeSize = badgeSize
        self.showsShadow = showsShadow
    }

    var body: some View {
        switch style {
        case .pill:
            pillBadge
        case .animal(let kind):
            animalBadge(kind: kind)
        }
    }

    private var pillBadge: some View {
        Text(title)
            .gaiaFont(.caption)
            .foregroundStyle(GaiaColor.olive)
            .padding(.horizontal, GaiaSpacing.cardInset)
            .padding(.vertical, GaiaSpacing.xs + GaiaSpacing.xxs)
            .background(GaiaColor.paperStrong, in: Capsule())
            .accessibilityLabel(title)
    }

    private func animalBadge(kind: GaiaAnimalBadgeKind) -> some View {
        ZStack {
            Circle()
                .fill(GaiaColor.paperStrong)

            Circle()
                .stroke(GaiaColor.broccoliBrown200, lineWidth: 1)

            GaiaAssetImage(name: kind.assetName, contentMode: .fit)
                .padding(GaiaSpacing.xs + GaiaSpacing.xxs)
        }
        .frame(width: badgeSize, height: badgeSize)
        .shadow(
            color: showsShadow ? GaiaShadow.navColor : .clear,
            radius: showsShadow ? GaiaShadow.navRadius : 0,
            x: 0,
            y: showsShadow ? GaiaSpacing.xxs : 0
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title.isEmpty ? kind.accessibilityLabel : title)
    }
}

enum GaiaAnimalBadgeKind: String, CaseIterable, Identifiable {
    case amphibian
    case bird
    case fish
    case fungi
    case insect
    case mammal
    case mollusk
    case plant
    case reptile

    var id: String { rawValue }

    var assetName: String {
        switch self {
        case .amphibian:
            return "badge/animal/amphibian"
        case .bird:
            return "badge/animal/bird"
        case .fish:
            return "badge/animal/fish"
        case .fungi:
            return "badge/animal/fungi"
        case .insect:
            return "badge/animal/insect"
        case .mammal:
            return "badge/animal/mammal"
        case .mollusk:
            return "badge/animal/mollusk"
        case .plant:
            return "badge/animal/plant"
        case .reptile:
            return "badge/animal/reptile"
        }
    }

    var accessibilityLabel: String {
        rawValue.capitalized
    }
}
