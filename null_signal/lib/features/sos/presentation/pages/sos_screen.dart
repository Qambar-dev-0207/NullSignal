import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:null_signal/core/services/feedback_service.dart';
import 'package:null_signal/features/sos/presentation/bloc/sos_cubit.dart';
import 'package:null_signal/features/sos/presentation/widgets/panic_button.dart';

class SosScreen extends StatelessWidget {
  const SosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SosCubit, SosState>(
      listener: (context, state) {
        if (state is SosBroadcastSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('SOS Broadcast Sent Successfully!'), backgroundColor: Colors.green),
          );
        } else if (state is SosError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('SOS Failed: ${state.message}'), backgroundColor: Colors.red),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'BROADCAST EMERGENCY',
              style: Theme.of(context).textTheme.displayLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            BlocBuilder<SosCubit, SosState>(
              builder: (context, state) {
                final isLoading = state is SosBroadcasting;
                return PanicButton(
                  label: isLoading ? 'SENDING...' : 'SEND SOS',
                  color: isLoading ? Colors.grey : const Color(0xFFFF5252),
                  textColor: Colors.white,
                  icon: isLoading ? Icons.hourglass_empty : Icons.sos,
                  onPressed: isLoading
                      ? () {}
                      : () {
                          FeedbackService.triggerSosHaptics();
                          context.read<SosCubit>().broadcastSos(
                                lat: 34.0522, // Static prototype lat
                                lon: -118.2437, // Static prototype lon
                              );
                        },
                );
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Transmitting to all nearby devices via NullSignal Mesh',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
