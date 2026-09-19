import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/kavach_button.dart';
import '../../../core/widgets/loading_view.dart';

/// Elder enters a 6-char pair code manually (accessibility-first).
class ScanPairScreen extends StatefulWidget {
  const ScanPairScreen({
    super.key,
    required this.onJoin,
    this.isLoading = false,
    this.error,
  });

  final Future<bool> Function(String familyId, String code) onJoin;
  final bool isLoading;
  final String? error;

  @override
  State<ScanPairScreen> createState() => _ScanPairScreenState();
}

class _ScanPairScreenState extends State<ScanPairScreen> {
  final _codeController = TextEditingController();
  final _familyIdController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    _familyIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Family se judein')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Guardian ka diya hua 6-akshar code daalein',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.xxl24),

            // 6 giant input boxes
            TextField(
              controller: _codeController,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: theme.textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 8,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
                UpperCaseTextFormatter(),
              ],
              decoration: InputDecoration(
                counterText: '',
                hintText: '------',
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest
                    .withOpacity(0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.l16),

            // Family ID (from deep link or manual)
            TextField(
              controller: _familyIdController,
              decoration: InputDecoration(
                labelText: 'Family ID (link se auto aayega)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            if (widget.error != null) ...[
              const SizedBox(height: AppSpacing.m12),
              Container(
                padding: const EdgeInsets.all(AppSpacing.m12),
                decoration: BoxDecoration(
                  color: AppColors.dangerContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _friendlyError(widget.error!),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.danger,
                  ),
                ),
              ),
            ],

            const Spacer(),

            if (widget.isLoading)
              const Center(child: LoadingView())
            else
              KavachButton(
                label: 'Judein',
                variant: KavachButtonVariant.filled,
                onPressed: _codeController.text.length == 6
                    ? () => widget.onJoin(
                  _familyIdController.text,
                  _codeController.text,
                )
                    : null,
              ),
            const SizedBox(height: AppSpacing.l16),
          ],
        ),
      ),
    );
  }

  String _friendlyError(String code) {
    if (code.contains('wrong_code')) return 'Galat code. Dobara check karein.';
    if (code.contains('not_found')) return 'Family nahi mili. Link check karein.';
    if (code.contains('self_pair')) return 'Aap khud ke guardian nahi ho sakte.';
    if (code.contains('already_paired')) return 'Aap pehle se jude hue hain.';
    return 'Kuch gadbad hui. Dobara try karein.';
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}