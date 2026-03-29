import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:null_signal/features/ai/domain/repositories/ai_service.dart';

abstract class AiState {}

class AiInitial extends AiState {}
class AiLoading extends AiState {}
class AiResponse extends AiState {
  final String title;
  final String content;
  AiResponse(this.title, this.content);
}
class AiError extends AiState {
  final String message;
  AiError(this.message);
}

class AiCubit extends Cubit<AiState> {
  final AIService _aiService;

  AiCubit(this._aiService) : super(AiInitial());

  Future<void> initialize() async {
    try {
      await _aiService.initialize();
    } catch (e) {
      emit(AiError('AI Initialization Failed: $e'));
    }
  }

  Future<void> getTriage(String symptoms) async {
    emit(AiLoading());
    try {
      final response = await _aiService.getTriageResponse(symptoms);
      emit(AiResponse('START TRIAGE SCORE', response));
    } catch (e) {
      emit(AiError('Triage Error: $e'));
    }
  }

  Future<void> getGuidance(String condition) async {
    emit(AiLoading());
    try {
      final response = await _aiService.getFirstAidGuidance(condition);
      emit(AiResponse('FIRST-AID GUIDE: $condition', response));
    } catch (e) {
      emit(AiError('Guidance Error: $e'));
    }
  }

  void reset() => emit(AiInitial());
}
