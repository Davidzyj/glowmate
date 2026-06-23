import SwiftUI
import UIKit

struct LightView: View {
    @EnvironmentObject private var model: GlowMateModel

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 18) {
                HeaderView(
                    title: model.localizer.text("light.title"),
                    subtitle: model.localizer.text("light.subtitle"),
                    badge: model.localizer.text("light.saved")
                )
                .padding(.top, 18)

                controlCard
                torchCard
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 22)
        }
        .accessibilityIdentifier("screen.light")
        .onAppear {
            model.torch.refreshAvailability()
        }
    }

    private var controlCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 10) {
                MetricTile(label: model.localizer.text("light.brightness"), value: model.localizer.percent(model.configuration.brightness))
                MetricTile(label: model.localizer.text("light.tone"), value: model.localizer.text(model.configuration.tone.titleKey))
                MetricTile(label: model.localizer.text("light.distance"), value: model.localizer.text(model.configuration.distanceKey))
            }

            VStack(alignment: .leading, spacing: 8) {
                SectionLabel(title: model.localizer.text("light.brightness"))
                Slider(value: Binding(
                    get: { model.configuration.brightness },
                    set: { model.updateBrightness($0) }
                ), in: 0.15...1.0)
                .tint(Theme.coral)
            }

            VStack(alignment: .leading, spacing: 12) {
                SectionLabel(title: model.localizer.text("light.tone"))
                HStack(spacing: 12) {
                    ForEach(LightTone.allCases) { tone in
                        Button {
                            model.selectTone(tone)
                        } label: {
                            VStack(spacing: 8) {
                                Circle()
                                    .fill(Theme.toneColor(tone))
                                    .frame(width: 42, height: 42)
                                    .overlay(
                                        Circle()
                                            .stroke(model.configuration.tone == tone ? Theme.coral : Color.white, lineWidth: 3)
                                    )
                                    .shadow(color: Theme.coral.opacity(0.16), radius: 8, x: 0, y: 5)
                                Text(model.localizer.text(tone.titleKey))
                                    .font(.caption2.weight(.bold))
                                    .foregroundStyle(Theme.secondary)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.65)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            Text(model.localizer.text(model.configuration.guidanceKey))
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.secondary)
                .fixedSize(horizontal: false, vertical: true)

            PrimaryButton(title: model.localizer.text("light.start"), symbol: "sparkles") {
                model.startSoftLight()
            }
        }
        .glowCard()
    }

    private var torchCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "flashlight.on.fill")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(model.torch.isAvailable ? Theme.coral : Theme.muted)
                    .frame(width: 38, height: 38)
                    .background(Theme.cardSoft)
                    .clipShape(Circle())
                VStack(alignment: .leading, spacing: 4) {
                    Text(model.localizer.text("light.torch"))
                        .font(.headline.weight(.heavy))
                        .foregroundStyle(Theme.ink)
                    Text(model.torch.isAvailable ? model.localizer.text(model.torch.isOn ? "light.torch.on" : "light.torch.off") : model.localizer.text("light.torch.unavailable"))
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Theme.muted)
                }
                Spacer()
                Toggle("", isOn: Binding(
                    get: { model.torch.isOn },
                    set: { _ in model.toggleTorch() }
                ))
                .labelsHidden()
                .tint(Theme.coral)
                .disabled(!model.torch.isAvailable)
            }
        }
        .glowCard()
    }
}

struct SoftLightFullScreenView: View {
    @EnvironmentObject private var model: GlowMateModel
    let configuration: LightConfiguration
    @State private var originalBrightness: CGFloat = UIScreen.main.brightness

    var body: some View {
        ZStack {
            Theme.toneColor(configuration.tone)
                .ignoresSafeArea()
            VStack(spacing: 18) {
                Spacer()
                Text(model.localizer.text("light.full.title"))
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundStyle(Theme.ink)
                Text(model.localizer.percent(configuration.brightness))
                    .font(.system(size: 54, weight: .heavy, design: .rounded))
                    .foregroundStyle(Theme.ink)
                Text(model.localizer.text(configuration.tone.titleKey))
                    .font(.headline.weight(.heavy))
                    .foregroundStyle(Theme.secondary)
                Spacer()
                Button {
                    model.isSoftLightPresented = false
                } label: {
                    Label(model.localizer.text("light.close"), systemImage: "xmark.circle.fill")
                        .font(.headline.weight(.heavy))
                        .foregroundStyle(Color.white)
                        .padding(.horizontal, 22)
                        .padding(.vertical, 14)
                        .background(Theme.ink)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .padding(.bottom, 28)
            }
        }
        .accessibilityIdentifier("screen.softLight")
        .onAppear {
            originalBrightness = UIScreen.main.brightness
            UIScreen.main.brightness = CGFloat(configuration.brightness)
            UIApplication.shared.isIdleTimerDisabled = true
        }
        .onDisappear {
            UIScreen.main.brightness = originalBrightness
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }
}
