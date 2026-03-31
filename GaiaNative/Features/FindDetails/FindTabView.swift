import SwiftUI

struct FindTabView: View {
    let species: Species

    var body: some View {
        VStack(alignment: .leading, spacing: GaiaSpacing.lg) {
            GaiaSurfaceCard {
                HStack(spacing: GaiaSpacing.md) {
                    GaiaAssetImage(name: "find-avatar-alice")
                        .frame(width: 52, height: 52)
                        .clipShape(Circle())
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Alice Edwards")
                            .font(GaiaTypography.calloutMedium)
                            .foregroundStyle(GaiaColor.textPrimary)
                        Text("Observed near Pertuso Canyon")
                            .font(GaiaTypography.footnote)
                            .foregroundStyle(GaiaColor.textSecondary)
                    }
                    Spacer()
                    Text("2h ago")
                        .font(GaiaTypography.caption2)
                        .foregroundStyle(GaiaColor.greyMuted)
                }
            }

            HStack(spacing: GaiaSpacing.sm) {
                detailTile(
                    title: "Biome",
                    value: "Riparian Edge",
                    caption: "Pertuso Canyon",
                    imageName: "find-biome-riparian"
                )
                detailTile(
                    title: "Weather",
                    value: "69°",
                    caption: "Partly cloudy",
                    imageName: "find-weather-bg"
                )
            }

            GaiaSectionHeader(title: "Projects", eyebrow: "Contribute")

            VStack(spacing: GaiaSpacing.sm) {
                projectCard(
                    imageName: "find-project-creek",
                    title: "Creek Recovery Watch",
                    subtitle: "Track habitat health along the arroyo.",
                    badge: "4 observers"
                )
                projectCard(
                    imageName: "find-project-pollinator",
                    title: "Pollinator Corridor",
                    subtitle: "Map shelter trees supporting native insects.",
                    badge: "2 projects"
                )
            }
        }
        .padding(.horizontal, GaiaSpacing.md)
    }

    private func detailTile(title: String, value: String, caption: String, imageName: String) -> some View {
        GaiaDataCard {
            VStack(alignment: .leading, spacing: GaiaSpacing.sm) {
                Text(title)
                    .font(GaiaTypography.caption2)
                    .foregroundStyle(GaiaColor.greyMuted)
                GaiaAssetImage(name: imageName)
                    .frame(height: 94)
                    .clipShape(RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous))
                Text(value)
                    .font(GaiaTypography.title)
                    .foregroundStyle(GaiaColor.textPrimary)
                Text(caption)
                    .font(GaiaTypography.footnote)
                    .foregroundStyle(GaiaColor.textSecondary)
            }
        }
    }

    private func projectCard(imageName: String, title: String, subtitle: String, badge: String) -> some View {
        GaiaSurfaceCard {
            HStack(spacing: GaiaSpacing.md) {
                GaiaAssetImage(name: imageName)
                    .frame(width: 92, height: 92)
                    .clipShape(RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous))

                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(GaiaTypography.calloutMedium)
                        .foregroundStyle(GaiaColor.textPrimary)
                    Text(subtitle)
                        .font(GaiaTypography.footnote)
                        .foregroundStyle(GaiaColor.textSecondary)
                    GaiaPill(title: badge, fill: GaiaColor.oliveGreen50, foreground: GaiaColor.olive)
                }
                Spacer(minLength: 0)
            }
        }
    }
}
