import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import '../../core/router/app_router.dart';
import '../../core/utils/app_logger.dart';

/// Top-level listener for Android Share Sheet intents (`ACTION_SEND`).
///
/// Handles cold start & warm start text/image shares and calls `reset()`
/// to prevent ghost-duplicate intent processing bugs.
class ShareIntakeListener extends ConsumerStatefulWidget {
  const ShareIntakeListener({required this.child, super.key});
  final Widget child;

  @override
  ConsumerState<ShareIntakeListener> createState() =>
      _ShareIntakeListenerState();
}

class _ShareIntakeListenerState extends ConsumerState<ShareIntakeListener> {
  StreamSubscription<List<SharedMediaFile>>? _intentSubscription;

  @override
  void initState() {
    super.initState();
    _initShareIntake();
  }

  void _initShareIntake() {
    // 1. Warm start stream listener
    _intentSubscription = ReceiveSharingIntent.instance.getMediaStream().listen(
          (List<SharedMediaFile> value) {
        _handleSharedFiles(value);
      },
      onError: (dynamic err) {
        AppLogger.w('ShareIntake stream error: $err');
      },
    );

    // 2. Cold start initial check
    ReceiveSharingIntent.instance.getInitialMedia().then((List<SharedMediaFile> value) {
      _handleSharedFiles(value);
      // Critical: reset intent to prevent ghost duplicate on app resume
      ReceiveSharingIntent.instance.reset();
    });
  }

  void _handleSharedFiles(List<SharedMediaFile> files) {
    if (files.isEmpty) return;

    final SharedMediaFile file = files.first;
    AppLogger.i('ShareIntake received file: ${file.path}, type: ${file.type}');

    if (!mounted) return;

    if (file.type == SharedMediaType.text) {
      final String text = file.path; // For text, path contains raw string
      if (text.isNotEmpty) {
        context.push(Routes.scan, extra: <String, dynamic>{'sharedText': text});
      }
    } else if (file.type == SharedMediaType.image) {
      context.push(Routes.scan, extra: <String, dynamic>{'sharedImagePath': file.path});
    }

    // Reset intent after handling
    ReceiveSharingIntent.instance.reset();
  }

  @override
  void dispose() {
    _intentSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}