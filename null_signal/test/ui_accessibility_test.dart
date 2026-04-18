import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:isar/isar.dart';
import 'package:mocktail/mocktail.dart';
import 'package:null_signal/core/services/mesh_service.dart';
import 'package:null_signal/core/services/security_service.dart';
import 'package:null_signal/core/services/gateway_monitor.dart';
import 'package:null_signal/core/theme/app_theme.dart';
import 'package:null_signal/features/mesh/data/repositories/nearby_mesh_service_impl.dart';
import 'package:null_signal/features/sos/presentation/bloc/sos_cubit.dart';
import 'package:null_signal/features/sos/presentation/bloc/ui_orchestrator_cubit.dart';
import 'package:null_signal/features/sos/presentation/widgets/panic_button.dart';
import 'package:null_signal/features/sos/presentation/pages/sos_screen.dart';

class MockIsar extends Mock implements Isar {}

void main() {
  late MockIsar mockIsar;
  late SecurityService securityService;

  setUp(() {
    mockIsar = MockIsar();
    securityService = SecurityService(mockIsar);
  });

  Widget createTestWidget(Widget child, {UIOrchestratorCubit? cubit}) {
    return BlocProvider.value(
      value: cubit ?? UIOrchestratorCubit(),
      child: MaterialApp(
        theme: AppTheme.panicTheme,
        home: Scaffold(body: child),
      ),
    );
  }

  group('UI & Accessibility Tests', () {
    testWidgets('PanicButton should have a minimum height of 96px', (tester) async {
      await tester.pumpWidget(createTestWidget(
        PanicButton(label: 'TEST', onPressed: () {}),
      ));

      final buttonFinder = find.byType(ElevatedButton);
      final RenderBox buttonBox = tester.renderObject(buttonFinder);
      
      expect(buttonBox.size.height, greaterThanOrEqualTo(96.0));
    });

    testWidgets('PanicButton should have correct semantics', (tester) async {
      await tester.pumpWidget(createTestWidget(
        PanicButton(label: 'SOS', onPressed: () {}),
      ));

      final semantics = tester.getSemantics(find.byType(PanicButton));
      expect(semantics.label, 'Panic Action: SOS');
      expect(semantics.hint, 'Large tap area, triggers immediately');
    });

    testWidgets('SosScreen should show large SEND SOS button', (tester) async {
      final gatewayMonitor = GatewayMonitor();
      final meshService = NearbyMeshServiceImpl(gatewayMonitor, securityService, mockIsar);

      await tester.pumpWidget(
        MultiRepositoryProvider(
          providers: [
            RepositoryProvider<MeshService>.value(value: meshService),
            RepositoryProvider<SecurityService>.value(value: securityService),
          ],
          child: MultiBlocProvider(
            providers: [
              BlocProvider(create: (context) => SosCubit(context.read<MeshService>(), context.read<SecurityService>(), 'test_id')),
            ],
            child: createTestWidget(const SosScreen()),
          ),
        ),
      );

      expect(find.text('SEND SOS'), findsOneWidget);
      expect(find.text('BROADCAST EMERGENCY'), findsOneWidget);
    });

    test('UIOrchestrator should toggle state', () {
      final cubit = UIOrchestratorCubit();
      expect(cubit.state, AppUIState.normal);
      cubit.switchToPanic();
      expect(cubit.state, AppUIState.panic);
      cubit.switchToNormal();
      expect(cubit.state, AppUIState.normal);
    });
  });
}
