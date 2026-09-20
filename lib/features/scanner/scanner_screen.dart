import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/kavach_button.dart';
import '../../core/widgets/kavach_scaffold.dart';
import 'models/qr_payload.dart';
import 'scanner_service.dart';

class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({
    this.initialText,
    this.initialImagePath,
    super.key,
  });

  final String? initialText;
  final String? initialImagePath;

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _ocrTextController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  bool _loading = false;
  bool _extractingOcr = false;
  bool _deepAi = true;
  String? _selectedImagePath;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    if (widget.initialText != null && widget.initialText!.isNotEmpty) {
      _textController.text = widget.initialText!;
      _tabController.index = 0;
    } else if (widget.initialImagePath != null &&
        widget.initialImagePath!.isNotEmpty) {
      _selectedImagePath = widget.initialImagePath;
      _tabController.index = 1;
      _extractTextFromInitialImage(widget.initialImagePath!);
    }
  }

  Future<void> _extractTextFromInitialImage(String path) async {
    setState(() => _extractingOcr = true);
    try {
      final String extracted = await ref
          .read(scannerServiceProvider)
          .extractTextFromImage(path);
      if (mounted) {
        setState(() {
          _extractingOcr = false;
          _ocrTextController.text = extracted;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _extractingOcr = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _textController.dispose();
    _ocrTextController.dispose();
    super.dispose();
  }

  Future<void> _pasteClipboard() async {
    final ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && data!.text!.isNotEmpty) {
      setState(() {
        _textController.text = data.text!;
      });
    }
  }

  Future<void> _runTextScan() async {
    if (_textController.text.trim().isEmpty) return;
    setState(() => _loading = true);

    try {
      final res = await ref
          .read(scannerServiceProvider)
          .scanText(_textController.text.trim(), forceAi: _deepAi);

      if (!mounted) return;
      context.push(Routes.scanResult, extra: <String, dynamic>{
        'result': res,
        'inputText': _textController.text,
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Scan failed: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(source: source);
      if (file == null) return;

      setState(() {
        _selectedImagePath = file.path;
        _extractingOcr = true;
        _ocrTextController.text = '';
      });

      // Step 1: Extract text using ML Kit Devanagari + Latin + Gemini Vision fallback
      final String extracted = await ref
          .read(scannerServiceProvider)
          .extractTextFromImage(file.path);

      if (!mounted) return;
      setState(() {
        _extractingOcr = false;
        _ocrTextController.text = extracted;
      });

      if (extracted.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Extracted ${extracted.length} characters! Tap "Analyze with Agentic AI Layer".',
            ),
            backgroundColor: AppColors.safe,
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No text detected by OCR. You can type/paste text manually below.',
            ),
            backgroundColor: AppColors.warning,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _extractingOcr = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image extraction failed: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  Future<void> _runExtractedAiScan() async {
    final String textToScan = _ocrTextController.text.trim();
    if (textToScan.isEmpty && _selectedImagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an image or enter extracted text.'),
        ),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      Uint8List? bytes;
      String mime = 'image/jpeg';
      if (_selectedImagePath != null) {
        final File f = File(_selectedImagePath!);
        if (await f.exists()) {
          bytes = await f.readAsBytes();
          final String lower = _selectedImagePath!.toLowerCase();
          if (lower.endsWith('.png')) mime = 'image/png';
          if (lower.endsWith('.webp')) mime = 'image/webp';
        }
      }

      final res = await ref.read(scannerServiceProvider).scanText(
        textToScan.isEmpty ? 'Image scan - visual inspection' : textToScan,
        source: ScanSource.shareImage,
        imageBytes: bytes,
        imageMime: mime,
        forceAi: true, // Agentic AI Layer
      );

      if (!mounted) return;
      context.push(Routes.scanResult, extra: <String, dynamic>{
        'result': res,
        'inputText': textToScan.isEmpty ? '(Image Scan)' : textToScan,
        'imagePath': _selectedImagePath,
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Agentic AI scan failed: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _onQrDetected(BarcodeCapture capture) async {
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? raw = barcodes.first.rawValue;
    if (raw == null || raw.isEmpty) return;

    // Pause scanner
    setState(() => _loading = true);

    try {
      final res = await ref.read(scannerServiceProvider).scanQrCode(raw);

      if (!mounted) return;
      context.push(Routes.scanResult, extra: <String, dynamic>{
        'result': res.result,
        'qrPayload': res.payload,
        'inputText': raw,
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('QR scan failed: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData t = Theme.of(context);

    return KavachScaffold(
      title: const Text('Scanner Hub'),
      bottomNavigationBar: TabBar(
        controller: _tabController,
        indicatorColor: t.colorScheme.primary,
        labelColor: t.colorScheme.primary,
        unselectedLabelColor: t.colorScheme.onSurfaceVariant,
        tabs: const <Widget>[
          Tab(icon: Icon(Icons.edit_note_rounded), text: 'Paste Text'),
          Tab(icon: Icon(Icons.image_search_rounded), text: 'Screenshot'),
          Tab(icon: Icon(Icons.qr_code_scanner_rounded), text: 'Live QR'),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          _buildPasteTab(t),
          _buildImageTab(t),
          _buildQrTab(t),
        ],
      ),
    );
  }

  Widget _buildPasteTab(ThemeData t) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.l16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text('Inspect Text', style: t.textTheme.titleMedium),
              const Spacer(),
              TextButton.icon(
                onPressed: _pasteClipboard,
                icon: const Icon(Icons.content_paste_rounded, size: 18),
                label: const Text('Paste Clipboard'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _textController,
            minLines: 5,
            maxLines: 10,
            decoration: const InputDecoration(
              hintText: 'Paste WhatsApp message, SMS, or link here...',
            ),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _deepAi,
            onChanged: (bool v) => setState(() => _deepAi = v),
            title: const Text(
              'AI Deep-Scan (Groq / Gemini)',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: const Text(
              'Detects unknown patterns & zero-day scams via LLM',
            ),
            secondary: const Icon(
              Icons.psychology_rounded,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          KavachButton(
            label: 'Scan Text',
            icon: Icons.shield_rounded,
            loading: _loading,
            expand: true,
            onPressed: _runTextScan,
          ),
        ],
      ),
    );
  }

  Widget _buildImageTab(ThemeData t) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.l16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text('Screenshot OCR & Agentic AI', style: t.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Upload a screenshot or photo to extract text and analyze through the Dev Agentic AI Layer.',
            style: t.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),

          // Upload Buttons Row
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: (_loading || _extractingOcr)
                      ? null
                      : () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_rounded),
                  label: const Text('Gallery'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: (_loading || _extractingOcr)
                      ? null
                      : () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt_rounded),
                  label: const Text('Camera'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Image Preview Container if an image is chosen
          if (_selectedImagePath != null) ...<Widget>[
            Container(
              padding: const EdgeInsets.all(AppSpacing.s8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: t.colorScheme.outlineVariant.withOpacity(0.5),
                ),
                borderRadius: AppRadius.rM,
                color: t.colorScheme.surfaceContainerHighest.withOpacity(0.3),
              ),
              child: Row(
                children: <Widget>[
                  ClipRRect(
                    borderRadius: AppRadius.rS,
                    child: Image.file(
                      File(_selectedImagePath!),
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.image_not_supported_rounded,
                        size: 32,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          _selectedImagePath!.split('/').last,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _extractingOcr
                              ? 'Extracting text...'
                              : '${_ocrTextController.text.length} characters extracted',
                          style: TextStyle(
                            fontSize: 12,
                            color: _extractingOcr
                                ? AppColors.warning
                                : AppColors.safe,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    tooltip: 'Clear',
                    onPressed: () => setState(() {
                      _selectedImagePath = null;
                      _ocrTextController.clear();
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // OCR Extraction Progress Indicator
          if (_extractingOcr) ...<Widget>[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: AppRadius.rM,
                color: t.colorScheme.surfaceContainerHighest.withOpacity(0.4),
              ),
              child: const Column(
                children: <Widget>[
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text(
                    'Step 1: Extracting text via Devanagari & Latin OCR...',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ] else if (_selectedImagePath != null) ...<Widget>[
            // Step 2: Show Extracted Text & Agentic AI Trigger
            Row(
              children: <Widget>[
                const Icon(
                  Icons.text_fields_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                const Text(
                  'Extracted OCR Text',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    _textController.text = _ocrTextController.text;
                    _tabController.animateTo(0);
                  },
                  icon: const Icon(Icons.copy_rounded, size: 14),
                  label: const Text('Edit in Paste Tab', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _ocrTextController,
              minLines: 4,
              maxLines: 8,
              decoration: InputDecoration(
                hintText: _ocrTextController.text.isEmpty
                    ? 'No text detected by OCR. Type or paste what the screenshot says here...'
                    : 'Extracted text...',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Step 3: Trigger Agentic AI Layer
            KavachButton(
              label: 'Analyze with Agentic AI Layer',
              icon: Icons.psychology_rounded,
              loading: _loading,
              expand: true,
              onPressed: _runExtractedAiScan,
            ),
          ] else ...<Widget>[
            // Placeholder when no image is selected yet
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border.all(
                  color: t.colorScheme.outlineVariant.withOpacity(0.4),
                  style: BorderStyle.solid,
                ),
                borderRadius: AppRadius.rL,
                color: t.colorScheme.surfaceContainerLow.withOpacity(0.5),
              ),
              child: Column(
                children: <Widget>[
                  Icon(
                    Icons.document_scanner_outlined,
                    size: 48,
                    color: t.colorScheme.onSurfaceVariant.withOpacity(0.5),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Two-Step Screenshot Detection:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '1. Select an image → OCR extracts Hindi/Marathi/English text.\n'
                    '2. Dev Agentic AI Layer (Groq / Gemini) evaluates intent and psychological deception.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQrTab(ThemeData t) {
    return Stack(
      children: <Widget>[
        MobileScanner(
          onDetect: _onQrDetected,
        ),
        Center(
          child: Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primary, width: 3),
              borderRadius: AppRadius.rL,
            ),
          ),
        ),
        Positioned(
          bottom: 24,
          left: 24,
          right: 24,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: AppRadius.rM,
            ),
            child: const Text(
              'Align UPI QR code within frame',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        if (_loading)
          Container(
            color: Colors.black54,
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),
      ],
    );
  }
}
