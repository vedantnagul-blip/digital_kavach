import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/kavach_button.dart';
import '../../../core/widgets/loading_view.dart';
import '../family_strings.dart';

class ScanPairScreen extends ConsumerStatefulWidget {
  const ScanPairScreen({
    super.key,
    this.onJoin,
    this.isLoading = false,
    this.error,
  });

  final Future<bool> Function(String familyId, String code)? onJoin;
  final bool isLoading;
  final String? error;

  @override
  ConsumerState<ScanPairScreen> createState() => _ScanPairScreenState();
}

class _ScanPairScreenState extends ConsumerState<ScanPairScreen> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _familyIdController = TextEditingController();

  bool _isConnecting = false;
  String? _localError;

  bool get _canConnect =>
      _codeController.text.trim().length == 6 &&
          _familyIdController.text.trim().isNotEmpty &&
          !_isConnecting &&
          !widget.isLoading;

  @override
  void dispose() {
    _codeController.dispose();
    _familyIdController.dispose();
    super.dispose();
  }

  void _onInputChanged(String value) {
    setState(() {
      _localError = null;
    });
  }

  Future<void> _connectShield() async {
    if (!_canConnect) return;

    final onJoin = widget.onJoin;

    if (onJoin == null) {
      setState(() {
        _localError =
        'Family pairing is not configured. Please open this screen '
            'from Family Shield.';
      });
      return;
    }

    setState(() {
      _isConnecting = true;
      _localError = null;
    });

    try {
      final success = await onJoin(
        _familyIdController.text.trim(),
        _codeController.text.trim().toUpperCase(),
      );

      if (!mounted) return;

      if (!success) {
        setState(() {
          _localError =
          'Could not connect. Check the Family ID, pairing code, '
              'account, and internet connection.';
        });
      }
      // The parent screen handles navigation after a successful join.
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _localError =
        'Connection failed. Please check your internet connection '
            'and try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isConnecting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final FamilyStrings s = ref.watch(familyStringsProvider);

    final errorMessage = _localError ?? widget.error;

    return Scaffold(
      appBar: AppBar(
        title: Text(s.scanPairTitle),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                s.scanPairTitle,
                style: theme.textTheme.headlineSmall,
              ),

              const SizedBox(height: AppSpacing.xxl24),

              TextField(
                controller: _codeController,
                maxLength: 6,
                textAlign: TextAlign.center,
                textCapitalization: TextCapitalization.characters,
                onChanged: _onInputChanged,
                style: theme.textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 8,
                ),
                inputFormatters: [
                  UpperCaseTextFormatter(),
                  FilteringTextInputFormatter.allow(
                    RegExp(r'[A-Z0-9]'),
                  ),
                ],
                decoration: InputDecoration(
                  labelText: 'Pairing Code',
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

              TextField(
                controller: _familyIdController,
                onChanged: _onInputChanged,
                decoration: InputDecoration(
                  labelText: 'Family ID',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              if (errorMessage != null) ...[
                const SizedBox(height: AppSpacing.l16),
                Text(
                  errorMessage,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],

              const Spacer(),

              if (_isConnecting || widget.isLoading)
                const Center(child: LoadingView())
              else
                KavachButton(
                  label: 'Connect Shield',
                  variant: KavachButtonVariant.filled,
                  onPressed: _canConnect ? _connectShield : null,
                ),

              const SizedBox(height: AppSpacing.l16),
            ],
          ),
        ),
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
    );
  }
}