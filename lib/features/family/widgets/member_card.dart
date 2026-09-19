import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../family_repo.dart';

/// Displays a family member with role chip and call action.
class MemberCard extends StatelessWidget {
  const MemberCard({
    super.key,
    required this.member,
    this.onUnpair,
  });

  final FamilyMember member;
  final VoidCallback? onUnpair;

  Future<void> _callMember(BuildContext context) async {
    if (member.phoneNumber == null || member.phoneNumber!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number nahi hai')),
      );
      return;
    }
    final uri = Uri.parse('tel:${member.phoneNumber}');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (_) {
      // ignore
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isElder = member.role == FamilyRole.elder;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.m12),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: isElder
                  ? AppColors.primary.withOpacity(0.15)
                  : AppColors.safe.withOpacity(0.15),
              child: Icon(
                isElder ? Icons.elderly : Icons.shield,
                color: isElder ? AppColors.primary : AppColors.safe,
              ),
            ),
            const SizedBox(width: AppSpacing.m12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.displayName,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isElder
                          ? AppColors.primary.withOpacity(0.1)
                          : AppColors.safe.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isElder ? 'Elder' : 'Guardian',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isElder ? AppColors.primary : AppColors.safe,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (member.phoneNumber != null)
              IconButton(
                icon: const Icon(Icons.call, color: AppColors.safe),
                tooltip: 'Call ${member.displayName}',
                onPressed: () => _callMember(context),
              ),
            if (onUnpair != null)
              IconButton(
                icon: Icon(
                  Icons.link_off,
                  color: theme.colorScheme.error,
                ),
                tooltip: 'Unpair',
                onPressed: onUnpair,
              ),
          ],
        ),
      ),
    );
  }
}