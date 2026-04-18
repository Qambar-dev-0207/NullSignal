import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:null_signal/core/services/feedback_service.dart';
import 'package:null_signal/core/theme/app_theme.dart';
import 'package:null_signal/core/theme/null_signal_widgets.dart';
import 'package:null_signal/core/utils/animations.dart';
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
  late AnimationController _shakeController;
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

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 50),
    );

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _onSOSTriggered();
      }
    });

    _progressController.addListener(() {
      if (_isHolding && _progressController.value > 0.7) {
        if (!_shakeController.isAnimating) {
          _shakeController.repeat(reverse: true);
        }
      } else {
        _shakeController.stop();
      }
    });
  }

  void _onSOSTriggered() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      if (!mounted) return;
      context.read<SosCubit>().broadcastSos(lat: position.latitude, lon: position.longitude);
    } catch (e) {
      if (!mounted) return;
      context.read<SosCubit>().broadcastSos(lat: 40.7128, lon: -74.0060);
    }
    _shakeController.stop();
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pulseController.dispose();
    _shakeController.dispose();
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
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
          _progressController.reset();
        } else if (state is SosError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: colors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
          _progressController.reset();
        }
      },
      child: AnimatedBuilder(
        animation: _shakeController,
        builder: (context, child) {
          double shakeOffset = 0;
          if (_shakeController.isAnimating) {
            shakeOffset = (math.Random().nextDouble() - 0.5) * 10 * _progressController.value;
          }
          return Transform.translate(
            offset: Offset(shakeOffset, shakeOffset),
            child: child,
          );
        },
        child: NullSignalScaffold(
          title: 'NullSignal',
          actions: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: colors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colors.error.withValues(alpha: 0.2)),
              ),
              child: const GlitchText(
                'PANIC ACTIVE',
                style: TextStyle(color: Colors.red, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.0),
              ),
            ),
            const SizedBox(width: 16),
            Icon(Icons.battery_charging_full, size: 20, color: colors.primary),
            const SizedBox(width: 24),
          ],
          body: ListView(
            padding: const EdgeInsets.only(top: 40, bottom: 40),
            children: [
              FadeInAnimation(
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
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return Container(
                              width: 320 + (40 * _pulseController.value),
                              height: 320 + (40 * _pulseController.value),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    colors.error.withValues(alpha: 0.15 * (1 - _pulseController.value)),
                                    colors.error.withValues(alpha: 0),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return Container(
                              width: 260 + (30 * _pulseController.value),
                              height: 260 + (30 * _pulseController.value),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: colors.error.withValues(alpha: 0.1 * (1 - _pulseController.value)),
                                  width: 2,
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(
                          width: 240,
                          height: 240,
                          child: AnimatedBuilder(
                            animation: _progressController,
                            builder: (context, child) {
                              return CircularProgressIndicator(
                                value: _progressController.value,
                                strokeWidth: 12,
                                color: colors.error,
                                backgroundColor: colors.surfaceContainerLow,
                                strokeCap: StrokeCap.round,
                              );
                            },
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 100),
                          width: _isHolding ? 180 : 200,
                          height: _isHolding ? 180 : 200,
                          decoration: BoxDecoration(
                            color: colors.error,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: colors.error.withValues(alpha: 0.4),
                                blurRadius: _isHolding ? 60 : 40,
                                offset: const Offset(0, 10),
                              ),
                              if (!_isHolding)
                                BoxShadow(
                                  color: Colors.white.withValues(alpha: 0.3),
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
                                Color.lerp(colors.error, Colors.black, 0.2)!,
                              ],
                            ),
                          ),
                          alignment: Alignment.center,
                          child: BlocBuilder<SosCubit, SosState>(
                            builder: (context, state) {
                              if (state is SosBroadcasting) {
                                return const BaryonLoader(color: Colors.white, size: 40);
                              }
                              return Text(
                                'SOS',
                                style: textTheme.displayLarge?.copyWith(
                                  color: Colors.white,
                                  fontSize: 72,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -4.0,
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
              FadeInAnimation(
                delay: const Duration(milliseconds: 200),
                child: Column(
                  children: [
                    Text(
                      _isHolding ? 'RELEASING ABORTS' : 'HOLD TO BROADCAST',
                      style: textTheme.labelSmall?.copyWith(
                        letterSpacing: 4.0,
                        color: _isHolding ? colors.error : colors.onSurface.withValues(alpha: 0.4),
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
                                : colors.onSurface.withValues(alpha: 0.1),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 64),
              Column(
                children: [
                  FadeInAnimation(
                    delay: const Duration(milliseconds: 400),
                    child: NullSignalCard(
                      padding: const EdgeInsets.all(20),
                      color: colors.surfaceContainerLow,
                      child: Row(
                        children: [
                          PulseContainer(
                            color: colors.primary,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: colors.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.security, color: colors.primary, size: 20),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('ENCRYPTION: AES-256-GCM', style: textTheme.labelSmall?.copyWith(fontSize: 8, color: colors.onSurface.withValues(alpha: 0.4))),
                                Text('SECURE MESH TUNNEL ACTIVE', style: textTheme.labelSmall?.copyWith(fontSize: 12, color: colors.onSurface, fontWeight: FontWeight.w900)),
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
                        child: FadeInAnimation(
                          delay: const Duration(milliseconds: 500),
                          child: _buildTechnicalCell('SATELLITE', 'SEARCHING...', Icons.satellite_alt, colors, textTheme),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FadeInAnimation(
                          delay: const Duration(milliseconds: 600),
                          child: _buildTechnicalCell('NODE ID', 'NS-ALPHA-01', Icons.fingerprint, colors, textTheme),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTechnicalCell(String label, String value, IconData icon, NullSignalColors colors, TextTheme textTheme) {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: textTheme.labelSmall?.copyWith(fontSize: 8, color: colors.onSurface.withValues(alpha: 0.4), letterSpacing: 1.0)),
              Icon(icon, size: 14, color: colors.onSurface.withValues(alpha: 0.3)),
            ],
          ),
          Text(value, style: textTheme.labelSmall?.copyWith(fontSize: 11, color: colors.onSurface, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}
