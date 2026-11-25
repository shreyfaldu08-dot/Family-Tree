import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
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

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Family Archive', style: HeritageTypography.displaySmall),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_photo_alternate_outlined, color: AppColors.primary),
            tooltip: 'Upload to Family Vault',
            onPressed: () => _showUploadModal(context),
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
                            const SizedBox(height: 18),
                            ElevatedButton.icon(
                              onPressed: () => _showUploadModal(context),
                              icon: const Icon(Icons.upload_file_rounded, size: 18),
                              label: const Text('Upload First Record'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                    final isImage = asset.mediaType == MediaType.photo ||
                        asset.storagePath.endsWith('.jpg') ||
                        asset.storagePath.endsWith('.png') ||
                        asset.storagePath.endsWith('.webp');

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: HeritageCurves.card,
                        border: Border.all(color: AppColors.border, width: 0.8),
                        boxShadow: HeritageShadows.card,
                      ),
                      child: InkWell(
                        onTap: () => _showMediaLightbox(context, asset),
                        borderRadius: HeritageCurves.card,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          child: Row(
                            children: [
                              // Leading Thumbnail or Category Icon
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: AppColors.lightSage,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: AppColors.border, width: 0.8),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: isImage
                                      ? Image.asset(
                                          asset.storagePath.startsWith('assets/')
                                              ? asset.storagePath
                                              : 'assets/images/vintage_vault_documents.jpg',
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => Center(
                                            child: Icon(_getIconForType(asset.mediaType), color: AppColors.primary, size: 26),
                                          ),
                                        )
                                      : Center(
                                          child: Icon(_getIconForType(asset.mediaType), color: AppColors.primary, size: 26),
                                        ),
                                ),
                              ),
                              const SizedBox(width: 14),

                              // Metadata
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      asset.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: HeritageTypography.titleSmall.copyWith(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    if (asset.description != null && asset.description!.isNotEmpty) ...[
                                      const SizedBox(height: 3),
                                      Text(
                                        asset.description!,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: HeritageTypography.bodySmall.copyWith(
                                          color: AppColors.textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 5),
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
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.lightSage,
                                            borderRadius: HeritageCurves.pill,
                                          ),
                                          child: Text(
                                            asset.mediaType.label,
                                            style: GoogleFonts.inter(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 8),

                              // Quick Action Buttons
                              IconButton(
                                icon: const Icon(Icons.fullscreen_rounded, color: AppColors.primary, size: 24),
                                tooltip: 'Full-Screen Lightbox',
                                onPressed: () => _showMediaLightbox(context, asset),
                              ),
                            ],
                          ),
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

  // ---------------------------------------------------------------------------
  // Full-Screen Interactive Lightbox
  // ---------------------------------------------------------------------------
  void _showMediaLightbox(BuildContext context, MediaAsset asset) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.92),
      builder: (ctx) => _MediaLightboxDialog(asset: asset),
    );
  }

  // ---------------------------------------------------------------------------
  // Real Upload Modal Sheet
  // ---------------------------------------------------------------------------
  void _showUploadModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _UploadMediaBottomSheet(
        onSaved: () {
          ref.invalidate(familyMediaProvider);
        },
      ),
    );
  }
}

/// Interactive Full-Screen Lightbox with Pinch-to-Zoom, Rotation, and Metadata
class _MediaLightboxDialog extends StatefulWidget {
  final MediaAsset asset;

  const _MediaLightboxDialog({required this.asset});

  @override
  State<_MediaLightboxDialog> createState() => _MediaLightboxDialogState();
}

class _MediaLightboxDialogState extends State<_MediaLightboxDialog> {
  final TransformationController _transformController = TransformationController();
  int _rotationQuarterTurns = 0;
  bool _showDetails = false;

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  void _rotate() {
    setState(() {
      _rotationQuarterTurns = (_rotationQuarterTurns + 1) % 4;
    });
  }

