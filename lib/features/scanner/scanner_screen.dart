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
import 'models/upi_spoof_detector.dart';
import 'scanner_service.dart';
import 'scanner_strings.dart';
import 'widgets/upi_spoof_sheet.dart';

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
  final ImagePicker _picker = ImagePicker();

  bool _loading = false;
  String? _selectedImagePath;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    if (widget.initialText != null && widget.initialText!.isNotEmpty) {
      _textController.text = widget.initialText!;
    }
    if (widget.initialImagePath != null) {
      _selectedImagePath = widget.initialImagePath;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _scanText() async {
    final String text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() => _loading = true);
    try {
      final res = await ref.read(scannerServiceProvider).scanText(text);
      if (!mounted) return;

      context.push(Routes.scanResult, extra: <String, dynamic>{
        'result': res.result,
        'inputText': text,
      });
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
        _loading = true;
      });

      final res =
          await ref.read(scannerServiceProvider).scanImage(file.path);
      if (!mounted) return;

      context.push(Routes.scanResult, extra: <String, dynamic>{
        'result': res.result,
        'inputText': res.extractedText ?? 'Image input',
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pasteFromClipboard() async {
    final ClipboardData? data =
        await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && data!.text!.isNotEmpty) {
      _textController.text = data.text!;
    }
  }

  Future<void> _onQrDetected(BarcodeCapture capture) async {
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? raw = barcodes.first.rawValue;
    if (raw == null || raw.isEmpty) return;

    final UpiQrPayload payload = UpiQrPayload.parse(raw);
    final analysis = UpiSpoofDetector.analyze(payload);

    // If critical merchant spoofing is detected, show instant Ghost UPI interceptor
    if (analysis.isSpoofed && mounted) {
      UpiSpoofSheet.show(
        context,
        payload: payload,
        onProceedAnyway: () => _processAndNavigateQr(raw),
      );
      return;
    }

    await _processAndNavigateQr(raw);
  }

  Future<void> _processAndNavigateQr(String raw) async {
    setState(() => _loading = true);
    try {
      final res = await ref.read(scannerServiceProvider).scanQrCode(raw);
      if (!mounted) return;
      context.push(Routes.scanResult, extra: <String, dynamic>{
        'result': res.result,
        'qrPayload': res.payload,
        'inputText': raw,
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ScannerStrings s = ref.watch(scannerStringsProvider);

    return KavachScaffold(
      title: s.tabText,
      bottomNavigationBar: TabBar(
        controller: _tabController,
        tabs: <Widget>[
          Tab(icon: const Icon(Icons.text_fields), text: s.tabText),
          Tab(icon: const Icon(Icons.image), text: s.tabImage),
          Tab(icon: const Icon(Icons.qr_code_scanner), text: s.tabQr),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: <Widget>[
                _buildTextTab(s),
                _buildImageTab(s),
                _buildQrTab(s),
              ],
            ),
    );
  }

  Widget _buildTextTab(ScannerStrings s) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.l16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _textController,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: InputDecoration(
                hintText: s.inputHint,
                border: const OutlineInputBorder(
                  borderRadius: AppRadius.rM,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.m12),
          Row(
            children: <Widget>[
              IconButton.outlined(
                icon: const Icon(Icons.paste_rounded),
                tooltip: s.pasteClipboard,
                onPressed: _pasteFromClipboard,
              ),
              const SizedBox(width: AppSpacing.s8),
              Expanded(
                child: KavachButton(
                  label: s.scanButton,
                  variant: KavachButtonVariant.filled,
                  onPressed: _scanText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImageTab(ScannerStrings s) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Icon(Icons.document_scanner_rounded, size: 80, color: AppColors.primary),
          const SizedBox(height: AppSpacing.xl20),
          Text(
            'OCR Scam Poster & Screenshot Scanner',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            'Upload WhatsApp screenshots, reward posters, or suspicious letters in English & Devanagari.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xxl24),
          KavachButton(
            label: s.pickGallery,
            icon: Icons.photo_library_rounded,
            variant: KavachButtonVariant.filled,
            onPressed: () => _pickImage(ImageSource.gallery),
          ),
          const SizedBox(height: AppSpacing.m12),
          KavachButton(
            label: s.takePhoto,
            icon: Icons.camera_alt_rounded,
            variant: KavachButtonVariant.tonal,
            onPressed: () => _pickImage(ImageSource.camera),
          ),
        ],
      ),
    );
  }

  Widget _buildQrTab(ScannerStrings s) {
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
          top: 24,
          left: 24,
          right: 24,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: AppRadius.rM,
              border: Border.all(color: Colors.cyanAccent.withOpacity(0.4)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.security, color: Colors.cyanAccent, size: 18),
                SizedBox(width: 8),
                Text(
                  'Ghost UPI Steganography Shield Active',
                  style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ],
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
              'Align UPI QR code within frame\nDetects forged merchant handles in real-time',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}
