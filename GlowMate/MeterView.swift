import SwiftUI
import UIKit

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
                model.startFillLightCamera()
            } label: {
                Label(
                    model.localizer.text("camera.openMode"),
                    systemImage: "sparkles"
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
            .accessibilityIdentifier("meter.openFillLightCamera")

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

struct FillLightCameraView: View {
    @EnvironmentObject private var model: GlowMateModel
    let configuration: LightConfiguration
    @State private var originalBrightness: CGFloat = UIScreen.main.brightness

    var body: some View {
        ZStack(alignment: .bottom) {
            Theme.toneColor(configuration.tone)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                topBar
                    .padding(.top, 14)

                Spacer(minLength: 4)

                cameraFrame

                HStack(spacing: 10) {
                    FillLightMetricPill(label: model.localizer.text("light.brightness"), value: model.localizer.percent(configuration.brightness))
                    FillLightMetricPill(label: model.localizer.text("light.tone"), value: model.localizer.text(configuration.tone.titleKey))
                }
                .padding(.horizontal, 6)

                Spacer(minLength: 6)

                shutterButton
                    .padding(.bottom, 18)
            }
            .padding(.horizontal, 18)

            if let toastKey = model.toastKey {
                ToastView(text: model.localizer.text(toastKey))
                    .padding(.bottom, 140)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .accessibilityIdentifier("screen.fillLightCamera")
        .animation(.spring(response: 0.32, dampingFraction: 0.86), value: model.toastKey)
        .onAppear {
            originalBrightness = UIScreen.main.brightness
            UIScreen.main.brightness = CGFloat(configuration.brightness)
            UIApplication.shared.isIdleTimerDisabled = true
            if !model.screenshotMode {
                model.camera.start()
            }
        }
        .onDisappear {
            UIScreen.main.brightness = originalBrightness
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }

    private var topBar: some View {
        HStack(spacing: 12) {
            Button {
                model.isFillLightCameraPresented = false
            } label: {
                Image(systemName: "xmark")
                    .font(.headline.weight(.heavy))
                    .foregroundStyle(Theme.ink)
                    .frame(width: 42, height: 42)
                    .background(Theme.card.opacity(0.86))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 3) {
                Text(model.localizer.text("camera.modeTitle"))
                    .font(.headline.weight(.heavy))
                    .foregroundStyle(Theme.ink)
                Text(model.localizer.text("camera.recommendedLight"))
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Theme.secondary)
            }

            Spacer()
        }
    }

    private var cameraFrame: some View {
        GeometryReader { proxy in
            let width = min(proxy.size.width * 0.72, 318)
            let height = min(proxy.size.height, width * 1.18)

            ZStack {
                RoundedRectangle(cornerRadius: 34, style: .continuous)
                    .fill(Theme.card.opacity(0.36))
                    .frame(width: width + 34, height: height + 34)
                preview
                    .frame(width: width, height: height)
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .stroke(Color.white.opacity(0.82), lineWidth: 3)
                    )
                    .shadow(color: Theme.ink.opacity(0.18), radius: 24, x: 0, y: 14)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 372)
    }

    @ViewBuilder
    private var preview: some View {
        if model.screenshotMode {
            DemoCameraArtwork()
        } else {
            CameraPreview(session: model.camera.session)
        }
    }

    private var shutterButton: some View {
        Button {
            model.takePhoto()
        } label: {
            VStack(spacing: 9) {
                ZStack {
                    Circle()
                        .fill(Theme.card)
                        .frame(width: 70, height: 70)
                    Circle()
                        .stroke(Theme.ink.opacity(0.12), lineWidth: 1)
                        .frame(width: 70, height: 70)
                    Image(systemName: model.camera.isCapturingPhoto ? "hourglass" : "camera.fill")
                        .font(.system(size: 26, weight: .heavy))
                        .foregroundStyle(Theme.coral)
                }
                Text(model.camera.isCapturingPhoto ? model.localizer.text("camera.saving") : model.localizer.text("camera.takePhoto"))
                    .font(.subheadline.weight(.heavy))
                    .foregroundStyle(Theme.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
        }
        .buttonStyle(.plain)
        .disabled(!canCapture)
        .opacity(canCapture ? 1.0 : 0.54)
        .accessibilityIdentifier("fillLightCamera.shutter")
    }

    private var canCapture: Bool {
        if model.screenshotMode {
            return true
        }
        return model.camera.permissionState == .authorized && !model.camera.isCapturingPhoto
    }
}

private struct FillLightMetricPill: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption2.weight(.bold))
                .foregroundStyle(Theme.secondary)
            Text(value)
                .font(.subheadline.weight(.heavy))
                .foregroundStyle(Theme.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .frame(maxWidth: .infinity, minHeight: 54)
        .background(Theme.card.opacity(0.78))
        .clipShape(Capsule())
    }
}
