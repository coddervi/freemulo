# FreeMulo

FreeMulo is a free, open-source iOS NFC utility and jailbreak research project for **Dopamine Rootless**.

> **Important:** FreeMulo is not a payment-card emulator. It does not clone bank cards, copy payment credentials, bypass Apple Wallet provisioning, or emulate EMV payment cards. A Wallet pass is not a payment card. Payment credentials can only be provisioned by the issuer and supported payment network.

## Project status

This repository starts with a buildable Rootless Theos tweak skeleton and an iOS app prototype.

- [x] Rootless Theos package scaffold
- [x] GitHub Actions workflow for `.deb`
- [x] SwiftUI app shell
- [x] CoreNFC NDEF reader/writer prototype
- [ ] Device testing on iOS 27 + Dopamine
- [ ] Wallet pass integration for legitimate, issuer-independent passes (requires a valid Pass Type ID certificate to sign passes)
- [ ] Further NFC protocol research, limited to APIs and hardware capabilities available on the target device

## Build the jailbreak package

The GitHub Actions workflow builds a Rootless `.deb` package. Push to `main` or run the workflow manually, then download the artifact named `freemulo-rootless-deb`.

Local build requirements: Theos, an iOS SDK, and a Rootless toolchain.

```sh
make package
```

## iOS app prototype

The SwiftUI source is in `app/FreeMulo/`. CoreNFC requires a physical compatible iPhone and the appropriate NFC entitlements/capabilities. NFC reading/writing support varies by iPhone model, iOS release, tag technology, and CoreNFC API availability. This source is a prototype and is not yet an installable IPA project.

## Safety and compatibility

- Only scan, write, or emulate tags you own or are explicitly authorized to test.
- NDEF reading/writing is not the same as cloning secure DESFire credentials.
- CoreNFC does not expose unrestricted low-level NFC controller access or general card emulation.
- Background NFC scanning and lock-screen invocation are subject to Apple's platform restrictions.
- The Rootless tweak currently contains a harmless initialization stub; it does not claim to unlock private NFC hardware APIs.

## License

MIT. See [LICENSE](LICENSE).
