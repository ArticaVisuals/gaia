import SwiftUI

struct FindDetailsLearnFoundInMapArtwork: View {
    private struct MapDot: Identifiable {
        let id: Int
        let x: CGFloat
        let y: CGFloat
        let diameter: CGFloat
    }

    private struct MapLabel: Identifiable {
        let id: String
        let title: String
        let x: CGFloat
        let y: CGFloat
    }

    // These normalized points are tuned against the Figma "Found in" learn map card.
    private let dots: [MapDot] = [
        .init(id: 0, x: 0.175, y: 0.300, diameter: 12),
        .init(id: 1, x: 0.205, y: 0.286, diameter: 10),
        .init(id: 2, x: 0.228, y: 0.314, diameter: 12),
        .init(id: 3, x: 0.252, y: 0.272, diameter: 10),
        .init(id: 4, x: 0.265, y: 0.332, diameter: 11),
        .init(id: 5, x: 0.288, y: 0.284, diameter: 12),
        .init(id: 6, x: 0.302, y: 0.350, diameter: 11),
        .init(id: 7, x: 0.324, y: 0.302, diameter: 12),
        .init(id: 8, x: 0.344, y: 0.370, diameter: 13),
        .init(id: 9, x: 0.356, y: 0.330, diameter: 11),
        .init(id: 10, x: 0.372, y: 0.402, diameter: 12),
        .init(id: 11, x: 0.394, y: 0.454, diameter: 12),
        .init(id: 12, x: 0.420, y: 0.430, diameter: 11),
        .init(id: 13, x: 0.438, y: 0.502, diameter: 13),
        .init(id: 14, x: 0.456, y: 0.546, diameter: 12),
        .init(id: 15, x: 0.476, y: 0.602, diameter: 12),
        .init(id: 16, x: 0.492, y: 0.638, diameter: 13),
        .init(id: 17, x: 0.512, y: 0.690, diameter: 12),
        .init(id: 18, x: 0.530, y: 0.732, diameter: 14),
        .init(id: 19, x: 0.545, y: 0.782, diameter: 13),
        .init(id: 20, x: 0.565, y: 0.834, diameter: 13),
        .init(id: 21, x: 0.585, y: 0.876, diameter: 12),
        .init(id: 22, x: 0.602, y: 0.930, diameter: 14),
        .init(id: 23, x: 0.350, y: 0.552, diameter: 16),
        .init(id: 24, x: 0.318, y: 0.498, diameter: 13),
        .init(id: 25, x: 0.288, y: 0.446, diameter: 12),
        .init(id: 26, x: 0.260, y: 0.408, diameter: 11),
        .init(id: 27, x: 0.238, y: 0.376, diameter: 10),
        .init(id: 28, x: 0.214, y: 0.344, diameter: 11),
        .init(id: 29, x: 0.338, y: 0.250, diameter: 10),
        .init(id: 30, x: 0.376, y: 0.248, diameter: 10),
        .init(id: 31, x: 0.410, y: 0.272, diameter: 11),
        .init(id: 32, x: 0.444, y: 0.310, diameter: 11),
        .init(id: 33, x: 0.474, y: 0.360, diameter: 10),
        .init(id: 34, x: 0.446, y: 0.640, diameter: 12),
        .init(id: 35, x: 0.420, y: 0.690, diameter: 11),
        .init(id: 36, x: 0.448, y: 0.742, diameter: 11),
        .init(id: 37, x: 0.470, y: 0.790, diameter: 10)
    ]

