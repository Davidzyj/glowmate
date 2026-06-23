import Foundation

enum LightingEngine {
    static func recommendation(for sample: LightingSample) -> LightRecommendation {
        let issue: LightingIssue
        if sample.centerLuminance < 0.34 {
            issue = .tooDark
        } else if sample.centerLuminance > 0.78 {
            issue = .tooBright
        } else if sample.warmth < -0.08 {
            issue = .cool
        } else if sample.warmth > 0.14 {
            issue = .yellow
        } else {
            issue = .balanced
        }

        let configuration: LightConfiguration
        let headlineKey: String

        switch issue {
        case .tooDark:
            configuration = LightConfiguration(
                brightness: min(1.0, 0.88 - sample.centerLuminance * 0.18),
                tone: sample.warmth < -0.04 ? .warmSkin : .naturalWhite,
                scene: .selfie,
                distanceKey: "distance.close",
                guidanceKey: "guidance.selfie"
            )
            headlineKey = "headline.tooDark"
        case .tooBright:
            configuration = LightConfiguration(
                brightness: 0.38,
                tone: .naturalWhite,
                scene: .selfie,
                distanceKey: "distance.meeting",
                guidanceKey: "guidance.meeting"
            )
            headlineKey = "headline.tooBright"
        case .cool:
            configuration = LightConfiguration(
                brightness: 0.72,
                tone: .warmSkin,
                scene: .selfie,
                distanceKey: "distance.close",
                guidanceKey: "guidance.selfie"
            )
            headlineKey = "headline.cool"
        case .yellow:
            configuration = LightConfiguration(
                brightness: 0.64,
                tone: .naturalWhite,
                scene: .food,
                distanceKey: "distance.table",
                guidanceKey: "guidance.food"
            )
            headlineKey = "headline.yellow"
        case .balanced:
            configuration = LightConfiguration(
                brightness: 0.58,
                tone: .naturalWhite,
                scene: .meeting,
                distanceKey: "distance.meeting",
                guidanceKey: "guidance.meeting"
            )
            headlineKey = "headline.balanced"
        }

        return LightRecommendation(
            score: score(for: sample, issue: issue),
            issue: issue,
            configuration: configuration,
            headlineKey: headlineKey,
            reasonKey: issue.reasonKey
        )
    }

    private static func score(for sample: LightingSample, issue: LightingIssue) -> Int {
        let target = 0.55
        let brightnessPenalty = abs(sample.centerLuminance - target) * 92
        let warmthPenalty = abs(sample.warmth) * 70
        let issuePenalty: Double = issue == .balanced ? 0 : 8
        let raw = 100 - brightnessPenalty - warmthPenalty - issuePenalty
        return max(32, min(98, Int(raw.rounded())))
    }
}
