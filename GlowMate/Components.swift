import SwiftUI

struct HeaderView: View {
    let title: String
    let subtitle: String
    let badge: String?

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(alignment: .leading, spacing: 7) {
                Text(title)
                    .font(.system(size: 30, weight: .heavy, design: .rounded))
                    .foregroundStyle(Theme.ink)
                    .fixedSize(horizontal: false, vertical: true)
                Text(subtitle)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 8)
            if let badge {
                Text(badge)
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(Color.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 9)
                    .background(Theme.primaryGradient)
                    .clipShape(Capsule())
            }
        }
    }
}

struct MetricTile: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.caption.weight(.bold))
                .foregroundStyle(Theme.muted)
            Text(value)
                .font(.system(size: 20, weight: .heavy, design: .rounded))
                .foregroundStyle(Theme.ink)
                .minimumScaleFactor(0.72)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Theme.cardSoft)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

struct PrimaryButton: View {
    let title: String
    let symbol: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: symbol)
                .font(.headline.weight(.heavy))
                .foregroundStyle(Color.white)
                .frame(maxWidth: .infinity, minHeight: 52)
                .background(Theme.primaryGradient)
                .clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
                .shadow(color: Theme.coral.opacity(0.24), radius: 12, x: 0, y: 7)
        }
        .buttonStyle(.plain)
    }
}

struct SectionLabel: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.headline.weight(.heavy))
            .foregroundStyle(Theme.ink)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct DemoCameraArtwork: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.25, green: 0.22, blue: 0.22),
                    Color(red: 0.58, green: 0.39, blue: 0.26),
                    Color(red: 1.0, green: 0.70, blue: 0.42)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Circle()
                .fill(Color(red: 1.0, green: 0.80, blue: 0.65).opacity(0.72))
                .frame(width: 116, height: 116)
                .offset(y: -20)
            RoundedRectangle(cornerRadius: 60, style: .continuous)
                .stroke(Color.white.opacity(0.82), lineWidth: 2)
                .frame(width: 154, height: 210)
                .offset(y: 12)
            Circle()
                .stroke(Color.white.opacity(0.8), lineWidth: 18)
                .padding(16)
                .blur(radius: 0.2)
        }
    }
}
