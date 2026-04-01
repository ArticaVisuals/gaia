import SwiftUI

struct LearnSpeciesCard: View {
    let species: Species

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(species.scientificName)
                .font(GaiaTypography.displayMedium)
                .foregroundStyle(GaiaColor.paperWhite50)
                .lineLimit(1)

            Text(species.summary)
                .font(.custom("Neue Haas Unica W1G", size: 12))
                .foregroundStyle(GaiaColor.paperWhite50)
                .lineSpacing(2.4)
                .fixedSize(horizontal: false, vertical: true)

            Button(action: {}) {
                Text("Read More")
                    .font(.custom("Neue Haas Unica W1G", size: 13))
                    .foregroundStyle(GaiaColor.olive)
                    .padding(.horizontal, 10)
                    .frame(height: 28)
                    .background(GaiaColor.paperWhite50, in: Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                .fill(GaiaColor.olive)
                .overlay(
                    RoundedRectangle(cornerRadius: GaiaRadius.md, style: .continuous)
                        .stroke(Color.black.opacity(0.1), lineWidth: 0.5)
                )
                .shadow(color: GaiaShadow.darkColor.opacity(0.55), radius: 18, x: 0, y: 5)
        )
    }
}
