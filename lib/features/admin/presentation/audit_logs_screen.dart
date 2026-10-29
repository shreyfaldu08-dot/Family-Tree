import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/typography.dart';
import '../../../data/models/audit_entry.dart';
import '../../../data/providers/repository_providers.dart';

class AuditLogsScreen extends ConsumerWidget {
  const AuditLogsScreen({super.key});

  void _confirmUndo(BuildContext context, WidgetRef ref, AuditEntry log) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: HeritageCurves.cardLarge),
        title: Text('Undo Action?', style: HeritageTypography.titleMedium.copyWith(fontWeight: FontWeight.w700)),
        content: Text(
          'Revert "${log.action.replaceAll('_', ' ')}" performed on ${log.entityType}? This will undo the modification.',
          style: HeritageTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: HeritageCurves.pill),
            ),
            onPressed: () {
              ref.read(auditLogsNotifierProvider.notifier).undoAction(log.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Successfully undid action: ${log.action.replaceAll('_', ' ')}'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            child: const Text('Confirm Undo'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(auditLogsNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Activity & Audit Log', style: HeritageTypography.displaySmall),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: logs.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.history_toggle_off_rounded, size: 54, color: AppColors.paleSage),
                  const SizedBox(height: 12),
                  Text('No Activity Logs Found', style: HeritageTypography.titleMedium),
                  const SizedBox(height: 4),
                  Text('Admin actions and edits will appear here.', style: HeritageTypography.bodySmall),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: logs.length,
              itemBuilder: (ctx, i) {
                final log = logs[i];
                final details = log.payload['details'] ?? log.payload['name'] ?? '';

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: HeritageCurves.card,
                    boxShadow: HeritageShadows.card,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.lightSage,
                              borderRadius: HeritageCurves.pill,
                            ),
                            child: Text(
                              log.action.replaceAll('_', ' ').toUpperCase(),
                              style: HeritageTypography.labelSmall.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          Text(
                            _formatDate(log.createdAt),
                            style: HeritageTypography.bodySmall.copyWith(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Target: ${log.entityType.toUpperCase()} (${log.entityId})',
                        style: HeritageTypography.labelSmall.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (details.toString().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          details.toString(),
                          style: HeritageTypography.bodyMedium.copyWith(fontSize: 12.5),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'By: ${log.actorEmail ?? log.actorId}',
                            style: HeritageTypography.bodySmall.copyWith(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          // Undo Action Button
                          OutlinedButton.icon(
                            icon: const Icon(Icons.undo_rounded, size: 14, color: AppColors.primary),
                            label: const Text('Undo', style: TextStyle(color: AppColors.primary, fontSize: 11)),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.paleSage),
                              shape: RoundedRectangleBorder(borderRadius: HeritageCurves.pill),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              minimumSize: Size.zero,
                            ),
                            onPressed: () => _confirmUndo(context, ref, log),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
