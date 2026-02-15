![logo.svg](assets/logo.svg)
<p align="center">
  English | <a href="README_FA.md">فارسی</a>
</p>
# Cf Config Doctor

A cross-platform **Cloudflare clean IP scanner and configuration generator** built with Flutter.

Cf Config Doctor helps you scan IP ranges, detect low-latency clean IPs, and export them in multiple formats including **VLESS links** and **Clash Meta YAML configuration**.

---

## ✨ Features

* 🔍 Multi-threaded IP scanning
* 🌐 HTTP probe and TLS socket scan modes
* ⚡ Latency measurement
* 📦 Export to:

    * VLESS links
    * Clash Meta full YAML config
    * Plain IP list
* 🌍 Multi-language support:

    * English
    * Persian (فارسی)
    * Arabic (العربية)
    * Chinese (中文)
    * Russian (Русский)
    * Turkish (Türkçe)
* 🖥 Desktop support (Windows, Linux, macOS)
* 📱 Android support
* 💾 File saving (Desktop & Android)
* 📋 Clipboard copy support
* 🎨 Theme & language switching

---

## screenshots
<img width="400" height="200" alt="Screenshot_20260214_170313" src="https://github.com/user-attachments/assets/444cff16-bed6-41b9-909b-0276511c755e" />
<img width="400" height="200" alt="Screenshot_20260214_170255" src="https://github.com/user-attachments/assets/0445ee75-19de-40cb-bad5-6947be3d8301" />
<img width="400" height="200" alt="Screenshot_20260214_170504" src="https://github.com/user-attachments/assets/a7069b8a-e74a-44a8-be08-b0eaf550a4c9" />
<img width="400" height="200" alt="Screenshot_20260214_170443" src="https://github.com/user-attachments/assets/3202815d-3ba7-45f2-8880-a6721af3d009" />
<img width="400" height="200" alt="Screenshot_20260214_170419" src="https://github.com/user-attachments/assets/219f8853-dfd9-4819-ae7e-10589e7684b8" />
<img width="400" height="200" alt="Screenshot_20260214_170401" src="https://github.com/user-attachments/assets/48df261f-c9bb-4341-b756-15d1840690f6" />



---
## 🏗 Architecture Overview

The application is structured around:

* **PlatformHelper** → Platform detection & capability handling
* **L10n System** → Built-in localization engine
* **Scanner Engine** → Async multi-threaded probing
* **Export Engine** → Generates VLESS and Clash configs
* **Persistent Settings** → Stored using SharedPreferences

The app is fully asynchronous and optimized for high concurrency scanning.

---

## 📦 Tech Stack

* Flutter
* Dart
* http package
* shared_preferences
* Material UI

---

## 🚀 Getting Started
## Usage

CF Scanner helps you discover fast, clean Cloudflare IP addresses from your location by performing real TLS handshakes (SNI-based) and measuring latency.

### 1. Desktop (Windows / macOS / Linux)

Full scanning functionality is available.

1. **Launch the app**
2. Go to the **Scan** tab
3. Fill in the basic configuration:

   | Field                                    | Example value                        | Description                                      |
      |------------------------------------------|--------------------------------------|--------------------------------------------------|
   | Domain (Host)                            | `speed.cloudflare.com`              | Cloudflare-proxied domain used for testing      |
   | UUID          (optional)                 | `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` | Your VLESS UUID (for generated links/configs) |
   | WebSocket Path                (optional) | `/` or `/ray` or `/ws`              | WS path used in your proxy setup                |
   | Concurrency                              | 80–150                              | Number of parallel tests (higher = faster)      |
   | Latency limit                            | 400–500 ms                          | Maximum acceptable handshake time               |
   | Max clean IPs/range                      | 5–10                                | Stop scanning range after finding this many     |

4. (Optional) Deselect any Cloudflare IP ranges you don't want to test
5. Click **START**
6. Watch the live progress:
    - IPs scanned per second
    - Current range
    - Clean IPs found so far
7. When satisfied → press **STOP**

8. Go to the **Results** tab
    - See sorted list of clean IPs (color-coded by latency)
    - Green < 150 ms • Orange 150–300 ms • Red > 300 ms

9. Go to the **Export** tab
   Choose format:

    - **Plain text**  
      Simple list: `IP (latency ms)`
    - **VLESS links**  
      Ready-to-import links (`vless://...`)
    - **Clash Meta config**  
      Complete YAML with:
        - all found proxies
        - auto (url-test) & manual (select) groups
        - Iran direct routing (`GEOIP,IR,DIRECT`)
        - TUN mode enabled
        - sane DNS settings

   Click **Copy to clipboard** or **Save to file**



### Tips for best results

- Use a domain that is always behind Cloudflare (e.g. your own site)
- Start with 80–120 concurrent connections; increase if your machine & network can handle it
- Reasonable latency limit: 350–600 ms depending on your country/ISP
- 5–8 clean IPs per range is usually more than enough for most proxy setups
- Scanning all ranges can take 5–40 minutes depending on settings and luck

Happy scanning!

---

## ⚙️ Configuration

You can configure:

* Domain (Host / SNI)
* UUID (optional for VLESS)
* WebSocket Path (optional)
* Threads count
* Latency threshold
* IP ranges (CIDR support)
* Scan method (HTTP or TLS)

---

## 📤 Export Options

### VLESS Links

Generates ready-to-use VLESS URIs for supported clients.

### Clash Meta Config

Produces a full YAML configuration including routing rules.

### Plain Text

Exports clean IP list only.

---

## 🌍 Localization

Language switching is built-in and supports RTL layouts for Persian and Arabic.

---

## 🛠 Build Release

### Windows

```bash
flutter build windows
```

### Linux

```bash
flutter build linux
```

### macOS

```bash
flutter build macos
```

### Android

```bash
flutter build apk --release
```

---

## 📌 Platform Support Matrix

| Platform | Scan       | Export     | Save File |
| -------- | ---------- | ---------- | --------- |
| Windows  | ✅          | ✅          | ✅         |
| Linux    | ✅          | ✅          | ✅         |
| macOS    | ✅          | ✅          | ✅         |
| Android  | ✅          | ✅          | ✅         |
| Web      | ⚠️ Limited | ⚠️ Limited | ❌         |

---

## ⚠ Disclaimer

This tool is provided for educational and research purposes only.
Users are responsible for how they use generated configurations.

---

## 🤝 Contributing

Pull requests are welcome.
For major changes, please open an issue first to discuss what you would like to change.

---


## 👨‍💻 Author

Developed with Flutter.

---

If you find this project useful, consider giving it a ⭐ on GitHub.
