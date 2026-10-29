import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/typography.dart';
import '../../../data/models/media_asset.dart';
import '../../../data/providers/repository_providers.dart';

class ArchiveScreen extends ConsumerStatefulWidget {
  const ArchiveScreen({super.key});

  @override
  ConsumerState<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends ConsumerState<ArchiveScreen> {
  MediaType? _selectedType;

  @override
  Widget build(BuildContext context) {
    final mediaAsync = ref.watch(familyMediaProvider);
    final membership = ref.watch(currentMembershipProvider).valueOrNull;
    final isAdmin = membership?.canWriteFamilyData ?? false;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Family Archive', style: HeritageTypography.displaySmall),
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.add_photo_alternate_outlined, color: AppColors.textPrimary),
              tooltip: 'Upload Private Media (Admin)',
              onPressed: () {
                _showUploadMockDialog(context);
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips (All, Photos, Audio, Documents, Videos)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                _chip('All Media', null),
                const SizedBox(width: 8),
                _chip('Photographs', MediaType.photo),
                const SizedBox(width: 8),
                _chip('Audio Stories', MediaType.audio),
                const SizedBox(width: 8),
                _chip('Documents', MediaType.document),
                const SizedBox(width: 8),
                _chip('Videos', MediaType.video),
              ],
            ),
          ),

          const SizedBox(height: 6),

          Expanded(
            child: mediaAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              error: (err, _) => Center(child: Text('Error loading archive: $err')),
              data: (allMedia) {
                var filtered = allMedia;
                if (_selectedType != null) {
                  filtered = filtered.where((m) => m.mediaType == _selectedType).toList();
                }

                if (filtered.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: HeritageCurves.cardLarge,
                          boxShadow: HeritageShadows.card,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: const BoxDecoration(
                                color: AppColors.lightSage,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.auto_stories_rounded,
                                size: 28,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Preserve Your First Memory',
                              style: HeritageTypography.titleMedium.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Upload vintage family photographs, letters, or audio recordings to safely preserve them in your encrypted family archive.',
                              textAlign: TextAlign.center,
                              style: HeritageTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: filtered.length,
                  itemBuilder: (ctx, i) {
                    final asset = filtered[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: HeritageCurves.card,
                        border: Border.all(color: AppColors.border, width: 0.8),
                        boxShadow: HeritageShadows.card,
                      ),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: HeritageCurves.card,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.lightSage,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Icon(
                            _getIconForType(asset.mediaType),
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                        title: Text(
                          asset.title,
                          style: HeritageTypography.titleSmall.copyWith(
                            fontSize: 15,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (asset.description != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                asset.description!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: HeritageTypography.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  asset.capturedDate != null
                                      ? 'Dated: ${asset.capturedDate!.year}'
                                      : 'Archival Record',
                                  style: HeritageTypography.lifeDates.copyWith(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.lightSage,
                                    borderRadius: HeritageCurves.pill,
                                  ),
                                  child: Text(
                                    'Private Bucket',
                                    style: HeritageTypography.labelSmall.copyWith(
                                      fontSize: 9,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.download_rounded, color: AppColors.primary),
                          tooltip: 'Signed Private Download',
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Generating short-lived signed URL for "${asset.title}"...'),
                                backgroundColor: AppColors.primary,
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForType(MediaType type) {
    switch (type) {
      case MediaType.photo:
        return Icons.photo_camera_back_outlined;
      case MediaType.audio:
        return Icons.record_voice_over_outlined;
      case MediaType.document:
        return Icons.description_outlined;
      case MediaType.video:
        return Icons.videocam_outlined;
    }
  }

  Widget _chip(String label, MediaType? type) {
    final isSelected = _selectedType == type;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedType = type;
        });
      },
      borderRadius: HeritageCurves.pill,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.paleSage : AppColors.lightSage,
          borderRadius: HeritageCurves.pill,
          boxShadow: isSelected ? HeritageShadows.activePill : null,
        ),
        child: Text(
          label,
          style: HeritageTypography.labelSmall.copyWith(
            color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _showUploadMockDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Upload Archival Media', style: HeritageTypography.displaySmall),
        content: Text(
          'In production, files are securely encrypted and streamed directly to the private Supabase Storage bucket with strict RLS policies.',
          style: HeritageTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
