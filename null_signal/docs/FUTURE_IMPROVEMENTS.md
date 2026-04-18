# NullSignal Future Enhancements Roadmap

This document outlines strategic features and architectural improvements aimed at increasing the life-saving potential and technical robustness of the NullSignal mesh network.

## 1. Biometric SOS Integration (Wearables & Health)
Transform NullSignal from a manual emergency tool into a proactive life-saving monitor by integrating with wearable devices and system health APIs.

*   **Apple HealthKit & Google Health Connect:** Register background observers to monitor for critical heart rate drops (Bradycardia) or sudden spikes (Tachycardia) indicative of shock or cardiac arrest.
*   **Wear OS & watchOS Companion Apps:** Stream real-time biometrics directly to the phone via the `Wearable` Data Client API for instantaneous detection.
*   **Biometric Verification Loop:** To prevent false positives (e.g., watch removal), implement a 30-second high-intensity haptic countdown before mesh broadcast. If the user does not tap "I AM OK," an automated SOS is triggered.

## 2. Visual AI Triage (Computer Vision)
Leverage Gemini Nano's multimodal capabilities to assist survivors with physical injuries.

*   **Offline Image Analysis:** Allow survivors to point their camera at an injury. The local AI identifies specific conditions such as "Arterial Bleeding," "Compound Fracture," or "First-Degree Burn."
*   **Augmented Reality (AR) Guidance:** Provide visual overlays on the camera feed showing exactly where to apply pressure or how to position a splint based on the AI's identification.

## 3. LoRa / Satellite Radio Bridge
Overcome the range limitations of Bluetooth (~100m) and WiFi-Direct (~200m) in rural or sparsely populated environments.

*   **External Hardware Support:** Add plug-and-play support for Bluetooth/USB-C LoRa (Long Range) modules (e.g., Semtech SX1262/SX1276).
*   **10km+ Range:** Extend the mesh footprint to cover entire villages or hiking trails without requiring internet, enabling long-distance emergency coordination.

## 4. Vector-Based Offline Maps
Turn raw coordinates into actionable intelligence without relying on online map servers.

*   **On-Device Tile Server:** Integrate an offline-first map engine (using MBTiles or Protomaps) with OpenStreetMap data.
*   **Topographic Emergency View:** When an SOS is received, display the survivor’s exact location on a detailed map showing terrain, water sources, and potential shelter locations.

## 5. "Ghost" Beacons (Energy Harvesting)
Ensure survivors can be found even when their device battery is nearly depleted.

*   **Ultra-Low-Power Mode:** A specialized system state that disables the screen, AI services, and all non-essential tasks.
*   **Survival Pulse:** The device sends a 1-byte "Presence" pulse every 5 minutes. This extends a 10% battery charge to last for 48+ hours, providing a search-and-rescue "ping" long after the phone appears dead.

## 6. Proof-of-Presence & Reputation Incentives
Strengthen the mesh network by encouraging users to keep the app active in the background.

*   **Relay Reputation:** A lightweight, local reputation system where nodes earn "Trust Credits" for relaying packets for others.
*   **Resource Prioritization:** High-reputation nodes (those who have helped the mesh the most) receive priority routing for their own non-critical packets during times of high mesh congestion.
