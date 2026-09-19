import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/kavach_button.dart';
import '../../../core/widgets/loading_view.dart';
import '../complaint_service.dart';
import '../recovery_pdf.dart';
import '../widgets/complaint_preview.dart';

/// Step 4: View, edit, and share the generated complaint.
class ComplaintViewerScreen extends StatefulWidget {
  const ComplaintViewerScreen({
    super.key,
    required this.draft,
    required this.onUpdateDraft,
    required this.onRegenerate,
    required this.onNext,
    required this.onBack,
    required this.isRegenerating,
  });

  final RecoveryDraft? draft;
  final void Function(RecoveryDraft) onUpdateDraft;
  final VoidCallback onRegenerate;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final bool isRegenerating;

  @override
  State<ComplaintViewerScreen> createState() => _ComplaintViewerScreenState();
}

class _ComplaintViewerScreenState extends State<ComplaintViewerScreen> {
  final _pdfGenerator = RecoveryPdf();
  bool _isGeneratingPdf = false;

  Future<void> _sharePdf() async {
    if (widget.draft == null) return;
    setState(() => _isGeneratingPdf = true);
    try {
      final bytes = await _pdfGenerator.generate(widget.draft!);
      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/kavach_complaint_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
      await file.writeAsBytes(bytes);
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/pdf')],
        subject: widget.draft!.emailSubject,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF share nahi ho paya: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isGeneratingPdf = false);
    }
  }

  Future<void> _openCybercrimePortal() async {
    final uri = Uri.parse('https://cybercrime.gov.in');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showUrlFallback();
      }
    } catch (_) {
      _showUrlFallback();
    }
  }

  void _showUrlFallback() {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cybercrime Portal'),
        content: const Text(
          'Browser nahi khul raha. Kripya cybercrime.gov.in manually kholein.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _editComplaint() async {
    if (widget.draft == null) return;
    final controller = TextEditingController(text: widget.draft!.complaintEn);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final dialogTheme = Theme.of(ctx);
        return AlertDialog(
          title: const Text('Shikayat edit karein'),
          content: SizedBox(
            width: double.maxFinite,
            child: TextField(
              controller: controller,
              maxLines: 20,
              style: dialogTheme.textTheme.labelLarge?.copyWith(
                fontFamily: 'monospace',
              ),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, controller.text),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    if (result != null && result.isNotEmpty) {
      widget.onUpdateDraft(widget.draft!.copyWith(complaintEn: result));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.draft == null || widget.isRegenerating) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const LoadingView(),
            const SizedBox(height: AppSpacing.l16),
            Text(
              'Shikayat taiyaar ho rahi hai…',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Aapki shikayat taiyaar hai',
            style: theme.textTheme.headlineLarge?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            'Neeche padhein aur zaruri ho toh edit karein.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.l16),

          Expanded(
            child: SingleChildScrollView(
              child: ComplaintPreview(
                draft: widget.draft!,
                onSharePdf: _isGeneratingPdf ? null : _sharePdf,
                onRegenerate: widget.onRegenerate,
                isRegenerating: widget.isRegenerating,
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.m12),

          // Edit + portal buttons
          Row(
            children: [
              Expanded(
                child: KavachButton(
                  label: 'Edit karein',
                  variant: KavachButtonVariant.outlined,
                  icon: Icons.edit,
                  onPressed: _editComplaint,
                ),
              ),
              const SizedBox(width: AppSpacing.s8),
              Expanded(
                child: KavachButton(
                  label: 'Portal kholein',
                  variant: KavachButtonVariant.outlined,
                  icon: Icons.open_in_new,
                  onPressed: _openCybercrimePortal,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.m12),

          // Navigation
          Row(
            children: [
              Expanded(
                child: KavachButton(
                  label: 'Peechhe',
                  variant: KavachButtonVariant.text,
                  onPressed: widget.onBack,
                ),
              ),
              const SizedBox(width: AppSpacing.m12),
              Expanded(
                flex: 2,
                child: KavachButton(
                  label: 'Aage: Bank ko email',
                  variant: KavachButtonVariant.filled,
                  onPressed: widget.onNext,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.l16),
        ],
      ),
    );
  }
}