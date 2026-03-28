# 🧑‍💻 Developer Guide: Build & Release

This guide explains how to manually build the application and how to trigger the automated GitHub Actions workflow for production releases.

---

## 🛠️ Local Development

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) installed and added to your path.
- macOS with Xcode installed (to build macOS/iOS).

### Initial Setup

```bash
flutter pub get
```

### Running the App

- **macOS (Debug)**: `flutter run -d macos`
- **iOS (Simulator/Device)**: `flutter run -d <device-id>`

---

## 📦 Manual Production Build (macOS)

If you want to generate the `.dmg` installer manually:

1.  **Build the Release App**:

    ```bash
    flutter build macos --release
    ```

2.  **Generate the DMG Installer**: Ensure you have `create-dmg` installed (`brew install create-dmg`), then run:
    ```bash
    create-dmg \
      --volname "Prime Invoice Installer" \
      --window-pos 200 120 \
      --window-size 800 400 \
      --icon-size 100 \
      --icon "Prime Invoice.app" 200 190 \
      --hide-extension "Prime Invoice.app" \
      --app-drop-link 600 185 \
      "Prime-Invoice-Installer.dmg" \
      "build/macos/Build/Products/Release/Prime Invoice.app"
    ```

---

## 🚀 Automated Release Workflow (GitHub Actions)

We have automated the build and release process using GitHub Actions. Whenever a **tag** starting with `v` (e.g., `v1.0.0`) is pushed, GitHub will:

1.  Build the macOS release version.
2.  Package it into a `.dmg` installer.
3.  Create a fresh Release on GitHub and upload the DMG as an asset.

### Steps to Trigger a New Release

1.  **Commit your changes** on the `main` branch.
2.  **Tag the version**:
    ```bash
    git tag v1.0.1
    ```
3.  **Push the code and tag**:
    ```bash
    git push origin main
    git push origin v1.0.1
    ```

### Monitoring Progress

You can see the build logs and status on the **'Actions'** tab of your GitHub repository.

---

## 🔒 Security Notes (macOS)

Since the app is not currently "Notarized" by Apple (which requires a $99/year developer account), users will need to:

1.  Right-click the app in their Applications folder and select **Open**.
2.  If it says "damaged", run: `xattr -cr /Applications/"Prime Invoice.app"`.
