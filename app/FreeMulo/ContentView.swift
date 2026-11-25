import SwiftUI
import PassKit
import UniformTypeIdentifiers

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
                            StatusTile(title: "Wallet", value: "PassKit", symbol: "wallet.pass")
                        }
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Инструменты").font(.title2.bold())
                            NavigationLink { TagToolsView() } label: {
                                ActionRow(title: "Считать NFC-метку", subtitle: "NDEF и поддерживаемые теги", symbol: "sensor.tag.radiowaves.forward")
                            }
                            NavigationLink { WalletPassView() } label: {
                                ActionRow(title: "Добавить в Apple Wallet", subtitle: "Импорт подписанного .pkpass", symbol: "wallet.pass")
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
    @State private var showingImporter = false
    @State private var passToAdd: PKPass?
    @State private var showingAddSheet = false
    @State private var errorMessage: String?
    @State private var showingError = false

    private var passType: UTType {
        UTType(filenameExtension: "pkpass") ?? .data
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "wave.3.right")
                                .font(.title2.bold())
                            Spacer()
                            Text("FREEMULO")
                                .font(.caption.bold())
                                .tracking(1.4)
                        }
                        Spacer(minLength: 16)
                        Text("WALLET PASS")
                            .font(.caption.weight(.semibold))
                            .tracking(1.5)
                            .foregroundStyle(.white.opacity(0.7))
                        Text("Моя карта")
                            .font(.system(size: 29, weight: .bold, design: .rounded))
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("ТИП").font(.system(size: 9, weight: .bold)).foregroundStyle(.white.opacity(0.65))
                                Text("Информационный пропуск").font(.caption.weight(.medium))
                            }
                            Spacer()
                            Image(systemName: "wave.3.right")
                                .font(.system(size: 30, weight: .light))
                        }
                    }
                    .foregroundStyle(.white)
                    .padding(22)
                    .frame(height: 205)
                    .background(
                        LinearGradient(colors: [Color(red: 0.18, green: 0.20, blue: 0.25), .black, Color(red: 0.25, green: 0.28, blue: 0.34)], startPoint: .topLeading, endPoint: .bottomTrailing),
                        in: RoundedRectangle(cornerRadius: 24)
                    )
                    .overlay(RoundedRectangle(cornerRadius: 24).stroke(.white.opacity(0.13), lineWidth: 1))

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Добавление в Apple Wallet")
                            .font(.title2.bold())
                        Text("Выбери готовый файл .pkpass — iOS проверит подпись, после чего откроется системное окно добавления в Wallet.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Button {
                        showingImporter = true
                    } label: {
                        Label("Выбрать .pkpass и добавить", systemImage: "plus")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.white)
                    .foregroundStyle(.black)

                    Label("Работает с действительными подписанными Wallet-пропусками", systemImage: "checkmark.seal")
                        .font(.footnote)
                        .foregroundStyle(.secondary)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Важно")
                            .font(.headline)
                        Text("Это обычный Wallet Pass, а не банковская карта. Банковские карты добавляются только через официальную выдачу банка и платёжной системы. FreeMulo не клонирует карты и не создаёт платёжные реквизиты.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 16))
                }
                .padding(20)
            }
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("Apple Wallet")
            .fileImporter(isPresented: $showingImporter, allowedContentTypes: [passType], allowsMultipleSelection: false) { result in
                importPass(result)
            }
            .sheet(isPresented: $showingAddSheet, onDismiss: { passToAdd = nil }) {
                if let passToAdd {
                    PassKitAddView(pass: passToAdd)
                        .ignoresSafeArea()
                }
            }
            .alert("Не удалось открыть пропуск", isPresented: $showingError) {
                Button("ОК", role: .cancel) {}
            } message: {
                Text(errorMessage ?? "Проверь файл .pkpass и его подпись.")
            }
        }
    }

    private func importPass(_ result: Result<[URL], Error>) {
        do {
            guard let url = try result.get().first else { return }
            let granted = url.startAccessingSecurityScopedResource()
            defer { if granted { url.stopAccessingSecurityScopedResource() } }
            let data = try Data(contentsOf: url)
            let pass = try PKPass(data: data)
            guard PKAddPassesViewController.canAddPasses(),
                  PKAddPassesViewController(pass: pass) != nil else {
                throw WalletImportError.walletUnavailable
            }
            passToAdd = pass
            showingAddSheet = true
        } catch {
            errorMessage = error.localizedDescription
            showingError = true
        }
    }
}

private enum WalletImportError: LocalizedError {
    case walletUnavailable
    var errorDescription: String? {
        "Добавление пропусков недоступно на этом устройстве или для этого файла."
    }
}

private struct PassKitAddView: UIViewControllerRepresentable {
    let pass: PKPass

    func makeUIViewController(context: Context) -> PKAddPassesViewController {
        let controller = PKAddPassesViewController(pass: pass)!
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ controller: PKAddPassesViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    final class Coordinator: NSObject, PKAddPassesViewControllerDelegate {
        func addPassesViewControllerDidFinish(_ controller: PKAddPassesViewController) {
            controller.dismiss(animated: true)
        }
    }
}
