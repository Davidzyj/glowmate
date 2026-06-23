import Foundation
import SwiftUI

final class GlowMateModel: ObservableObject {
    @Published var selectedTab: AppTab
    @Published var selectedLanguage: AppLanguage?
    @Published var configuration: LightConfiguration
    @Published var records: [LightingRecord]
    @Published var recommendation: LightRecommendation
    @Published var toastKey: String?
    @Published var isSoftLightPresented = false

    let camera = CameraMeter()
    let torch = TorchController()
    let screenshotMode: Bool

    private let persistence: PersistenceProviding

    var language: AppLanguage {
        selectedLanguage ?? AppLanguage.inferred()
    }

    var localizer: Localizer {
        Localizer(language: language)
    }

    init() {
        #if DEBUG
        let isScreenshot = ScreenshotMode.isEnabled
        screenshotMode = isScreenshot
        selectedTab = isScreenshot ? ScreenshotMode.requestedTab : .meter
        persistence = isScreenshot ? MemoryPersistence(state: ScreenshotMode.demoState) : UserDefaultsPersistence()
        #else
        let isScreenshot = false
        screenshotMode = false
        selectedTab = .meter
        persistence = UserDefaultsPersistence()
        #endif

        let state = persistence.load()
        selectedLanguage = state.selectedLanguage
        configuration = state.configuration
        records = state.records
        #if DEBUG
        let initialSample = isScreenshot ? ScreenshotMode.demoSample : .neutral
        #else
        let initialSample = LightingSample.neutral
        #endif
        recommendation = LightingEngine.recommendation(for: initialSample)

        #if DEBUG
        if isScreenshot {
            selectedLanguage = state.selectedLanguage ?? .english
        }
        #endif
    }

    func updateSample(_ sample: LightingSample) {
        recommendation = LightingEngine.recommendation(for: sample)
    }

    func applyRecommendation() {
        configuration = recommendation.configuration
        addRecord(sourceKey: recommendation.issue.titleKey, configuration: configuration, score: recommendation.score)
        selectedTab = .light
        showToast("meter.applied")
        save()
    }

    func updateBrightness(_ brightness: Double) {
        configuration.brightness = brightness
        showToast("light.saved")
        save()
    }

    func selectTone(_ tone: LightTone) {
        configuration.tone = tone
        showToast("light.saved")
        save()
    }

    func startSoftLight() {
        isSoftLightPresented = true
        addRecord(sourceKey: configuration.scene?.titleKey ?? configuration.tone.titleKey, configuration: configuration, score: recommendation.score)
        save()
    }

    func selectScene(_ scene: ScenePreset) {
        configuration = scene.configuration
        addRecord(sourceKey: scene.titleKey, configuration: configuration, score: recommendation.score)
        selectedTab = .light
        showToast("scene.selected")
        save()
    }

    func restoreRecord(_ record: LightingRecord) {
        configuration = record.configuration
        selectedTab = .light
        showToast("records.restored")
        save()
    }

    func clearRecords() {
        records = []
        save()
    }

    func setLanguage(_ language: AppLanguage?) {
        selectedLanguage = language
        showToast("settings.languageChanged")
        save()
    }

    func toggleTorch() {
        let target = !torch.isOn
        torch.setTorch(active: target, level: configuration.brightness)
        showToast(target ? "light.torch.on" : "light.torch.off")
    }

    func privacyURL() -> URL {
        URL(string: "https://davidzyj.github.io/glowmate/\(language.rawValue)/privacy.html")!
    }

    func supportURL() -> URL {
        URL(string: "https://davidzyj.github.io/glowmate/\(language.rawValue)/support.html")!
    }

    private func addRecord(sourceKey: String, configuration: LightConfiguration, score: Int) {
        var next = records
        next.insert(LightingRecord(sourceKey: sourceKey, configuration: configuration, score: score), at: 0)
        records = Array(next.prefix(10))
    }

    private func save() {
        let state = PersistedState(selectedLanguage: selectedLanguage, configuration: configuration, records: records)
        persistence.save(state)
    }

    private func showToast(_ key: String) {
        toastKey = key
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) { [weak self] in
            if self?.toastKey == key {
                self?.toastKey = nil
            }
        }
    }
}
