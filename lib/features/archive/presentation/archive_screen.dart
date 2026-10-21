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
      backgroundColor: HeritageColors.warmIvory,
      appBar: AppBar(
        title: Text('Family Archive', style: HeritageTypography.displaySmall),
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.add_photo_alternate_outlined, color: HeritageColors.charcoal),
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

          const Divider(height: 1),

          Expanded(
            child: mediaAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: HeritageColors.forestGreen),
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
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.photo_library_outlined, size: 52, color: HeritageColors.sage),
                          const SizedBox(height: 12),
                          Text('No Archival Assets in this Category', style: HeritageTypography.titleMedium),
                          const SizedBox(height: 4),
                          Text(
                            'Historical documents and audio recordings are securely preserved in private storage.',
                            textAlign: TextAlign.center,
                            style: HeritageTypography.bodySmall,
                          ),
                        ],
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
                        color: HeritageColors.warmIvoryLight,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: HeritageColors.stone, width: 1.2),
                        boxShadow: const [
                          BoxShadow(
                            color: HeritageColors.subtleShadow,
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: HeritageColors.stoneLight,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: HeritageColors.stoneDark, width: 1),
                          ),
                          child: Icon(
                            _getIconForType(asset.mediaType),
                            color: HeritageColors.forestGreen,
                            size: 24,
                          ),
                        ),
                        title: Text(
                          asset.title,
                          style: HeritageTypography.titleSmall.copyWith(fontSize: 15),
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
                                style: HeritageTypography.bodySmall,
                              ),
                            ],
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  asset.capturedDate != null
                                      ? 'Dated: ${asset.capturedDate!.year}'
                                      : 'Archival Record',
                                  style: HeritageTypography.lifeDates.copyWith(fontSize: 11),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: HeritageColors.stone,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Private Bucket',
                                    style: HeritageTypography.labelSmall.copyWith(
                                      fontSize: 9,
                                      color: HeritageColors.forestGreen,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.download_rounded, color: HeritageColors.forestGreen),
                          tooltip: 'Signed Private Download',
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Generating short-lived signed URL for "${asset.title}"...'),
                                backgroundColor: HeritageColors.forestGreen,
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
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        if (val) {
          setState(() {
            _selectedType = type;
          });
        }
      },
      selectedColor: HeritageColors.softBlueAccent,
      backgroundColor: HeritageColors.surfaceSecondary,
      side: BorderSide(
        color: isSelected ? HeritageColors.blueHighlight : HeritageColors.borderSubtle,
        width: 1.0,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      labelStyle: HeritageTypography.labelSmall.copyWith(
        color: isSelected ? HeritageColors.charcoal : HeritageColors.charcoalMuted,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
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
