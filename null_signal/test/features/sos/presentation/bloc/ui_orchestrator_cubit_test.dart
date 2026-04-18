import 'package:flutter_test/flutter_test.dart';
import 'package:null_signal/features/sos/presentation/bloc/ui_orchestrator_cubit.dart';

void main() {
  late UIOrchestratorCubit cubit;

  setUp(() {
    cubit = UIOrchestratorCubit();
  });

  tearDown(() {
    cubit.close();
  });

  group('UIOrchestratorCubit Tests', () {
    test('Initial state is AppUIState.normal', () {
      expect(cubit.state, equals(AppUIState.normal));
      expect(cubit.isPanic, isFalse);
    });

    test('switchToPanic emits AppUIState.panic', () {
      cubit.switchToPanic();
      expect(cubit.state, equals(AppUIState.panic));
      expect(cubit.isPanic, isTrue);
    });

    test('switchToNormal emits AppUIState.normal', () {
      cubit.switchToPanic();
      cubit.switchToNormal();
      expect(cubit.state, equals(AppUIState.normal));
    });

    test('toggle switches between states', () {
      cubit.toggle();
      expect(cubit.state, equals(AppUIState.panic));
      cubit.toggle();
      expect(cubit.state, equals(AppUIState.normal));
    });
  });
}
