import SwiftUI

struct ProfileImpactTab: View {
    let profile: ProfileSummary
    @EnvironmentObject private var contentStore: ContentStore
    @State private var showsExpandedMap = false

    var body: some View {
        VStack(alignment: .leading, spacing: GaiaSpacing.lg) {
            ImpactSummaryCard(profile: profile)

            GaiaDataCard {
                VStack(alignment: .leading, spacing: GaiaSpacing.md) {
                    Text("Stats")
                        .font(GaiaTypography.titleRegular)
                        .foregroundStyle(GaiaColor.textPrimary)
                    HStack {
                        stat(value: "63", label: "Species")
                        Spacer()
                        stat(value: "23", label: "IDs")
                        Spacer()
                        stat(value: "4", label: "Projects")
                    }
                }
            }

            GaiaActionCard(accent: GaiaColor.olive) {
                VStack(alignment: .leading, spacing: GaiaSpacing.sm) {
                    Text("Keep your streak going")
                        .font(GaiaTypography.calloutMedium)
                        .foregroundStyle(GaiaColor.textPrimary)
                    Text("You’ve logged 5 days in a row. Head outside today to make it 6 and earn the Week Warrior badge.")
                        .font(GaiaTypography.subheadline)
                        .foregroundStyle(GaiaColor.textSecondary)
                    GaiaPill(title: "Log an Observation", fill: GaiaColor.olive, foreground: GaiaColor.paperStrong)
                }
            }

            GaiaSectionHeader(title: "Your Impact")
            ZStack(alignment: .topTrailing) {
                ExploreMapView(observations: contentStore.observations, recenterRequestID: nil)
                    .frame(height: 220)
                    .clipShape(RoundedRectangle(cornerRadius: GaiaRadius.card, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: GaiaRadius.card, style: .continuous)
                            .stroke(GaiaColor.oliveGreen100, lineWidth: 1)
                    )
                ExpandMapButton {
                    showsExpandedMap = true
                }
                .padding(GaiaSpacing.sm)
            }

            GaiaDataCard {
                VStack(alignment: .leading, spacing: GaiaSpacing.md) {
                    Text("Medals")
                        .font(GaiaTypography.titleRegular)
                        .foregroundStyle(GaiaColor.textPrimary)
                    HStack(spacing: GaiaSpacing.sm) {
                        medal("Week Warrior")
                        medal("Tree Spotter")
                        medal("ID Helper")
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showsExpandedMap) {
            ImpactMapExpandedScreen(observations: contentStore.observations) {
                showsExpandedMap = false
            }
        }
    }

    private func stat(value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(GaiaTypography.title2Medium)
                .foregroundStyle(GaiaColor.textPrimary)
            Text(label)
                .font(GaiaTypography.footnote)
                .foregroundStyle(GaiaColor.textSecondary)
        }
    }

    private func medal(_ title: String) -> some View {
        GaiaPill(title: title, fill: GaiaColor.oliveGreen50, foreground: GaiaColor.olive)
    }
}
