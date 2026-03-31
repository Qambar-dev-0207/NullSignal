import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:null_signal/core/theme/app_theme.dart';
import 'package:null_signal/core/theme/null_signal_widgets.dart';
import 'package:null_signal/features/ai/presentation/bloc/ai_cubit.dart';
import 'package:null_signal/features/ai/data/models/chat_message.dart';

class PanicAIHelpScreen extends StatefulWidget {
  const PanicAIHelpScreen({super.key});

  @override
  State<PanicAIHelpScreen> createState() => _PanicAIHelpScreenState();
}

class _PanicAIHelpScreenState extends State<PanicAIHelpScreen> {
  final TextEditingController _queryController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _queryController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<NullSignalColors>()!;
    final textTheme = Theme.of(context).textTheme;

    return NullSignalScaffold(
      title: 'NullSignal',
      actions: [
        Text(
          'EMERGENCY AI',
          style: textTheme.labelSmall?.copyWith(
            color: colors.primaryContainer,
            fontSize: 11,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(width: 16),
        Icon(Icons.battery_charging_full, size: 20, color: colors.primary),
        const SizedBox(width: 24),
      ],
      body: BlocConsumer<AiCubit, AiState>(
        listener: (context, state) {
          if (state is AiResponse || state is AiError || state is AiLoading) {
            _scrollToBottom();
          }
        },
        builder: (context, state) {
          List<ChatMessage> history = [];
          if (state is AiResponse) history = state.history;
          if (state is AiLoading) history = state.history;
          if (state is AiError) history = state.history;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              _animateIn(child: _buildTerminalQuery(context, colors, textTheme), delay: 0),
              const SizedBox(height: 24),

              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(bottom: 32),
                  itemCount: history.length + (state is AiLoading ? 1 : 0) + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'EMERGENCY FAQ',
                                style: textTheme.labelSmall?.copyWith(
                                  fontSize: 9,
                                  color: colors.onSurface.withOpacity(0.4),
                                ),
                              ),
                              Icon(Icons.emergency, color: colors.onSurface.withOpacity(0.4), size: 14),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildFaqItem(context, 'SNAKE BITE PROTOCOL', Icons.bug_report, colors, textTheme),
                          const SizedBox(height: 8),
                          _buildFaqItem(context, 'SEVERE WOUND CARE', Icons.healing, colors, textTheme),
                          const SizedBox(height: 8),
                          _buildFaqItem(context, 'BURN MANAGEMENT', Icons.fire_hydrant_alt, colors, textTheme),
                          const SizedBox(height: 32),
                        ],
                      );
                    }
                    
                    final historyIndex = index - 1;
                    if (historyIndex < history.length) {
                      final msg = history[historyIndex];
                      return _buildChatMessage(msg, colors, textTheme);
                    }
                    
                    if (state is AiLoading && historyIndex == history.length) {
                      return _buildTerminalPlaceholder('DECRYPTING RESPONSE...', colors, textTheme);
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildChatMessage(ChatMessage msg, NullSignalColors colors, TextTheme textTheme) {
    final isAI = msg.isAI;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isAI ? colors.surfaceContainerLowest : colors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isAI ? colors.primary.withOpacity(0.1) : colors.outlineVariant.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isAI ? Icons.terminal : Icons.person_outline,
                size: 14,
                color: isAI ? colors.primary : colors.onSurface.withOpacity(0.5),
              ),
              const SizedBox(width: 8),
              Text(
                isAI ? 'NANO_AI' : 'USER_AUTH',
                style: textTheme.labelSmall?.copyWith(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: isAI ? colors.primary : colors.onSurface.withOpacity(0.5),
                ),
              ),
              const Spacer(),
              Text(
                '${DateTime.fromMillisecondsSinceEpoch(msg.timestamp).hour}:${DateTime.fromMillisecondsSinceEpoch(msg.timestamp).minute}',
                style: textTheme.labelSmall?.copyWith(fontSize: 8, color: colors.onSurface.withOpacity(0.3)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            msg.content,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 13,
              height: 1.5,
              color: colors.onSurface.withOpacity(0.9),
            ),
          ),
        ],
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

  Widget _buildFaqItem(BuildContext context, String title, IconData icon, NullSignalColors colors, TextTheme textTheme) {
    return GestureDetector(
      onTap: () {
        context.read<AiCubit>().getGuidance(title);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.outlineVariant.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: colors.primary.withOpacity(0.6)),
            const SizedBox(width: 16),
            Text(
              title,
              style: textTheme.labelSmall?.copyWith(fontSize: 11, color: colors.onSurface, fontWeight: FontWeight.w900),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, size: 12, color: colors.onSurface.withOpacity(0.2)),
          ],
        ),
      ),
    );
  }

  Widget _buildTerminalQuery(BuildContext context, NullSignalColors colors, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: colors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: colors.primary.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Text(
              'TERM >',
              style: textTheme.labelSmall?.copyWith(
                fontSize: 10,
                color: colors.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _queryController,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  hintText: 'ASK NANO...',
                  hintStyle: TextStyle(
                    color: colors.onSurface.withOpacity(0.2),
                    letterSpacing: 1.5,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                ),
                textInputAction: TextInputAction.go,
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    context.read<AiCubit>().sendMessage(value);
                    _queryController.clear();
                  }
                },
              ),
            ),
            Icon(Icons.send, color: colors.primary, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildTerminalPlaceholder(String text, NullSignalColors colors, TextTheme textTheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outlineVariant.withOpacity(0.1), style: BorderStyle.solid),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}
