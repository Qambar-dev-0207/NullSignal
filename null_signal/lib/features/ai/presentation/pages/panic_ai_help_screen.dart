import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:null_signal/core/theme/app_theme.dart';
import 'package:null_signal/core/theme/null_signal_widgets.dart';
import 'package:null_signal/core/utils/animations.dart';
import 'package:null_signal/features/ai/domain/entities/sector_summary.dart';
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: colors.primaryContainer.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.primaryContainer.withValues(alpha: 0.2)),
          ),
          child: Text(
            'SECURE AI',
            style: textTheme.labelSmall?.copyWith(
              color: colors.primaryContainer,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 24),
      ],
      body: BlocConsumer<AiCubit, AiState>(
        listener: (context, state) {
          if (state is AiResponse || state is AiError || state is AiLoading) {
            _scrollToBottom();
          }
        },
        builder: (context, state) {
          if (state is AiProvisioning) {
            return _buildProvisioningOverlay(context, state, colors, textTheme);
          }

          List<ChatMessage> history = [];
          List<SectorSummary> sectorSummaries = [];
          if (state is AiResponse) {
            history = state.history;
            sectorSummaries = state.sectorSummaries;
          }
          if (state is AiLoading) history = state.history;
          if (state is AiError) history = state.history;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              FadeInAnimation(
                child: _buildTerminalQuery(context, colors, textTheme),
              ),
              const SizedBox(height: 24),

              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(bottom: 32),
                  itemCount: history.length + (state is AiLoading ? 1 : 0) + (sectorSummaries.isNotEmpty ? 2 : 1),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return FadeInAnimation(
                        delay: const Duration(milliseconds: 200),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'EMERGENCY PROTOCOLS',
                                  style: textTheme.labelSmall?.copyWith(
                                    fontSize: 9,
                                    color: colors.onSurface.withValues(alpha: 0.4),
                                    letterSpacing: 2.0,
                                  ),
                                ),
                                Icon(Icons.security, color: colors.onSurface.withValues(alpha: 0.2), size: 14),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildProtocolGrid(context, colors, textTheme),
                            const SizedBox(height: 32),
                            if (sectorSummaries.isNotEmpty) ...[
                              _buildSectorSummarySection(sectorSummaries, colors, textTheme),
                              const SizedBox(height: 32),
                            ],
                            const Divider(height: 1),
                            const SizedBox(height: 32),
                          ],
                        ),
                      );
                    }
                    
                    final historyIndex = index - 1;
                    if (historyIndex < history.length) {
                      final msg = history[historyIndex];
                      return FadeInAnimation(
                        offset: const Offset(10, 0),
                        child: _buildChatMessage(msg, colors, textTheme),
                      );
                    }
                    
                    if (state is AiLoading && historyIndex == history.length) {
                      return FadeInAnimation(
                        child: _buildLoadingTerminal(colors, textTheme),
                      );
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

  Widget _buildSectorSummarySection(List<SectorSummary> summaries, NullSignalColors colors, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'SECTOR SUMMARIES',
              style: textTheme.labelSmall?.copyWith(
                fontSize: 9,
                color: colors.primary,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'LIVE',
                style: textTheme.labelSmall?.copyWith(fontSize: 7, color: colors.primary, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: summaries.length,
            itemBuilder: (context, index) {
              final summary = summaries[index];
              return Container(
                width: 280,
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colors.primary.withValues(alpha: 0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          summary.sectorId,
                          style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold, color: colors.primary),
                        ),
                        Text(
                          '${summary.survivorCount} SURVIVORS',
                          style: textTheme.labelSmall?.copyWith(fontSize: 8, color: colors.onSurface.withValues(alpha: 0.5)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Text(
                        summary.summary,
                        style: textTheme.bodySmall?.copyWith(fontSize: 11, height: 1.4),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      children: summary.urgentNeeds.take(3).map((need) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: colors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          need.toUpperCase(),
                          style: textTheme.labelSmall?.copyWith(fontSize: 7, color: colors.error, fontWeight: FontWeight.bold),
                        ),
                      )).toList(),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProtocolGrid(BuildContext context, NullSignalColors colors, TextTheme textTheme) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.5,
      children: [
        _buildProtocolItem(context, 'SNAKE BITE', Icons.bug_report, colors, textTheme),
        _buildProtocolItem(context, 'WOUND CARE', Icons.healing, colors, textTheme),
        _buildProtocolItem(context, 'BURN MGMT', Icons.fire_hydrant_alt, colors, textTheme),
        _buildProtocolItem(context, 'CPR STEPS', Icons.favorite, colors, textTheme),
      ],
    );
  }

  Widget _buildProtocolItem(BuildContext context, String title, IconData icon, NullSignalColors colors, TextTheme textTheme) {
    return GestureDetector(
      onTap: () {
        context.read<AiCubit>().getGuidance(title);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: colors.primary.withValues(alpha: 0.6)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: textTheme.labelSmall?.copyWith(fontSize: 9, color: colors.onSurface, fontWeight: FontWeight.w900),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatMessage(ChatMessage msg, NullSignalColors colors, TextTheme textTheme) {
    final isAI = msg.isAI;
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isAI ? colors.primary.withValues(alpha: 0.1) : colors.onSurface.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isAI ? Icons.psychology : Icons.person,
              size: 16,
              color: isAI ? colors.primary : colors.onSurface.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      isAI ? 'AI ASSISTANT' : 'YOU',
                      style: textTheme.labelSmall?.copyWith(
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        color: isAI ? colors.primary : colors.onSurface.withValues(alpha: 0.4),
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '• ${DateTime.fromMillisecondsSinceEpoch(msg.timestamp).hour}:${DateTime.fromMillisecondsSinceEpoch(msg.timestamp).minute.toString().padLeft(2, '0')}',
                      style: textTheme.labelSmall?.copyWith(fontSize: 8, color: colors.onSurface.withValues(alpha: 0.2)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isAI ? colors.surfaceContainerLowest : Colors.transparent,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    border: isAI ? Border.all(color: colors.primary.withValues(alpha: 0.05)) : null,
                  ),
                  child: Text(
                    msg.content,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      height: 1.6,
                      color: colors.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTerminalQuery(BuildContext context, NullSignalColors colors, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: colors.onSurface.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            '//',
            style: TextStyle(
              fontSize: 14,
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
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                hintText: 'INPUT SECURE QUERY...',
                hintStyle: TextStyle(
                  color: colors.onSurface.withValues(alpha: 0.2),
                  fontSize: 12,
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
          PulseContainer(
            color: colors.primary,
            child: GestureDetector(
              onTap: () {
                if (_queryController.text.isNotEmpty) {
                  context.read<AiCubit>().sendMessage(_queryController.text);
                  _queryController.clear();
                }
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.arrow_upward, color: Colors.white, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingTerminal(NullSignalColors colors, TextTheme textTheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(height: 16),
          Text(
            'DECRYPTING AI PAYLOAD...',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: colors.onSurface.withValues(alpha: 0.3),
              letterSpacing: 2.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProvisioningOverlay(BuildContext context, AiProvisioning state, NullSignalColors colors, TextTheme textTheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: state.isError ? colors.error.withValues(alpha: 0.3) : colors.primary.withValues(alpha: 0.1)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 40, offset: const Offset(0, 10)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    state.isError ? Icons.sync_problem : Icons.cloud_download,
                    size: 48,
                    color: state.isError ? colors.error : colors.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    state.isError ? 'PROVISIONING FAILED' : (state.progress == 99 ? 'INITIALIZING ENGINE' : 'PROVISIONING OFFLINE AI'),
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      color: state.isError ? colors.error : colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.isError 
                      ? 'Connection interrupted or license verification failed.' 
                      : (state.progress == 99 
                          ? 'Loading Gemma 4 weights into secure memory. This may take 30-60 seconds...'
                          : 'Downloading Gemma 4 E2B weights (2.6GB). This happens only once.'),
                    textAlign: TextAlign.center,
                    style: textTheme.bodySmall?.copyWith(color: colors.onSurface.withValues(alpha: 0.5)),
                  ),
                  const SizedBox(height: 32),
                  if (!state.isError) ...[
                    if (state.progress == 99)
                      const BaryonLoader(size: 40)
                    else
                      Stack(
                        children: [
                          Container(
                            height: 6,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: colors.onSurface.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            height: 6,
                            width: MediaQuery.of(context).size.width * (state.progress / 100),
                            decoration: BoxDecoration(
                              color: colors.primary,
                              borderRadius: BorderRadius.circular(3),
                              boxShadow: [
                                BoxShadow(color: colors.primary.withValues(alpha: 0.4), blurRadius: 8),
                              ],
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          state.progress == 99 ? 'BOOTING...' : '${state.progress}% COMPLETE',
                          style: textTheme.labelSmall?.copyWith(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                            color: colors.primary,
                          ),
                        ),
                        Text(
                          'DO NOT CLOSE APP',
                          style: textTheme.labelSmall?.copyWith(
                            fontSize: 8,
                            color: colors.onSurface.withValues(alpha: 0.3),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => context.read<AiCubit>().forceRedownload(),
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('RETRY PROVISIONING'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.error,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
