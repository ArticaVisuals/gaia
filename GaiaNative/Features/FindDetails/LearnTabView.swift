import SwiftUI

struct LearnTabView: View {
    let species: Species
    let stories: [StoryCard]
    let onExpandMap: () -> Void
    let onOpenStory: (StoryCard) -> Void

    private var galleryImages: [String] {
        let images = species.galleryAssetNames
        guard images.count >= 5 else {
            return Array(images.dropFirst())
        }

        return [
            images[1],
            images[2],
            images[0],
            images[4],
            images[3]
        ]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            LearnSpeciesCard(species: species)
                .padding(.horizontal, GaiaSpacing.md)
                .padding(.top, GaiaSpacing.sm)

            section(title: "Gallery") {
                GalleryRail(imageNames: galleryImages)
            }

            section(title: "Stats") {
                StatsCard(species: species)
            }

            section(title: "Map") {
                LearnMapCard(action: onExpandMap)
            }

            section(title: "Stories") {
                ForEach(stories) { story in
                    StoryPreviewCard(story: story) {
                        onOpenStory(story)
                    }
                }
            }
        }
    }

    private func section<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle(title)
            content()
        }
        .padding(.horizontal, GaiaSpacing.md)
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(GaiaTypography.titleRegular)
            .foregroundStyle(GaiaColor.inkBlack300)
    }
}

private struct LearnMapCard: View {
    let action: () -> Void

    private struct PinPlacement {
        let x: CGFloat
        let y: CGFloat
    }

    private let pins: [PinPlacement] = [
        .init(x: 0.105, y: 0.201),
        .init(x: 0.208, y: 0.514),
        .init(x: 0.222, y: 0.617),
        .init(x: 0.251, y: 0.682),
        .init(x: 0.305, y: 0.565),
        .init(x: 0.310, y: 0.440),
        .init(x: 0.352, y: 0.318),
        .init(x: 0.635, y: 0.551),
        .init(x: 0.681, y: 0.734),
        .init(x: 0.874, y: 0.357),
        .init(x: 0.894, y: 0.201),
        .init(x: 0.924, y: 0.351)
    ]

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                GaiaAssetImage(name: "learn-map-fallback")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()

                GeometryReader { proxy in
                    ForEach(Array(pins.enumerated()), id: \.offset) { _, pin in
                        LearnMapPin()
                            .position(x: proxy.size.width * pin.x, y: proxy.size.height * pin.y)
                    }
                }
                .allowsHitTesting(false)

                LearnMapExpandBadge()
                    .padding(.top, 12)
                    .padding(.trailing, 12)
            }
        }
        .buttonStyle(.plain)
        .frame(height: 214)
        .clipShape(RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                .stroke(GaiaColor.broccoliBrown200, lineWidth: 0.5)
        )
        .shadow(color: GaiaShadow.mdColor, radius: GaiaShadow.mdRadius, x: 0, y: GaiaShadow.mdYOffset)
        .contentShape(RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous))
        .accessibilityElement(children: .contain)
        .accessibilityHint("Opens the expanded map")
    }
}

private struct LearnMapPin: View {
    private let pinSize: CGFloat = 22

    var body: some View {
        Circle()
            .fill(
                LinearGradient(
                    colors: [
                        Color(red: 116 / 255, green: 161 / 255, blue: 93 / 255),
                        Color(red: 110 / 255, green: 145 / 255, blue: 82 / 255)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: pinSize, height: pinSize)
            .shadow(color: Color(red: 116 / 255, green: 161 / 255, blue: 93 / 255, opacity: 0.55), radius: 2, x: 0.5, y: 1)
            .shadow(color: Color(red: 116 / 255, green: 161 / 255, blue: 93 / 255, opacity: 0.18), radius: 6, x: 0, y: 3)
    }
}

private struct LearnMapExpandBadge: View {
    var body: some View {
        ZStack {
            GaiaMaterialBackground(cornerRadius: 24, interactive: false)

            GaiaIcon(kind: .expand, size: 32, tint: GaiaColor.olive)
        }
        .frame(width: 48, height: 48)
        .clipShape(Circle())
        .accessibilityHidden(true)
    }
}
