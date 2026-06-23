import SwiftUI

struct RecordsView: View {
    @EnvironmentObject private var model: GlowMateModel

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 18) {
                HeaderView(
                    title: model.localizer.text("records.title"),
                    subtitle: model.localizer.text("records.subtitle"),
                    badge: "\(model.records.count)"
                )
                .padding(.top, 18)

                if model.records.isEmpty {
                    emptyState
                } else {
                    VStack(spacing: 12) {
                        ForEach(model.records) { record in
                            recordRow(record)
                        }
                    }

                    Button(role: .destructive) {
                        model.clearRecords()
                    } label: {
                        Label(model.localizer.text("records.clear"), systemImage: "trash")
                            .font(.subheadline.weight(.heavy))
                            .foregroundStyle(Theme.danger)
                            .frame(maxWidth: .infinity, minHeight: 48)
                            .background(Theme.card)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 22)
        }
        .accessibilityIdentifier("screen.records")
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "clock.badge.questionmark")
                .font(.system(size: 38, weight: .semibold))
                .foregroundStyle(Theme.coral)
            Text(model.localizer.text("records.empty"))
                .font(.headline.weight(.bold))
                .foregroundStyle(Theme.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding(28)
        .glowCard()
    }

    private func recordRow(_ record: LightingRecord) -> some View {
        Button {
            model.restoreRecord(record)
        } label: {
            HStack(spacing: 13) {
                ZStack {
                    Circle()
                        .fill(Theme.toneColor(record.configuration.tone))
                    Text("\(record.score)")
                        .font(.caption.weight(.heavy))
                        .foregroundStyle(Theme.ink)
                }
                .frame(width: 44, height: 44)

                VStack(alignment: .leading, spacing: 5) {
                    Text(model.localizer.text(record.sourceKey))
                        .font(.headline.weight(.heavy))
                        .foregroundStyle(Theme.ink)
                    Text("\(model.localizer.percent(record.configuration.brightness)) · \(model.localizer.text(record.configuration.tone.titleKey))")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Theme.muted)
                }
                Spacer()
                Image(systemName: "arrow.up.forward.circle.fill")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Theme.coral)
            }
            .padding(14)
            .background(Theme.card)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(Theme.line, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
