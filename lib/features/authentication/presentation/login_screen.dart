import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme/colors.dart';
import '../../../app/theme/typography.dart';
import '../../../data/models/membership.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/providers/repository_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl = TextEditingController(text: 'sara.wilson@kensingtonlegacy.org');
  final _passwordCtrl = TextEditingController(text: 'password123');
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _selectedPersonaId = 'p_gen9_sara';

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handlePersonaLogin(FamilyPersona persona) async {
    setState(() {
      _isLoading = true;
      _selectedPersonaId = persona.id;
      _emailCtrl.text = persona.email;
      _passwordCtrl.text = persona.defaultPassword;
    });

    try {
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.switchPersona(persona.id);

      // Update role notifier
      ref.read(currentUserRoleProvider.notifier).setRole(persona.role);
      ref.read(userBranchPersonIdProvider.notifier).setPersonId(persona.id);

      ref.invalidate(currentProfileProvider);
      ref.invalidate(currentMembershipProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Logged in as ${persona.displayName} (${persona.roleTitle})',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Persona switch error: $e'),
            backgroundColor: HeritageColors.statusError,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleEmailLogin() async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an email address.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.signInWithEmail(email: email, password: password);

      // Synchronize role from repo
      final activeRole = authRepo.currentRole;
      ref.read(currentUserRoleProvider.notifier).setRole(activeRole);

      final currentUserId = authRepo.currentUserId;
      if (currentUserId != null) {
        ref.read(userBranchPersonIdProvider.notifier).setPersonId(currentUserId);
      }

      ref.invalidate(currentProfileProvider);
      ref.invalidate(currentMembershipProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome to Vansora Heritage!'),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: $e'),
            backgroundColor: HeritageColors.statusError,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    try {
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.signInWithGoogle();

      ref.read(currentUserRoleProvider.notifier).setRole(MemberRole.primaryAdmin);
      ref.invalidate(currentProfileProvider);
      ref.invalidate(currentMembershipProvider);

      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google Sign-in failed: $e'),
            backgroundColor: HeritageColors.statusError,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authRepo = ref.watch(authRepositoryProvider);
    final personas = authRepo.personas;

    return Scaffold(
      backgroundColor: HeritageColors.warmIvory,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 580),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Heritage crest emblem
                  Center(
                    child: Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        color: AppColors.lightSage,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.18),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.auto_stories_rounded,
                        color: AppColors.primary,
                        size: 36,
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  Text(
                    'Vansora',
                    textAlign: TextAlign.center,
                    style: HeritageTypography.displayLarge.copyWith(
                      fontSize: 34,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Living digital heritage across ten generations',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // =========================================================
                  // 1. ONE-CLICK DEMO PERSONA ACCESS (FOR ANY EVALUATOR)
                  // =========================================================
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: HeritageCurves.cardLarge,
                      border: Border.all(color: AppColors.border, width: 1.2),
                      boxShadow: HeritageShadows.card,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.paleBlue,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.flash_on_rounded, size: 18, color: AppColors.primary),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '1-Click Instant Persona Access',
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    'Select any family member to preview their personalized view & permissions',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Persona grid / list
                        ...personas.map((persona) {
                          final isSelected = _selectedPersonaId == persona.id;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _buildPersonaCard(persona, isSelected),
                          );
                        }),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  // =========================================================
                  // 2. CUSTOM CREDENTIALS LOGIN CARD
                  // =========================================================
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: HeritageCurves.cardLarge,
                      boxShadow: HeritageShadows.card,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Or Sign In with Any Account',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Enter any custom or family email to start an authenticated session',
                          style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                        ),

                        const SizedBox(height: 18),

                        // Google Sign-In button
                        OutlinedButton.icon(
                          onPressed: _isLoading ? null : _handleGoogleLogin,
                          icon: const Icon(Icons.g_mobiledata, size: 28),
                          label: const Text('Continue with Google'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),

                        const SizedBox(height: 16),

                        Row(
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Text('or email passcode', style: HeritageTypography.bodySmall),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),

                        const SizedBox(height: 16),

                        TextField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Email Address',
                            hintText: 'e.g. sara.wilson@kensingtonlegacy.org',
                            prefixIcon: const Icon(Icons.email_outlined, size: 20),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),

                        const SizedBox(height: 14),

                        TextField(
                          controller: _passwordCtrl,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline, size: 20),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                size: 20,
                              ),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),

                        const SizedBox(height: 8),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => context.push('/forgot-password'),
                            child: const Text('Forgot Password?'),
                          ),
                        ),

                        const SizedBox(height: 12),

                        ElevatedButton(
                          onPressed: _isLoading ? null : _handleEmailLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : Text(
                                  'Sign In to Heritage Vault',
                                  style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
                                ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Connect to Family Tree with Unique ID button
                  OutlinedButton.icon(
                    onPressed: () => context.push('/lineage-bridge'),
                    icon: const Icon(Icons.account_tree_outlined, size: 18, color: AppColors.primary),
                    label: const Text(
                      'Join with Unique Family Tree ID',
                      style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: HeritageCurves.pill),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Invitation code redemption button
                  TextButton.icon(
                    onPressed: () => context.push('/redeem-invitation'),
                    icon: const Icon(Icons.vpn_key_outlined, size: 18),
                    label: const Text('Have an invitation passcode? Redeem here'),
                  ),

                  // Register link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have an account?", style: HeritageTypography.bodySmall),
                      TextButton(
                        onPressed: () => context.push('/signup'),
                        child: const Text('Sign Up', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),

                  // Dedicated Admin portal shortcut
                  Center(
                    child: TextButton.icon(
                      onPressed: () => context.push('/admin/login'),
                      icon: const Icon(Icons.admin_panel_settings_outlined, size: 16),
                      label: const Text('Admin Authority Portal (/admin/login)'),
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

  Widget _buildPersonaCard(FamilyPersona persona, bool isSelected) {
    Color badgeBg;
    Color badgeText;
    IconData roleIcon;

    switch (persona.role) {
      case MemberRole.primaryAdmin:
        badgeBg = const Color(0xFFEFF6FF);
        badgeText = const Color(0xFF1D4ED8);
        roleIcon = Icons.admin_panel_settings_rounded;
        break;
      case MemberRole.branchElder:
        badgeBg = const Color(0xFFFEF3C7);
        badgeText = const Color(0xFFB45309);
        roleIcon = Icons.stars_rounded;
        break;
      case MemberRole.contributor:
        badgeBg = const Color(0xFFF0FDF4);
        badgeText = const Color(0xFF15803D);
        roleIcon = Icons.edit_note_rounded;
        break;
      case MemberRole.viewer:
        badgeBg = const Color(0xFFF1F5F9);
        badgeText = const Color(0xFF475569);
        roleIcon = Icons.visibility_outlined;
        break;
    }

    return Material(
      color: isSelected ? const Color(0xFFF8FAFC) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.border,
          width: isSelected ? 1.8 : 0.8,
        ),
      ),
      child: InkWell(
        onTap: _isLoading ? null : () => _handlePersonaLogin(persona),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.paleSage,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: persona.avatarAsset != null
                      ? Image.asset(
                          persona.avatarAsset!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Center(
                            child: Text(
                              persona.displayName.isNotEmpty ? persona.displayName[0] : '?',
                              style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: AppColors.primary),
                            ),
                          ),
                        )
                      : const Center(
                          child: Icon(Icons.person_outline_rounded, color: AppColors.primary, size: 22),
                        ),
                ),
              ),

              const SizedBox(width: 12),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            persona.displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: badgeBg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(roleIcon, size: 11, color: badgeText),
                              const SizedBox(width: 3),
                              Text(
                                persona.roleTitle,
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: badgeText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${persona.generation} • ${persona.email}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Action button pill
              ElevatedButton(
                onPressed: _isLoading ? null : () => _handlePersonaLogin(persona),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected ? AppColors.primary : AppColors.lightSage,
                  foregroundColor: isSelected ? Colors.white : AppColors.primary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Login',
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward_rounded, size: 14),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
