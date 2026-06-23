import SwiftUI

struct MeterView: View {
    @EnvironmentObject private var model: GlowMateModel

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 18) {
                HeaderView(
                    title: model.localizer.text("meter.title"),
                    subtitle: model.localizer.text("meter.subtitle"),
                    badge: model.screenshotMode ? model.localizer.text("meter.demo") : nil
                )
                .padding(.top, 18)

                cameraPanel

                recommendationPanel
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 22)
        }
        .accessibilityIdentifier("screen.meter")
        .onAppear {
            if model.screenshotMode {
                #if DEBUG
                model.updateSample(ScreenshotMode.demoSample)
                #endif
            } else {
                model.camera.refreshPermission()
                model.camera.start()
            }
        }
        .onDisappear {
            if !model.screenshotMode {
                model.camera.stop()
            }
        }
        .onReceive(model.camera.$sample) { sample in
            guard !model.screenshotMode else { return }
            model.updateSample(sample)
        }
    }

    @ViewBuilder
    private var cameraPanel: some View {
        VStack(spacing: 12) {
            ZStack(alignment: .bottomLeading) {
                if model.screenshotMode {
                    DemoCameraArtwork()
                } else {
                    switch model.camera.permissionState {
                    case .authorized:
                        CameraPreview(session: model.camera.session)
                    case .unknown, .denied:
                        permissionView
                    }
                }

                Text(model.localizer.text(model.recommendation.issue.titleKey))
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(Theme.secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 9)
                    .background(Theme.page.opacity(0.94))
                    .clipShape(Capsule())
                    .padding(14)
            }
            .frame(height: 260)
            .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .stroke(Color.white.opacity(0.7), lineWidth: 1)
            )
            .shadow(color: Theme.coral.opacity(0.16), radius: 22, x: 0, y: 14)

            Button {
                model.takePhoto()
            } label: {
                Label(
                    model.camera.isCapturingPhoto ? model.localizer.text("camera.saving") : model.localizer.text("camera.takePhoto"),
                    systemImage: model.camera.isCapturingPhoto ? "hourglass" : "camera.fill"
                )
                .font(.headline.weight(.heavy))
                .foregroundStyle(canTakePhoto ? Color.white : Theme.muted)
                .frame(maxWidth: .infinity, minHeight: 52)
                .background(canTakePhoto ? Theme.primaryGradient : LinearGradient(colors: [Theme.cardSoft, Theme.cardSoft], startPoint: .leading, endPoint: .trailing))
                .clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 17, style: .continuous)
                        .stroke(canTakePhoto ? Color.clear : Theme.line, lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            .disabled(!canTakePhoto)
            .accessibilityIdentifier("meter.takePhoto")

            if model.camera.permissionState != .authorized && !model.screenshotMode {
                Text(model.localizer.text("camera.needCamera"))
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Theme.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private var canTakePhoto: Bool {
        if model.screenshotMode {
            return true
        }
        return model.camera.permissionState == .authorized && !model.camera.isCapturingPhoto
    }

    private var permissionView: some View {
        VStack(spacing: 14) {
            Image(systemName: "camera.viewfinder")
                .font(.system(size: 38, weight: .semibold))
                .foregroundStyle(Theme.coral)
            Text(model.localizer.text("meter.permission.title"))
                .font(.headline.weight(.heavy))
                .foregroundStyle(Theme.ink)
            Text(model.localizer.text("meter.permission.body"))
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            Button {
                model.camera.requestPermission()
            } label: {
                Text(model.localizer.text("meter.permission.button"))
                    .font(.subheadline.weight(.heavy))
                    .foregroundStyle(Color.white)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 12)
                    .background(Theme.primaryGradient)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.cardSoft)
    }

    private var recommendationPanel: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center, spacing: 14) {
                ZStack {
                    Circle()
                        .stroke(Theme.cardSoft, lineWidth: 10)
                    Circle()
                        .trim(from: 0, to: CGFloat(model.recommendation.score) / 100.0)
                        .stroke(Theme.primaryGradient, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    VStack(spacing: 2) {
                        Text("\(model.recommendation.score)")
                            .font(.system(size: 24, weight: .heavy, design: .rounded))
                            .foregroundStyle(Theme.ink)
                        Text(model.localizer.text("common.score"))
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(Theme.muted)
                    }
                }
                .frame(width: 86, height: 86)

                VStack(alignment: .leading, spacing: 7) {
                    Text(model.localizer.text(model.recommendation.headlineKey))
                        .font(.title3.weight(.heavy))
                        .foregroundStyle(Theme.ink)
                    Text(model.localizer.text(model.recommendation.reasonKey))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            HStack(spacing: 10) {
                MetricTile(label: model.localizer.text("light.brightness"), value: model.localizer.percent(model.recommendation.configuration.brightness))
                MetricTile(label: model.localizer.text("light.tone"), value: model.localizer.text(model.recommendation.configuration.tone.titleKey))
                MetricTile(label: model.localizer.text("light.distance"), value: model.localizer.text(model.recommendation.configuration.distanceKey))
            }

            Text(model.localizer.text(model.recommendation.configuration.guidanceKey))
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.secondary)
                .fixedSize(horizontal: false, vertical: true)

            PrimaryButton(title: model.localizer.text("meter.apply"), symbol: "checkmark.circle.fill") {
                model.applyRecommendation()
            }
        }
        .glowCard()
    }
}
