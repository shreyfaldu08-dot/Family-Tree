import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/typography.dart';
import '../../../data/models/media_asset.dart';
import '../../../data/providers/repository_providers.dart';

class ManageMediaScreen extends ConsumerStatefulWidget {
  const ManageMediaScreen({super.key});

  @override
  ConsumerState<ManageMediaScreen> createState() => _ManageMediaScreenState();
}

class _ManageMediaScreenState extends ConsumerState<ManageMediaScreen> {
  String _selectedTab = 'all'; // 'all', 'photo', 'document'

  void _showUploadDialog() {
    final titleCtrl = TextEditingController();
    final urlCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String mediaType = 'photo';
    String? selectedPersonId;

    final personsAsync = ref.read(familyPersonsProvider);
    final persons = personsAsync.valueOrNull ?? const [];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: HeritageCurves.cardLarge),
          title: Text('Upload Family Media', style: HeritageTypography.titleMedium.copyWith(fontWeight: FontWeight.w700)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Title / Caption', prefixIcon: Icon(Icons.title_rounded)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: urlCtrl,
                  decoration: const InputDecoration(labelText: 'File URL / Image Link', prefixIcon: Icon(Icons.link_rounded)),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: mediaType,
                  decoration: const InputDecoration(labelText: 'Media Type', prefixIcon: Icon(Icons.category_outlined)),
                  items: const [
                    DropdownMenuItem(value: 'photo', child: Text('Photograph / Portrait')),
                    DropdownMenuItem(value: 'document', child: Text('Historical Document / Certificate')),
                  ],
                  onChanged: (val) {
                    if (val != null) setDialogState(() => mediaType = val);
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedPersonId,
                  decoration: const InputDecoration(labelText: 'Tag Relative (Optional)', prefixIcon: Icon(Icons.person_outline_rounded)),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('General Family Archive')),
                    ...persons.map((p) => DropdownMenuItem(value: p.id, child: Text(p.displayName))),
                  ],
                  onChanged: (val) {
                    setDialogState(() => selectedPersonId = val);
                  },
                ),
              ],
            ),
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
              onPressed: () async {
                if (titleCtrl.text.trim().isNotEmpty && urlCtrl.text.trim().isNotEmpty) {
                  final mediaRepo = ref.read(mediaRepositoryProvider);
                  final membership = ref.read(currentMembershipProvider).valueOrNull;
                  final messenger = ScaffoldMessenger.of(context);
                  final nav = Navigator.of(ctx);

                  final asset = MediaAsset(
                    id: 'med_${DateTime.now().millisecondsSinceEpoch}',
                    familyId: 'fam_kensington_01',
                    storagePath: urlCtrl.text.trim(),
                    signedUrl: urlCtrl.text.trim(),
                    mimeType: mediaType == 'photo' ? 'image/jpeg' : 'application/pdf',
                    fileSizeBytes: 1024 * 1024,
                    mediaType: mediaType == 'photo' ? MediaType.photo : MediaType.document,
                    title: titleCtrl.text.trim(),
                    description: descCtrl.text.trim().isNotEmpty ? descCtrl.text.trim() : null,
                    uploaderId: 'usr_admin',
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  );

                  await mediaRepo.createMediaAsset(asset, membership);

                  ref.invalidate(familyMediaProvider);
                  nav.pop();
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Media uploaded to family archive!'), backgroundColor: AppColors.primary),
                  );
                }
              },
              child: const Text('Save Media'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaAsync = ref.watch(familyMediaProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Manage Media & Scans', style: HeritageTypography.displaySmall),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_upload_outlined, color: AppColors.primary),
            tooltip: 'Upload Media',
            onPressed: _showUploadDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs (All, Photos, Documents)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                _buildTabChip('all', 'All Media'),
                const SizedBox(width: 8),
                _buildTabChip('photo', 'Photos & Portraits'),
                const SizedBox(width: 8),
                _buildTabChip('document', 'Documents & Scans'),
              ],
            ),
          ),

          // Media Content Grid
          Expanded(
            child: mediaAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              error: (err, _) => Center(child: Text('Error: $err')),
              data: (assets) {
                final filtered = assets.where((a) {
                  if (_selectedTab == 'photo') return a.mediaType == MediaType.photo;
                  if (_selectedTab == 'document') return a.mediaType == MediaType.document;
                  return true;
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.photo_library_outlined, size: 48, color: AppColors.paleSage),
                        const SizedBox(height: 12),
                        Text('No media found', style: HeritageTypography.titleSmall),
                        Text('Click "+" to upload family photos and certificates.', style: HeritageTypography.bodySmall),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemBuilder: (ctx, idx) {
                    final asset = filtered[idx];
                    final isPhoto = asset.mediaType == MediaType.photo;

                    return Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: HeritageCurves.card,
                        boxShadow: HeritageShadows.card,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              color: AppColors.lightSage,
                              child: isPhoto && asset.signedUrl != null && asset.signedUrl!.isNotEmpty
                                  ? Image.network(
                                      asset.signedUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (c, e, s) => const Center(child: Icon(Icons.image_outlined, size: 36, color: AppColors.primary)),
                                    )
                                  : Center(
                                      child: Icon(
                                        isPhoto ? Icons.photo_outlined : Icons.description_outlined,
                                        size: 40,
                                        color: AppColors.primary,
                                      ),
                                    ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  asset.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: HeritageTypography.titleSmall.copyWith(fontSize: 12.5, fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isPhoto ? 'Photo' : 'Document',
                                  style: HeritageTypography.bodySmall.copyWith(fontSize: 10, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        ],
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

  Widget _buildTabChip(String key, String label) {
    final isSelected = _selectedTab == key;
    return InkWell(
      onTap: () => setState(() => _selectedTab = key),
      borderRadius: HeritageCurves.pill,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: HeritageCurves.pill,
          boxShadow: isSelected ? HeritageShadows.activePill : HeritageShadows.card,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
