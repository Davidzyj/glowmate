import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var model: GlowMateModel
    @Environment(\.openURL) private var openURL

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 18) {
                HeaderView(
                    title: model.localizer.text("settings.title"),
                    subtitle: model.localizer.text("settings.subtitle"),
                    badge: nil
                )
                .padding(.top, 18)

                languageCard
                infoCard
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 22)
        }
        .accessibilityIdentifier("screen.settings")
    }

    private var languageCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionLabel(title: model.localizer.text("settings.language"))

            Button {
                model.setLanguage(nil)
            } label: {
                languageRow(title: model.localizer.text("settings.system"), selected: model.selectedLanguage == nil)
            }
            .buttonStyle(.plain)

            ForEach(AppLanguage.allCases) { language in
                Button {
                    model.setLanguage(language)
                } label: {
                    languageRow(title: language.title, selected: model.selectedLanguage == language)
                }
                .buttonStyle(.plain)
            }
        }
        .glowCard()
    }

    private func languageRow(title: String, selected: Bool) -> some View {
        HStack {
            Text(title)
                .font(.subheadline.weight(.heavy))
                .foregroundStyle(Theme.ink)
            Spacer()
            Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(selected ? Theme.success : Theme.muted)
        }
        .padding(12)
        .background(Theme.cardSoft)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var infoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(model.localizer.text("settings.localOnly"))
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.secondary)
                .fixedSize(horizontal: false, vertical: true)

            settingLink(title: model.localizer.text("settings.privacy"), symbol: "hand.raised") {
                openURL(model.privacyURL())
            }

            settingLink(title: model.localizer.text("settings.support"), symbol: "questionmark.circle") {
                openURL(model.supportURL())
            }

            Text(model.localizer.text("settings.version"))
                .font(.caption.weight(.bold))
                .foregroundStyle(Theme.muted)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 4)
        }
        .glowCard()
    }

    private func settingLink(title: String, symbol: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: symbol)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(Theme.coral)
                    .frame(width: 34, height: 34)
                    .background(Theme.cardSoft)
                    .clipShape(Circle())
                Text(title)
                    .font(.subheadline.weight(.heavy))
                    .foregroundStyle(Theme.ink)
                Spacer()
                Image(systemName: "arrow.up.forward")
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(Theme.muted)
            }
            .padding(12)
            .background(Theme.card)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Theme.line, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
