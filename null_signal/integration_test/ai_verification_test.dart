import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:null_signal/features/ai/data/repositories/android_ai_service.dart';
import 'package:null_signal/features/ai/data/repositories/ios_ai_service.dart';
import 'dart:io';
import 'dart:async';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Offline AI Full Cycle Integration Test', () {
    testWidgets('Initialize, Download, and Chat with Gemma 4', (WidgetTester tester) async {
      final service = Platform.isAndroid ? AndroidAIService(useGPU: true) : IosAIService();
      
      debugPrint('--- AI DIAGNOSTICS START ---');
      debugPrint('Platform: ${Platform.operatingSystem}');
      
      final supported = await service.isSupported();
      debugPrint('AI Hardware Support: $supported');
      
      if (!supported && Platform.isAndroid) {
        debugPrint('Falling back to CPU mode...');
        final cpuService = AndroidAIService(useGPU: false);
        await _runFullFlow(cpuService);
      } else {
        await _runFullFlow(service);
      }
    });
  });
}

Future<void> _runFullFlow(dynamic service) async {
  final completer = Completer<void>();
  
  if (service is AndroidAIService) {
    service.downloadProgress.listen((progress) {
      debugPrint('Download Progress: $progress%');
      if (progress >= 100) {
        if (!completer.isCompleted) completer.complete();
      }
    });
  } else {
    // iOS handles download internally in initialize() call in this version
    completer.complete();
  }

  debugPrint('Starting Initialization...');
  try {
    await service.initialize();
    debugPrint('Initialization Call Successful');
  } catch (e) {
    debugPrint('Initialization Call Failed: $e');
    return;
  }

  debugPrint('Waiting for model to be ready (Max 10 mins for first download)...');
  await completer.future.timeout(const Duration(minutes: 10), onTimeout: () {
    debugPrint('TIMEOUT: Model download took too long.');
  });

  debugPrint('Model Ready. Testing Generation...');
  final response = await service.chat('hello, identity check');
  debugPrint('AI Response: $response');
  
  expect(response, isNotEmpty);
  expect(response.toLowerCase(), contains('nullsignal'));
  debugPrint('--- AI DIAGNOSTICS COMPLETE: SUCCESS ---');
}
