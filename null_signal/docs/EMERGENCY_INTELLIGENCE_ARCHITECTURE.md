# Advanced Emergency Intelligence Architecture - NullSignal

This document defines the architecture for the hazard mapping, crowd safety, and seismic monitoring features.

## 1. Real-time Hazard Overlays (Google Earth Engine)
- **Objective:** Provide offline-first vector hazard boundaries (fire, flood, cyclone).
- **Service:** `HazardOverlayService`
- **Flow:**
    1. **Gateway Acquisition:** Gateway nodes periodically poll Google Earth Engine (GEE) APIs.
    2. **Compression:** GeoJSON polygons are simplified (Douglas-Peucker) and compressed to fit <5KB.
    3. **Mesh Injection:** Broadcasted as `MeshPacket` with `type: HAZARD_MAP`.
    4. **Client Rendering:** `MapOverlayCubit` receives packets, persists them in Isar, and updates `flutter_map`'s `PolygonLayer`.

## 2. Mesh-powered Crowd Crush Prediction
- **Objective:** Predict and alert for crowd crush events using BLE telemetry.
- **Service:** `CrowdMonitorService`
- **Flow:**
    1. **Telemetry:** Nodes track number of BLE neighbors every 30s.
    2. **Analysis:** `CrowdRiskCubit` calculates the rate of density change.
    3. **AI Inference:** If density > threshold, Gemini Nano analyzes the trend (e.g., "Rising rapidly, 15 nodes/m²").
    4. **Alerting:** Broadcasts `CROWD_ALERT` with exit vectors.

## 3. Mesh-inferred Building Damage Scoring
- **Objective:** Map structural damage using accelerometer spikes and node silence.
- **Service:** `SeismicMonitorService`
- **Flow:**
    1. **Sensing:** Continuous monitoring of 3-axis accelerometer data.
    2. **Spike Detection:** Sudden high-G events trigger a `SEISMIC_EVENT` packet.
    3. **Aggregated Mapping:** `DamageHeatmapService` tracks which areas reported spikes and which areas went silent (inferred collapse).
    4. **Scoring:** On-device AI provides safety guidance based on event magnitude and local node health.

## 4. New Packet Types
- `HAZARD_MAP`: Contains compressed GeoJSON geometry.
- `CROWD_ALERT`: High-priority alert with evacuation guidance.
- `SEISMIC_EVENT`: Sensor telemetry for mesh-wide damage aggregation.
