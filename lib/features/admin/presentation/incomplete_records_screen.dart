import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/typography.dart';
import '../../../data/models/person.dart';
import '../../../data/providers/repository_providers.dart';

class IncompleteRecordsScreen extends ConsumerWidget {
  const IncompleteRecordsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adminRepo = ref.watch(adminRepositoryProvider);
    final membership = ref.watch(currentMembershipProvider).valueOrNull;

    return Scaffold(
      backgroundColor: HeritageColors.warmIvory,
      appBar: AppBar(
        title: Text('Incomplete Records', style: HeritageTypography.displaySmall),
      ),
      body: FutureBuilder<List<Person>>(
        future: adminRepo.getIncompleteRecords('fam_kensington_01', membership),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: HeritageColors.forestGreen));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final list = snapshot.data ?? [];
          if (list.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.verified_outlined, size: 54, color: HeritageColors.forestGreen),
                    const SizedBox(height: 14),
                    Text('Archive In Integrity', style: HeritageTypography.displaySmall),
                    const SizedBox(height: 6),
                    Text(
                      'All family member records possess vital dates, birthplaces, and parent connections.',
                      textAlign: TextAlign.center,
                      style: HeritageTypography.bodyMedium,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            itemCount: list.length,
            itemBuilder: (ctx, i) {
              final person = list[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: HeritageColors.warmIvoryLight,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: HeritageColors.stone, width: 1.2),
                ),
                child: ListTile(
                  title: Text(person.displayName, style: HeritageTypography.titleSmall),
                  subtitle: Text(
                    !person.isVerified
                        ? 'Unverified record • Missing primary source'
                        : 'Missing birth location or dates',
                    style: HeritageTypography.bodySmall.copyWith(color: HeritageColors.statusWarning),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  onTap: () => context.push('/admin/persons/edit/${person.id}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
