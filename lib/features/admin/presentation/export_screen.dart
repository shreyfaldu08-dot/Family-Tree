import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/typography.dart';
import '../../../data/providers/repository_providers.dart';

class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  String? _exportedJson;
  bool _isExporting = false;

  Future<void> _performExport() async {
    setState(() => _isExporting = true);
    try {
      final repo = ref.read(adminRepositoryProvider);
      final membership = ref.read(currentMembershipProvider).valueOrNull;
      final jsonStr = await repo.exportArchiveJson('fam_kensington_01', membership);
      if (mounted) {
        setState(() => _exportedJson = jsonStr);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export error: $e'), backgroundColor: HeritageColors.statusError),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HeritageColors.warmIvory,
      appBar: AppBar(
        title: Text('Export & Recovery', style: HeritageTypography.displaySmall),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: HeritageCurves.cardLarge,
              boxShadow: HeritageShadows.card,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Archive Backup & Data Portability', style: HeritageTypography.titleMedium),
                const SizedBox(height: 6),
                Text(
                  'Family Legacy guarantees full ownership of your heritage. You can export a canonical, structured JSON document containing all family members, direct relationships, timeline events, and media metadata.',
                  style: HeritageTypography.bodyMedium,
                ),
                const SizedBox(height: 18),
                ElevatedButton.icon(
                  onPressed: _isExporting ? null : _performExport,
                  icon: const Icon(Icons.cloud_download_outlined),
                  label: _isExporting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Generate Archive JSON Export'),
                ),
              ],
            ),
          ),

          if (_exportedJson != null) ...[
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Exported Archive Payload', style: HeritageTypography.displaySmall),
                IconButton(
                  icon: const Icon(Icons.copy, color: AppColors.textPrimary),
                  tooltip: 'Copy JSON',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _exportedJson!));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Archive JSON copied to clipboard!')),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              height: 380,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.lightSage,
                borderRadius: HeritageCurves.card,
              ),
              child: SingleChildScrollView(
                child: SelectableText(
                  _exportedJson!,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11.5,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
