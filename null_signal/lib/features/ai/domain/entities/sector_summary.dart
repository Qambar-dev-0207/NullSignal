import 'package:isar/isar.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sector_summary.g.dart';

@collection
@JsonSerializable()
class SectorSummary {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  final String sectorId;
  
  final String summary;
  final int timestamp;
  
  final double centerLatitude;
  final double centerLongitude;
  final double radius; // in meters
  
  final int survivorCount;
  final List<String> urgentNeeds;

  SectorSummary({
    required this.sectorId,
    required this.summary,
    required this.timestamp,
    required this.centerLatitude,
    required this.centerLongitude,
    required this.radius,
    required this.survivorCount,
    required this.urgentNeeds,
  });

  factory SectorSummary.fromJson(Map<String, dynamic> json) => _$SectorSummaryFromJson(json);
  Map<String, dynamic> toJson() => _$SectorSummaryToJson(this);
}
