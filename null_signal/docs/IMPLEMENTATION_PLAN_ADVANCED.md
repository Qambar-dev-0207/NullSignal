# Implementation Plan - Advanced Features

This plan outlines the steps to implement Mesh Insight Synthesis, Acoustic Triangulation, Satellite-Mesh Hybridization, and AI Resource Matching.

## Phase 1: Environment Setup & Foundation (Task 1 & 2 partial)
1. Add necessary dependencies: `audioplayers`, `record`.
2. Define core models:
    - `SectorSummary` in `lib/features/ai/domain/entities/sector_summary.dart`.
    - `ResourceExchangePacket` in `lib/core/models/resource_packet.dart`.
3. Run `build_runner` to generate G-files.

## Phase 2: AI & Mesh Insight (Task 1)
1. Create `MeshInsightService` in `lib/features/ai/data/repositories/mesh_insight_service_impl.dart`.
2. Implement sector-based buffering logic.
3. Integrate with `google_generative_ai` (Gemini Nano simulation for now if on-device isn't fully available).
4. Update `AiCubit` to expose sector summaries.
5. Create UI component for Sector Summaries in `PanicAIHelpScreen`.

## Phase 3: Sonar & Acoustic Triangulation (Task 2)
1. Implement `SonarService` for chirp emission and detection.
2. Implement `TDoAEngine` for triangulation math.
3. Create `3DMeshTopologyVisualizer` using CustomPainter or a 3D library (if available, otherwise 2D projection).
4. Implement "Dead Man's Switch" (DMS) trigger logic in `SosCubit`.

## Phase 4: Satellite & Resource Matching (Task 3 & 4)
1. Implement `SatelliteGatewayService` (Mock).
2. Update `MeshService` routing to use `SatelliteGatewayService` for critical packets.
3. Implement `ResourceBrokerService` for P2P resource matching.
4. Use Gemini for semantic matching of "needs" and "offers".
5. Implement `CrowdDensityMonitor` using mesh peer counts and geolocator.
6. Create `ResourceExchangeScreen` UI.

## Phase 5: Verification & Testing
1. Unit tests for `TDoAEngine`.
2. Unit tests for `ResourceBrokerService` matching logic.
3. Integration test for the full SOS escalation path (Mesh -> Satellite).
4. Final UI/UX Polish.
