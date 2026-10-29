import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/typography.dart';
import '../../../data/models/app_user.dart';
import '../../../data/providers/repository_providers.dart';

class ManageUsersScreen extends ConsumerStatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  ConsumerState<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends ConsumerState<ManageUsersScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showAddAdminDialog() {
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

  void _confirmDeleteUser(AppUser user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: HeritageCurves.cardLarge),
        title: Text('Delete User Account?', style: HeritageTypography.titleMedium.copyWith(fontWeight: FontWeight.w700)),
        content: Text(
          'Are you sure you want to permanently delete account for ${user.name} (${user.emailOrPhone})? This cannot be undone.',
          style: HeritageTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusError,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: HeritageCurves.pill),
            ),
            onPressed: () {
              ref.read(userManagementProvider.notifier).deleteUser(user.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('User ${user.name} deleted.')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final users = ref.watch(userManagementProvider);
    final filtered = users.where((u) {
      if (_query.isEmpty) return true;
      return u.name.toLowerCase().contains(_query.toLowerCase()) ||
          u.emailOrPhone.toLowerCase().contains(_query.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Manage Users', style: HeritageTypography.displaySmall),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_rounded, color: AppColors.primary),
            tooltip: 'Add Admin Account',
            onPressed: _showAddAdminDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: HeritageCurves.pill,
                boxShadow: HeritageShadows.card,
              ),
              child: TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  hintText: 'Search users by name or email/phone...',
                  hintStyle: HeritageTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                  border: InputBorder.none,
                  icon: const Icon(Icons.search_rounded, size: 20, color: AppColors.primary),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            setState(() {
                              _searchCtrl.clear();
                              _query = '';
                            });
                          },
                        )
                      : null,
                ),
                onChanged: (val) => setState(() => _query = val.trim()),
              ),
            ),
          ),

          // User List
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text('No users found', style: HeritageTypography.bodyMedium),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, idx) {
                      final user = filtered[idx];
                      final isAdminUser = user.role == 'admin';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: HeritageCurves.card,
                            boxShadow: HeritageShadows.card,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: isAdminUser ? AppColors.paleSage : AppColors.lightSage,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isAdminUser ? Icons.admin_panel_settings_rounded : Icons.person_rounded,
                                  color: isAdminUser ? AppColors.primary : AppColors.textSecondary,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          user.name,
                                          style: HeritageTypography.titleSmall.copyWith(fontWeight: FontWeight.w700),
                                        ),
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: isAdminUser ? AppColors.primary.withOpacity(0.12) : AppColors.lightSage,
                                            borderRadius: HeritageCurves.pill,
                                          ),
                                          child: Text(
                                            user.role.toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w800,
                                              color: isAdminUser ? AppColors.primary : AppColors.textSecondary,
                                            ),
                                          ),
                                        ),
                                        if (user.isBlocked) ...[
                                          const SizedBox(width: 4),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppColors.statusError.withOpacity(0.12),
                                              borderRadius: HeritageCurves.pill,
                                            ),
                                            child: const Text(
                                              'BLOCKED',
                                              style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.w800,
                                                color: AppColors.statusError,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    Text(
                                      user.emailOrPhone,
                                      style: HeritageTypography.bodySmall.copyWith(
                                        fontSize: 11,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Block / Unblock Toggle
                              IconButton(
                                icon: Icon(
                                  user.isBlocked ? Icons.lock_open_rounded : Icons.block_rounded,
                                  color: user.isBlocked ? AppColors.primary : AppColors.statusError,
                                  size: 20,
                                ),
                                tooltip: user.isBlocked ? 'Unblock user' : 'Block user',
                                onPressed: () {
                                  ref.read(userManagementProvider.notifier).toggleBlock(user.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(user.isBlocked ? 'User unblocked' : 'User blocked'),
                                      duration: const Duration(seconds: 1),
                                    ),
                                  );
                                },
                              ),
                              // Delete Button
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.statusError, size: 20),
                                tooltip: 'Delete user',
                                onPressed: () => _confirmDeleteUser(user),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
