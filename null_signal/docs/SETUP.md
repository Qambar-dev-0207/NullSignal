# Setup & Installation Guide

This guide will help you set up the development environment for **NullSignal** and deploy it to your physical devices.

## 1. Prerequisites

### Software Requirements
*   **Flutter SDK:** ^3.8.0
*   **Android Studio / VS Code:** With Flutter & Dart plugins.
*   **Android SDK:** API Level 31 or higher (required for Gemini Nano / AICore).
*   **iOS Development:** macOS with Xcode 15+ (for physical device testing).

### Hardware Requirements
*   **Physical Devices:** Mesh networking (Nearby Connections) and local AI inference (Gemini Nano) require physical hardware. Emulators can be used for UI work but will fallback to simulated services.
*   **Supported AI Devices:** 
    *   **Android:** Pixel 8/9/10, Samsung S24/S25 series (requires updated Google AICore).
    *   **iOS:** iPhone 12 or newer (for optimal CoreML/Metal performance).

## 2. Environment Configuration

### Gemini API Key (Online Fallback)
While NullSignal is "Offline-First," it uses Google's Online Gemini Pro as a fallback for emulators or devices without local NPU support.

1.  Obtain a key from [Google AI Studio](https://aistudio.google.com/app/apikey).
2.  Add it to your environment:
    *   **macOS/Linux:** `export GEMINI_API_KEY="your_key"`
    *   **Windows:** `$env:GEMINI_API_KEY="your_key"`

## 3. Installation Steps

1.  **Clone the Repository:**
    ```bash
    git clone https://github.com/your-repo/null_signal.git
    cd null_signal
    ```

2.  **Install Dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Generate Code (Isar/JSON):**
    ```bash
    dart run build_runner build --delete-conflicting-outputs
    ```

4.  **Run the Application:**
    *   Ensure your physical device is connected and authorized.
    *   **Android:** `flutter run` (Ensure `minSdk 31` is reflected in `build.gradle.kts`).
    *   **iOS:** `flutter run` (Ensure signing is configured in Xcode).

## 4. Permissions
Upon first launch, NullSignal will request:
*   **Bluetooth & WiFi:** For P2P Mesh communication.
*   **Location:** For SOS coordinate precision (Fine Location).
*   **Nearby Devices:** To discover peers without internet.
*   **Notifications:** For critical SOS alerts.
