import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:null_signal/features/ai/data/repositories/android_ai_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AndroidAIService Initialization Flow', () {
    const channel = MethodChannel('com.nullsignal/aicore');
    final log = <MethodCall>[];

    setUp(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (methodCall) async {
        log.add(methodCall);
        if (methodCall.method == 'isSupported') return true;
        if (methodCall.method == 'initializeModel') return true;
        return null;
      });
    });

    tearDown(() {
      log.clear();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
    });

    test('isSupported calls native method', () async {
      final service = AndroidAIService();
      final result = await service.isSupported();
      expect(result, true);
      expect(log.last.method, 'isSupported');
    });

    test('initialize calls native initializeModel with useGPU flag', () async {
      final service = AndroidAIService(useGPU: true);
      await service.initialize();
      expect(log.any((call) => call.method == 'initializeModel' && call.arguments['useGPU'] == true), true);
    });

    test('initialization with CPU flag (useGPU: false)', () async {
      final service = AndroidAIService(useGPU: false);
      await service.initialize();
      expect(log.any((call) => call.method == 'initializeModel' && call.arguments['useGPU'] == false), true);
    });

    test('progress stream receives data from native side', () async {
      // Placeholder for internal stream verification
    });
  });
}
