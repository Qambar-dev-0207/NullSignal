import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:null_signal/features/ai/presentation/bloc/ai_cubit.dart';
import 'package:null_signal/features/sos/presentation/widgets/panic_button.dart';

class PanicAiHelpScreen extends StatelessWidget {
  const PanicAiHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AiCubit, AiState>(
      listener: (context, state) {
        if (state is AiResponse) {
          _showAiDialog(context, state.title, state.content);
        } else if (state is AiError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AiLoading;

        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'OFFLINE AI HELP',
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: 24),
              const Text(
                'Select immediate need:',
                style: TextStyle(fontSize: 24, color: Colors.white70),
              ),
              const SizedBox(height: 24),
              if (isLoading)
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFFFFEB3B)),
                  ),
                )
              else
                Expanded(
                  child: ListView(
                    children: [
                      PanicButton(
                        label: 'TRIAGE ME',
                        icon: Icons.assignment_ind,
                        onPressed: () => context.read<AiCubit>().getTriage('I am feeling dizzy and have a headache.'),
                      ),
                      const SizedBox(height: 16),
                      PanicButton(
                        label: 'CPR GUIDE',
                        icon: Icons.favorite,
                        onPressed: () => context.read<AiCubit>().getGuidance('CPR'),
                      ),
                      const SizedBox(height: 16),
                      PanicButton(
                        label: 'BLEEDING',
                        icon: Icons.opacity,
                        onPressed: () => context.read<AiCubit>().getGuidance('Bleeding Control'),
                      ),
                      const SizedBox(height: 16),
                      PanicButton(
                        label: 'FRACTURES',
                        icon: Icons.personal_injury,
                        onPressed: () => context.read<AiCubit>().getGuidance('Fractures'),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showAiDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        title: Text(title, style: const TextStyle(color: Color(0xFFFFEB3B), fontSize: 28)),
        content: SingleChildScrollView(
          child: Text(content, style: const TextStyle(color: Colors.white, fontSize: 20)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('DISMISS', style: TextStyle(color: Color(0xFFFFEB3B), fontSize: 20)),
          ),
        ],
      ),
    );
  }
}
