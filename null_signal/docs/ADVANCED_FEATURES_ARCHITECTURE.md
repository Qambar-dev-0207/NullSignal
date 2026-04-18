# Advanced Features Architecture - NullSignal

This document outlines the architectural design for the four advanced features to be implemented in the PathOS project.

## 1. Mesh Insight Synthesis
- **Purpose:** Automatically synthesize hundreds of incoming reports into low-bandwidth "Sector Summaries" to prevent information overload for rescuers.
- **Components:**
    - `MeshInsightService`: Orchestrates the synthesis process.
    - `SectorSummary`: Data model representing the synthesized output for a specific geographic area.
    - `GeminiNanoService`: Wrapper for the on-device Gemini Nano model.
- **Data Flow:**
    1. `MeshInsightService` listens to `MeshService.incomingPackets`.
    2. Packets are grouped into "Sectors" based on their `latitude` and `longitude`.
    3. Periodically, `MeshInsightService` passes a batch of sector-specific reports to `GeminiNanoService`.
    4. Gemini Nano generates a concise summary (e.g., "Sector A: 50 survivors, rising water").
    5. The summary is stored locally and can be broadcast back to the mesh as a `low-priority` packet to inform others.

## 2. Acoustic Triangulation (Sonar)
- **Purpose:** Triangulate the position of a buried user using ultrasonic chirps and TDoA (Time Difference of Arrival) logic.
- **Components:**
    - `SonarService`: Manages the emission and detection of ultrasonic chirps.
    - `TDoAEngine`: Calculates the relative position based on timing differences.
    - `3DMeshTopologyVisualizer`: UI component to render the 3D position of users.
- **Data Flow:**
    1. Dead Man's Switch (DMS) triggers on a buried device.
    2. `SonarService` starts emitting high-frequency ultrasonic chirps.
    3. Nearby "active" devices detect these chirps using their microphones.
    4. Detecting devices record the exact timestamp of arrival.
    5. Detecting devices exchange these timestamps via the mesh.
    6. `TDoAEngine` uses these timestamps to triangulate the source's position relative to the known positions of the detecting devices.
    7. The coordinates are sent to the `3DMeshTopologyVisualizer`.

## 3. Satellite-Mesh Hybridization
- **Purpose:** Integrate the Android Satellite SOS API to funnel critical SOS packets from the mesh through a single satellite-enabled device.
- **Components:**
    - `SatelliteGatewayService`: Interfaces with the Android Satellite SOS API.
    - `GatewayOrchestrator`: Decides when to escalate packets to satellite.
- **Data Flow:**
    1. `MeshService` receives an `SOS` priority packet.
    2. `GatewayOrchestrator` checks for terrestrial internet connectivity via `GatewayMonitor`.
    3. If no internet is available, it checks if the device has `Satellite` capabilities.
    4. If available, `SatelliteGatewayService` is used to send the SOS payload.
    5. This device acts as the "Ultimate Gateway" for the surrounding mesh.

## 4. AI Resource Matching
- **Purpose:** P2P "Resource Exchange" where on-device AI act as brokers to match needs with available resources.
- **Components:**
    - `ResourceBrokerService`: Manages the local inventory and matching logic.
    - `ResourceExchangePacket`: New packet type for broadcasting offers and needs.
    - `CrowdDensityMonitor`: Analyzes mesh telemetry to identify safe swap points.
- **Data Flow:**
    1. User A lists "Extra Blankets" in their local inventory.
    2. User B lists a need for "Insulin".
    3. `ResourceBrokerService` broadcasts `ResourceExchangePacket`s periodically.
    4. On-device AI (via `GeminiNanoService`) scans received packets for potential matches.
    5. When a match is found (e.g., "Insulin" <-> "Medical Supplies"), the AI notifies the users.
    6. `CrowdDensityMonitor` suggests a "Safe Swap Point" based on areas with low congestion and known safe locations.
