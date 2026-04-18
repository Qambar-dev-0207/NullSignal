# NullSignal Multi-Device Testing Protocol (2026)

This protocol outlines the steps required to verify decentralized emergency functions across multiple physical devices.

## Prerequisites
- Minimum 2 physical devices (Android 14+ recommended for Gemini Nano, iOS 17+ for Gemma).
- `GEMINI_API_KEY` configured during build for cloud fallback verification.
- Location services enabled on all devices.
- Bluetooth and WiFi enabled (Internet NOT required).

## Test Scenarios

### 1. Zero-Signal Logic Verification (Simulator/Automated)
This ensures the underlying state machines work even when physical radios are unavailable.
1.  Run `flutter test test/offline_ai_verification_test.dart`.
2.  **Verify**: All 5 tests pass (Pseudo-AI heuristics, reordered triage priority).
3.  Check reordering logic: Inputting "no pulse" must result in **BLACK** status, even if "breathing" is also mentioned.

### 2. UI/UX & Visual Cohesion
1.  Launch the app in "Normal" or "Panic" mode.
2.  **Verify Theme**: Background matches `0xFFF5E6D3` (Beige), primary buttons use `0xFFB71C1C` (Red).
3.  Navigate to **MESH** page.
4.  **Verify 3D Topology**: Discovered nodes should orbit the central "Self" node in a 3D coordinate space. Lines should only pulse red for active connections.

### 3. Peer Discovery & Mesh Formation
1.  Launch NullSignal on Device A and Device B.
2.  Navigate to the **MESH** tab on both devices.
3.  **Verify**: Both devices should appear in each other's "Discovered Nodes" list within 15 seconds.
4.  **Verify**: Status should change from `discovered` to `connected` automatically.

### 2. Offline Messaging (1-to-1)
1.  On Device A, select Device B from the Mesh list.
2.  Send a text message: "SYSTEM CHECK ALPHA".
3.  **Verify**: Device B receives a Snackbar notification with the message and Sender ID.
4.  **Verify**: Message history persists in the local database on both devices.

### 3. Multi-Hop SOS Broadcast
1.  Arrange 3 devices in a line: Device A --- Device B --- Device C.
2.  Ensure Device A and Device C are NOT within range of each other, but both are in range of Device B.
3.  Trigger SOS on Device A (Hold "SOS" button for 3 seconds).
4.  **Verify**: Device B receives the SOS alert.
5.  **Verify**: Device C receives the SOS alert (relayed by Device B).
6.  **Verify**: All devices show the correct Sender ID and GPS coordinates of Device A.

### 4. Offline AI Triage
1.  Put Device A into Airplane Mode (Keep BT/WiFi on).
2.  Navigate to **AI HELP**.
3.  Input symptoms: "Severe bleeding from leg, pulse is fast, skin is cold."
4.  **Verify**: AI returns a **RED** triage score.
5.  **Verify**: AI provides numbered first-aid steps (Pressure, Tourniquet, Elevation).
6.  **Verify**: Response time is < 5 seconds (Local Inference).

### 5. Local Hazard Filtering
1.  Inject a mock hazard on Device A (using Debug mode or automated polling).
2.  Move Device B to a location > 10km away from the hazard (or mock the location).
3.  **Verify**: Device B does NOT show the hazard on the map.
4.  Move Device B within 5km of the hazard.
5.  **Verify**: Device B displays the hazard overlay correctly.

## Success Benchmarks
| Feature | Target |
|---------|--------|
| Mesh Discovery | < 15s |
| SOS Relay Latency | < 2s per hop |
| AI Triage Latency | < 5s (On-device) |
| Battery Drain | < 4% per hour (Active Mesh) |
