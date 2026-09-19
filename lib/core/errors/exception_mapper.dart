import 'package:digital_kavach/core/l10n/strings_base.dart';
import 'package:flutter/foundation.dart';

import '../l10n/l10n.dart';
import 'kavach_exception.dart';

/// UI-friendly rendering of a [KavachException].
@immutable
class UserFacingError {
  const UserFacingError({
    required this.title,
    required this.hint,
    required this.canRetry,
  });

  final String title;
  final String hint;
  final bool canRetry;
}

/// Maps a [KavachException] to a localized [UserFacingError].
///
/// Called by [ErrorStateView] and any snackbar/toast utility.
class ExceptionMapper {
  const ExceptionMapper._();

  static UserFacingError toUserMessage(KavachException e, L10n l10n) {
    final StringsBase s = l10n.strings;
    switch (e) {
      case NetworkException _:
        return UserFacingError(
          title: s.errorNetworkTitle,
          hint: s.errorNetworkHint,
          canRetry: true,
        );
      case KavachTimeoutException _:
        return UserFacingError(
          title: s.errorTimeoutTitle,
          hint: s.errorTimeoutHint,
          canRetry: true,
        );
      case AiProviderException _:
      case AiParseException _:
      case NoProviderException _:
        return UserFacingError(
          title: s.errorAiTitle,
          hint: s.errorAiHint,
          canRetry: true,
        );
      case QuotaExceededException _:
        return UserFacingError(
          title: s.errorAiQuotaTitle,
          hint: s.errorAiQuotaHint,
          canRetry: false,
        );
      case PermissionException _:
        return UserFacingError(
          title: s.errorPermissionTitle,
          hint: s.errorPermissionHint,
          canRetry: false,
        );
      case AuthException _:
        return UserFacingError(
          title: s.errorAuthTitle,
          hint: s.errorAuthHint,
          canRetry: true,
        );
      case StorageException _:
        return UserFacingError(
          title: s.errorStorageTitle,
          hint: s.errorStorageHint,
          canRetry: false,
        );
      case ValidationException _:
        return UserFacingError(
          title: s.errorDefaultTitle,
          hint: s.errorDefaultHint,
          canRetry: false,
        );
      case UnknownException _:
        return UserFacingError(
          title: s.errorUnknownTitle,
          hint: s.errorUnknownHint,
          canRetry: true,
        );
    }
  }
}