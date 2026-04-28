import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:isar/isar.dart';
import 'package:null_signal/features/ai/data/models/chat_message.dart';
import 'package:null_signal/features/ai/domain/entities/sector_summary.dart';
import 'package:null_signal/features/ai/domain/repositories/ai_service.dart';
import 'package:null_signal/features/ai/domain/repositories/mesh_insight_service.dart';
import 'package:null_signal/features/ai/data/repositories/gemini_ai_service.dart';
import 'package:null_signal/features/ai/data/repositories/android_ai_service.dart';

abstract class AiState {}

class AiInitial extends AiState {}
class AiProvisioning extends AiState {
  final int progress;
  final bool isError;
  AiProvisioning(this.progress, {this.isError = false});
}
class AiLoading extends AiState {
  final List<ChatMessage> history;
  AiLoading({this.history = const []});
}
class AiResponse extends AiState {
  final String title;
  final String content;
  final List<ChatMessage> history;
  final List<SectorSummary> sectorSummaries;
  AiResponse(this.title, this.content, {this.history = const [], this.sectorSummaries = const []});
}
class AiError extends AiState {
  final String message;
  final List<ChatMessage> history;
  AiError(this.message, {this.history = const []});
}

class AiCubit extends Cubit<AiState> {
  final AIService _aiService;
  final MeshInsightService _meshInsightService;
  final Isar _isar;
  StreamSubscription? _downloadSub;
  StreamSubscription? _summariesSub;

  AiCubit(this._aiService, this._meshInsightService, this._isar) : super(AiInitial());

  Future<void> initialize() async {
    _downloadSub?.cancel();
    _downloadSub = _aiService.downloadProgress.listen((progress) {
      if (progress < 100) {
        emit(AiProvisioning(progress, isError: progress == -1));
      }
    });

    try {
      await _aiService.initialize();
      _meshInsightService.start();

      _summariesSub?.cancel();
      _summariesSub = _meshInsightService.sectorSummariesStream.listen((summaries) {
        if (state is AiResponse) {
          final s = state as AiResponse;
          emit(AiResponse(s.title, s.content, history: s.history, sectorSummaries: summaries));
        }
      });

      final history = await _isar.chatMessages.where().sortByTimestamp().findAll();
      final summaries = await _meshInsightService.getStoredSummaries();
      emit(AiResponse('SYSTEM READY', 'Nano AI online.', history: history, sectorSummaries: summaries));
    } catch (e) {
      // ALREADY_INITIALIZING means a previous call is still running (e.g. a retry was
      // tapped while the original download was still in progress). In that case the
      // existing download is fine — just let it finish and the progress stream will
      // keep the UI updated.
      final message = e.toString();
      if (message.contains('ALREADY_INITIALIZING')) return;
      if (state is! AiProvisioning) {
        emit(AiError('AI Initialization Failed: $e'));
      }
    }
  }

  Future<void> forceRedownload() async {
    final aiService = _aiService;
    if (aiService is GeminiAIService) {
      if (aiService.nativeService is AndroidAIService) {
        await (aiService.nativeService as AndroidAIService).deleteModel();
        initialize();
      }
    }
  }

  @override
  Future<void> close() {
    _downloadSub?.cancel();
    _summariesSub?.cancel();
    return super.close();
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
      final response = await _aiService.chat(message, history: history);
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
