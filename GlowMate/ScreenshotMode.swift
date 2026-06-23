import Foundation

enum ScreenshotMode {
    static var isEnabled: Bool {
        #if DEBUG
        return ProcessInfo.processInfo.arguments.contains("--glowmate-screenshots")
        #else
        return false
        #endif
    }

    static var requestedTab: AppTab {
        #if DEBUG
        let arguments = ProcessInfo.processInfo.arguments
        if let index = arguments.firstIndex(of: "--glowmate-screen"),
           arguments.indices.contains(index + 1),
           let tab = AppTab(rawValue: arguments[index + 1]) {
            return tab
        }
        #endif
        return .meter
    }

    #if DEBUG
    static var demoState: PersistedState {
        let records = [
            LightingRecord(sourceKey: "scene.nightRoom", configuration: ScenePreset.nightRoom.configuration, score: 72),
            LightingRecord(sourceKey: "scene.selfie", configuration: ScenePreset.selfie.configuration, score: 81),
            LightingRecord(sourceKey: "scene.product", configuration: ScenePreset.product.configuration, score: 76)
        ]
        return PersistedState(
            selectedLanguage: .english,
            configuration: ScenePreset.selfie.configuration,
            records: records
        )
    }

    static var demoSample: LightingSample {
        LightingSample(luminance: 0.31, warmth: -0.10, centerLuminance: 0.27)
    }
    #endif
}
