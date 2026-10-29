import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/typography.dart';
import '../../../data/models/membership.dart';
import '../../../data/providers/repository_providers.dart';

class AdminLoginScreen extends ConsumerStatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  ConsumerState<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends ConsumerState<AdminLoginScreen> {
  final _emailCtrl = TextEditingController(text: 'admin@vansora.heritage');
  final _passwordCtrl = TextEditingController(text: 'admin1234');
  bool _isLoading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleAdminLogin() async {
    setState(() => _isLoading = true);
    try {
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.signInWithEmail(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
      );

      // Explicitly set role to Admin
      ref.read(currentUserRoleProvider.notifier).setRole(MemberRole.primaryAdmin);

      ref.invalidate(currentProfileProvider);
      ref.invalidate(currentMembershipProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Admin authenticated successfully. Full edit rights granted.'),
            backgroundColor: AppColors.primary,
          ),
        );
        context.go('/admin');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Admin Login failed: $e'),
            backgroundColor: AppColors.statusError,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Admin Portal', style: HeritageTypography.displaySmall),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/'),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 74,
                      height: 74,
                      decoration: const BoxDecoration(
                        color: AppColors.lightSage,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.admin_panel_settings_rounded,
                        color: AppColors.primary,
                        size: 38,
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  Text(
                    'Admin Authority Login',
                    textAlign: TextAlign.center,
                    style: HeritageTypography.displayMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    'Exclusive access for authorized lineage keepers. Single authority to add, edit, and safeguard family records.',
                    textAlign: TextAlign.center,
                    style: HeritageTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 28),

                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: HeritageCurves.cardLarge,
                      boxShadow: HeritageShadows.card,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Admin Username / Email',
                            prefixIcon: Icon(Icons.shield_outlined, size: 20),
                          ),
                        ),

                        const SizedBox(height: 16),

                        TextField(
                          controller: _passwordCtrl,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Master Password',
                            prefixIcon: Icon(Icons.lock_outline_rounded, size: 20),
                          ),
                        ),

                        const SizedBox(height: 22),

                        ElevatedButton(
                          onPressed: _isLoading ? null : _handleAdminLogin,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Text('Sign In as Admin Authority'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // User notice: NO signup link here
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.lightSage.withOpacity(0.5),
                      borderRadius: HeritageCurves.pill,
                    ),
                    child: Text(
                      '🛡️ Admin accounts are created exclusively by the existing Family Admin in Admin Settings. Sign up is disabled on this portal.',
                      textAlign: TextAlign.center,
                      style: HeritageTypography.bodySmall.copyWith(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  Center(
                    child: TextButton(
                      onPressed: () => context.go('/login'),
                      child: const Text('Switch to Regular Family Member Login'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
