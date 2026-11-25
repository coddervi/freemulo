import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem { Label("Главная", systemImage: "wave.3.right") }
                .tag(0)
            TagToolsView()
                .tabItem { Label("NFC", systemImage: "dot.radiowaves.left.and.right") }
                .tag(1)
            WalletPassView()
                .tabItem { Label("Wallet", systemImage: "wallet.pass") }
                .tag(2)
        }
        .tint(.white)
    }
}

private struct DashboardView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("FreeMulo")
                                .font(.system(size: 34, weight: .bold, design: .rounded))
                            Text("NFC tools & Wallet passes")
                                .foregroundStyle(.secondary)
                        }
                        HStack(spacing: 12) {
                            StatusTile(title: "NFC", value: "Готов", symbol: "dot.radiowaves.left.and.right")
                            StatusTile(title: "Режим", value: "Reader", symbol: "wave.3.right")
                        }
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Инструменты").font(.title2.bold())
                            NavigationLink { TagToolsView() } label: {
                                ActionRow(title: "Считать NFC-метку", subtitle: "NDEF и поддерживаемые теги", symbol: "sensor.tag.radiowaves.forward")
                            }
                            NavigationLink { WalletPassView() } label: {
                                ActionRow(title: "Wallet Pass", subtitle: "Информация о поддержке пропусков", symbol: "wallet.pass")
                            }
                        }
                    }
                    .padding(20)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

private struct StatusTile: View {
    let title: String
    let value: String
    let symbol: String
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: symbol).font(.title2)
            Text(title).font(.caption).foregroundStyle(.secondary)
            Text(value).font(.headline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 20))
    }
}

private struct ActionRow: View {
    let title: String
    let subtitle: String
    let symbol: String
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: symbol).font(.title2).frame(width: 44, height: 44)
                .background(.white.opacity(0.1), in: RoundedRectangle(cornerRadius: 13))
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.headline).foregroundStyle(.primary)
                Text(subtitle).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right").font(.caption.bold()).foregroundStyle(.secondary)
        }
        .padding(14)
        .background(.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 18))
    }
}

struct TagToolsView: View {
    @StateObject private var reader = NDEFReader()
    var body: some View {
        NavigationStack {
            List {
                Section("NFC Reader") {
                    Button {
                        reader.begin()
                    } label: {
                        Label("Сканировать метку", systemImage: "dot.radiowaves.left.and.right")
                    }
                    .disabled(!reader.available || reader.isReading)
                    if reader.isReading { ProgressView("Поднесите метку к iPhone") }
                    if let message = reader.message { Text(message).textSelection(.enabled) }
                    if let error = reader.error { Text(error).foregroundStyle(.red) }
                }
                Section {
                    Text("Запись NDEF будет добавлена после проверки записи на поддерживаемых метках. Не используйте инструмент с чужими или защищёнными картами.")
                        .font(.footnote).foregroundStyle(.secondary)
                }
            }
            .navigationTitle("NFC")
        }
    }
}

struct WalletPassView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Wallet") {
                    Label("Поддержка Wallet Pass", systemImage: "wallet.pass")
                    Text("FreeMulo сможет подготовить обычные информационные пропуска. Для добавления в Apple Wallet нужен подписанный Pass Type ID pass. Такой пропуск не является банковской картой и не поддерживает оплату.")
                        .font(.footnote).foregroundStyle(.secondary)
                }
                Section("Платёжные карты") {
                    Text("Банковские карты добавляются в Wallet только через авторизованное банком/платёжной системой provisioning. FreeMulo не создаёт и не эмулирует платёжные реквизиты.")
                        .font(.footnote).foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Wallet")
        }
    }
}
