# 🧾 Invoice Generator

A powerful, cross-platform Flutter application designed to streamline your invoicing process. Generate professional PDFs, manage clients, and track your business transactions effortlessly on **macOS** and **iOS**.

---

## ✨ Features

- **🚀 Professional PDFs**: Generate sleek, branded invoices with customizable business details and watermarks.
- **👥 Client Management**: Easily import and manage your clients using your device's contacts.
- **💾 Offline First**: All your data stays on your device with local SQLite storage.
- **🌗 Dynamic Themes**: Supports Light, Dark, and System Material You themes.
- **🖥️ Desktop & Mobile**: Fully optimized for macOS (Desktop) and iPhone (iOS).

---

## 🛠️ Installation Instructions

### 🍏 macOS

Since this application is not distributed through the official Mac App Store, macOS may show a security warning. Follow these steps:

1. **Install the App**:
   - Double-click the `.dmg` file to open it.
   - Drag **Invoice Generator** into your **Applications** folder.

2. **First-Time Launch (Bypassing the Warning)**:
   - If you see a message saying "unidentified developer":
   - **Right-click** (or Control-click) the app icon in your Applications folder.
   - Select **Open** from the menu.
   - Click **Open** again in the dialog box.

3. **Troubleshooting "App is Damaged"**:
   - If macOS says the app is "damaged", run this command in your Terminal:
   ```bash
   xattr -cr /Applications/"Invoice Generator.app"
   ```

### 📱 iPhone (iOS)

- **Via Xcode**:
  1. Open `ios/Runner.xcworkspace` in Xcode.
  2. Select your device and Hit **Run**.
  3. _Note: Ensure you have your development team configured in Xcode settings._

---

## 🧑‍💻 Development

If you'd like to build the project from source, ensure you have the Flutter SDK installed.

1. **Fetch Dependencies**:

   ```bash
   flutter pub get
   ```

2. **Run on macOS**:

   ```bash
   flutter run -d macos
   ```

3. **Run on iOS**:
   ```bash
   flutter run -d <your-device-id>
   ```

---

## 🔒 Permissions & Privacy

We value your privacy. This app requires the following permissions:

- **Contacts**: To import client information directly into invoices.
- **File System**: To save and share generated PDF documents.
- **Printing**: To allow printing invoices directly.

---

_Built with ❤️ using Flutter._
