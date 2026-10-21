import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/typography.dart';
import '../../../data/models/audit_entry.dart';
import '../../../data/providers/repository_providers.dart';

class AuditLogsScreen extends ConsumerWidget {
  const AuditLogsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adminRepo = ref.watch(adminRepositoryProvider);
    final membership = ref.watch(currentMembershipProvider).valueOrNull;

    return Scaffold(
      backgroundColor: HeritageColors.warmIvory,
      appBar: AppBar(
        title: Text('Archival Audit History', style: HeritageTypography.displaySmall),
      ),
      body: FutureBuilder<List<AuditEntry>>(
        future: adminRepo.getAuditLogs('fam_kensington_01', membership),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: HeritageColors.forestGreen));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final logs = snapshot.data ?? [];
          if (logs.isEmpty) {
            return const Center(child: Text('No audit events logged yet.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            itemCount: logs.length,
            itemBuilder: (ctx, i) {
              final log = logs[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: HeritageColors.warmIvoryLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: HeritageColors.stone, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          log.action.replaceAll('_', ' ').toUpperCase(),
                          style: HeritageTypography.labelSmall.copyWith(
                            color: HeritageColors.forestGreen,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${log.createdAt.year}-${log.createdAt.month.toString().padLeft(2, '0')}-${log.createdAt.day.toString().padLeft(2, '0')}',
                          style: HeritageTypography.lifeDates,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Entity: ${log.entityType} (${log.entityId})',
                      style: HeritageTypography.titleSmall.copyWith(fontSize: 13),
                    ),
                    if (log.actorEmail != null) ...[
                      const SizedBox(height: 2),
                      Text('By: ${log.actorEmail!}', style: HeritageTypography.bodySmall),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