    private let labels: [MapLabel] = [
        .init(id: "ventura", title: "Ventura", x: 0.115, y: 0.176),
        .init(id: "bakersfield", title: "Bakersfield", x: 0.248, y: 0.182),
        .init(id: "las-vegas", title: "Las Vegas", x: 0.565, y: 0.132),
        .init(id: "mojave", title: "Mojave Desert", x: 0.555, y: 0.310),
        .init(id: "prescott", title: "Prescott", x: 0.785, y: 0.390),
        .init(id: "kingman", title: "Kingman", x: 0.702, y: 0.282),
        .init(id: "arizona", title: "ARIZONA", x: 0.840, y: 0.510),
        .init(id: "phoenix", title: "Phoenix", x: 0.812, y: 0.664),
        .init(id: "yuma", title: "Yuma", x: 0.676, y: 0.804),
        .init(id: "rocky", title: "Rocky Point", x: 0.710, y: 0.955),
        .init(id: "mexicali", title: "Mexicali", x: 0.560, y: 0.850),
        .init(id: "tijuana", title: "Tijuana", x: 0.455, y: 0.950),
        .init(id: "san-luis", title: "San Luis Obispo", x: 0.138, y: 0.286),
        .init(id: "santa-barbara", title: "Santa Barbara", x: 0.205, y: 0.466),
        .init(id: "los-angeles", title: "Los Angeles", x: 0.305, y: 0.610)
    ]

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size

            ZStack {
                RoundedRectangle(cornerRadius: 0, style: .continuous)
                    .fill(GaiaColor.oliveGreen50)

                backgroundWash
                stateBoundary(in: size)

                ForEach(labels) { label in
                    Text(label.title)
                        .font(GaiaTypography.captionMedium)
                        .foregroundStyle(GaiaColor.oliveGreen700.opacity(0.78))
                        .position(x: size.width * label.x, y: size.height * label.y)
                }

                ForEach(dots) { dot in
                    Circle()
                        .fill(GaiaColor.olive.opacity(0.94))
                        .frame(width: dot.diameter, height: dot.diameter)
                        .position(x: size.width * dot.x, y: size.height * dot.y)
                }
            }
            .clipped()
        }
        .allowsHitTesting(false)
    }

    private var backgroundWash: some View {
        ZStack {
            LinearGradient(
                colors: [
                    GaiaColor.oliveGreen50.opacity(0.97),
                    GaiaColor.oliveGreen50.opacity(0.89)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Path { path in
                path.move(to: CGPoint(x: 210, y: -10))
                path.addCurve(
                    to: CGPoint(x: 350, y: 220),
                    control1: CGPoint(x: 320, y: 15),
                    control2: CGPoint(x: 382, y: 140)
                )
                path.addCurve(
                    to: CGPoint(x: 230, y: 210),
                    control1: CGPoint(x: 320, y: 248),
                    control2: CGPoint(x: 268, y: 248)
                )
                path.closeSubpath()
            }
            .fill(GaiaColor.paperStrong.opacity(0.48))

            Path { path in
                path.move(to: CGPoint(x: -10, y: 12))
                path.addCurve(
                    to: CGPoint(x: 156, y: 62),
                    control1: CGPoint(x: 44, y: 12),
                    control2: CGPoint(x: 112, y: 42)
                )
                path.addCurve(
                    to: CGPoint(x: 84, y: 108),
                    control1: CGPoint(x: 174, y: 88),
                    control2: CGPoint(x: 122, y: 120)
                )
                path.addCurve(
                    to: CGPoint(x: -10, y: 90),
                    control1: CGPoint(x: 38, y: 96),
                    control2: CGPoint(x: 4, y: 92)
                )
                path.closeSubpath()
            }
            .fill(GaiaColor.paperStrong.opacity(0.22))
        }
    }

    private func stateBoundary(in size: CGSize) -> some View {
        Path { path in
            path.move(to: CGPoint(x: size.width * 0.396, y: size.height * 0.06))
            path.addCurve(
                to: CGPoint(x: size.width * 0.442, y: size.height * 0.30),
                control1: CGPoint(x: size.width * 0.432, y: size.height * 0.12),
                control2: CGPoint(x: size.width * 0.456, y: size.height * 0.22)
            )
            path.addCurve(
                to: CGPoint(x: size.width * 0.506, y: size.height * 0.88),
                control1: CGPoint(x: size.width * 0.425, y: size.height * 0.50),
                control2: CGPoint(x: size.width * 0.476, y: size.height * 0.74)
            )
            path.addCurve(
                to: CGPoint(x: size.width * 0.544, y: size.height * 0.99),
                control1: CGPoint(x: size.width * 0.522, y: size.height * 0.93),
                control2: CGPoint(x: size.width * 0.534, y: size.height * 0.97)
            )
        }
        .stroke(GaiaColor.paperStrong.opacity(0.52), lineWidth: 1.1)
    }
}
