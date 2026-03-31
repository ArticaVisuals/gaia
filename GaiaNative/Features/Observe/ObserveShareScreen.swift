import SwiftUI

struct ObserveShareScreen: View {
    let onBack: () -> Void
    let onDone: () -> Void

    var body: some View {
        ZStack(alignment: .top) {
            GaiaColor.surfacePrimary.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: GaiaSpacing.lg) {
                    Text("Share the moment")
                        .font(GaiaTypography.displayMedium)
                        .foregroundStyle(GaiaColor.textPrimary)
                    Text("Your observation is ready as a pair of story cards for sharing or saving.")
                        .font(GaiaTypography.subheadline)
                        .foregroundStyle(GaiaColor.textSecondary)

                    GaiaStoryCardSurface {
                        VStack(alignment: .leading, spacing: GaiaSpacing.md) {
                            GaiaAssetImage(name: "observe-share-impact")
                                .frame(height: 220)
                                .clipShape(RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous))
                            Text("My Impact")
                                .font(GaiaTypography.title1)
                                .foregroundStyle(GaiaColor.textPrimary)
                            Text("Each observation helps build a richer picture of urban ecology over time.")
                                .font(GaiaTypography.subheadline)
                                .foregroundStyle(GaiaColor.textSecondary)
                        }
                    }

                    GaiaStoryCardSurface {
                        VStack(alignment: .leading, spacing: GaiaSpacing.md) {
                            GaiaAssetImage(name: "observe-share-why-matters")
                                .frame(height: 220)
                                .clipShape(RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous))
                            Text("Why It Matters")
                                .font(GaiaTypography.title1)
                                .foregroundStyle(GaiaColor.textPrimary)
                            Text("Coast Live Oak anchors habitat, shade, and food webs across Southern California.")
                                .font(GaiaTypography.subheadline)
                                .foregroundStyle(GaiaColor.textSecondary)
                        }
                    }

                    Button(action: onDone) {
                        Text("Back to Explore")
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