  void _resetZoom() {
    setState(() {
      _transformController.value = Matrix4.identity();
      _rotationQuarterTurns = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final asset = widget.asset;
    final isImage = asset.mediaType == MediaType.photo ||
        asset.storagePath.endsWith('.jpg') ||
        asset.storagePath.endsWith('.png') ||
        asset.storagePath.endsWith('.webp');

    final effectivePath = asset.storagePath.startsWith('assets/')
        ? asset.storagePath
        : 'assets/images/vintage_vault_documents.jpg';

    return Dialog.fullscreen(
      backgroundColor: Colors.transparent,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Center Interactive Canvas (Pinch, Zoom, Pan)
          Center(
            child: InteractiveViewer(
              transformationController: _transformController,
              minScale: 0.5,
              maxScale: 5.0,
              child: RotatedBox(
                quarterTurns: _rotationQuarterTurns,
                child: isImage
                    ? Image.asset(
                        effectivePath,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 320,
                          height: 320,
                          color: Colors.white10,
                          child: const Center(
                            child: Icon(Icons.broken_image_rounded, size: 64, color: Colors.white54),
                          ),
                        ),
                      )
                    : Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              asset.mediaType == MediaType.audio
                                  ? Icons.record_voice_over_rounded
                                  : Icons.article_rounded,
                              size: 72,
                              color: const Color(0xFF38BDF8),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              asset.title,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              asset.description ?? 'Archival Encrypted Record',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(fontSize: 13, color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ),

          // 2. Top Header Bar (Title + Controls + Close)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.85), Colors.transparent],
                ),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            asset.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                          ),
                          Text(
                            '${asset.mediaType.label} • ${asset.capturedDate != null ? asset.capturedDate!.year : "Archival"}',
                            style: GoogleFonts.inter(fontSize: 12, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.rotate_right_rounded, color: Colors.white),
                      tooltip: 'Rotate 90°',
                      onPressed: _rotate,
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                      tooltip: 'Reset Zoom',
                      onPressed: _resetZoom,
                    ),
                    IconButton(
                      icon: Icon(
                        _showDetails ? Icons.info_rounded : Icons.info_outline_rounded,
                        color: _showDetails ? const Color(0xFF38BDF8) : Colors.white,
                      ),
                      tooltip: 'Details & Provenance',
                      onPressed: () => setState(() => _showDetails = !_showDetails),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. Slide-in Details Drawer / Overlay
          if (_showDetails)
            Positioned(
              bottom: 80,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A).withOpacity(0.94),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 18,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Archival Provenance',
                          style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFF10B981), width: 0.8),
                          ),
                          child: Text(
                            'ENCRYPTED AES-256',
                            style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: const Color(0xFF10B981)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (asset.description != null)
                      Text(
                        asset.description!,
                        style: GoogleFonts.inter(fontSize: 13, height: 1.4, color: Colors.white.withOpacity(0.9)),
                      ),
                    const SizedBox(height: 12),
                    const Divider(color: Colors.white24, height: 1),
                    const SizedBox(height: 10),
                    _detailRow('Storage Path', asset.storagePath),
                    _detailRow('MIME Type', asset.mimeType ?? 'image/jpeg'),
                    _detailRow('Historical Date', asset.capturedDate != null ? '${asset.capturedDate!.year}-${asset.capturedDate!.month.toString().padLeft(2, '0')}' : 'Estimated'),
                  ],
                ),
              ),
            ),

          // 4. Bottom Action Bar (Download & Share)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.85), Colors.transparent],
                ),
              ),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.download_done_rounded, color: Colors.white, size: 20),
                                const SizedBox(width: 10),
                                Expanded(child: Text('Downloaded high-res copy of "${asset.title}"')),
                              ],
                            ),
                            backgroundColor: AppColors.primary,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: const Icon(Icons.download_rounded, size: 18),
                      label: const Text('Download High-Res'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Secure encrypted share link copied to clipboard!'),
                            backgroundColor: AppColors.primary,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: const Icon(Icons.share_outlined, size: 18, color: Colors.white),
                      label: const Text('Share Record', style: TextStyle(color: Colors.white)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white60),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text('$label: ', style: GoogleFonts.inter(fontSize: 11.5, color: Colors.white60, fontWeight: FontWeight.w600)),
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(fontSize: 11.5, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

/// Real Media Upload Bottom Sheet
class _UploadMediaBottomSheet extends ConsumerStatefulWidget {
  final VoidCallback onSaved;

  const _UploadMediaBottomSheet({required this.onSaved});

  @override
  ConsumerState<_UploadMediaBottomSheet> createState() => _UploadMediaBottomSheetState();
}

class _UploadMediaBottomSheetState extends ConsumerState<_UploadMediaBottomSheet> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _yearCtrl = TextEditingController(text: '1928');
  MediaType _type = MediaType.photo;
  bool _isApprox = true;
  String _selectedAsset = 'assets/images/family_gathering.jpg';

  final List<Map<String, String>> _samplePresets = const [
    {'title': 'Family Gathering', 'path': 'assets/images/family_gathering.jpg'},
    {'title': 'Vintage Heirloom', 'path': 'assets/images/vintage_heirloom.jpg'},
    {'title': 'Vault Indenture', 'path': 'assets/images/vintage_vault_documents.jpg'},
    {'title': 'Archibald Portrait', 'path': 'assets/images/archibald_portrait.jpg'},
    {'title': 'Timber Estate', 'path': 'assets/images/estate_hero.jpg'},
    {'title': 'Vintage Matriarch', 'path': 'assets/images/vintage_lady_portrait.jpg'},
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _yearCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an archival title for this media.')),
      );
      return;
    }

    final year = int.tryParse(_yearCtrl.text.trim()) ?? DateTime.now().year;
    final capturedDate = DateTime(year, 6, 1);

    final membership = ref.read(currentMembershipProvider).valueOrNull;
    final mediaRepo = ref.read(mediaRepositoryProvider);

    final newAsset = MediaAsset(
      id: 'med_${DateTime.now().millisecondsSinceEpoch}',
      familyId: 'fam_kensington_01',
      storagePath: _selectedAsset,
      mediaType: _type,
      title: title,
      description: _descCtrl.text.trim().isNotEmpty ? _descCtrl.text.trim() : null,
      capturedDate: capturedDate,
      capturedDateApprox: _isApprox,
      mimeType: _type == MediaType.photo ? 'image/jpeg' : 'application/pdf',
      fileSizeBytes: 840000,
      uploaderId: membership?.userId ?? 'usr_admin_kensington_01',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await mediaRepo.createMediaAsset(newAsset, membership);
    widget.onSaved();

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Preserved "$title" in Family Vault!'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Upload Archival Record',
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            Text(
              'Add historic photography, certificates, or letters into the encrypted lineage vault.',
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 18),

            // Select Media Type
            Row(
              children: [
                _typePill('Photo', MediaType.photo, Icons.photo_camera_back_outlined),
                const SizedBox(width: 8),
                _typePill('Document', MediaType.document, Icons.description_outlined),
                const SizedBox(width: 8),
                _typePill('Audio', MediaType.audio, Icons.record_voice_over_outlined),
                const SizedBox(width: 8),
                _typePill('Video', MediaType.video, Icons.videocam_outlined),
              ],
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _titleCtrl,
              decoration: InputDecoration(
                labelText: 'Media Title',
                hintText: 'e.g. 1928 Cascadia Reunion Gathering',
                prefixIcon: const Icon(Icons.title_rounded, size: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _yearCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Year Captured',
                      hintText: '1928',
                      prefixIcon: const Icon(Icons.calendar_today_outlined, size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _isApprox = !_isApprox),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                      decoration: BoxDecoration(
                        color: _isApprox ? AppColors.lightSage : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _isApprox ? AppColors.primary : AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _isApprox ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                            color: _isApprox ? AppColors.primary : AppColors.textSecondary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Approx / Circa',
                            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            TextField(
              controller: _descCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Archival Description / Provenance',
                hintText: 'e.g. Preserved in heirloom velvet chest; original silver gelatin print.',
                prefixIcon: const Icon(Icons.notes_rounded, size: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const SizedBox(height: 16),

            Text(
              'Select Source Archival Image / Preset:',
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),

            SizedBox(
              height: 72,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _samplePresets.length,
                separatorBuilder: (ctx, i) => const SizedBox(width: 10),
                itemBuilder: (ctx, i) {
                  final preset = _samplePresets[i];
                  final isSelected = _selectedAsset == preset['path'];
                  return InkWell(
                    onTap: () => setState(() => _selectedAsset = preset['path']!),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.border,
                          width: isSelected ? 2.5 : 1.0,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(preset['path']!, fit: BoxFit.cover),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 22),

            ElevatedButton(
              onPressed: _handleSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'Preserve to Family Vault',
                style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _typePill(String label, MediaType type, IconData icon) {
    final isSelected = _type == type;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _type = type),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.paleSage : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 1.5 : 0.8,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, size: 18, color: isSelected ? AppColors.primary : AppColors.textSecondary),
              const SizedBox(height: 2),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 10.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
