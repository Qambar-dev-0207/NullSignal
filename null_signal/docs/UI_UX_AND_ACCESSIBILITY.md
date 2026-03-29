# NullSignal UI/UX & Accessibility

This document details the interface design and accessibility standards implemented in NullSignal to ensure usability during extreme disaster scenarios.

## 1. Design Philosophy: "Panic-Optimized"
NullSignal is designed for users with shaking hands, in low light, or with limited mobility. Every interaction is prioritized for speed and reliability.

### Key Standards:
- **Minimum Tap Targets:** 96px for all primary actions in Panic Mode.
- **Maximum Contrast:** strictly adheres to WCAG AAA (7:1 ratio) using a Yellow/Black/White palette.
- **Limited Screens:** Panic Mode restricts the app to 3 core screens to prevent cognitive overload.

## 2. Dual-Theme Orchestration
The app utilizes a global `UIOrchestrator` (BLoC) to manage state.

- **NormalTheme:** A standard Material 3 Dark theme for preparation and configuration.
- **PanicTheme:** High-contrast, large-button theme that overrides all standard layouts when an emergency is detected or triggered.

## 3. The 3-Screen Navigation (Panic Mode)
When in Panic Mode, the navigation is simplified into three tabs:
1. **AI HELP:** Offline first-aid guidance and triage.
2. **SOS:** Central broadcast button for emergency transmission.
3. **NEARBY:** Mesh health and peer node monitoring.

## 4. Accessibility & Multimodal Feedback
To support users who cannot see the screen or are pinned under debris:

- **Haptic Feedback (`FeedbackService`):**
  - **Morse SOS:** ... --- ... vibration pattern for broadcast confirmation.
  - **Confirmation Pulse:** Single short vibration for successful taps.
- **Voice Commands:** System-level integration (Siri/Google Assistant) to trigger SOS via the "NullSignal SOS" wake-word.
- **Semantics:** Every interactive element in Panic Mode is wrapped in `Semantics` with high-priority labels and hints for TalkBack and VoiceOver.
