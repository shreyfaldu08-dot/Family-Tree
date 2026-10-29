import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/typography.dart';
import '../../../data/providers/repository_providers.dart';

class AdminSettingsScreen extends ConsumerWidget {
  const AdminSettingsScreen({super.key});

  void _showAddAdminDialog(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final contactCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: HeritageCurves.cardLarge),
        title: Text('Add New Admin Account', style: HeritageTypography.titleMedium.copyWith(fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'New admins will have full authority to add, edit, and delete family records.',
              style: HeritageTypography.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person_outline_rounded)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: contactCtrl,
              decoration: const InputDecoration(labelText: 'Email or Phone', prefixIcon: Icon(Icons.email_outlined)),
            ),
          ],
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
              if (nameCtrl.text.trim().isNotEmpty && contactCtrl.text.trim().isNotEmpty) {
                ref.read(userManagementProvider.notifier).addAdmin(
                      name: nameCtrl.text.trim(),
                      emailOrPhone: contactCtrl.text.trim(),
                    );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('New administrator account created!'), backgroundColor: AppColors.primary),
                );
              }
            },
            child: const Text('Create Admin'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(adminSettingsProvider);
    final settingsNotifier = ref.read(adminSettingsProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Admin Settings & Privacy', style: HeritageTypography.displaySmall),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. Privacy Controls Section
          _buildSectionHeader('Privacy & Data Protection'),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: HeritageCurves.card,
              boxShadow: HeritageShadows.card,
            ),
            child: Column(
              children: [
                SwitchListTile(
                  activeColor: AppColors.primary,
                  title: Text('Hide Sensitive Details of Living Relatives', style: HeritageTypography.titleSmall.copyWith(fontWeight: FontWeight.w700)),
                  subtitle: Text(
                    'Automatically hides contact numbers and exact birth times of living people from regular viewers.',
                    style: HeritageTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                  value: settings.hideSensitiveLivingDetails,
                  onChanged: (v) => settingsNotifier.toggleHideSensitiveLivingDetails(),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                SwitchListTile(
                  activeColor: AppColors.primary,
                  title: Text('Allow Family Member Downloads', style: HeritageTypography.titleSmall.copyWith(fontWeight: FontWeight.w700)),
                  subtitle: Text(
                    'Permits view-only family members to export tree images and PDF lineage documents.',
                    style: HeritageTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                  value: settings.allowUserDownloads,
                  onChanged: (v) => settingsNotifier.toggleAllowUserDownloads(),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                SwitchListTile(
                  activeColor: AppColors.primary,
                  title: Text('Enable "Suggest a Correction" Notes', style: HeritageTypography.titleSmall.copyWith(fontWeight: FontWeight.w700)),
                  subtitle: Text(
                    'Displays a note submission button on member profiles for users to suggest fixes to the admin.',
                    style: HeritageTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                  value: settings.allowCorrectionSuggestions,
                  onChanged: (v) => settingsNotifier.toggleCorrectionSuggestions(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 2. Language Switcher (English, Hindi, Gujarati)
          _buildSectionHeader('System Language'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: HeritageCurves.card,
              boxShadow: HeritageShadows.card,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select the primary language for family heritage records and menus:',
                  style: HeritageTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildLanguageChip('en', 'English (English)', settings.activeLanguage, settingsNotifier),
                    const SizedBox(width: 8),
                    _buildLanguageChip('hi', 'हिंदी (Hindi)', settings.activeLanguage, settingsNotifier),
                    const SizedBox(width: 8),
                    _buildLanguageChip('gu', 'ગુજરાતી (Gujarati)', settings.activeLanguage, settingsNotifier),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 3. Admin Accounts Management
          _buildSectionHeader('Administrator Access'),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: HeritageCurves.card,
              boxShadow: HeritageShadows.card,
            ),
            child: ListTile(
              leading: const Icon(Icons.person_add_alt_1_rounded, color: AppColors.primary),
              title: Text('Create Additional Admin Account', style: HeritageTypography.titleSmall.copyWith(fontWeight: FontWeight.w700)),
              subtitle: Text('Grant an elder or family co-curator full editing rights.', style: HeritageTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
              trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.paleSage),
              onTap: () => _showAddAdminDialog(context, ref),
            ),
          ),

          const SizedBox(height: 24),

          // 4. Backup & Export Section
          _buildSectionHeader('Archive Backup & Export'),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: HeritageCurves.card,
              boxShadow: HeritageShadows.card,
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.file_download_outlined, color: AppColors.primary),
                  title: Text('Export Complete Lineage (JSON Backup)', style: HeritageTypography.titleSmall.copyWith(fontWeight: FontWeight.w700)),
                  subtitle: Text('Download complete genealogical tree structure, relationships, and metadata.', style: HeritageTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
                  trailing: const Icon(Icons.download_rounded, color: AppColors.primary),
                  onTap: () {
                    context.push('/admin/export');
                  },
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.picture_as_pdf_outlined, color: AppColors.primary),
                  title: Text('Generate Heritage PDF Book / Tree Chart', style: HeritageTypography.titleSmall.copyWith(fontWeight: FontWeight.w700)),
                  subtitle: Text('Formatted printable heirloom pedigree chart across all generations.', style: HeritageTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
                  trailing: const Icon(Icons.print_rounded, color: AppColors.primary),
                  onTap: () {
                    context.push('/admin/export');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: HeritageTypography.titleSmall.copyWith(
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildLanguageChip(String code, String label, String currentCode, AdminSettingsNotifier notifier) {
    final isSelected = code == currentCode;
    return Expanded(
      child: InkWell(
        onTap: () => notifier.setLanguage(code),
        borderRadius: HeritageCurves.pill,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.background,
            borderRadius: HeritageCurves.pill,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
