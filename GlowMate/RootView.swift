import SwiftUI

struct RootView: View {
    @EnvironmentObject private var model: GlowMateModel

    var body: some View {
        ZStack(alignment: .bottom) {
            Theme.page.ignoresSafeArea()

            VStack(spacing: 0) {
                currentContent
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                TabBar()
            }

            if let toastKey = model.toastKey {
                ToastView(text: model.localizer.text(toastKey))
                    .padding(.bottom, 86)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.32, dampingFraction: 0.86), value: model.selectedTab)
        .animation(.spring(response: 0.32, dampingFraction: 0.86), value: model.toastKey)
        .fullScreenCover(isPresented: $model.isSoftLightPresented) {
            SoftLightFullScreenView(configuration: model.configuration)
                .environmentObject(model)
        }
    }

    @ViewBuilder
    private var currentContent: some View {
        switch model.selectedTab {
        case .meter:
            MeterView()
        case .light:
            LightView()
        case .scenes:
            ScenesView()
        case .records:
            RecordsView()
        case .settings:
            SettingsView()
        }
    }
}

struct TabBar: View {
    @EnvironmentObject private var model: GlowMateModel

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases) { tab in
                Button {
                    model.selectedTab = tab
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: tab.symbol)
                            .font(.system(size: 17, weight: .semibold))
                        Text(model.localizer.text(tab.titleKey))
                            .font(.caption2.weight(.bold))
                    }
                    .frame(maxWidth: .infinity, minHeight: 58)
                    .foregroundStyle(model.selectedTab == tab ? Theme.coral : Theme.muted)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("tab.\(tab.rawValue)")
            }
        }
        .padding(.horizontal, 12)
        .padding(.top, 8)
        .padding(.bottom, 10)
        .background(Theme.card.opacity(0.98))
        .overlay(Rectangle().fill(Theme.line).frame(height: 1), alignment: .top)
    }
}

struct ToastView: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.subheadline.weight(.bold))
            .foregroundStyle(Color.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Theme.primaryGradient)
            .clipShape(Capsule())
            .shadow(color: Theme.coral.opacity(0.24), radius: 14, x: 0, y: 8)
    }
}
