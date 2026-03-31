import SwiftUI

struct ObserveDetailsScreen: View {
    let onBack: () -> Void
    let onContinue: () -> Void

    var body: some View {
        ZStack(alignment: .top) {
            GaiaColor.surfacePrimary.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: GaiaSpacing.lg) {
                    HStack(spacing: GaiaSpacing.sm) {
                        GaiaAssetImage(name: "observe-photo-square")
                            .frame(width: 148, height: 148)
                            .clipShape(RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous))
                        GaiaAssetImage(name: "observe-photo-portrait")
                            .frame(maxWidth: .infinity)
                            .frame(height: 148)
                            .clipShape(RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous))
                    }

                    GaiaActionCard(accent: GaiaColor.brandAccent) {
                        HStack(alignment: .top, spacing: GaiaSpacing.md) {
                            GaiaAssetImage(name: "observe-suggestion-top")
                                .frame(width: 64, height: 64)
                                .clipShape(RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous))

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Suggested ID")
                                    .font(GaiaTypography.caption2)
                                    .foregroundStyle(GaiaColor.greyMuted)
                                Text("Coast Live Oak")
                                    .font(GaiaTypography.title)
                                    .foregroundStyle(GaiaColor.textPrimary)
                                Text("Quercus agrifolia")
                                    .font(GaiaTypography.footnote)
                                    .foregroundStyle(GaiaColor.textWarmSecondary)
                                Text("A strong match based on leaf edge, acorn form, and the nearby riparian habitat.")
                                    .font(GaiaTypography.subheadline)
                                    .foregroundStyle(GaiaColor.textSecondary)
                                    .padding(.top, 6)
                            }
                        }
                    }

                    GaiaDataCard {
                        VStack(alignment: .leading, spacing: GaiaSpacing.md) {
                            Text("Where it was found")
                                .font(GaiaTypography.titleRegular)
                                .foregroundStyle(GaiaColor.textPrimary)
                            GaiaAssetImage(name: "observe-location-map")
                                .frame(height: 160)
                                .clipShape(RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous))
                            Text("Pertuso Canyon, Pasadena")
                                .font(GaiaTypography.subheadlineMedium)
                                .foregroundStyle(GaiaColor.textPrimary)
                            Text("Captured at 2:15 PM near the creek edge.")
                                .font(GaiaTypography.subheadline)
                                .foregroundStyle(GaiaColor.textSecondary)
                        }
                    }

                    Button(action: onContinue) {
                        Text("Continue to Share")
                            .font(GaiaTypography.calloutMedium)
                            .foregroundStyle(GaiaColor.paperStrong)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(GaiaColor.olive, in: Capsule())
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, GaiaSpacing.md)
                .padding(.top, 92)
                .padding(.bottom, GaiaSpacing.xxxl)
            }

            HStack {
                ToolbarGlassButton(icon: .back, accessibilityLabel: "Back", action: onBack)
                Spacer()
            }
            .padding(.horizontal, GaiaSpacing.md)
            .safeAreaPadding(.top, 8)
        }
    }
}
