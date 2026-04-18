# Implementation Plan - Emergency Intelligence Features

This plan details the steps to replace the Sonar feature with real-time hazard mapping, crowd safety, and seismic monitoring.

## 1. Phase 1: Sonar Removal & Cleanup
- [ ] Delete `lib/features/sos/domain/logic/tdoa_engine.dart`.
- [ ] Delete `lib/features/sos/data/repositories/sonar_service_impl.dart`.
- [ ] Delete `lib/features/sos/domain/repositories/sonar_service.dart`.
- [ ] Remove `sonarService` from `main.dart` (Imports, DI, Constructor).
- [ ] Remove `sonarService` and DMS sonar logic from `SosCubit`.
- [ ] Delete `test/tdoa_engine_test.dart`.
- [ ] Update `test/widget_test.dart` to remove Sonar mocks.

## 2. Phase 2: Hazard Overlays (Google Earth Engine)
- [ ] Update `MeshPacket` model to include `HAZARD_MAP` type and GeoJSON payload.
- [ ] Create `HazardOverlayService` (Gateway logic to poll mock GEE API).
- [ ] Implement `MapOverlayCubit` to manage polygon state.
- [ ] Update dashboard map to render GeoJSON polygons using `flutter_map`.

## 3. Phase 3: Crowd Crush Prediction
- [ ] Create `CrowdMonitorService` to track neighbor count trends from `MeshService`.
- [ ] Implement `CrowdAnalysisEngine` using Gemini Nano (on-device inference).
- [ ] Add `CROWD_ALERT` packet type and UI notification logic.

## 4. Phase 4: Building Damage Scoring
- [ ] Add `sensors_plus` dependency to `pubspec.yaml`.
- [ ] Create `SeismicMonitorService` to detect G-force spikes.
- [ ] Implement `DamageHeatmapService` to aggregate `SEISMIC_EVENT` packets.
- [ ] Add UI layer for damage visualization.

## 5. Phase 5: Verification
- [ ] Run `flutter analyze` to ensure zero regressions.
- [ ] Add unit tests for `CrowdAnalysisEngine` logic.
- [ ] Manual verification of mock hazard injection.
