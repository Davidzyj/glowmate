import SwiftUI

struct ScenesView: View {
    @EnvironmentObject private var model: GlowMateModel

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 18) {
                HeaderView(
                    title: model.localizer.text("scene.title"),
                    subtitle: model.localizer.text("scene.subtitle"),
                    badge: model.configuration.scene.map { model.localizer.text($0.titleKey) }
                )
                .padding(.top, 18)

                VStack(spacing: 12) {
                    ForEach(ScenePreset.allCases) { scene in
                        sceneRow(scene)
                    }
                }
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 22)
        }
        .accessibilityIdentifier("screen.scenes")
    }

    private func sceneRow(_ scene: ScenePreset) -> some View {
        let isSelected = model.configuration.scene == scene
        return Button {
            model.selectScene(scene)
        } label: {
            HStack(spacing: 13) {
                Image(systemName: icon(for: scene))
                    .font(.title3.weight(.bold))
                    .foregroundStyle(isSelected ? Color.white : Theme.coral)
                    .frame(width: 42, height: 42)
                    .background(isSelected ? AnyShapeStyle(Theme.primaryGradient) : AnyShapeStyle(Theme.cardSoft))
                    .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))

                VStack(alignment: .leading, spacing: 5) {
                    Text(model.localizer.text(scene.titleKey))
                        .font(.headline.weight(.heavy))
                        .foregroundStyle(Theme.ink)
                    Text(model.localizer.text(scene.subtitleKey))
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Theme.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 5) {
                    Text(model.localizer.percent(scene.configuration.brightness))
                        .font(.headline.weight(.heavy))
                        .foregroundStyle(Theme.ink)
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(isSelected ? Theme.success : Theme.muted)
                }
            }
            .padding(14)
            .background(Theme.card)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(isSelected ? Theme.coral.opacity(0.35) : Theme.line, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private func icon(for scene: ScenePreset) -> String {
        switch scene {
        case .selfie: return "person.crop.circle"
        case .food: return "fork.knife"
        case .product: return "shippingbox"
        case .meeting: return "video"
        case .nightRoom: return "moon.stars"
        }
    }
}
