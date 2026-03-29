import 'package:flutter_bloc/flutter_bloc.dart';

enum AppUIState { normal, panic }

class UIOrchestratorCubit extends Cubit<AppUIState> {
  UIOrchestratorCubit() : super(AppUIState.normal);

  void switchToPanic() => emit(AppUIState.panic);
  void switchToNormal() => emit(AppUIState.normal);
  
  void toggle() {
    if (state == AppUIState.normal) {
      switchToPanic();
    } else {
      switchToNormal();
    }
  }

  bool get isPanic => state == AppUIState.panic;
}
