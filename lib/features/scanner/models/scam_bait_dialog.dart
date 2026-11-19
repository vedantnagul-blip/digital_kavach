import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/kavach_button.dart';
import '../../../core/widgets/kavach_scaffold.dart';
import '../../../data/ai/gemma_plugin_service.dart';
import '../models/scam_bait_generator.dart';

/// Dialog for generating decoy replies to scammers (Ramesh Kaka mode)
class ScamBaitDialog extends ConsumerStatefulWidget {
  const ScamBaitDialog({
    required this.scamText,
    super.key,
  });

  final String scamText;

  @override
  ConsumerState<ScamBaitDialog> createState() => _ScamBaitDialogState();
}

class _ScamBaitDialogState extends ConsumerState<ScamBaitDialog> {
  String? _baitReply;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _generateBaitReply();
  }

  Future<void> _generateBaitReply() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _baitReply = null;
    });

    try {
      final gemmaService = ref.read(gemmaPluginServiceProvider);

      // Try Gemma first if available
      if (gemmaService.isReady) {
        final reply = await gemmaService.generateBaitReply(widget.scamText);
        if (reply != null && reply.isNotEmpty) {
          setState(() {
            _baitReply = reply;
            _isLoading = false;
          });
          return;
        }
      }

      // Fallback to heuristic templates
      final fallbackReply = ScamBaitGenerator.generateBaitReply(widget.scamText);
      setState(() {
        _baitReply = fallbackReply;
        _isLoading = false;
      });
    } catch (e) {
      // Fallback to heuristic templates on error
      try {
        final fallbackReply = ScamBaitGenerator.generateBaitReply(widget.scamText);
        setState(() {
          _baitReply = fallbackReply;
          _isLoading = false;
        });
      } catch (fallbackError) {
        setState(() {
          _error = 'Failed to generate bait reply: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _copyToClipboard() async {
    if (_baitReply == null) return;

    await Clipboard.setData(ClipboardData(text: _baitReply!));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('✅ Bait reply copied to clipboard!'),
        backgroundColor: AppColors.safe,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return KavachScaffold(
      title: const Text('🎣 ScamBaiter - Ramesh Kaka Mode'),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _generateBaitReply,
          tooltip: 'Regenerate',
        ),
      ],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.l16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Description
            Card(
              elevation: 0,
              color: AppColors.lightSurfaceVariant,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.m12),
                child: Text(
                  'Ramesh Kaka is an innocent elderly persona that generates '
                      'confused, polite replies to delay scammers and make them reveal '
                      'their true intentions. This gives you time to report the fraud.',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.l16),

            // Scam Message
            Text(
              'Original Scam Message:',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.s8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.m12),
                child: SelectableText(
                  widget.scamText,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppColors.danger,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.l16),

            // Loading
            if (_isLoading) ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.xxl24),
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: AppSpacing.m12),
                      Text('Ramesh Kaka is typing a decoy reply on-device...'),
                    ],
                  ),
                ),
              ),
            ],

            // Error
            if (_error != null && !_isLoading) ...[
              Card(
                color: AppColors.dangerContainer,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.m12),
                  child: Text(
                    _error!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.danger,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.l16),
            ],

            // Bait Reply
            if (_baitReply != null && !_isLoading) ...[
              Text(
                '🎣 Ramesh Kaka\'s Decoy Reply:',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.s8),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.m12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SelectableText(
                        _baitReply!,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: AppColors.primary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.m12),
                      const Divider(),
                      const SizedBox(height: AppSpacing.s8),
                      KavachButton(
                        label: '📋 Copy Bait Reply',
                        icon: Icons.copy,
                        onPressed: _copyToClipboard,
                        expand: true,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.l16),
              Text(
                '⚠️ Send this reply to the scammer to delay them while you report to 1930.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.warning,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}