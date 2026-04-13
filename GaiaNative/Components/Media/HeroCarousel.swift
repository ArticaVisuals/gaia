// figma: https://www.figma.com/design/4e4G3tnSR7AdPbf0jAYPP1/Gaia?node-id=665-4594
import SwiftUI

struct HeroCarousel: View {
    let imageNames: [String]
    let title: String
    let subtitle: String

    @State private var selection = 0
    @State private var scrollOriginY: CGFloat?
    @State private var collapseProgress: CGFloat = 0
    @State private var measuredWidth: CGFloat = Layout.designWidth

    private let heroShadow = GaiaColor.shadowProjectHero.opacity(0.84)

    private enum Layout {
        // Mirrors the prototype's Figma-derived contracted hero blur behavior.
        static let designWidth: CGFloat = 402
        static let collapseDistance: CGFloat = 223
        static let maxBlurRadius: CGFloat = 7.253
        static let blurBleed: CGFloat = 3
        static let expandedBlurStart: CGFloat = 0.3322
        static let collapsedBlurStart: CGFloat = 58.5 / 228
        static let maxSoftnessRadius: CGFloat = 2.5
        static let maxSoftnessOpacity: CGFloat = 0.18
    }

    private struct ScrollSnapshot: Equatable {
        let minY: CGFloat
        let width: CGFloat
    }

    private var carouselImages: [String] {
        let preferredImages = Array(imageNames.prefix(4))
        return preferredImages.isEmpty ? imageNames : preferredImages
    }

    var body: some View {
        let clampedProgress = min(max(collapseProgress, 0), 1)

        VStack(spacing: GaiaSpacing.sm) {
            TabView(selection: $selection) {
                ForEach(Array(carouselImages.enumerated()), id: \.offset) { index, imageName in
                    ProgressiveBlurImage(
                        imageName: imageName,
                        blurRadius: interpolatedBlurRadius(for: clampedProgress),
                        blurBleed: interpolatedBlurBleed,
                        blurMaskStops: blurMaskStops(for: clampedProgress),
                        readabilityStops: readabilityStops,
                        softnessRadius: interpolatedSoftnessRadius(for: clampedProgress),
                        softnessOpacity: Layout.maxSoftnessOpacity * clampedProgress
                    )
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 262)
            .overlay(alignment: .bottomLeading) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .gaiaFont(.displayMedium)
                        .foregroundStyle(GaiaColor.paperStrong)
                        .lineLimit(1)

                    Text(subtitle)
                        .gaiaFont(.caption)
                        .foregroundStyle(GaiaColor.paperWhite50.opacity(0.95))
                        .textCase(.none)
                }
                .padding(.leading, GaiaSpacing.detailInset)
                .padding(.bottom, GaiaSpacing.cardInset)
                .frame(maxWidth: .infinity, alignment: .leading)
                .allowsHitTesting(false)
            }
            .clipShape(
                UnevenRoundedRectangle(
                    cornerRadii: .init(
                        topLeading: 0,
                        bottomLeading: 8,
                        bottomTrailing: 8,
                        topTrailing: 0
                    ),
                    style: .continuous
                )
            )
            .shadow(
                color: heroShadow,
                radius: 20,
                x: 0,
                y: 6
            )

            HStack(spacing: GaiaSpacing.sm) {
                ForEach(carouselImages.indices, id: \.self) { index in
                    Circle()
                        .fill(index == selection ? GaiaColor.olive : GaiaColor.oliveGreen200)
                        .frame(width: GaiaSpacing.sm, height: GaiaSpacing.sm)
                }
            }
            .padding(.horizontal, GaiaSpacing.lg)
            .frame(height: 16)
        }
        .onGeometryChange(for: ScrollSnapshot.self) { geometry in
            ScrollSnapshot(
                minY: geometry.frame(in: .global).minY,
                width: geometry.size.width
            )
        } action: { snapshot in
            updateCollapseProgress(with: snapshot)
        }
        .onDisappear {
            scrollOriginY = nil
            collapseProgress = 0
        }
    }

    private func updateCollapseProgress(with snapshot: ScrollSnapshot) {
        measuredWidth = snapshot.width
        let collapseDistance = max(1, Layout.collapseDistance * widthScale(for: snapshot.width))

        if let originY = scrollOriginY {
            let offset = max(0, originY - snapshot.minY)
            collapseProgress = min(offset / collapseDistance, 1)
        } else {
            scrollOriginY = snapshot.minY
            collapseProgress = 0
        }
    }

    private func widthScale(for width: CGFloat) -> CGFloat {
        max(width / Layout.designWidth, 0)
    }

    private func interpolatedBlurRadius(for progress: CGFloat) -> CGFloat {
        Layout.maxBlurRadius * widthScale(for: measuredWidth) * progress
    }

    private var interpolatedBlurBleed: CGFloat {
        Layout.blurBleed * widthScale(for: measuredWidth)
    }

    private func interpolatedSoftnessRadius(for progress: CGFloat) -> CGFloat {
        Layout.maxSoftnessRadius * widthScale(for: measuredWidth) * progress
    }

    private func blurMaskStops(for progress: CGFloat) -> [Gradient.Stop] {
        let start = Layout.expandedBlurStart + ((Layout.collapsedBlurStart - Layout.expandedBlurStart) * progress)
        return [
            .init(color: .clear, location: 0),
            .init(color: .clear, location: start),
            .init(color: .black, location: 1)
        ]
    }

    private var readabilityStops: [Gradient.Stop] {
        [
            .init(color: .clear, location: 0),
            .init(color: .clear, location: Layout.expandedBlurStart),
            .init(color: Color.black.opacity(0.65), location: 1)
        ]
    }
}
