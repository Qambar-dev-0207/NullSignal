# NullSignal — Multi-Device Testing Protocol

## Prerequisites
- Minimum 2 physical Android devices (API 31+)
- Both devices: Bluetooth + WiFi enabled, internet NOT required for mesh tests
- `GEMINI_API_KEY` optional (only for cloud fallback verification)
- AI model provisioned on both devices before mesh tests

---

## Unit Tests (No Device Required)

```bash
cd null_signal
flutter test                                        # all unit tests
flutter test test/security_e2ee_test.dart          # E2EE crypto
flutter test test/routing_engine_test.dart          # DTN routing
flutter test test/offline_ai_verification_test.dart # heuristic AI fallback
flutter test test/ai_status_test.dart
flutter test test/mesh_connectivity_test.dart
```

Integration tests (physical device required):
```bash
flutter test integration_test/ai_verification_test.dart
```

---

## Scenario 1 — AI Provisioning

1. Fresh install (no model in `filesDir`).
2. Launch app → `TacticalAiProvisioningScreen` appears.
3. **If bundled asset present:** progress bar advances 0→99% (copy), then jumps to 100%. Time: < 60 s.
4. **If no asset:** progress shows download percentage. Requires Wi-Fi.
5. After 100%: app transitions to main UI.
6. Navigate to **AI HELP** → send message "hello".
7. **Verify:** response from Gemma 4 (not heuristic mode text).

Expected logcat:
```
[MediaPipe] Model staged from bundled APK asset
[MediaPipe] Gemma 4 model loaded successfully
```

---

## Scenario 2 — Offline AI Triage

1. Enable Airplane Mode on device (keep BT/WiFi on manually after).
2. Navigate to **AI HELP**.
3. Input: `"Severe bleeding from leg, pulse is fast, skin is cold."`
4. **Verify:** returns RED triage score.
5. **Verify:** numbered first-aid steps provided.
6. **Verify:** response time < 10 s (on-device inference).
7. Input: `"No pulse, no breathing."` → **Verify:** BLACK status returned.

---

## Scenario 3 — Peer Discovery & Mesh Formation

1. Launch NullSignal on Device A and Device B.
2. Navigate to **MESH** tab on both.
3. **Verify within 15 s:** both devices appear in each other's discovered list.
4. **Verify:** status auto-advances from `discovered` → `connected`.
5. Logcat filter `[NULLSIGNAL]` on both devices:
   - Device A: `NODE FOUND: <endpointId>`
   - Device B: `CONNECTED TO <endpointId>`

**If 0 peers after 45 s:**
- Confirm `ACCESS_FINE_LOCATION` was granted
- Confirm no `neverForLocation` flags in manifest (see `AndroidManifest.xml:12-17`)
- Logcat should show `No peers visible, cycling advertising+discovery...`

---

## Scenario 4 — Encrypted Direct Message

1. On Device A → MESH tab → select Device B → send: `"SYSTEM CHECK ALPHA"`
2. **Verify on Device B:** Snackbar shows `MSG FROM <senderId>: SYSTEM CHECK ALPHA`
3. Logcat on Device A: `MeshCubit: Message E2EE encrypted for <deviceId>`
4. **Verify:** Message persists in local Isar DB after app restart.

---

## Scenario 5 — Multi-Hop SOS Relay

Physical layout: `Device A ←—BLE—→ Device B ←—BLE—→ Device C`
(A and C out of range of each other)

1. Hold SOS button on Device A for 3 s.
2. **Verify on Device B:** SOS dialog appears. Sender ID = Device A. Coordinates shown.
3. **Verify on Device C:** SOS dialog appears (relayed by B). Sender ID still = Device A.
4. **Verify TTL:** packet arrives at C with TTL decremented from 5 (start) to 3.
5. Re-broadcast: new SOS packet arrives at B and C every ~15 s with new `packetId`.

---

## Scenario 6 — Dead Man Switch

1. Set device flat, do not move or touch for 8 min.
2. **Verify:** `SAFETY CHECK-IN` overlay appears with haptic feedback.
3. Do not tap button for 30 s.
4. **Verify:** SOS broadcast fires automatically.
5. Logcat: `onAutoSosTriggered`

---

## Scenario 7 — Gateway Internet Relay

1. Device A: enable internet (WiFi/4G). Device B: Airplane + BT/WiFi-Direct only.
2. Device A advertises as `{deviceId}|G` (confirm in logcat: `Advertising OK` + `|G` suffix).
3. On Device B: trigger SOS.
4. **Verify on Device A:** logcat shows `HTTP POST` to `api.nullsignal.io/v1/sos/relay`.
5. (If endpoint active) Verify acknowledgement received.

---

## Scenario 8 — Seismic Detection

1. Navigate to **STATUS** tab.
2. Firmly tap device on a hard surface several times (simulate impact).
3. **Verify:** seismic alert emitted (logcat: `localGForceStream` event > 15G threshold).
4. With 2+ devices: shake both simultaneously.
5. **Verify:** damage heatmap aggregates entries from both node IDs.

---

## Success Benchmarks

| Feature | Target |
|---|---|
| Peer discovery | < 15 s |
| Connection establishment | < 5 s after discovery |
| SOS relay per hop | < 2 s |
| AI triage response (on-device) | < 10 s |
| Model provisioning (bundled copy) | < 60 s |
| Dead Man Switch trigger | 8 min inactivity + 30 s grace |
| Battery drain (active mesh) | < 4% / hour |
| SeenPacket dedup | 0 duplicate packets processed |
