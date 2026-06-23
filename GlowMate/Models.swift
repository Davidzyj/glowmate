import Foundation
import SwiftUI

enum AppTab: String, CaseIterable, Identifiable {
    case meter
    case light
    case scenes
    case records
    case settings

    var id: String { rawValue }

    var titleKey: String {
        switch self {
        case .meter: return "tab.meter"
        case .light: return "tab.light"
        case .scenes: return "tab.scenes"
        case .records: return "tab.records"
        case .settings: return "tab.settings"
        }
    }

    var symbol: String {
        switch self {
        case .meter: return "camera.metering.center.weighted"
        case .light: return "circle.lefthalf.filled"
        case .scenes: return "square.grid.2x2"
        case .records: return "clock.arrow.circlepath"
        case .settings: return "gearshape"
        }
    }
}

enum AppLanguage: String, CaseIterable, Identifiable, Codable {
    case english = "en"
    case simplifiedChinese = "zh-Hans"
    case japanese = "ja"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .english: return "English"
        case .simplifiedChinese: return "简体中文"
        case .japanese: return "日本語"
        }
    }

    static func inferred() -> AppLanguage {
        let preferred = Locale.preferredLanguages.map { $0.lowercased() }
        if preferred.contains(where: { $0.hasPrefix("zh-hans") || $0 == "zh" || $0.hasPrefix("zh-cn") }) {
            return .simplifiedChinese
        }
        if preferred.contains(where: { $0.hasPrefix("ja") }) {
            return .japanese
        }
        return .english
    }
}

enum LightTone: String, CaseIterable, Identifiable, Codable {
    case warmSkin
    case naturalWhite
    case coolWhite
    case blush

    var id: String { rawValue }

    var titleKey: String {
        switch self {
        case .warmSkin: return "tone.warmSkin"
        case .naturalWhite: return "tone.naturalWhite"
        case .coolWhite: return "tone.coolWhite"
        case .blush: return "tone.blush"
        }
    }
}

enum LightingIssue: String, Codable {
    case tooDark
    case tooBright
    case cool
    case yellow
    case balanced

    var titleKey: String {
        switch self {
        case .tooDark: return "issue.tooDark"
        case .tooBright: return "issue.tooBright"
        case .cool: return "issue.cool"
        case .yellow: return "issue.yellow"
        case .balanced: return "issue.balanced"
        }
    }

    var reasonKey: String {
        switch self {
        case .tooDark: return "reason.tooDark"
        case .tooBright: return "reason.tooBright"
        case .cool: return "reason.cool"
        case .yellow: return "reason.yellow"
        case .balanced: return "reason.balanced"
        }
    }
}

enum ScenePreset: String, CaseIterable, Identifiable, Codable {
    case selfie
    case food
    case product
    case meeting
    case nightRoom

    var id: String { rawValue }

    var titleKey: String {
        switch self {
        case .selfie: return "scene.selfie"
        case .food: return "scene.food"
        case .product: return "scene.product"
        case .meeting: return "scene.meeting"
        case .nightRoom: return "scene.nightRoom"
        }
    }

    var subtitleKey: String {
        switch self {
        case .selfie: return "scene.selfie.subtitle"
        case .food: return "scene.food.subtitle"
        case .product: return "scene.product.subtitle"
        case .meeting: return "scene.meeting.subtitle"
        case .nightRoom: return "scene.nightRoom.subtitle"
        }
    }

    var configuration: LightConfiguration {
        switch self {
        case .selfie:
            return LightConfiguration(brightness: 0.72, tone: .warmSkin, scene: self, distanceKey: "distance.close", guidanceKey: "guidance.selfie")
        case .food:
            return LightConfiguration(brightness: 0.68, tone: .naturalWhite, scene: self, distanceKey: "distance.table", guidanceKey: "guidance.food")
        case .product:
            return LightConfiguration(brightness: 0.82, tone: .coolWhite, scene: self, distanceKey: "distance.product", guidanceKey: "guidance.product")
        case .meeting:
            return LightConfiguration(brightness: 0.55, tone: .naturalWhite, scene: self, distanceKey: "distance.meeting", guidanceKey: "guidance.meeting")
        case .nightRoom:
            return LightConfiguration(brightness: 0.78, tone: .warmSkin, scene: self, distanceKey: "distance.close", guidanceKey: "guidance.nightRoom")
        }
    }
}

struct LightConfiguration: Codable, Equatable {
    var brightness: Double
    var tone: LightTone
    var scene: ScenePreset?
    var distanceKey: String
    var guidanceKey: String

    static let defaultValue = LightConfiguration(
        brightness: 0.72,
        tone: .warmSkin,
        scene: .selfie,
        distanceKey: "distance.close",
        guidanceKey: "guidance.selfie"
    )
}

struct LightRecommendation: Codable, Equatable {
    var score: Int
    var issue: LightingIssue
    var configuration: LightConfiguration
    var headlineKey: String
    var reasonKey: String
}

struct LightingSample: Equatable {
    var luminance: Double
    var warmth: Double
    var centerLuminance: Double

    static let neutral = LightingSample(luminance: 0.46, warmth: 0.02, centerLuminance: 0.42)
}

struct LightingRecord: Identifiable, Codable, Equatable {
    var id: UUID
    var createdAt: Date
    var sourceKey: String
    var configuration: LightConfiguration
    var score: Int

    init(id: UUID = UUID(), createdAt: Date = Date(), sourceKey: String, configuration: LightConfiguration, score: Int) {
        self.id = id
        self.createdAt = createdAt
        self.sourceKey = sourceKey
        self.configuration = configuration
        self.score = score
    }
}

struct PersistedState: Codable {
    var selectedLanguage: AppLanguage?
    var configuration: LightConfiguration
    var records: [LightingRecord]

    static let empty = PersistedState(
        selectedLanguage: nil,
        configuration: .defaultValue,
        records: []
    )
}
