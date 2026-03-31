import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:isar/isar.dart';
import 'package:null_signal/features/ai/data/models/chat_message.dart';
import 'package:null_signal/features/ai/domain/repositories/ai_service.dart';

abstract class AiState {}

class AiInitial extends AiState {}
class AiLoading extends AiState {
  final List<ChatMessage> history;
  AiLoading({this.history = const []});
}
class AiResponse extends AiState {
  final String title;
  final String content;
  final List<ChatMessage> history;
  AiResponse(this.title, this.content, {this.history = const []});
}
class AiError extends AiState {
  final String message;
  final List<ChatMessage> history;
  AiError(this.message, {this.history = const []});
}

class AiCubit extends Cubit<AiState> {
  final AIService _aiService;
  final Isar _isar;

  AiCubit(this._aiService, this._isar) : super(AiInitial());

  Future<void> initialize() async {
    try {
      await _aiService.initialize();
      final history = await _isar.chatMessages.where().sortByTimestamp().findAll();
      emit(AiResponse('SYSTEM READY', 'Nano AI online.', history: history));
    } catch (e) {
      emit(AiError('AI Initialization Failed: $e'));
    }
  }

  Future<List<ChatMessage>> _getHistory() async {
    return await _isar.chatMessages.where().sortByTimestamp().findAll();
  }

  Future<void> _saveMessage(String content, bool isAI) async {
    final message = ChatMessage(
      senderId: isAI ? 'NANO' : 'USER',
      content: content,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      isAI: isAI,
    );
    await _isar.writeTxn(() => _isar.chatMessages.put(message));
  }

  Future<void> getTriage(String symptoms) async {
    final history = await _getHistory();
    emit(AiLoading(history: history));
    try {
      await _saveMessage('TRIAGE REQUEST: $symptoms', false);
      final response = await _aiService.getTriageResponse(symptoms);
      await _saveMessage(response, true);
      final updatedHistory = await _getHistory();
      emit(AiResponse('START TRIAGE SCORE', response, history: updatedHistory));
    } catch (e) {
      emit(AiError('Triage Error: $e', history: history));
    }
  }

  Future<void> getGuidance(String condition) async {
    final history = await _getHistory();
    emit(AiLoading(history: history));
    try {
      await _saveMessage('GUIDANCE REQUEST: $condition', false);
      final response = await _aiService.getFirstAidGuidance(condition);
      await _saveMessage(response, true);
      final updatedHistory = await _getHistory();
      emit(AiResponse('FIRST-AID GUIDE: ${condition.toUpperCase()}', response, history: updatedHistory));
    } catch (e) {
      emit(AiError('Guidance Error: $e', history: history));
    }
  }

  Future<void> sendMessage(String message) async {
    final history = await _getHistory();
    emit(AiLoading(history: history));
    try {
      await _saveMessage(message, false);
      final response = await _aiService.chat(message);
      await _saveMessage(response, true);
      final updatedHistory = await _getHistory();
      emit(AiResponse('TERMINAL RESPONSE', response, history: updatedHistory));
    } catch (e) {
      emit(AiError('Chat Error: $e', history: history));
    }
  }

  void reset() async {
    await _isar.writeTxn(() => _isar.chatMessages.clear());
    emit(AiInitial());
  }
}
