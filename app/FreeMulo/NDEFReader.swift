import Foundation
import CoreNFC

@MainActor
final class NDEFReader: NSObject, ObservableObject, NFCNDEFReaderSessionDelegate {
    @Published private(set) var message: String?
    @Published private(set) var error: String?
    @Published private(set) var isReading = false

    var available: Bool { NFCNDEFReaderSession.readingAvailable }
    private var session: NFCNDEFReaderSession?

    func begin() {
        guard available else {
            error = "NFC-чтение недоступно на этом устройстве."
            return
        }
        error = nil
        message = nil
        isReading = true
        let newSession = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
        newSession.alertMessage = "Поднесите NFC-метку к верхней части iPhone."
        session = newSession
        newSession.begin()
    }

    nonisolated func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        Task { @MainActor in
            self.isReading = false
            self.session = nil
            let nsError = error as NSError
            if nsError.code != NFCReaderError.readerSessionInvalidationErrorUserCanceled {
                self.error = error.localizedDescription
            }
        }
    }

    nonisolated func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        let output = messages.flatMap(\.records).map { record -> String in
            let type = String(data: record.type, encoding: .utf8) ?? record.type.map { String(format: "%02x", $0) }.joined()
            let payload = String(data: record.payload, encoding: .utf8) ?? record.payload.map { String(format: "%02x", $0) }.joined()
            return "Тип: \(type)\nДанные: \(payload)"
        }.joined(separator: "\n\n")
        Task { @MainActor in
            self.message = output.isEmpty ? "NDEF-записей не найдено." : output
        }
    }
}
