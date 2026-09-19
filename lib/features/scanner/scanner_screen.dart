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
  final ImagePicker _picker = ImagePicker();

  bool _loading = false;
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
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _textController.dispose();
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
          .scanText(_textController.text.trim());

      if (!mounted) return;
      context.push(Routes.scanResult, extra: <String, dynamic>{
        'result': res,
        'inputText': _textController.text,
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? file = await _picker.pickImage(source: source);
    if (file == null) return;

    setState(() {
      _selectedImagePath = file.path;
      _loading = true;
    });

    try {
      final res = await ref
          .read(scannerServiceProvider)
          .scanImage(_selectedImagePath!);

      if (!mounted) return;
      context.push(Routes.scanResult, extra: <String, dynamic>{
        'result': res.result,
        'inputText': res.extractedText,
        'imagePath': _selectedImagePath,
      });
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
          const SizedBox(height: 16),
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
          Text('Screenshot OCR Scan', style: t.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            'Upload a payment screenshot, WhatsApp chat image, or fake offer banner.',
            style: t.textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _loading ? null : () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_rounded),
                  label: const Text('Gallery'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _loading ? null : () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt_rounded),
                  label: const Text('Camera'),
                ),
              ),
            ],
          ),
          if (_loading) ...<Widget>[
            const SizedBox(height: 32),
            const Center(
              child: Column(
                children: <Widget>[
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text('Reading text via ML Kit OCR...'),
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