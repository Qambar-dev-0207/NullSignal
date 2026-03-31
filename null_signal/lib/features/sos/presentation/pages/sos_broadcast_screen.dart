import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:null_signal/core/services/feedback_service.dart';
import 'package:null_signal/core/theme/app_theme.dart';
import 'package:null_signal/core/theme/null_signal_widgets.dart';
import 'package:null_signal/features/sos/presentation/bloc/sos_cubit.dart';

class SOSBroadcastScreen extends StatefulWidget {
  const SOSBroadcastScreen({super.key});

  @override
  State<SOSBroadcastScreen> createState() => _SOSBroadcastScreenState();
}

class _SOSBroadcastScreenState extends State<SOSBroadcastScreen>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _pulseController;
  bool _isHolding = false;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _onSOSTriggered();
      }
    });
  }

  void _onSOSTriggered() {
    context.read<SosCubit>().broadcastSos(lat: 40.7128, lon: -74.0060);
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<NullSignalColors>()!;
    final textTheme = Theme.of(context).textTheme;

    return BlocListener<SosCubit, SosState>(
      listener: (context, state) {
        if (state is SosBroadcastSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('EMERGENCY BROADCAST SENT: ${state.packetId.substring(0, 8)}'),
              backgroundColor: Colors.green,
            ),
          );
          _progressController.reset();
        } else if (state is SosError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: colors.error,
            ),
          );
          _progressController.reset();
        }
      },
      child: NullSignalScaffold(
        title: 'NullSignal',
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: colors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colors.error.withOpacity(0.2)),
            ),
            child: Text(
              'PANIC ACTIVE',
              style: textTheme.labelSmall?.copyWith(
                color: colors.error,
                fontSize: 9,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Icon(Icons.battery_charging_full, size: 20, color: colors.primary),
          const SizedBox(width: 24),
        ],
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      // High-Fidelity SOS Center Area
                      _animateIn(
                        delay: 0,
                        child: Center(
                          child: GestureDetector(
                            onTapDown: (_) {
                              setState(() => _isHolding = true);
                              _progressController.forward();
                              FeedbackService.triggerSosHaptics();
                            },
                            onTapUp: (_) {
                              setState(() => _isHolding = false);
                              _progressController.reverse();
                            },
                            onTapCancel: () {
                              setState(() => _isHolding = false);
                              _progressController.reverse();
                            },
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Outer Atmospheric Glow
                                AnimatedBuilder(
                                  animation: _pulseController,
                                  builder: (context, child) {
                                    return Container(
                                      width: 340 + (40 * _pulseController.value),
                                      height: 340 + (40 * _pulseController.value),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: RadialGradient(
                                          colors: [
                                            colors.error.withOpacity(0.15 * (1 - _pulseController.value)),
                                            colors.error.withOpacity(0),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                // Pulsing Rings
                                AnimatedBuilder(
                                  animation: _pulseController,
                                  builder: (context, child) {
                                    return Container(
                                      width: 280 + (30 * _pulseController.value),
                                      height: 280 + (30 * _pulseController.value),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: colors.error.withOpacity(0.1 * (1 - _pulseController.value)),
                                          width: 2,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                // Progress Ring (The Security Gate)
                                SizedBox(
                                  width: 260,
                                  height: 260,
                                  child: AnimatedBuilder(
                                    animation: _progressController,
                                    builder: (context, child) {
                                      return CircularProgressIndicator(
                                        value: _progressController.value,
                                        strokeWidth: 8,
                                        color: colors.error,
                                        backgroundColor: colors.surfaceContainerLow,
                                        strokeCap: StrokeCap.round,
                                      );
                                    },
                                  ),
                                ),
                                // Main SOS Button
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 100),
                                  width: _isHolding ? 200 : 220,
                                  height: _isHolding ? 200 : 220,
                                  decoration: BoxDecoration(
                                    color: colors.error,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: colors.error.withOpacity(0.4),
                                        blurRadius: _isHolding ? 60 : 40,
                                        offset: const Offset(0, 10),
                                      ),
                                      if (!_isHolding)
                                        BoxShadow(
                                          color: Colors.white.withOpacity(0.3),
                                          blurRadius: 0,
                                          offset: const Offset(0, -6),
                                          spreadRadius: -2,
                                        ),
                                    ],
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        colors.error,
                                        Color.lerp(colors.error, Colors.black, 0.1)!,
                                      ],
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: BlocBuilder<SosCubit, SosState>(
                                    builder: (context, state) {
                                      if (state is SosBroadcasting) {
                                        return const CircularProgressIndicator(color: Colors.white);
                                      }
                                      return Text(
                                        'SOS',
                                        style: textTheme.displayLarge?.copyWith(
                                          color: Colors.white,
                                          fontSize: 84,
                                          letterSpacing: -6.0,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),
                      // Status indicators
                      _animateIn(
                        delay: 1,
                        child: Column(
                          children: [
                            Text(
                              _isHolding ? 'RELEASING ABORTS' : 'HOLD TO BROADCAST',
                              style: textTheme.labelSmall?.copyWith(
                                letterSpacing: 4.0,
                                color: _isHolding ? colors.error : colors.onSurface.withOpacity(0.4),
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(5, (index) {
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width: 8,
                                  height: 8,
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _isHolding && _progressController.value > (index / 5)
                                        ? colors.error 
                                        : colors.onSurface.withOpacity(0.1),
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // Technical Data Bento
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Column(
                          children: [
                            _animateIn(
                              delay: 2,
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: colors.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: colors.outlineVariant.withOpacity(0.1)),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: colors.primary.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(Icons.security, color: colors.primary, size: 20),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('ENCRYPTION: AES-256', style: textTheme.labelSmall?.copyWith(fontSize: 8, color: colors.onSurface.withOpacity(0.4))),
                                          Text('Secure Mesh Tunnel Active', style: textTheme.labelSmall?.copyWith(fontSize: 12, color: colors.onSurface, fontWeight: FontWeight.w900)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _animateIn(delay: 3, child: _buildTechnicalCell('SATELLITE', 'Searching...', Icons.satellite_alt, colors, textTheme)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _animateIn(delay: 4, child: _buildTechnicalCell('NODE ID', 'NS-ALPHA-01', Icons.fingerprint, colors, textTheme)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _animateIn({required Widget child, required int delay}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + (delay * 100)),
      curve: Curves.easeOutQuart,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  Widget _buildTechnicalCell(String label, String value, IconData icon, NullSignalColors colors, TextTheme textTheme) {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: textTheme.labelSmall?.copyWith(fontSize: 8, color: colors.onSurface.withOpacity(0.4))),
              Icon(icon, size: 14, color: colors.onSurface.withOpacity(0.3)),
            ],
          ),
          Text(value, style: textTheme.labelSmall?.copyWith(fontSize: 12, color: colors.onSurface, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}
