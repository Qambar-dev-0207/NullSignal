import 'package:isar/isar.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chat_message.g.dart';

@collection
@JsonSerializable()
class ChatMessage {
  Id id = Isar.autoIncrement;

  final String senderId;
  final String content;
  final int timestamp;
  final bool isAI;

  ChatMessage({
    required this.senderId,
    required this.content,
    required this.timestamp,
    required this.isAI,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) => _$ChatMessageFromJson(json);
  Map<String, dynamic> toJson() => _$ChatMessageToJson(this);
}
